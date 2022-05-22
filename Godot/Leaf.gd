extends Node2D

onready var clickArea = $ClickArea
onready var sunlightParticles = $SunlightParticles
onready var sunlightTargetA = $SunlightTargetA
onready var sunlightTargetB = $SunlightTargetB
onready var normalVector = $SunlightTargetA/NormalVector

const MAX_SUNLIGHT_PARTICLES = 8

export (bool) var active = true

var leafAngle = 0
var sun

func _ready():
	if self.material:
		$LeafSprite.material = self.material
	if not active:
		sunlightParticles.emitting = false
	sun = get_tree().get_nodes_in_group("Sun")[0]
	sun.connect("light_changed", self, "_update_sunlight")
	clickArea.connect("rotated", self, "_rotated")
	clickArea.connect("deselected", self, "_show_normal_vector", [false])
	_update_sunlight()

func set_color(color):
	$LeafSprite.self_modulate = color

func _show_normal_vector(shouldShowNormalVector):
	normalVector.visible = shouldShowNormalVector

func _rotated(angle):
	if not active:
		return
	_show_normal_vector(true)
	var clampedAngle = clamp(angle, -PI/4, PI/4)
	if clampedAngle != rotation:
		rotation = clampedAngle
		_update_sunlight()

func _update_sunlight():
	if not active:
		return
	var exposure = get_current_exposure()
	normalVector.scale = Vector2.ONE * exposure * 2
	var particleCount = int(MAX_SUNLIGHT_PARTICLES * sun.brightness * exposure)
	if particleCount < 1:
		sunlightParticles.emitting = false
	else:
		if particleCount != sunlightParticles.amount:
			sunlightParticles.amount = particleCount
		if not sunlightParticles.emitting:
			sunlightParticles.emitting = true

func get_current_exposure():
	var sunVector = sun.global_position - sunlightTargetA.global_position
	var leafNormalVector = sunlightTargetB.global_position - sunlightTargetA.global_position
	var sunAngle = abs(sunVector.angle_to(leafNormalVector))
	#sunAngle = clamp(sunAngle, 0, PI/2)
	return abs(cos(sunAngle))
