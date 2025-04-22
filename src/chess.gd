extends Node

class Piece:
	var class_type:Object = PieceInterface
	var group:int = 0
	var instance:PieceInstance = null

func create_piece(_class_type:Object, _group:int) -> Piece:
	var new_piece:Piece = Piece.new()
	new_piece.class_type = _class_type
	new_piece.group = _group
	return new_piece

class PieceInterface:
	static func create_instance(_position_name:String, _group:int) -> PieceInstance:
		return null
	static func execute_navi(_state:ChessState, _position_name_from:String, _position_name_to:String) -> void:
		pass
	static func get_valid_navi(_state:ChessState, _position_name_from:String) -> PackedStringArray:
		return []

class PieceKing extends PieceInterface:
	static func create_instance(position_name:String, group:int) -> PieceInstance:
		var packed_scene:PackedScene = load("res://scene/piece_king.tscn")
		var instance:PieceInstance = packed_scene.instantiate()
		instance.position_name = position_name
		instance.group = group
		return instance

	static func execute_navi(state:ChessState, position_name_from:String, position_name_to:String) -> void:
		if state.has_piece(position_name_to):
			state.capture_piece(position_name_to)
		state.move_piece(position_name_from, position_name_to)

	static func get_valid_navi(state:ChessState, position_name_from:String) -> PackedStringArray:
		var directions:PackedVector2Array = [Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1)]
		var answer:PackedStringArray = []
		for iter:Vector2i in directions:
			var position_name_to:String = Chess.direction_to(position_name_from, iter)
			if !position_name_to || state.has_piece(position_name_to) && state.get_piece(position_name_from).group == state.get_piece(position_name_to).group:
				continue
			answer.push_back(position_name_to)
		return answer

class ChessState:
	var state_name:String = "test"
	var current:Dictionary[String, Piece] = {}
	var history:PackedStringArray = []
	func _init() -> void:
		current = {
			"e1": Chess.create_piece(PieceKing, 0),
			"e8": Chess.create_piece(PieceKing, 8)
		}
	func get_piece_instance(position_name:String) -> PieceInstance:
		var instance:PieceInstance = current[position_name].instance
		if is_instance_valid(instance):
			return instance
		instance = current[position_name].class_type.create_instance(position_name, current[position_name].group)
		current[position_name].instance = instance
		return instance

	func get_piece(position_name:String) -> Piece:
		if !position_name || !current.has(position_name):
			return null
		return current[position_name]

	func get_valid_navi(position_name_from:String) -> PackedStringArray:
		if has_piece(position_name_from):
			return current[position_name_from].class_type.get_valid_navi(self, position_name_from)
		return []

	func execute_navi(position_name_from:String, position_name_to:String) -> void:
		if has_piece(position_name_from):
			current[position_name_from].class_type.execute_navi(self, position_name_from, position_name_to)

	func has_piece(position_name:String) -> bool:
		return current.has(position_name)

	func capture_piece(position_name:String) -> void:
		var instance:PieceInstance = get_piece(position_name).instance
		if is_instance_valid(instance):
			instance.queue_free()
		current.erase(position_name)

	func move_piece(position_name_from:String, position_name_to:String) -> void:
		var piece:Piece = get_piece(position_name_from)
		current.erase(position_name_from)
		current[position_name_to] = piece
		var instance:PieceInstance = piece.instance
		if is_instance_valid(instance):
			instance.move(position_name_to)

var current_chessboard:Chessboard = null
@onready var test_state:ChessState = ChessState.new()

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

func get_chess_state() -> ChessState:
	return test_state

