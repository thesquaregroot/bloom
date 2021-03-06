extends Node2D

var FlowerScene = preload("Flower.tscn")
var StemSegmentScene = preload("StemSegment.tscn")
var RootScene = preload("Root.tscn")
var Leaf = preload("Leaf.gd")

onready var game = $".."
onready var undergroundResources = $"../UndergroundResources"
onready var body = $Body
onready var taproot = $Taproot
onready var growthPreview = $GrowthPreview
onready var growthArrow = $GrowthPreview/Arrow
onready var flowerBudPreview = $GrowthPreview/FlowerBud
onready var stemSegmentPreview = $GrowthPreview/StemSegment
onready var growthPreviewClickArea = $GrowthPreview/ClickArea
onready var rootsClickArea = $RootsClickArea
onready var roots = $Roots
onready var growRootsSounds = $GrowRootsSound
onready var growPlantSounds = $GrowPlantSound

onready var resourceMeters = $"../CanvasLayer/ResourceMeters"

var size = 1
var haveFlowerBud = false
var budOrBloomTime = 0
var flowerReference
var hasBloomed = false
var hasDied = false

const MAX_SIZE = 4

var flowerColor

var _nutrients = 0
var _water = 0
var _sugar = 0

var _maxWater = 100.0
var _maxNutrients = 100.0
var _maxSugar = 100.0

const PHOTOSYNTHESIS_WATER_COST = 10
const PHOTOSYNTHESIS_NUTRIENT_COST = 2

const STEM_SEGMENT_NUTRIENTS = 25
const STEM_SEGMENT_WATER = 25
const STEM_SEGMENT_SUGAR = 25

const FLOWER_BUD_NUTRIENTS = 100
const FLOWER_BUD_WATER = 100
const FLOWER_BUD_SUGAR = 250

const FLOWER_WATER_CONSUMPTION = 10
const FLOWER_SUGAR_CONSUMPTION = 2

const STEM_SEGMENT_HEIGHT = -128

const BASE_NUTRIENTS_COLLECTION = 5
const BASE_WATER_COLLECTION = 1
const ROOT_NUTRIENTS_COLLECTION = 0.01
const ROOT_WATER_COLLECTION = 0.01
const MAX_SUNLIGHT_PER_LEAF = 0.1

const ROOT_NUTRIENT_COST = 1

func _ready():
	# random flower color every game
	flowerColor = Color(randf(), randf(), randf(), 1.0)
	$Body/StemSegment.set_flower_color(flowerColor)

	growthArrow.visible = false
	flowerBudPreview.visible = false
	stemSegmentPreview.visible = false
	growthPreviewClickArea.connect("clicked", self, "_grow_plant")
	growthPreviewClickArea.connect("mouse_over", self, "_show_growth_preview")
	rootsClickArea.connect("clicked", self, "_add_root_segment")

func _grow_plant():
	if _can_grow_bud():
		_add_flower_bud()
		growPlantSounds.play()
		budOrBloomTime = OS.get_ticks_msec()
	if _can_grow_stem_segment():
		_add_stem_segment()
		growPlantSounds.play()

func _add_stem_segment():
	growthPreview.position.y += STEM_SEGMENT_HEIGHT
	var newStemSegment = StemSegmentScene.instance()
	newStemSegment.set_flower_color(flowerColor)
	newStemSegment.position.y = (size + 0.5) * STEM_SEGMENT_HEIGHT # add .5 since the origin is in the center of the texture
	body.add_child(newStemSegment)
	_nutrients -= STEM_SEGMENT_NUTRIENTS
	_water -= STEM_SEGMENT_WATER
	_sugar -= STEM_SEGMENT_SUGAR
	size += 1
	_maxNutrients += 50
	_maxWater += 50
	_maxSugar += 100

func _add_flower_bud():
	var flowerBud = FlowerScene.instance()
	flowerBud.set_flower_color(flowerColor)
	flowerBud.position.y = (size + 0.5) * STEM_SEGMENT_HEIGHT # add .5 since the origin is in the center of the texture
	body.add_child(flowerBud)
	_nutrients -= FLOWER_BUD_NUTRIENTS
	_water -= FLOWER_BUD_WATER / 2.0 # keep half of the water, to prevent ending immediately
	_sugar -= FLOWER_BUD_SUGAR
	flowerReference = flowerBud
	haveFlowerBud = true

func _show_growth_preview(shouldShow):
	if haveFlowerBud:
		# cannot grow further
		flowerBudPreview.visible = false
		stemSegmentPreview.visible = false
		return
	if _can_grow_bud():
		flowerBudPreview.visible = shouldShow
		stemSegmentPreview.visible = false
		return
	else:
		flowerBudPreview.visible = false

	if not _can_grow_stem_segment():
		shouldShow = false
	stemSegmentPreview.visible = shouldShow

