extends Node2D

signal moved

var previousPosition

func _ready():
	previousPosition = position

func _physics_process(_delta):
	if position != previousPosition:
		emit_signal("moved")
	previousPosition = position
