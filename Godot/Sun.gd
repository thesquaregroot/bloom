extends Node2D

signal moved

var previousPosition

func _ready():
	previousPosition = global_position

func _physics_process(delta):
	if global_position != previousPosition:
		emit_signal("moved")
	previousPosition = global_position
