extends Node

var pieces:Dictionary[String, Dictionary] = {
	"test": {
		"a1": {
			"class": "rook",
			"group": 0
		},
		"b1": {
			"class": "knight",
			"group": 0
		},
		"c1": {
			"class": "bishop",
			"group": 0
		},
		"d1": {
			"class": "queen",
			"group": 0
		},
		"e1": {
			"class": "king",
			"group": 0
		},
		"f1": {
			"class": "bishop",
			"group": 0
		},
		"g1": {
			"class": "knight",
			"group": 0
		},
		"h1": {
			"class": "rook",
			"group": 0
		},
		"a2": {
			"class": "pawn",
			"group": 0
		},
		"b2": {
			"class": "pawn",
			"group": 0
		},
		"c2": {
			"class": "pawn",
			"group": 0
		},
		"d2": {
			"class": "pawn",
			"group": 0
		},
		"e2": {
			"class": "pawn",
			"group": 0
		},
		"f2": {
			"class": "pawn",
			"group": 0
		},
		"g2": {
			"class": "pawn",
			"group": 0
		},
		"h2": {
			"class": "pawn",
			"group": 0
		},
		"a7": {
			"class": "pawn",
			"group": 1
		},
		"b7": {
			"class": "pawn",
			"group": 1
		},
		"c7": {
			"class": "pawn",
			"group": 1
		},
		"d7": {
			"class": "pawn",
			"group": 1
		},
		"e7": {
			"class": "pawn",
			"group": 1
		},
		"f7": {
			"class": "pawn",
			"group": 1
		},
		"g7": {
			"class": "pawn",
			"group": 1
		},
		"h7": {
			"class": "pawn",
			"group": 1
		},
		"a8": {
			"class": "rook",
			"group": 1
		},
		"b8": {
			"class": "knight",
			"group": 1
		},
		"c8": {
			"class": "bishop",
			"group": 1
		},
		"d8": {
			"class": "queen",
			"group": 1
		},
		"e8": {
			"class": "king",
			"group": 1
		},
		"f8": {
			"class": "bishop",
			"group": 1
		},
		"g8": {
			"class": "knight",
			"group": 1
		},
		"h8": {
			"class": "rook",
			"group": 1
		}
	}
}
var current_chessboard:Chessboard = null

func to_piece_position(position_name:String) -> Vector2i:
	var position_name_buffer:PackedByteArray = position_name.to_ascii_buffer()
	return Vector2i(position_name_buffer[0] - 97, position_name_buffer[1] - 49)

func to_position_name(piece_position:Vector2i) -> String:
	if piece_position.x < 0 || piece_position.x > 7 || piece_position.y < 0 || piece_position.y > 7:
		return ""
	return "%c%c" % [piece_position.x + 97, piece_position.y + 49]

func direction_to(position_name_from:String, direction:Vector2i) -> String:
	return to_position_name(to_piece_position(position_name_from) + direction)

func change_chessboard(next:String) -> void:
	if is_instance_valid(current_chessboard):
		current_chessboard.queue_free()
	var packed_scene:PackedScene = load("res://scene/chessboard_%s.tscn" % next)
	current_chessboard = packed_scene.instantiate()
	get_tree().root.add_child(current_chessboard)

func get_current_chessboard() -> Chessboard:
	return current_chessboard
  
func set_current_chessboard(_chessboard:Chessboard) -> void:
	current_chessboard = _chessboard

func get_piece_instance(chessboard_name:String, position_name:String) -> PieceInstance:
	var piece:PieceInstance = null
	if pieces[chessboard_name][position_name].has("instance"):
		return pieces[chessboard_name][position_name]["instance"]
	var packed_scene:PackedScene = load("res://scene/piece_%s.tscn" % pieces[chessboard_name][position_name]["class"])
	piece = packed_scene.instantiate()
	piece.chessboard_name = chessboard_name
	piece.position_name = position_name
	piece.group = pieces[chessboard_name][position_name]["group"]
	pieces[chessboard_name][position_name]["instance"] = piece
	return piece

func get_piece(chessboard_name:String, position_name:String) -> Dictionary:	# 不允许直接获得对象本身
	return pieces[chessboard_name][position_name]

