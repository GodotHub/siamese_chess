extends Node3D
@onready var ray_cast:RayCast3D = $ray_cast

var mouse_moved:bool = false
var mouse_start_position_name:String = ""
var actor:Actor = null
var can_move:bool = true

func _ready() -> void:
	pass

func _physics_process(_delta:float) -> void:
	if is_instance_valid(actor):
		global_position = global_position.lerp(actor.global_position, 0.3)
	#$head/camera.set_rotation(Vector3(deg_to_rad(sin(Time.get_unix_time_from_system())), 0, 0))
	#$head/camera.set_rotation(Vector3(0, deg_to_rad(sin(Time.get_unix_time_from_system() + 5)) * 0.5, 0))
	#$head/camera.set_rotation(Vector3(0, 0, deg_to_rad(sin(Time.get_unix_time_from_system()) * 0.5)))

func set_initial_interact(interact:Interact) -> void:
	interact.enter()

func _unhandled_input(event:InputEvent) -> void:
	if !can_move:
		return
	if event is InputEventMouseButton || event is InputEventMouseMotion:
		var area:Area3D = click_area(event.position)
		if is_instance_valid(area):
			area.emit_signal("input", self, area, event, $ray_cast.get_collision_point(), $ray_cast.get_collision_normal())
		get_viewport().set_input_as_handled()
	if event is InputEventMultiScreenDrag:
		$head.rotation.y += event.relative.x / 100

func click_area(screen_position:Vector2) -> Area3D:
	var from:Vector3 = $head/camera.project_ray_origin(screen_position)
	var to:Vector3 = $head/camera.project_ray_normal(screen_position) * 200
	ray_cast.global_position = from
	ray_cast.target_position = to
	ray_cast.collision_mask = 3
	ray_cast.force_raycast_update()
	if ray_cast.is_colliding():
		return ray_cast.get_collider()
	return null

func set_actor(_actor:Actor) -> void:
	if !is_instance_valid(_actor):
		return
	actor = _actor

func force_set_camera(other:Camera3D) -> void:
	$head.global_transform = other.global_transform
	$head/camera.fov = other.fov
