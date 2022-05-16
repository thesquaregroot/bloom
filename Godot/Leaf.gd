extends Node2D

onready var dragToRotateArea = $ClickArea

var leafAngle = 0

func _ready():
	dragToRotateArea.connect("rotated", self, "_rotated")

func _rotated(angle):
	rotation = clamp(angle, -PI/4, PI/4)