#func get_valid_navi_queen(chessboard_name:String, position_name_from:String) -> PackedStringArray:
#	var directions:PackedVector2Array = [Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1)]
#	var answer:PackedStringArray = []
#	for iter:Vector2i in directions:
#		var position_name_to:String = direction_to(position_name_from, iter)
#		while !(!position_name_to || has_piece(chessboard_name, position_name_to) && pieces[chessboard_name][position_name_from]["group"] == pieces[chessboard_name][position_name_to]["group"]):
#			answer.push_back(position_name_to)
#			position_name_to = direction_to(position_name_to, iter)
#	return answer
#
#func get_valid_navi_rook(chessboard_name:String, position_name_from:String) -> PackedStringArray:
#	var directions:PackedVector2Array = [Vector2i(-1, 0), Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, 0)]
#	var answer:PackedStringArray = []
#	for iter:Vector2i in directions:
#		var position_name_to:String = direction_to(position_name_from, iter)
#		while !(!position_name_to || has_piece(chessboard_name, position_name_to) && pieces[chessboard_name][position_name_from]["group"] == pieces[chessboard_name][position_name_to]["group"]):
#			answer.push_back(position_name_to)
#			position_name_to = direction_to(position_name_to, iter)
#	return answer
#
#func get_valid_navi_bishop(chessboard_name:String, position_name_from:String) -> PackedStringArray:
#	var directions:PackedVector2Array = [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]
#	var answer:PackedStringArray = []
#	for iter:Vector2i in directions:
#		var position_name_to:String = direction_to(position_name_from, iter)
#		while !(!position_name_to || has_piece(chessboard_name, position_name_to) && pieces[chessboard_name][position_name_from]["group"] == pieces[chessboard_name][position_name_to]["group"]):
#			answer.push_back(position_name_to)
#			position_name_to = direction_to(position_name_to, iter)
#	return answer
#
#func get_valid_navi_knight(chessboard_name:String, position_name_from:String) -> PackedStringArray:
#	var directions:PackedVector2Array = [Vector2i(1, 2), Vector2i(2, 1), Vector2i(-1, 2), Vector2i(-2, 1), Vector2i(1, -2), Vector2i(2, -1), Vector2i(-1, -2), Vector2i(-2, -1)]
#	var answer:PackedStringArray = []
#	for iter:Vector2i in directions:
#		var position_name_to:String = direction_to(position_name_from, iter)
#		if !position_name_to || has_piece(chessboard_name, position_name_to) && pieces[chessboard_name][position_name_from]["group"] == pieces[chessboard_name][position_name_to]["group"]:
#			continue
#		answer.push_back(position_name_to)
#	return answer
#
#func get_valid_navi_pawn(chessboard_name:String, position_name_from:String) -> PackedStringArray:
#	var answer:PackedStringArray = []
#	var forward:Vector2i = Vector2i(0, 1) if pieces[chessboard_name][position_name_from]["group"] == 0 else Vector2i(0, -1)
#	var on_start:bool = pieces[chessboard_name][position_name_from]["group"] == 0 && position_name_from[1] == "2" || pieces[chessboard_name][position_name_from]["group"] == 1 && position_name_from[1] == "7"
#	var position_name_to:String = direction_to(position_name_from, forward)
#	var position_name_to_2:String = direction_to(position_name_from, forward * 2)
#	var position_name_to_l:String = direction_to(position_name_to, Vector2i(1, 0))
#	var position_name_to_r:String = direction_to(position_name_to, Vector2i(-1, 0))
#	if !has_piece(chessboard_name, position_name_to):
#		answer.push_back(position_name_to)
#		if on_start && !has_piece(chessboard_name, position_name_to_2):
#			answer.push_back(position_name_to_2)
#	if has_piece(chessboard_name, position_name_to_l) && pieces[chessboard_name][position_name_from]["group"] != pieces[chessboard_name][position_name_to_l]["group"]:
#		answer.push_back(position_name_to_l)
#	if has_piece(chessboard_name, position_name_to_r) && pieces[chessboard_name][position_name_from]["group"] != pieces[chessboard_name][position_name_to_r]["group"]:
#		answer.push_back(position_name_to_r)
#	return answer
#
#func execute_navi_king(chessboard_name:String, position_name_from:String, position_name_to:String) -> void:
#	if Chess.has_piece(chessboard_name, position_name_to):
#		Chess.capture_piece(chessboard_name, position_name_to)
#	Chess.move_piece(chessboard_name, position_name_from, position_name_to)
#
#func execute_navi_queen(chessboard_name:String, position_name_from:String, position_name_to:String) -> void:
#	if Chess.has_piece(chessboard_name, position_name_to):
#		Chess.capture_piece(chessboard_name, position_name_to)
#	Chess.move_piece(chessboard_name, position_name_from, position_name_to)
#
#func execute_navi_rook(chessboard_name:String, position_name_from:String, position_name_to:String) -> void:
#	if Chess.has_piece(chessboard_name, position_name_to):
#		Chess.capture_piece(chessboard_name, position_name_to)
#	Chess.move_piece(chessboard_name, position_name_from, position_name_to)
#
#func execute_navi_bishop(chessboard_name:String, position_name_from:String, position_name_to:String) -> void:
#	if Chess.has_piece(chessboard_name, position_name_to):
#		Chess.capture_piece(chessboard_name, position_name_to)
#	Chess.move_piece(chessboard_name, position_name_from, position_name_to)
#
#func execute_navi_knight(chessboard_name:String, position_name_from:String, position_name_to:String) -> void:
#	if Chess.has_piece(chessboard_name, position_name_to):
#		Chess.capture_piece(chessboard_name, position_name_to)
#	Chess.move_piece(chessboard_name, position_name_from, position_name_to)
#	
#func execute_navi_pawn(chessboard_name:String, position_name_from:String, position_name_to:String) -> void:
#	if Chess.has_piece(chessboard_name, position_name_to):
#		Chess.capture_piece(chessboard_name, position_name_to)
#	Chess.move_piece(chessboard_name, position_name_from, position_name_to)
#
