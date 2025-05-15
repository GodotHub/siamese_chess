extends PieceInterface
class_name PieceInterfaceRook

static func get_name() -> String:
	return "Rook"

static func create_instance(position_name:String, group:int) -> PieceInstance:
	var packed_scene:PackedScene = load("res://scene/piece_rook.tscn")
	var instance:PieceInstance = packed_scene.instantiate()
	instance.position_name = position_name
	instance.group = group
	return instance

static func execute_move(state:ChessState, move:Move) -> void:
	if Chess.to_piece_position(move.position_name_from).x >= 4:
		if state.get_piece(move.position_name_from).group == 0:
			state.extra[1].erase(state.extra[1].find("K"), 1)
		else:
			state.extra[1].erase(state.extra[1].find("k"), 1)
	elif Chess.to_piece_position(move.position_name_from).x <= 3:
		if state.get_piece(move.position_name_from).group == 0:
			state.extra[1].erase(state.extra[1].find("Q"), 1)
		else:
			state.extra[1].erase(state.extra[1].find("q"), 1)
	if state.has_piece(move.position_name_to):
		state.capture_piece(move.position_name_to)
	if move.position_name_to in state.extra[6]:
		# 直接拿下国王判定胜利吧（唉）
		if state.get_piece(move.position_name_from).group == 0:
			state.capture_piece("c8")
			state.capture_piece("g8")
		else:
			state.capture_piece("c1")
			state.capture_piece("g1")
	state.move_piece(move.position_name_from, move.position_name_to)

static func get_valid_move(state:ChessState, position_name_from:String) -> Array[Move]:
	var directions:PackedVector2Array = [Vector2i(-1, 0), Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, 0)]
	var output:Array[Move] = []
	for iter:Vector2i in directions:
		var position_name_to:String = Chess.direction_to(position_name_from, iter)
		while position_name_to && (!state.has_piece(position_name_to) || state.get_piece(position_name_from).group != state.get_piece(position_name_to).group):
			output.push_back(Move.create(position_name_from, position_name_to, "", "Default"))
			if state.has_piece(position_name_to) && state.get_piece(position_name_from).group != state.get_piece(position_name_to).group:
				break
			position_name_to = Chess.direction_to(position_name_to, iter)
			if state.has_piece(position_name_to) && state.get_piece(position_name_from).group == state.get_piece(position_name_to).group && state.get_piece(position_name_to).class_type.get_name() == "King":
				var group:int = state.get_piece(position_name_to).group
				if Chess.to_piece_position(position_name_from).x >= 4 && (group == 0 && state.extra[1].contains("K") || group == 1 && state.extra[1].contains("k")):
					output.push_back(Move.create(position_name_to, "g" + ("1" if group == 0 else "8"), position_name_from, "Short Castling"))
				elif Chess.to_piece_position(position_name_from).x <= 3 && (group == 0 && state.extra[1].contains("Q") || group == 1 && state.extra[1].contains("q")):
					output.push_back(Move.create(position_name_to, "c" + ("1" if group == 0 else "8"), position_name_from, "Long Castling"))
	return output

static func get_value() -> float:
	return 5