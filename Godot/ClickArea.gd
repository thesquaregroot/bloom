extends Area2D

signal clicked

func _input(event: InputEvent):
	if (event is InputEventMouseButton && event.pressed):
		emit_signal("clicked")
