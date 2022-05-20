extends Control

onready var waterMeter = $VBoxContainer/WaterMeter/FillBar
onready var nutrientsMeter = $VBoxContainer/NutrientsMeter/FillBar
onready var sugarMeter = $VBoxContainer/SugarMeter/FillBar

func update_meters(water, nutrients, sugar):
	waterMeter.material.set_shader_param("amount", water)
	nutrientsMeter.material.set_shader_param("amount", nutrients)
	sugarMeter.material.set_shader_param("amount", sugar)
