extends Sprite

onready var animationPlayer = $AnimationPlayer
onready var tween = $Tween

onready var leaf1 = $Leaf1
onready var leaf2 = $Leaf2

func set_flower_color(color):
	var mixColor = Color.white.linear_interpolate(color, 0.5)
	self_modulate = mixColor
	$Leaf1.set_color(mixColor)
	$Leaf2.set_color(mixColor)

func die():
	animationPlayer.play("Die")

func _lower_leaves():
	tween.interpolate_property(leaf1, "rotation_degrees", leaf1.rotation, -80, 3.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property(leaf2, "rotation_degrees", leaf2.rotation, 80, 3.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
