extends Node

var pieces:Dictionary[String, Dictionary] = {
	"test": {
		"a1": {
			"class": "rook",
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
		"h1": {
			"class": "rook",
			"group": 0
		}
	}
}
var current_chessboard:Chessboard = null

func to_piece_position(position_name:String) -> Vector2i:
	var position_name_buffer:PackedByteArray = position_name.to_ascii_buffer()
	return Vector2i(position_name_buffer[0] - 97, position_name_buffer[1] - 49)

func to_position_name(piece_position:Vector2i) -> String:
	return "%c%c" % [piece_position.x + 97, piece_position.y + 49]

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
	if has_piece(chessboard_name, position_name_from):
		return call("is_navi_valid_" + pieces[chessboard_name][position_name_from]["class"], chessboard_name, position_name_from, position_name_to)
	return false

func execute_navi(chessboard_name:String, position_name_from:String, position_name_to:String) -> void:
	if is_navi_valid(chessboard_name, position_name_from, position_name_to):
		call("execute_navi_" + pieces[chessboard_name][position_name_from]["class"], chessboard_name, position_name_from, position_name_to)

func is_navi_valid_king(chessboard_name:String, position_name_from:String, position_name_to:String) -> bool:
	var position_from:Vector2i = to_piece_position(position_name_from)
	var position_to:Vector2i = to_piece_position(position_name_to)
	var distance:float = position_from.distance_squared_to(position_to)
	if distance != 1 && distance != 2:
		return false
	if has_piece(chessboard_name, position_name_to) && pieces[chessboard_name][position_name_from]["group"] == pieces[chessboard_name][position_name_to]["group"]:
		return false
	return true

func is_navi_valid_queen(chessboard_name:String, position_name_from:String, position_name_to:String) -> bool:
	var position_from:Vector2i = to_piece_position(position_name_from)
	var position_to:Vector2i = to_piece_position(position_name_to)
	if position_to == position_from || position_from.x != position_to.x && position_from.y != position_to.y && position_from.x + position_from.y != position_to.x + position_to.y && position_from.x - position_from.y != position_to.x - position_to.y:
		return false
	var direction:Vector2i = position_to - position_from
	direction.x = 1 if direction.x > 0 else (-1 if direction.x < 0 else 0)
	direction.y = 1 if direction.y > 0 else (-1 if direction.y < 0 else 0)
	while position_from != position_to:
		position_from += direction
		if has_piece(chessboard_name, to_position_name(position_from)) && (position_from != position_to || pieces[chessboard_name][position_name_from]["group"] == pieces[chessboard_name][position_name_to]["group"]):
			return false
	return true


func is_navi_valid_rook(chessboard_name:String, position_name_from:String, position_name_to:String) -> bool:
	var position_from:Vector2i = to_piece_position(position_name_from)
	var position_to:Vector2i = to_piece_position(position_name_to)
	if position_from.x != position_to.x && position_from.y != position_to.y:
		return false
	var direction:Vector2i = position_to - position_from
	direction.x = 1 if direction.x > 0 else (-1 if direction.x < 0 else 0)
	direction.y = 1 if direction.y > 0 else (-1 if direction.y < 0 else 0)
	while position_from != position_to:
		position_from += direction
		if has_piece(chessboard_name, to_position_name(position_from)) && (position_from != position_to || pieces[chessboard_name][position_name_from]["group"] == pieces[chessboard_name][position_name_to]["group"]):
			return false
	return true

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
