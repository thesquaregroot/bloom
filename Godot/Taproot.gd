extends Node2D

onready var clickArea = $ClickArea
onready var taprootSprite = $TaprootSprite
onready var nutrientParticles = $AbsorbtionParticles

var absorbing setget _set_absorbing

func _ready():
	clickArea.connect("clicked", self, "_toggle_absorbing")
	clickArea.connect("mouse_over", self, "_mouse_over")
	_set_absorbing(true)

func _set_absorbing(value):
	absorbing = value
	# update nodes
	taprootSprite.material.set_shader_param("enabled", value)
	nutrientParticles.emitting = value

func _toggle_absorbing():
	_set_absorbing(not absorbing)

func _mouse_over(value):
	taprootSprite.material.set_shader_param("mouseOver", value)

