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

static func create_event(state:ChessState, move:Move) -> Array[ChessEvent]:
	var output:Array[ChessEvent] = []
	var forward:Vector2i = Vector2i(0, 1) if state.get_piece(move.position_name_from).group == 0 else Vector2i(0, -1)
	if Chess.to_piece_position(move.position_name_to) - Chess.to_piece_position(move.position_name_from) == forward * 2:
		output.push_back(ChessEvent.ChangeExtra.create(2, state.get_extra(2), Chess.direction_to(move.position_name_from, forward)))
	if state.has_piece(move.position_name_to):
		output.push_back(ChessEvent.CapturePiece.create(move.position_name_to, state.get_piece(move.position_name_to)))
	if move.position_name_to == state.get_extra(2):
		var captured_position_name:String = Chess.direction_to(move.position_name_to, -forward)
		output.push_back(ChessEvent.CapturePiece.create(captured_position_name, state.get_piece(captured_position_name)))
	if state.get_extra(5).contains(move.position_name_to):
		if state.get_piece(move.position_name_from).group == 0:
			if state.has_piece("c8") && state.get_piece("c8").class_type.get_name() == "King":
				output.push_back(ChessEvent.CapturePiece.create("c8", state.get_piece("c8")))
			if state.has_piece("g8") && state.get_piece("g8").class_type.get_name() == "King":
				output.push_back(ChessEvent.CapturePiece.create("g8", state.get_piece("g8")))
		else:
			if state.has_piece("c1") && state.get_piece("c1").class_type.get_name() == "King":
				output.push_back(ChessEvent.CapturePiece.create("c1", state.get_piece("c1")))
			if state.has_piece("g1") && state.get_piece("g1").class_type.get_name() == "King":
				output.push_back(ChessEvent.CapturePiece.create("g1", state.get_piece("g1")))
	if move.extra:
		match move.extra:
			"Q":
				output.push_back(ChessEvent.AddPiece.create(move.position_name_to, Piece.create(PieceInterfaceQueen, state.get_piece(move.position_name_from).group)))
			"R":
				output.push_back(ChessEvent.AddPiece.create(move.position_name_to, Piece.create(PieceInterfaceRook, state.get_piece(move.position_name_from).group)))
			"N":
				output.push_back(ChessEvent.AddPiece.create(move.position_name_to, Piece.create(PieceInterfaceKnight, state.get_piece(move.position_name_from).group)))
			"B":
				output.push_back(ChessEvent.AddPiece.create(move.position_name_to, Piece.create(PieceInterfaceBishop, state.get_piece(move.position_name_from).group)))
		output.push_back(ChessEvent.CapturePiece.create(move.position_name_from, state.get_piece(move.position_name_from)))
	else:
		output.push_back(ChessEvent.MovePiece.create(move.position_name_from, move.position_name_to))
	return output

static func get_valid_move(state:ChessState, position_name_from:String) -> Array[Move]:
	var output:Array[Move] = []
	var group:int = state.get_piece(position_name_from).group
	var forward:Vector2i = Vector2i(0, 1) if group == 0 else Vector2i(0, -1)
	var on_start:bool = group == 0 && position_name_from[1] == "2" || group == 1 && position_name_from[1] == "7"
	var position_name_to:String = Chess.direction_to(position_name_from, forward)
	var position_name_to_2:String = Chess.direction_to(position_name_from, forward * 2)
	var position_name_to_l:String = Chess.direction_to(position_name_to, Vector2i(1, 0))
	var position_name_to_r:String = Chess.direction_to(position_name_to, Vector2i(-1, 0))
	var can_en_passant:bool = state.get_extra(2) != "-" && (group == 0 && state.get_extra(2)[1] == "6" || group == 1 && state.get_extra(2)[1] == "3")
	if position_name_to && !state.has_piece(position_name_to):
		if group == 0 && position_name_to[1] == "8" || group == 1 && position_name_to[1] == "1":
			output.push_back(Move.create(position_name_from, position_name_to, "Q", "Promote to Queen"))
			output.push_back(Move.create(position_name_from, position_name_to, "R", "Promote to Rook"))
			output.push_back(Move.create(position_name_from, position_name_to, "N", "Promote to Knight"))
			output.push_back(Move.create(position_name_from, position_name_to, "B", "Promote to Bishop"))
		else:
			output.push_back(Move.create(position_name_from, position_name_to, "", "Default"))
		if on_start && !state.has_piece(position_name_to_2):
			output.push_back(Move.create(position_name_from, position_name_to_2, "", "Default"))
	if position_name_to_l && (state.has_piece(position_name_to_l) && group != state.get_piece(position_name_to_l).group || can_en_passant && position_name_to_l == state.get_extra(2)):
		if group == 0 && position_name_to_l[1] == "8" || group == 1 && position_name_to_l[1] == "1":
			output.push_back(Move.create(position_name_from, position_name_to_l, "Q", "Promote to Queen"))
			output.push_back(Move.create(position_name_from, position_name_to_l, "R", "Promote to Rook"))
			output.push_back(Move.create(position_name_from, position_name_to_l, "N", "Promote to Knight"))
			output.push_back(Move.create(position_name_from, position_name_to_l, "B", "Promote to Bishop"))
		else:
			output.push_back(Move.create(position_name_from, position_name_to_l, "", "Default"))
	if position_name_to_r && (state.has_piece(position_name_to_r) && group != state.get_piece(position_name_to_r).group || can_en_passant && position_name_to_r == state.get_extra(2)):
		if group == 0 && position_name_to_r[1] == "8" || group == 1 && position_name_to_r[1] == "1":
			output.push_back(Move.create(position_name_from, position_name_to_r, "Q", "Promote to Queen"))
			output.push_back(Move.create(position_name_from, position_name_to_r, "R", "Promote to Rook"))
			output.push_back(Move.create(position_name_from, position_name_to_r, "N", "Promote to Knight"))
			output.push_back(Move.create(position_name_from, position_name_to_r, "B", "Promote to Bishop"))
		else:
			output.push_back(Move.create(position_name_from, position_name_to_r, "", "Default"))
	return output
