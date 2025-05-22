extends Node3D

signal tap_position(position_name:String)
signal finger_on_position(position_name:String)
signal finger_up()

@onready var ray_cast:RayCast3D = $ray_cast

var mouse_moved:bool = false
var mouse_start_position_name:String = ""
var initial_camera:Camera3D = null
var current_camera:Camera3D = null

func _ready() -> void:
	pass

func set_initial_camera(other:Camera3D) -> void:
	initial_camera = other
	force_set_camera(other)

func _unhandled_input(event:InputEvent) -> void:
	if current_camera != initial_camera:
		input_chessboard(event)
	else:
		input_overview(event)

func input_overview(event:InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
			var inspect_camera:Area3D = click_inspection(event.position)
			if is_instance_valid(inspect_camera) && inspect_camera.has_node("camera_3d"):
				move_camera(inspect_camera.get_node("camera_3d"))

func input_chessboard(event:InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
			var position_name:String = click_chessboard(event.position)
			finger_on_position.emit(click_chessboard(event.position))
			tap_position.emit(position_name)
			mouse_moved = false
			mouse_start_position_name = position_name
		elif !event.pressed && mouse_moved && event.button_index == MOUSE_BUTTON_LEFT:
			var position_name:String = click_chessboard(event.position)
			tap_position.emit(position_name)
			finger_up.emit()
	if event is InputEventMouseMotion:
		var position_name:String = click_chessboard(event.position)
		if mouse_start_position_name != position_name:
			mouse_moved = true
		finger_on_position.emit(position_name)

	#if event is InputEventSingleScreenTouch:
	#	var position_name:String = click_chessboard(event.position)
	#	if position_name && event.pressed:
	#		start_drawing_move.emit(position_name)
	#	else:
	#		end_drawing_move.emit()
	#if event is InputEventSingleScreenTap:
	#	var position_name:String = click_chessboard(event.position)
	#	if !inspect_position_name:
	#		tap_position.emit(position_name)
	#		inspect_position_name = position_name
	#	else:
	#		confirm_move.emit(inspect_position_name, position_name)
	#		inspect_position_name = ""
		# 查询position_name位置下的状态
	#if event is InputEventSingleScreenDrag:
	#	var position_name:String = click_chessboard(event.position)
	#	if position_name:
	#	# 在position_name位置上绘制
	#		drawing_move.emit(position_name)
	#if event is InputEventMultiScreenDrag:
	#	#cancel_drawing_move.emit()
	#	rotation.y -= event.relative.x / 300
	#	$head.rotation.x -= event.relative.y / 300
	if event is InputEventScreenPinch:
		#cancel_drawing_move.emit()
		if event.relative < 1:
			move_camera(initial_camera)
		#$camera.position.z -= event.relative / 200
	#if event is InputEventKey && event.pressed && event.keycode == KEY_SPACE:
	#	confirm.emit()

func click_inspection(screen_position:Vector2) -> Area3D:
	var from:Vector3 = $camera.project_ray_origin(screen_position)
	var to:Vector3 = $camera.project_ray_normal(screen_position) * 200
	ray_cast.global_position = from
	ray_cast.target_position = to
	ray_cast.collision_mask = 1
	ray_cast.force_raycast_update()
	if ray_cast.is_colliding():
		return ray_cast.get_collider()
	return null

func click_chessboard(screen_position:Vector2) -> String:
	var from:Vector3 = $camera.project_ray_origin(screen_position)
	var to:Vector3 = $camera.project_ray_normal(screen_position) * 200
	ray_cast.global_position = from
	ray_cast.target_position = to
	ray_cast.collision_mask = 2
	ray_cast.force_raycast_update()
	if ray_cast.is_colliding():
		return ray_cast.get_collider().get_name()
	return ""

func move_camera(other:Camera3D) -> void:
	current_camera = other
	var tween:Tween = create_tween()
	tween.tween_property($camera, "global_transform", other.global_transform, 1).set_trans(Tween.TRANS_SINE)
	tween.set_parallel()
	tween.tween_property($camera, "fov", other.fov, 1).set_trans(Tween.TRANS_SINE)

func force_set_camera(other:Camera3D) -> void:
	current_camera = other
	$camera.global_transform = other.global_transform
	$camera.fov = other.fov
