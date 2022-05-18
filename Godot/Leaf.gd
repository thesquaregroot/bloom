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
	sun.connect("moved", self, "_update_sunlight")
	dragToRotateArea.connect("rotated", self, "_rotated")
	_update_sunlight()

func _rotated(angle):
	rotation = clamp(angle, -PI/4, PI/4)
	_update_sunlight()

func _update_sunlight():
	var exposure = get_current_exposure()
	var particleCount = MAX_SUNLIGHT_PARTICLES * exposure
	if particleCount < 1:
		sunlightParticles.emitting = false
	else:
		sunlightParticles.amount = particleCount
		sunlightParticles.emitting = true

func get_current_exposure():
	var sunVector = sun.global_position - sunlightTargetA.global_position
	var leafNormalVector = sunlightTargetB.global_position - sunlightTargetA.global_position
	var sunAngle = abs(sunVector.angle_to(leafNormalVector))
	sunAngle = clamp(sunAngle, 0, PI/2)
	return cos(sunAngle)
