extends Node2D

signal light_changed
var previousPosition

export (float, 0, 1) var brightness = 1.0 setget _set_brightness

func _ready():
	previousPosition = position

func _set_brightness(value):
	brightness = value
	emit_signal("light_changed")

func _physics_process(_delta):
	if position != previousPosition:
		emit_signal("light_changed")
	previousPosition = position
