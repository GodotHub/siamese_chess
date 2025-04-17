extends Node3D

@onready var ray_cast:RayCast3D = $ray_cast
var position_name:String = ""
var start_position:String = ""

func _ready() -> void:
	pass

func _unhandled_input(event:InputEvent) -> void:
	if event is InputEventSingleScreenTouch:
		click(event.position)
		start_position = position_name
	if event is InputEventSingleScreenTap:
		click(event.position)
		# 查询position_name位置下的状态
	if event is InputEventSingleScreenDrag:
		click(event.position)
		# 在position_name位置上绘制
	if event is InputEventMultiScreenDrag:
		rotation.y -= event.relative.x / 300
		$head.rotation.x -= event.relative.y / 300
	if event is InputEventScreenPinch:
		$head/camera.position.z -= event.relative / 200

func click(screen_position:Vector2) -> void:
	var from:Vector3 = $head/camera.project_ray_origin(screen_position)
	var to:Vector3 = $head/camera.project_ray_normal(screen_position) * 200
	ray_cast.global_position = from
	ray_cast.target_position = to
	ray_cast.force_raycast_update()
	if ray_cast.is_colliding():
		position_name = ray_cast.get_collider().get_name()
