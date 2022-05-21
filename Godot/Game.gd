extends Node2D

const SCROLL_MAX = 400
const SCROLL_MIN = -600

onready var animationPlayer = $AnimationPlayer
onready var tween = $Tween
onready var nightTimer = $NightTimer

var scrollEnabled = true

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
	if scrollEnabled and event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			_scroll(10)
		elif event.button_index == BUTTON_WHEEL_DOWN:
			_scroll(-10)

func _scroll(amount):
	position.y = clamp(position.y + amount, SCROLL_MIN, SCROLL_MAX)

func scroll_to(targetPositionY, duration, callbackNode, callbackMethod, callbackDelay = 0, shouldDisableScroll = true):
	scrollEnabled = not shouldDisableScroll
	var finalPositionY = clamp(position.y - targetPositionY + 400, SCROLL_MIN, SCROLL_MAX) # + 400 to center on screen
	tween.interpolate_property(self, "position:y", position.y, finalPositionY, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_callback(callbackNode, duration + callbackDelay, callbackMethod)
	tween.start()

func set_music_volume(newVolumeDb):
	var musicBusIndex = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(musicBusIndex, newVolumeDb)
