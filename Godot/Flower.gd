extends Node2D

onready var animationPlayer = $AnimationPlayer

func set_flower_color(flowerColor):
	$Bud.modulate = Color.white.linear_interpolate(flowerColor, 0.5)
	$Bloom.modulate = flowerColor
	$FlowerParticles.process_material.color = flowerColor

func bloom():
	animationPlayer.play("Bloom")

func die():
	animationPlayer.play("Die")
