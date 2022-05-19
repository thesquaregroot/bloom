extends Node2D

const SCROLL_MAX = 400
const SCROLL_MIN = -600

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			_zoom(10)
		elif event.button_index == BUTTON_WHEEL_DOWN:
			_zoom(-10)

func _zoom(amount):
	position.y = clamp(position.y + amount, SCROLL_MIN, SCROLL_MAX)