func _add_root_segment():
	if _nutrients < 1:
		return

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
	growRootsSounds.play()

	# activate any newly intersected resources
	var rootSegments = _get_all_root_segments(roots)
	for resource in undergroundResources.get_children():
		if not resource.active:
			for segment in rootSegments:
				var rootRelativeResourcePosition = resource.global_position - roots.global_position
				if Geometry.segment_intersects_circle(segment[0], segment[1], rootRelativeResourcePosition, resource.intersectionRadius) >= 0:
					resource.active = true
					break

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

func _process(delta):
	if hasDied:
		return
	if haveFlowerBud:
		# flower consumes water and sugar rapidly
		var budOrBloomOffset = OS.get_ticks_msec() - budOrBloomTime
		_water -= (FLOWER_WATER_CONSUMPTION + budOrBloomOffset / 60000) * delta
		_sugar -= (FLOWER_SUGAR_CONSUMPTION + budOrBloomOffset / 60000) * delta
		if _water < 0 or _sugar < 0:
			if not hasBloomed:
				_water = clamp(_water, 100, _maxWater) # boost of water upon blooming
				_sugar = clamp(_sugar, 50, _maxSugar)
				game.scroll_to(flowerReference.global_position.y, 1, flowerReference, "bloom", 0, false)
				hasBloomed = true
				budOrBloomTime = OS.get_ticks_msec()
			else:
				# game over
				game.scroll_to(flowerReference.global_position.y, 1, self, "_die")
				game.set_music_volume(-5)
	else:
		var canGrowBud = _can_grow_bud()
		var canGrowPlant = _can_grow_stem_segment()
		if canGrowBud:
			growthArrow.visible = not flowerBudPreview.visible
		elif canGrowPlant:
			growthArrow.visible = not stemSegmentPreview.visible
		else:
			growthArrow.visible = false

func _die():
	hasDied = true
	for child in body.get_children():
		if child.has_method("die"):
			child.die()
	taproot.die()
	game.scroll_to(self.global_position.y, 6, self, "_exit", 2)

func _exit():
	game.return_to_main_menu()

func _can_grow_bud():
	# shortcut to test plant lifecycle
	#return size == MAX_SIZE
	return _nutrients > FLOWER_BUD_NUTRIENTS and \
		_water > FLOWER_BUD_WATER and \
		_sugar > FLOWER_BUD_SUGAR

func _can_grow_stem_segment():
	# shortcut to test plant lifecycle
	#return size < MAX_SIZE
	return size < MAX_SIZE and \
		_nutrients > STEM_SEGMENT_NUTRIENTS and \
		_water > STEM_SEGMENT_WATER and \
		_sugar > STEM_SEGMENT_SUGAR

func _physics_process(delta):
	# extract resources from soil
	if taproot.absorbing:
		var rootSegments = _get_all_root_segments(roots)
		var totalRootLength = 0
		# get bonuses from root length
		for segment in rootSegments:
			totalRootLength += segment[0].distance_to(segment[1])
		var bonusNutrients = ROOT_NUTRIENTS_COLLECTION * totalRootLength
		var bonusWater = ROOT_WATER_COLLECTION * totalRootLength
		# get bonuses for active resources
		for resource in undergroundResources.get_children():
			if resource.active:
				bonusNutrients += resource.nutrients
				bonusWater += resource.water
		_nutrients += (BASE_NUTRIENTS_COLLECTION + bonusNutrients) * delta
		_water += (BASE_WATER_COLLECTION + bonusWater) * delta
		# ensure maxes are respected
		_nutrients = clamp(_nutrients, 0, _maxNutrients)
		_water = clamp(_water, 0, _maxWater)

	# perform photosynthesis
	var currentSunlight = 0
	for leaf in _get_all_leaves(body):
		currentSunlight += MAX_SUNLIGHT_PER_LEAF * leaf.get_current_exposure()
	# limited by current sunlight, available nutrients, and available water
	var photosynthensis = min(currentSunlight * 2.0 * delta, min(_nutrients / PHOTOSYNTHESIS_NUTRIENT_COST, _water / PHOTOSYNTHESIS_WATER_COST))
	if photosynthensis > 0:
		# consume nutrients and water
		_nutrients -= photosynthensis * PHOTOSYNTHESIS_NUTRIENT_COST
		_water -= photosynthensis * PHOTOSYNTHESIS_WATER_COST
		# gain sugar
		_sugar += photosynthensis
		_sugar = clamp(_sugar, 0, _maxSugar)
		#print("Performed " + str(photosynthensis) + " photosynthesis, new total sugar: " + str(_sugar))
	#print("nutrients: " + str(_nutrients))
	#print("water: " + str(_water))
	#print("sugar: " + str(_sugar))
	_update_resource_meters()

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

func _update_resource_meters():
	resourceMeters.update_meters(_water / _maxWater, _nutrients / _maxNutrients, _sugar / _maxSugar)
