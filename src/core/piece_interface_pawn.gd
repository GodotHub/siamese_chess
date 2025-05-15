extends PieceInterface
class_name PieceInterfacePawn

static func get_name() -> String:
	return "Pawn"

static func create_instance(position_name:String, group:int) -> PieceInstance:
	var packed_scene:PackedScene = load("res://scene/piece_pawn.tscn")
	var instance:PieceInstance = packed_scene.instantiate()
	instance.position_name = position_name
	instance.group = group
	return instance

static func execute_move(state:ChessState, move:Move) -> void:
	var forward:Vector2i = Vector2i(0, 1) if state.get_piece(move.position_name_from).group == 0 else Vector2i(0, -1)
	if Chess.to_piece_position(move.position_name_to) - Chess.to_piece_position(move.position_name_from) == forward * 2:
		state.extra[2] = Chess.direction_to(move.position_name_from, forward)
	if state.has_piece(move.position_name_to):
		state.capture_piece(move.position_name_to)
	if move.position_name_to == state.extra[2]:
		var captured_position_name:String = Chess.direction_to(move.position_name_to, -forward)
		state.capture_piece(captured_position_name)
	if move.position_name_to in state.extra[5]:
		# 直接拿下国王判定胜利吧（唉）
		if state.get_piece(move.position_name_from).group == 0:
			state.capture_piece("c8")
			state.capture_piece("g8")
		else:
			state.capture_piece("c1")
			state.capture_piece("g1")
	if move.extra:
		match move.extra:
			"Q":
				state.add_piece(move.position_name_to, Piece.create(PieceInterfaceQueen, state.get_piece(move.position_name_from).group))
			"R":
				state.add_piece(move.position_name_to, Piece.create(PieceInterfaceRook, state.get_piece(move.position_name_from).group))
			"N":
				state.add_piece(move.position_name_to, Piece.create(PieceInterfaceKnight, state.get_piece(move.position_name_from).group))
			"B":
				state.add_piece(move.position_name_to, Piece.create(PieceInterfaceBishop, state.get_piece(move.position_name_from).group))
		state.capture_piece(move.position_name_from)
	else:
		state.move_piece(move.position_name_from, move.position_name_to)

static func get_valid_move(state:ChessState, position_name_from:String) -> Array[Move]:
	var output:Array[Move] = []
	var forward:Vector2i = Vector2i(0, 1) if state.get_piece(position_name_from).group == 0 else Vector2i(0, -1)
	var on_start:bool = state.get_piece(position_name_from).group == 0 && position_name_from[1] == "2" || state.get_piece(position_name_from).group == 1 && position_name_from[1] == "7"
	var position_name_to:String = Chess.direction_to(position_name_from, forward)
	var position_name_to_2:String = Chess.direction_to(position_name_from, forward * 2)
	var position_name_to_l:String = Chess.direction_to(position_name_to, Vector2i(1, 0))
	var position_name_to_r:String = Chess.direction_to(position_name_to, Vector2i(-1, 0))
	if position_name_to && !state.has_piece(position_name_to):
		if state.get_piece(position_name_from).group == 0 && position_name_to[1] == "8" || state.get_piece(position_name_from).group == 1 && position_name_to[1] == "1":
			output.push_back(Move.create(position_name_from, position_name_to, "Q", "Promote to Queen"))
			output.push_back(Move.create(position_name_from, position_name_to, "R", "Promote to Rook"))
			output.push_back(Move.create(position_name_from, position_name_to, "N", "Promote to Knight"))
			output.push_back(Move.create(position_name_from, position_name_to, "B", "Promote to Bishop"))
		else:
			output.push_back(Move.create(position_name_from, position_name_to, "", "Default"))
		if on_start && !state.has_piece(position_name_to_2):
			output.push_back(Move.create(position_name_from, position_name_to_2, "", "Default"))
	if position_name_to_l && (state.has_piece(position_name_to_l) && state.get_piece(position_name_from).group != state.get_piece(position_name_to_l).group || position_name_to_l == state.extra[2]):
		if state.get_piece(position_name_from).group == 0 && position_name_to_l[1] == "8" || state.get_piece(position_name_from).group == 1 && position_name_to_l[1] == "1":
			output.push_back(Move.create(position_name_from, position_name_to_l, "Q", "Promote to Queen"))
			output.push_back(Move.create(position_name_from, position_name_to_l, "R", "Promote to Rook"))
			output.push_back(Move.create(position_name_from, position_name_to_l, "N", "Promote to Knight"))
			output.push_back(Move.create(position_name_from, position_name_to_l, "B", "Promote to Bishop"))
		else:
			output.push_back(Move.create(position_name_from, position_name_to_l, "", "Default"))
	if position_name_to_r && (state.has_piece(position_name_to_r) && state.get_piece(position_name_from).group != state.get_piece(position_name_to_r).group || position_name_to_r == state.extra[2]):
		if state.get_piece(position_name_from).group == 0 && position_name_to_r[1] == "8" || state.get_piece(position_name_from).group == 1 && position_name_to_r[1] == "1":
			output.push_back(Move.create(position_name_from, position_name_to_r, "Q", "Promote to Queen"))
			output.push_back(Move.create(position_name_from, position_name_to_r, "R", "Promote to Rook"))
			output.push_back(Move.create(position_name_from, position_name_to_r, "N", "Promote to Knight"))
			output.push_back(Move.create(position_name_from, position_name_to_r, "B", "Promote to Bishop"))
		else:
			output.push_back(Move.create(position_name_from, position_name_to_r, "", "Default"))
	return output
static func get_value() -> float:
	return 1
