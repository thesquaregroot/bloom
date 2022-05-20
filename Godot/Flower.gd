extends Node2D

onready var animationPlayer = $AnimationPlayer

func bloom():
	animationPlayer.play("Bloom")

func die():
	animationPlayer.play("Die")
