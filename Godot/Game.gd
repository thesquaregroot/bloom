extends Node2D

var NutrientScene = preload("Nutrient.tscn")
var WaterScene = preload("Water.tscn")

const SCROLL_MAX = 400
const SCROLL_MIN = -600

onready var animationPlayer = $AnimationPlayer
onready var tween = $Tween
onready var nightTimer = $NightTimer

onready var groundArea = $Background/Ground
onready var undergroundResources = $UndergroundResources

const RESOURCE_BORDER = 20
const WATER_COUNT = 15
const NUTRIENT_COUNT = 15

var scrollEnabled = true
var groundAreaWidth
var groundAreaHeight

func _ready():
	randomize()
	animationPlayer.connect("animation_finished", self, "_next_animation")
	nightTimer.connect("timeout", self, "_next_animation", ["NightTimer"])
	animationPlayer.play("DaySunMovement")
	
	var groundRect = groundArea.rect_size
	if groundArea.rect_rotation == 90:
		groundRect = Vector2(groundRect.y, groundRect.x)
	groundAreaWidth = groundRect.x
	groundAreaHeight = groundRect.y
	_populate_underground_resources()

func _next_animation(justFinished):
	if justFinished == "DaySunMovement":
		animationPlayer.play("DayToNight")
	elif justFinished == "DayToNight":
		nightTimer.start()
	elif justFinished == "NightTimer":
		animationPlayer.play("NightToDay")
	elif justFinished == "NightToDay":
		animationPlayer.play("DaySunMovement")

func _populate_underground_resources():
	for i in range(WATER_COUNT):
		var water = WaterScene.instance()
		_add_resource(water)
	for i in range(NUTRIENT_COUNT):
		var nutrient = NutrientScene.instance()
		_add_resource(nutrient)

func _add_resource(resource):
	var xPos = randf() * (groundAreaWidth - 2 * RESOURCE_BORDER) + RESOURCE_BORDER
	var yPos = randf() * (groundAreaHeight - 2 * RESOURCE_BORDER) + RESOURCE_BORDER
	undergroundResources.add_child(resource)
	resource.position = Vector2(xPos, yPos)

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
	var screenOffset = 400
	var finalPositionY = clamp(position.y - targetPositionY + screenOffset, SCROLL_MIN, SCROLL_MAX)
	tween.interpolate_property(self, "position:y", position.y, finalPositionY, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_callback(callbackNode, duration + callbackDelay, callbackMethod)
	tween.start()

func set_music_volume(newVolumeDb):
	var musicBusIndex = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(musicBusIndex, newVolumeDb)
