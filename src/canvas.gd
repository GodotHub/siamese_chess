extends Node3D

@onready var resolution:Vector2 = Vector2(512, 512)

var line:Array[Line2D] = []	# 直接暴力搜解决问题
var drawing_line:Dictionary[int, Line2D] = {}

func _ready():
	$sub_viewport.size = resolution

func erase(_position:Vector2) -> void:
	pass

func clear() -> void:
	for iter:Line2D in get_children():
		iter.queue_free()

func start_drawing(finger_index:int, start_position:Vector2) -> void:
	var new_line:Line2D = Line2D.new()
	new_line.joint_mode = Line2D.LINE_JOINT_ROUND
	new_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	new_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	new_line.default_color = Color(0, 0, 0, 1)
	new_line.width = 20
	new_line.add_point(start_position)
	drawing_line[finger_index] = new_line
	$sub_viewport.add_child(new_line)
	line.push_back(new_line)

func drawing_curve(finger_index:int, drawing_position:Vector2) -> void:
	if !drawing_line.has(finger_index):
#		start_draw(finger_index, drawing_position)
		return
	var current_line:Line2D = drawing_line[finger_index]
	if current_line.get_point_count() > 0 && current_line.get_point_position(current_line.get_point_count() - 1).distance_squared_to(drawing_position) < 3 * 3:
		return
	current_line.add_point(drawing_position)

func drawing_straight(finger_index:int, drawing_position) -> void:
	if !drawing_line.has(finger_index):
		return
	var current_line:Line2D = drawing_line[finger_index]
	#if current_line.get_point_count() > 0 && current_line.get_point_position(current_line.get_point_count() - 1).distance_squared_to(drawing_position) < 3 * 3:
	#	return
	# 有可能会做折现，不做清理
	if current_line.get_point_count() < 2:
		current_line.add_point(drawing_position)
	current_line.set_point_position(current_line.get_point_count() - 1, drawing_position)

func end_drawing(finger_index:int) -> void:
	if !drawing_line.has(finger_index):
		return
	drawing_line.erase(finger_index)

func cancel_drawing() -> void:
	for key:int in drawing_line:
		if is_instance_valid(drawing_line[key]):
			drawing_line[key].queue_free()
	drawing_line.clear()

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
