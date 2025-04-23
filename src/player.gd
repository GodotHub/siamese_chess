extends Node3D

signal tap_position(position_name:String)
signal finger_on_position(position_name:String)
signal finger_up()

@onready var ray_cast:RayCast3D = $ray_cast

var mouse_moved:bool = false
var mouse_start_position_name:String = ""

func _ready() -> void:
	pass

func _unhandled_input(event:InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
			var position_name:String = click(event.position)
			finger_on_position.emit(click(event.position))
			tap_position.emit(position_name)
			mouse_moved = false
			mouse_start_position_name = position_name
		elif !event.pressed && mouse_moved && event.button_index == MOUSE_BUTTON_LEFT:
			var position_name:String = click(event.position)
			tap_position.emit(position_name)
			finger_up.emit()
	if event is InputEventMouseMotion:
		var position_name:String = click(event.position)
		if mouse_start_position_name != position_name:
			mouse_moved = true
		finger_on_position.emit(position_name)

	#if event is InputEventSingleScreenTouch:
	#	var position_name:String = click(event.position)
	#	if position_name && event.pressed:
	#		start_drawing_navi.emit(position_name)
	#	else:
	#		end_drawing_navi.emit()
	#if event is InputEventSingleScreenTap:
	#	var position_name:String = click(event.position)
	#	if !inspect_position_name:
	#		tap_position.emit(position_name)
	#		inspect_position_name = position_name
	#	else:
	#		confirm_navi.emit(inspect_position_name, position_name)
	#		inspect_position_name = ""
		# 查询position_name位置下的状态
	#if event is InputEventSingleScreenDrag:
	#	var position_name:String = click(event.position)
	#	if position_name:
	#	# 在position_name位置上绘制
	#		drawing_navi.emit(position_name)
	if event is InputEventMultiScreenDrag:
		#cancel_drawing_navi.emit()
		rotation.y -= event.relative.x / 300
		$head.rotation.x -= event.relative.y / 300
	if event is InputEventScreenPinch:
		#cancel_drawing_navi.emit()
		$head/camera.position.z -= event.relative / 200
	#if event is InputEventKey && event.pressed && event.keycode == KEY_SPACE:
	#	confirm.emit()

func click(screen_position:Vector2) -> String:
	var from:Vector3 = $head/camera.project_ray_origin(screen_position)
	var to:Vector3 = $head/camera.project_ray_normal(screen_position) * 200
	ray_cast.global_position = from
	ray_cast.target_position = to
	ray_cast.force_raycast_update()
	if ray_cast.is_colliding():
		return ray_cast.get_collider().get_name()
	return ""
