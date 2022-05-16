extends Node2D

var Root = preload("Root.tscn")

onready var taproot = $Taproot
onready var rootsClickArea = $RootsClickArea
onready var roots = $Roots

export var size = 1 setget _set_size

func _ready():
	rootsClickArea.connect("clicked", self, "_add_root_segment")

func _set_size(value):
	size = value
	_rebuild_plant()

func _rebuild_plant():
	pass

func _add_root_segment():
	var clickPosition = get_local_mouse_position()
	var closestPoint = roots.position
	var closestDistance = clickPosition.distance_squared_to(closestPoint)
	var closestObject = roots
	var lines = _get_root_lines(roots)
	for line in lines:
		for point in line.points:
			var pointDistance = clickPosition.distance_squared_to(point)
			if pointDistance < closestDistance:
				closestDistance = pointDistance
				closestPoint = point
				closestObject = line
	if closestObject != roots and closestPoint == closestObject.points[closestObject.points.size() - 1]:
		closestObject.add_point(clickPosition)
	else:
		_add_new_root(roots, closestPoint, clickPosition)

func _get_root_lines(parent):
	var lines = []
	for line in parent.get_children():
		lines.append(line)
		lines.append_array(_get_root_lines(line))
	return lines

func _add_new_root(parent, startPosition, endPosition):
	var root : Line2D = Root.instance()
	root.add_point(startPosition)
	root.add_point(endPosition)
	parent.add_child(root)
