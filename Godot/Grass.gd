extends Node2D

# adapated from https://github.com/jhlothamer/MultiMeshInstance2DDemo
# video: https://youtu.be/mscJW51dotE

onready var cloneMesh : MeshInstance2D = $GrassSprite
onready var multiMeshInstance : MultiMeshInstance2D = $MultiMeshInstance

func _ready():
	_distribute_grass()

func _distribute_grass():
	var multiMesh = multiMeshInstance.multimesh
	multiMesh.mesh = cloneMesh.mesh
	var screenWidth = ProjectSettings.get_setting("display/window/size/width")
	for i in range(multiMesh.instance_count):
		var instancePosition = Vector2(randf() * screenWidth / cloneMesh.scale.x, cloneMesh.position.y)
		var instanceTransform = Transform2D(0.0, instancePosition).scaled(cloneMesh.scale)
		multiMesh.set_instance_transform_2d(i, instanceTransform)
