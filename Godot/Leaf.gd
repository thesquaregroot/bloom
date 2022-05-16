extends Node2D

onready var dragToRotateArea = $ClickArea
onready var sunlightParticles = $SunlightParticles
onready var sunlightTargetA = $SunlightTargetA
onready var sunlightTargetB = $SunlightTargetB

const MAX_SUNLIGHT_PARTICLES = 32

var leafAngle = 0
var sun

func _ready():
	sun = get_tree().get_nodes_in_group("Sun")[0]
	dragToRotateArea.connect("rotated", self, "_rotated")
	_rotated(0)

func _rotated(angle):
	rotation = clamp(angle, -PI/4, PI/4)
	_update_sunlight()

func _update_sunlight():
	var sunVector = sun.global_position - sunlightTargetA.global_position
	var leafNormalVector = sunlightTargetB.global_position - sunlightTargetA.global_position
	var sunAngle = abs(sunVector.angle_to(leafNormalVector))
	sunAngle = clamp(sunAngle, 0, PI/2)
	var exposure = cos(sunAngle)
	var particleCount = MAX_SUNLIGHT_PARTICLES * exposure
	if particleCount < 1:
		sunlightParticles.emitting = false
	else:
		sunlightParticles.amount = particleCount
		sunlightParticles.emitting = true
