extends Node2D

var Root = preload("Root.tscn")
var Leaf = preload("Leaf.gd")

onready var body = $Body
onready var taproot = $Taproot
onready var rootsClickArea = $RootsClickArea
onready var roots = $Roots

export var size = 1 setget _set_size

var _nutrients = 0
var _water = 0
var _sugar = 0

const BASE_NUTRIENTS_COLLECTION = 1
const BASE_WATER_COLLECTION = 1
const MAX_SUNLIGHT_PER_LEAF = 1

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

func _physics_process(delta):
	# extract resources from soil
	if taproot.absorbing:
		# TODO: account for extended roots
		_nutrients += BASE_NUTRIENTS_COLLECTION * delta
		_water += BASE_WATER_COLLECTION * delta

	# perform photosynthesis
	var currentSunlight = 0
	for leaf in _get_all_leaves(body):
		currentSunlight += MAX_SUNLIGHT_PER_LEAF * leaf.get_current_exposure()
	# limited by current sunlight, available nutrients, and available water
	var photosynthensis = min(currentSunlight, min(_nutrients, _water))
	if photosynthensis > 0:
		# consume nutrients and water
		_nutrients -= photosynthensis
		_water -= photosynthensis
		# gain sugar
		_sugar += photosynthensis
		print("Performed " + str(photosynthensis) + " photosynthesis, new total sugar: " + str(_sugar))

func _get_all_leaves(node):
	var leaves = []
	for child in node.get_children():
		if child is Leaf:
			leaves.append(child)
		else:
			leaves.append_array(_get_all_leaves(child))
	return leaves
