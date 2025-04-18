extends Node3D

@onready var resolution:float = 512

var line:Array[Line2D] = []	# 直接暴力搜解决问题
var drawing_line:Line2D = null

func _ready():
	$sub_viewport.size = Vector2(resolution, resolution)

func clear() -> void:
	for iter:Line2D in $sub_viewport.get_children():
		iter.queue_free()

func start_drawing(start_position:Vector2) -> void:
	var new_line:Line2D = Line2D.new()
	new_line.joint_mode = Line2D.LINE_JOINT_ROUND
	new_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	new_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	new_line.default_color = Color(0, 0, 0, 1)
	new_line.width = 20
	new_line.add_point(start_position)
	drawing_line = new_line
	$sub_viewport.add_child(new_line)
	line.push_back(new_line)

func drawing_curve(drawing_position:Vector2) -> void:
	if !is_instance_valid(drawing_line):
#		start_draw(finger_index, drawing_position)
		return
	if drawing_line.get_point_count() > 0 && drawing_line.get_point_position(drawing_line.get_point_count() - 1).distance_squared_to(drawing_position) < 3 * 3:
		return
	drawing_line.add_point(drawing_position)

func drawing_straight(drawing_position) -> void:
	if !is_instance_valid(drawing_line):
		return
	#if drawing_line.get_point_count() > 0 && drawing_line.get_point_position(drawing_line.get_point_count() - 1).distance_squared_to(drawing_position) < 3 * 3:
	#	return
	# 有可能会做折现，不做清理
	if drawing_line.get_point_count() < 2:
		drawing_line.add_point(drawing_position)
	drawing_line.set_point_position(drawing_line.get_point_count() - 1, drawing_position)

func end_drawing() -> void:
	if !is_instance_valid(drawing_line):
		return
	drawing_line = null

func cancel_drawing() -> void:
	if is_instance_valid(drawing_line):
		drawing_line.queue_free()

func erase_line(drawing_position:Vector2) -> void:
	cancel_drawing()
	var point_list:Array = get_children()
	for iter:Line2D in point_list:
		if iter.get_point_count() < 2:
			iter.queue_free()
		for point:Vector2 in iter.points:
			if point.distance_squared_to(drawing_position) < 10 * 10:
				iter.queue_free()
				break

func convert_name_to_position(_name:String) -> Vector2:
	var ascii:PackedByteArray = _name.to_ascii_buffer()
	var converted:Vector2 = Vector2(ascii[0] - 97, 7 - (ascii[1] - 49))
	return converted * resolution / 8 + Vector2(resolution / 16, resolution / 16)