func get_pieces_in_chessboard(chessboard_name:String) -> Dictionary:
	return pieces[chessboard_name]

func move_piece(chessboard_name:String, from:String, to:String) -> void:
	var piece_data:Dictionary = pieces[chessboard_name][from]
	pieces[chessboard_name].erase(from)
	pieces[chessboard_name][to] = piece_data
	if pieces[chessboard_name][to].has("instance"):
		var instance:PieceInstance = pieces[chessboard_name][to]["instance"]
		instance.move(to)

func capture_piece(chessboard_name:String, position_name:String) -> void:
	if pieces[chessboard_name][position_name].has("instance"):
		var instance:PieceInstance = pieces[chessboard_name][position_name]["instance"]
		pieces[chessboard_name][position_name].erase("instance")
		instance.queue_free()
	pieces[chessboard_name].erase(position_name)

func has_piece(chessboard_name:String, position_name:String) -> bool:
	return pieces.has(chessboard_name) && pieces[chessboard_name].has(position_name)

func is_navi_valid(chessboard_name:String, position_name_from:String, position_name_to:String) -> bool:
	return get_valid_navi(chessboard_name, position_name_from).has(position_name_to)

func get_valid_navi(chessboard_name:String, position_name_from:String) -> PackedStringArray:
	if has_piece(chessboard_name, position_name_from):
		return call("get_valid_navi_" + pieces[chessboard_name][position_name_from]["class"], chessboard_name, position_name_from)
	return []

func execute_navi(chessboard_name:String, position_name_from:String, position_name_to:String) -> void:
	if is_navi_valid(chessboard_name, position_name_from, position_name_to):
		call("execute_navi_" + pieces[chessboard_name][position_name_from]["class"], chessboard_name, position_name_from, position_name_to)

func get_valid_navi_king(chessboard_name:String, position_name_from:String) -> PackedStringArray:
	var directions:PackedVector2Array = [Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1)]
	var answer:PackedStringArray = []
	for iter:Vector2i in directions:
		var position_name_to:String = direction_to(position_name_from, iter)
		if !position_name_to || has_piece(chessboard_name, position_name_to) && pieces[chessboard_name][position_name_from]["group"] == pieces[chessboard_name][position_name_to]["group"]:
			continue
		answer.push_back(position_name_to)
	return answer

func get_valid_navi_queen(chessboard_name:String, position_name_from:String) -> PackedStringArray:
	var directions:PackedVector2Array = [Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1)]
	var answer:PackedStringArray = []
	for iter:Vector2i in directions:
		var position_name_to:String = direction_to(position_name_from, iter)
		while !(!position_name_to || has_piece(chessboard_name, position_name_to) && pieces[chessboard_name][position_name_from]["group"] == pieces[chessboard_name][position_name_to]["group"]):
			answer.push_back(position_name_to)
			position_name_to = direction_to(position_name_to, iter)
	return answer

func get_valid_navi_rook(chessboard_name:String, position_name_from:String) -> PackedStringArray:
	var directions:PackedVector2Array = [Vector2i(-1, 0), Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, 0)]
	var answer:PackedStringArray = []
	for iter:Vector2i in directions:
		var position_name_to:String = direction_to(position_name_from, iter)
		while !(!position_name_to || has_piece(chessboard_name, position_name_to) && pieces[chessboard_name][position_name_from]["group"] == pieces[chessboard_name][position_name_to]["group"]):
			answer.push_back(position_name_to)
			position_name_to = direction_to(position_name_to, iter)
	return answer

func get_valid_navi_bishop(chessboard_name:String, position_name_from:String) -> PackedStringArray:
	var directions:PackedVector2Array = [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]
	var answer:PackedStringArray = []
	for iter:Vector2i in directions:
		var position_name_to:String = direction_to(position_name_from, iter)
		while !(!position_name_to || has_piece(chessboard_name, position_name_to) && pieces[chessboard_name][position_name_from]["group"] == pieces[chessboard_name][position_name_to]["group"]):
			answer.push_back(position_name_to)
			position_name_to = direction_to(position_name_to, iter)
	return answer

