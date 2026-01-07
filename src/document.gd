extends Node2D
class_name Document
# 文档分为模板和实例
# 实例包含了文件名称和变量

var filename:String = ""	# 文档名称，唯一
var template:String = ""	# 模板路径
var lines:Array[Line2D] # 线条
var drawing_line:Line2D = null
var width:float = 3
var color:Color = Color(0.1, 0.1, 0.1, 1)

func _ready() -> void:
	pass

func parse(_data:String) -> void:
	var data_dict:Dictionary = JSON.parse_string(_data)
	draw_lines(data_dict["lines"])

func stringify() -> String:
	var data_dict:Dictionary = {}
	data_dict["lines"] = get_lines()
	return JSON.stringify(data_dict)

func save_file() -> void:
	var data:String = stringify()
	var path:String = "user://archive/" + filename
	DirAccess.make_dir_absolute("user://archive/")
	var file:FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(data)
	file.close()

func load_file() -> void:
	var data:String = FileAccess.get_file_as_string("user://archive/" + filename)
	parse(data)

func clear_file() -> void:
	DirAccess.remove_absolute("user://archive/" + filename)

func set_filename(_filename:String) -> void:
	filename = _filename

func get_filename() -> String:
	return filename

func get_rect() -> Rect2:
	return Rect2(-552 / 2, -780 / 2, 552, 780)

func start_drawing(start_position:Vector2) -> void:
	var new_line:Line2D = Line2D.new()
	new_line.joint_mode = Line2D.LINE_JOINT_ROUND
	new_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	new_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	new_line.default_color = color
	new_line.width = width
	new_line.add_point(start_position)
	drawing_line = new_line
	add_child(new_line)
	lines.push_back(new_line)

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
		if lines.has(drawing_line):
			lines.erase(drawing_line)
		drawing_line.queue_free()

func erase_line(drawing_position:Vector2) -> void:
	cancel_drawing()
	var point_list:Array = lines.duplicate(false)
	for iter:Line2D in point_list:
		if iter.get_point_count() < 2:
			lines.erase(iter)
			iter.queue_free()
		for i:int in iter.get_point_count():
			if iter.get_point_position(i).distance_squared_to(drawing_position) < 10 * 10:
				lines.erase(iter)
				iter.queue_free()
				break

func clear_lines() -> void:
	for iter:Line2D in lines:
		iter.queue_free()
	lines.clear()

func get_lines() -> Array:
	var output:Array = []
	for iter:Line2D in lines:
		var point_list:PackedFloat32Array = []
		for i:int in iter.get_point_count():
			point_list.push_back(iter.get_point_position(i).x)
			point_list.push_back(iter.get_point_position(i).y)
		output.push_back(point_list)
	return output

func draw_lines(_lines:Array) -> void:
	for iter:PackedFloat32Array in _lines:
		var line:Line2D = Line2D.new()
		line.joint_mode = Line2D.LINE_JOINT_ROUND
		line.begin_cap_mode = Line2D.LINE_CAP_ROUND
		line.end_cap_mode = Line2D.LINE_CAP_ROUND
		line.default_color = color
		line.width = width
		for i:int in iter.size() / 2:
			var point:Vector2 = Vector2(iter[i * 2], iter[i * 2 + 1])
			line.add_point(point)
		add_child(line)
		lines.push_back(line)
