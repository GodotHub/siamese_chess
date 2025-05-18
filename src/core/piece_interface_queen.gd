extends PieceInterface
class_name PieceInterfaceQueen

static func get_name() -> String:
	return "Queen"

static func create_instance(position_name:String, group:int) -> PieceInstance:
	var packed_scene:PackedScene = load("res://scene/piece_queen.tscn")
	var instance:PieceInstance = packed_scene.instantiate()
	instance.position_name = position_name
	instance.group = group
	return instance

static func execute_move(state:ChessState, move:Move) -> void:
	if state.has_piece(move.position_name_to):
		state.capture_piece(move.position_name_to)
	if move.position_name_to in state.extra[5]:
		# 直接拿下国王判定胜利吧（唉）
		if state.get_piece(move.position_name_from).group == 0:
			state.capture_piece("c8")
			state.capture_piece("g8")
		else:
			state.capture_piece("c1")
			state.capture_piece("g1")

	state.move_piece(move.position_name_from, move.position_name_to)

static func get_valid_move(state:ChessState, position_name_from:String) -> Array[Move]:
	var directions:PackedVector2Array = [Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1)]
	var output:Array[Move] = []
	for iter:Vector2i in directions:
		var position_name_to:String = Chess.direction_to(position_name_from, iter)
		while position_name_to && (!state.has_piece(position_name_to) || state.get_piece(position_name_from).group != state.get_piece(position_name_to).group):
			output.push_back(Move.create(position_name_from, position_name_to, "", "Default"))
			if state.has_piece(position_name_to) && state.get_piece(position_name_from).group != state.get_piece(position_name_to).group:
				break
			position_name_to = Chess.direction_to(position_name_to, iter)
	return output

static func get_value(position_name:String, group:int) -> float:
	const position_value:PackedInt32Array = [
		6,   1,  -8,-104,  69,  24,  88,  26,
		 14,  32,  60, -10,  20,  76,  57,  24,
		 -2,  43,  32,  60,  72,  63,  43,   2,
		  1, -16,  22,  17,  25,  20, -13,  -6,
		-14, -15,  -2,  -5,  -1, -10, -20, -22,
		-30,  -6, -13, -11, -16, -11, -16, -27,
		-36, -18,   0, -19, -15, -15, -21, -38,
		-39, -30, -31, -13, -31, -36, -34, -42]
	var piece_position:Vector2i = Chess.to_piece_position(position_name)
	if group == 1:
		piece_position.y = 7 - piece_position.y
	return (position_value[piece_position.x + (7 - piece_position.y) * 8] / 100.0 + 9.29) * (1 if group == 0 else -1)
