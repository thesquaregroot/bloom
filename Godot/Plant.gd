extends Node2D

var RootScene = preload("Root.tscn")
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
const ROOT_NUTRIENTS_COLLECTION = 0.01
const ROOT_WATER_COLLECTION = 0.01
const MAX_SUNLIGHT_PER_LEAF = 0.1

const ROOT_NUTRIENT_COST = 1

func _ready():
	rootsClickArea.connect("clicked", self, "_add_root_segment")

func _set_size(value):
	size = value
	_rebuild_plant()

func _rebuild_plant():
	pass

func _add_root_segment():
	taproot.absorbing = false
	var clickPosition = get_local_mouse_position()
	var closestPoint = roots.position
	var closestDistanceSquared = clickPosition.distance_squared_to(closestPoint)
	var closestObject = roots
	var lines = _get_root_lines(roots)
	for line in lines:
		for point in line.points:
			var pointDistanceSquared = clickPosition.distance_squared_to(point)
			if pointDistanceSquared < closestDistanceSquared:
				closestDistanceSquared = pointDistanceSquared
				closestPoint = point
				closestObject = line
	# have closest point, determine how far we can go from it, spending nutrients
	var endPosition = clickPosition
	var closestDistance = sqrt(closestDistanceSquared)
	if closestDistance > _nutrients:
		var clickDirection = (clickPosition - closestPoint).normalized()
		endPosition = closestPoint + clickDirection * _nutrients
		print("Used all " + str(_nutrients) + " nutrients")
		_nutrients = 0
	else:
		# expend nutrients based on click distance
		_nutrients -= closestDistance
		print("Using " + str(closestDistance) + " nutrients, " + str(_nutrients) + " remaining")
	if closestObject != roots and closestPoint == closestObject.points[closestObject.points.size() - 1]:
		closestObject.add_point(endPosition)
	else:
		_add_new_root(roots, closestPoint, endPosition)

func _get_root_lines(parent):
	var lines = []
	for line in parent.get_children():
		lines.append(line)
		lines.append_array(_get_root_lines(line))
	return lines

func _add_new_root(parent, startPosition, endPosition):
	var root : Line2D = RootScene.instance()
	root.add_point(startPosition)
	root.add_point(endPosition)
	parent.add_child(root)

func _physics_process(delta):
	# extract resources from soil
	if taproot.absorbing:
		var rootSegments = _get_all_root_segments(roots)
		var totalRootLength = 0
		for segment in rootSegments:
			totalRootLength += segment[0].distance_to(segment[1])
		_nutrients += (BASE_NUTRIENTS_COLLECTION + ROOT_NUTRIENTS_COLLECTION * totalRootLength) * delta
		_water += (BASE_WATER_COLLECTION + ROOT_WATER_COLLECTION * totalRootLength) * delta

	# perform photosynthesis
	var currentSunlight = 0
	for leaf in _get_all_leaves(body):
		currentSunlight += MAX_SUNLIGHT_PER_LEAF * leaf.get_current_exposure()
	# limited by current sunlight, available nutrients, and available water
	var photosynthensis = min(currentSunlight * delta, min(_nutrients, _water))
	if photosynthensis > 0:
		# consume nutrients and water
		_nutrients -= photosynthensis
		_water -= photosynthensis
		# gain sugar
		_sugar += photosynthensis
		#print("Performed " + str(photosynthensis) + " photosynthesis, new total sugar: " + str(_sugar))

func _get_all_root_segments(node):
	var segments = []
	for child in node.get_children():
		if child is Line2D:
			for i in range(child.get_point_count() - 1):
				var point1 = child.get_point_position(i)
				var point2 = child.get_point_position(i+1)
				segments.append(PoolVector2Array([point1, point2]))
		# always descend into child, since lines can be nested
		segments.append_array(_get_all_root_segments(child))
	return segments

func _get_all_leaves(node):
	var leaves = []
	for child in node.get_children():
		if child is Leaf:
			leaves.append(child)
		else:
			leaves.append_array(_get_all_leaves(child))
	return leaves
