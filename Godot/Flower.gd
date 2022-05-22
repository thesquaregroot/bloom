extends Node2D

onready var animationPlayer = $AnimationPlayer

func set_flower_color(flowerColor):
	var mixColor = Color.white.linear_interpolate(flowerColor, 0.5)
	$Base.modulate = mixColor
	$Bud.modulate = mixColor
	$Bloom.modulate = flowerColor
	$FlowerParticles.process_material.color = flowerColor

func bloom():
	animationPlayer.play("Bloom")

func die():
	animationPlayer.play("Die")