func get_valid_navi_knight(chessboard_name:String, position_name_from:String) -> PackedStringArray:
	var directions:PackedVector2Array = [Vector2i(1, 2), Vector2i(2, 1), Vector2i(-1, 2), Vector2i(-2, 1), Vector2i(1, -2), Vector2i(2, -1), Vector2i(-1, -2), Vector2i(-2, -1)]
	var answer:PackedStringArray = []
	for iter:Vector2i in directions:
		var position_name_to:String = direction_to(position_name_from, iter)
		if !position_name_to || has_piece(chessboard_name, position_name_to) && pieces[chessboard_name][position_name_from]["group"] == pieces[chessboard_name][position_name_to]["group"]:
			continue
		answer.push_back(position_name_to)
	return answer

func get_valid_navi_pawn(chessboard_name:String, position_name_from:String) -> PackedStringArray:
	var answer:PackedStringArray = []
	var forward:Vector2i = Vector2i(0, 1) if pieces[chessboard_name][position_name_from]["group"] == 0 else Vector2i(0, -1)
	var on_start:bool = pieces[chessboard_name][position_name_from]["group"] == 0 && position_name_from[1] == "2" || pieces[chessboard_name][position_name_from]["group"] == 1 && position_name_from[1] == "7"
	var position_name_to:String = direction_to(position_name_from, forward)
	var position_name_to_2:String = direction_to(position_name_from, forward * 2)
	var position_name_to_l:String = direction_to(position_name_to, Vector2i(1, 0))
	var position_name_to_r:String = direction_to(position_name_to, Vector2i(-1, 0))
	if !has_piece(chessboard_name, position_name_to):
		answer.push_back(position_name_to)
		if on_start && !has_piece(chessboard_name, position_name_to_2):
			answer.push_back(position_name_to_2)
	if has_piece(chessboard_name, position_name_to_l) && pieces[chessboard_name][position_name_from]["group"] != pieces[chessboard_name][position_name_to_l]["group"]:
		answer.push_back(position_name_to_l)
	if has_piece(chessboard_name, position_name_to_r) && pieces[chessboard_name][position_name_from]["group"] != pieces[chessboard_name][position_name_to_r]["group"]:
		answer.push_back(position_name_to_r)
	return answer

func execute_navi_king(chessboard_name:String, position_name_from:String, position_name_to:String) -> void:
	if Chess.has_piece(chessboard_name, position_name_to):
		Chess.capture_piece(chessboard_name, position_name_to)
	Chess.move_piece(chessboard_name, position_name_from, position_name_to)

func execute_navi_queen(chessboard_name:String, position_name_from:String, position_name_to:String) -> void:
	if Chess.has_piece(chessboard_name, position_name_to):
		Chess.capture_piece(chessboard_name, position_name_to)
	Chess.move_piece(chessboard_name, position_name_from, position_name_to)

func execute_navi_rook(chessboard_name:String, position_name_from:String, position_name_to:String) -> void:
	if Chess.has_piece(chessboard_name, position_name_to):
		Chess.capture_piece(chessboard_name, position_name_to)
	Chess.move_piece(chessboard_name, position_name_from, position_name_to)

func execute_navi_bishop(chessboard_name:String, position_name_from:String, position_name_to:String) -> void:
	if Chess.has_piece(chessboard_name, position_name_to):
		Chess.capture_piece(chessboard_name, position_name_to)
	Chess.move_piece(chessboard_name, position_name_from, position_name_to)

func execute_navi_knight(chessboard_name:String, position_name_from:String, position_name_to:String) -> void:
	if Chess.has_piece(chessboard_name, position_name_to):
		Chess.capture_piece(chessboard_name, position_name_to)
	Chess.move_piece(chessboard_name, position_name_from, position_name_to)
	
func execute_navi_pawn(chessboard_name:String, position_name_from:String, position_name_to:String) -> void:
	if Chess.has_piece(chessboard_name, position_name_to):
		Chess.capture_piece(chessboard_name, position_name_to)
	Chess.move_piece(chessboard_name, position_name_from, position_name_to)
