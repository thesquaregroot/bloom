extends Node2D

export var size = 1 setget _set_size

func _ready():
	pass # Replace with function body.

func _set_size(value):
	size = value
	_rebuild_plant()

func _rebuild_plant():
	pass
