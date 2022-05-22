extends Node2D

onready var animationPlayer = $AnimationPlayer
onready var clickArea = $ClickArea
onready var taprootSprite = $TaprootSprite
onready var nutrientParticles = $AbsorbtionParticles

const AUTO_ABSORB_DELAY_MSEC = 5000

var dead = false
var absorbing setget _set_absorbing
var timeAbsorbingStopped

func _ready():
	clickArea.connect("clicked", self, "_toggle_absorbing")
	clickArea.connect("mouse_over", self, "_mouse_over")
	_set_absorbing(true)

func _set_absorbing(value):
	absorbing = value
	if value:
		timeAbsorbingStopped = null
	else:
		timeAbsorbingStopped = OS.get_system_time_msecs()
	# update nodes
	taprootSprite.material.set_shader_param("enabled", value)
	nutrientParticles.emitting = value

func _toggle_absorbing():
	_set_absorbing(not absorbing)

func _mouse_over(value):
	taprootSprite.material.set_shader_param("mouseOver", value)

func _process(_delta):
	if not absorbing and not dead:
		if OS.get_system_time_msecs() > (timeAbsorbingStopped + AUTO_ABSORB_DELAY_MSEC):
			_set_absorbing(true)

func die():
	_set_absorbing(false)
	animationPlayer.play("Die")
	nutrientParticles.visible = false
	dead = true
