extends Node3D
@onready var ray_cast:RayCast3D = $ray_cast

var mouse_moved:bool = false
var mouse_start_position_name:String = ""
var camera_stack:Array[Camera3D] = []
var inspectable_item_stack:Array[InspectableItem] = []

func _ready() -> void:
	pass

func set_initial_camera(other:Camera3D, inspectable_item:InspectableItem = null) -> void:
	camera_stack = [other]
	inspectable_item_stack = [inspectable_item]
	if is_instance_valid(inspectable_item):
		inspectable_item.set_enabled(true)
	force_set_camera(other)

func _unhandled_input(event:InputEvent) -> void:
	if event is InputEventMouseButton || event is InputEventMouseMotion:
		var area:Area3D = click_area(event.position)
		if is_instance_valid(area):
			area.emit_signal("input", self, area, event, $ray_cast.get_collision_point(), $ray_cast.get_collision_normal())
	if event is InputEventScreenPinch:
		#cancel_drawing_move.emit()
		if event.relative < 1 && camera_stack.size() >= 2:
			pop_stack()
			move_camera(camera_stack[-1])

func add_stack(camera:Camera3D, inspectable_item:InspectableItem) -> void:
	if is_instance_valid(inspectable_item_stack[-1]):
		inspectable_item_stack[-1].set_enabled(false)
	camera_stack.push_back(camera)
	inspectable_item_stack.push_back(inspectable_item)
	if is_instance_valid(inspectable_item_stack[-1]):
		inspectable_item_stack[-1].set_enabled(true)

func pop_stack() -> void:
	if is_instance_valid(inspectable_item_stack[-1]):
		inspectable_item_stack[-1].set_enabled(false)
	camera_stack.pop_back()
	inspectable_item_stack.pop_back()
	if is_instance_valid(inspectable_item_stack[-1]):
		inspectable_item_stack[-1].set_enabled(true)

func click_area(screen_position:Vector2) -> Area3D:
	var from:Vector3 = $camera.project_ray_origin(screen_position)
	var to:Vector3 = $camera.project_ray_normal(screen_position) * 200
	ray_cast.global_position = from
	ray_cast.target_position = to
	ray_cast.collision_mask = 2 if is_instance_valid(inspectable_item_stack[-1]) else 1
	ray_cast.force_raycast_update()
	if ray_cast.is_colliding():
		return ray_cast.get_collider()
	return null

func move_camera(other:Camera3D) -> void:
	var tween:Tween = create_tween()
	tween.tween_property($camera, "global_transform", other.global_transform, 1).set_trans(Tween.TRANS_SINE)
	tween.set_parallel()
	tween.tween_property($camera, "fov", other.fov, 1).set_trans(Tween.TRANS_SINE)

func force_set_camera(other:Camera3D) -> void:
	$camera.global_transform = other.global_transform
	$camera.fov = other.fov
