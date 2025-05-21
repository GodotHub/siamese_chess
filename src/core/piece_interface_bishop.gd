extends PieceInterface
class_name PieceInterfaceBishop

static func get_name() -> String:
	return "Bishop"

static func create_instance(position_name:String, group:int) -> PieceInstance:
	var packed_scene:PackedScene = load("res://scene/piece_bishop.tscn")
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
	var directions:PackedVector2Array = [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]
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
		-59, -78, -82, -76, -23,-107, -37, -50,
		-11,  20,  35, -42, -39,  31,   2, -22,
		 -9,  39, -32,  41,  52, -10,  28, -14,
		 25,  17,  20,  34,  26,  25,  15,  10,
		 13,  10,  17,  23,  17,  16,   0,   7,
		 14,  25,  24,  15,   8,  25,  20,  15,
		 19,  20,  11,   6,   7,   6,  20,  16,
		 -7,   2, -15, -12, -14, -15, -10, -10]
	var piece_position:Vector2i = Chess.to_piece_position(position_name)
	if group == 1:
		piece_position.y = 7 - piece_position.y
	return (position_value[piece_position.x + (7 - piece_position.y) * 8] / 100.0) + 3.2 * (1 if group == 0 else -1)
