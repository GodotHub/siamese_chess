extends Node3D

var map:Dictionary[String, Node3D] = {}

var navigation:Array[Node3D] = []	# 线条是有排序的

func _ready() -> void:
	for iter:Node3D in $chess.get_children():
		var position_name:String = get_position_name(iter.position)
		map[position_name] = iter
		iter.position = get_node(position_name).position

func get_position_name(_position:Vector3) -> String:
	var chess_pos:Vector2i = Vector2i(int(_position.x + 4) / 1, int(_position.z + 4) / 1)
	return "%c%d" % [chess_pos.x + 97, chess_pos.y + 1]

func start_navigation(position_name:String) -> void:
	navigation.push_back(null)
