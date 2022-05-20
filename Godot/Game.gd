extends Node2D

const SCROLL_MAX = 400
const SCROLL_MIN = -600

onready var animationPlayer = $AnimationPlayer
onready var nightTimer = $NightTimer

func _ready():
	animationPlayer.connect("animation_finished", self, "_next_animation")
	nightTimer.connect("timeout", self, "_next_animation", ["NightTimer"])
	animationPlayer.play("DaySunMovement")

func _next_animation(justFinished):
	if justFinished == "DaySunMovement":
		animationPlayer.play("DayToNight")
	elif justFinished == "DayToNight":
		nightTimer.start()
	elif justFinished == "NightTimer":
		animationPlayer.play("NightToDay")
	elif justFinished == "NightToDay":
		animationPlayer.play("DaySunMovement")

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			_zoom(10)
		elif event.button_index == BUTTON_WHEEL_DOWN:
			_zoom(-10)

func _zoom(amount):
	position.y = clamp(position.y + amount, SCROLL_MIN, SCROLL_MAX)
