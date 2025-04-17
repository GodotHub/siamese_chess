extends Node3D

signal start_drawing_navi(position_name:String)
signal drawing_navi(position_name:String)
signal end_drawing_navi()
signal cancel_drawing_navi()

signal confirm()

@onready var ray_cast:RayCast3D = $ray_cast

func _ready() -> void:
	pass

func _unhandled_input(event:InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
			var position_name:String = click(event.position)
			if position_name:
				start_drawing_navi.emit(position_name)
		elif !event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
			end_drawing_navi.emit()
	if event is InputEventMouseMotion:
		if !event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			return
		var position_name:String = click(event.position)
		if !position_name:
			cancel_drawing_navi.emit()
		drawing_navi.emit(position_name) 

	if event is InputEventSingleScreenTouch:
		var position_name:String = click(event.position)
		if position_name && event.pressed:
			start_drawing_navi.emit(position_name)
		else:
			end_drawing_navi.emit()
	if event is InputEventSingleScreenTap:
		click(event.position)
		# 查询position_name位置下的状态
	if event is InputEventSingleScreenDrag:
		var position_name:String = click(event.position)
		if position_name:
		# 在position_name位置上绘制
			drawing_navi.emit(position_name)
	if event is InputEventMultiScreenDrag:
		cancel_drawing_navi.emit()
		rotation.y -= event.relative.x / 300
		$head.rotation.x -= event.relative.y / 300
	if event is InputEventScreenPinch:
		cancel_drawing_navi.emit()
		$head/camera.position.z -= event.relative / 200
	if event is InputEventKey && event.pressed && event.keycode == KEY_SPACE:
		confirm.emit()

func click(screen_position:Vector2) -> String:
	var from:Vector3 = $head/camera.project_ray_origin(screen_position)
	var to:Vector3 = $head/camera.project_ray_normal(screen_position) * 200
	ray_cast.global_position = from
	ray_cast.target_position = to
	ray_cast.force_raycast_update()
	if ray_cast.is_colliding():
		return ray_cast.get_collider().get_name()
	return ""
