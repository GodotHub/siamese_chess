extends Node3D

var map:Dictionary[String, Node3D] = {}
var navi:Array[String] = []	# 线条是有排序的，总结下来只有四个字符：起点和终点

func _ready() -> void:
	for iter:Node3D in $chess.get_children():
		var position_name:String = get_position_name(iter.position)
		map[position_name] = iter
		iter.position = get_node(position_name).position
	$player.connect("start_drawing_navi", start_drawing_navi)
	$player.connect("drawing_navi", drawing_navi)
	$player.connect("end_drawing_navi", end_drawing_navi)
	$player.connect("cancel_drawing_navi", cancel_drawing_navi)

func get_position_name(_position:Vector3) -> String:
	var chess_pos:Vector2i = Vector2i(int(_position.x + 4) / 1, int(_position.z + 4) / 1)
	return "%c%d" % [chess_pos.x + 97, chess_pos.y + 1]

func start_drawing_navi(position_name:String) -> void:
	var ascii:PackedByteArray = position_name.to_ascii_buffer()
	var converted:Vector2 = Vector2(ascii[0] - 97, 7 - (ascii[1] - 49))
	$canvas.start_drawing(0, converted * 512 / 8 + Vector2(512 / 16, 512 / 16))
	navi.push_back(position_name)

func drawing_navi(position_name:String) -> void:
	var ascii:PackedByteArray = position_name.to_ascii_buffer()
	var converted:Vector2 = Vector2(ascii[0] - 97, 7 - (ascii[1] - 49))
	$canvas.drawing_straight(0, converted * 512 / 8 + Vector2(512 / 16, 512 / 16))
	navi[-1] = navi[-1].substr(0, 2) + position_name

func end_drawing_navi() -> void:
	$canvas.end_drawing(0)

func cancel_drawing_navi() -> void:
	$canvas.cancel_drawing()
	navi.pop_back()

func check_piece() -> void:
	pass

func confirm() -> void:
	pass
