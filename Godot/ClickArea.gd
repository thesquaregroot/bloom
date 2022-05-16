extends Area2D

onready var parent = $".."

signal rotated
signal clicked
signal mouse_over

var hasMouse = false
var selected = false

func _ready():
	connect("mouse_entered", self, "_mouse_over", [true])
	connect("mouse_exited", self, "_mouse_over", [false])

func _input(event: InputEvent):
	if (event is InputEventMouseButton && event.button_index == BUTTON_LEFT):
		selected = event.pressed and hasMouse
		if selected:
			emit_signal("clicked")

func _mouse_over(value):
	hasMouse = value
	emit_signal("mouse_over", value)

func _physics_process(delta):
	if selected:
		var xFlip = sign(parent.scale.x)
		var currentVector = Vector2(-xFlip * cos(parent.rotation), sin(parent.rotation))
		var newMouseVector = get_global_mouse_position() - parent.global_position
		var targetVector = lerp(currentVector, newMouseVector, 25 * delta)
		var angle = - targetVector.angle_to(xFlip * Vector2.LEFT);
		emit_signal("rotated", angle);

