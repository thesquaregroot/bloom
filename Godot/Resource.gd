extends Sprite

export (float) var water = 0
export (float) var nutrients = 0
export (float) var intersectionRadius = 8

var active = false setget _set_active

func _set_active(value):
	active = value
	self.material.set_shader_param("isActive", value)
