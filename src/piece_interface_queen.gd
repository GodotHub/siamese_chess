extends Chess.PieceInterface
class_name PieceInterfaceQueen

static func get_name() -> String:
	return "Queen"

static func create_instance(position_name:String, group:int) -> PieceInstance:
	var packed_scene:PackedScene = load("res://scene/piece_queen.tscn")
	var instance:PieceInstance = packed_scene.instantiate()
	instance.position_name = position_name
	instance.group = group
	return instance

static func execute_move(state:Chess.ChessState, move:Chess.Move) -> void:
	if state.has_piece(move.position_name_to):
		state.capture_piece(move.position_name_to)
	if move.position_name_to in state.king_passant:
		# 直接拿下国王判定胜利吧（唉）
		if state.get_piece(move.position_name_from).group == 0:
			state.capture_piece("c8")
			state.capture_piece("g8")
		else:
			state.capture_piece("c1")
			state.capture_piece("g1")

	state.move_piece(move.position_name_from, move.position_name_to)

static func get_valid_move(state:Chess.ChessState, position_name_from:String) -> Array[Move]:
	var directions:PackedVector2Array = [Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1)]
	var output:Array[Move] = []
	for iter:Vector2i in directions:
		var position_name_to:String = Chess.direction_to(position_name_from, iter)
		while position_name_to && (!state.has_piece(position_name_to) || state.get_piece(position_name_from).group != state.get_piece(position_name_to).group):
			output.push_back(Chess.create_move(position_name_from, position_name_to, "", "Default"))
			if state.has_piece(position_name_to) && state.get_piece(position_name_from).group != state.get_piece(position_name_to).group:
				break
			position_name_to = Chess.direction_to(position_name_to, iter)
	return output

static func get_value() -> float:
	return 9