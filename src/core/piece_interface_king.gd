extends PieceInterface
class_name PieceInterfaceKing

static func get_name() -> String:
	return "King"

static func create_instance(position_name:String, group:int) -> PieceInstance:
	var packed_scene:PackedScene = load("res://scene/piece_king.tscn")
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
			state.capture_piece("g8")	# 两边全吃了也行，虽然不够优雅
		else:
			state.capture_piece("c1")
			state.capture_piece("g1")

	if state.get_piece(move.position_name_from).group == 0:
		if state.extra[1].find("K") != -1:
			state.extra[1] = state.extra[1].erase(state.extra[1].find("K"), 1)
		if state.extra[1].find("Q") != -1:
			state.extra[1] = state.extra[1].erase(state.extra[1].find("Q"), 1)
	else:
		if state.extra[1].find("k") != -1:
			state.extra[1] = state.extra[1].erase(state.extra[1].find("k"), 1)
		if state.extra[1].find("q") != -1:
			state.extra[1] = state.extra[1].erase(state.extra[1].find("q"), 1)
	state.move_piece(move.position_name_from, move.position_name_to)
	if move.extra:
		if move.position_name_to == "g1":
			state.move_piece(move.extra, "f1")
		if move.position_name_to == "c1":
			state.move_piece(move.extra, "d1")
		if move.position_name_to == "g8":
			state.move_piece(move.extra, "f8")
		if move.position_name_to == "c8":
			state.move_piece(move.extra, "d8")
		# 在move.position_name_from到move.position_name_to之间设置king_passant
		var piece_position_from:Vector2i = Chess.to_piece_position(move.position_name_from)
		var piece_position_to:Vector2i = Chess.to_piece_position(move.position_name_to)
		state.extra[5] = ""
		for i:int in range(piece_position_from.x, piece_position_to.x + (1 if piece_position_from.x < piece_position_to.x else -1), 1 if piece_position_from.x < piece_position_to.x else -1):
			for j:int in range(piece_position_from.y, piece_position_to.y + (1 if piece_position_from.y < piece_position_to.y else -1), 1 if piece_position_from.y < piece_position_to.y else -1):
				state.extra[5] += Chess.to_position_name(Vector2(i, j))

static func get_valid_move(state:ChessState, position_name_from:String) -> Array[Move]:
	var directions:PackedVector2Array = [Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1)]
	var output:Array[Move] = []
	for iter:Vector2i in directions:
		var position_name_to:String = Chess.direction_to(position_name_from, iter)
		if !position_name_to || state.has_piece(position_name_to) && state.get_piece(position_name_from).group == state.get_piece(position_name_to).group:
			continue
		output.push_back(Move.create(position_name_from, position_name_to, "", "Default"))
	return output

static func get_value(position_name:String, group:int) -> float:
	const position_value:PackedInt32Array = [
		4,  54,  47, -99, -99,  60,  83, -62,
		-32,  10,  55,  56,  56,  55,  10,   3,
		-62,  12, -57,  44, -67,  28,  37, -31,
		-55,  50,  11,  -4, -19,  13,   0, -49,
		-55, -43, -52, -28, -51, -47,  -8, -50,
		-47, -42, -43, -79, -64, -32, -29, -32,
		 -4,   3, -14, -50, -57, -18,  13,   4,
		 17,  30,  -3, -14,   6,  -1,  40,  18
	]
	var piece_position:Vector2i = Chess.to_piece_position(position_name)
	if group == 1:
		piece_position.y = 7 - piece_position.y
	return (position_value[piece_position.x + (7 - piece_position.y) * 8] / 100.0 + 600.0) * (1 if group == 0 else -1)
