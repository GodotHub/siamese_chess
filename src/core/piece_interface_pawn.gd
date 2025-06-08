extends PieceInterface
class_name PieceInterfacePawn

static func get_name() -> String:
	return "Pawn"

static func create_instance(from:int, group:int) -> PieceInstance:
	var packed_scene:PackedScene = load("res://scene/piece_pawn.tscn")
	var instance:PieceInstance = packed_scene.instantiate()
	instance.position_name = Chess.to_position_name(from)
	instance.group = group
	return instance

static func create_event(_state:ChessState, _move:int) -> Array[ChessEvent]:
	var output:Array[ChessEvent] = []
	var forward:int = -16 if _state.get_piece(Move.from(_move)).group == 0 else 16
	if Move.to(_move) - Move.from(_move) == forward * 2:
		output.push_back(ChessEvent.ChangeExtra.create(2, _state.get_extra(2), Chess.to_position_name(Move.from(_move) + forward)))
	if _state.has_piece(Move.to(_move)):
		output.push_back(ChessEvent.CapturePiece.create(Move.to(_move), _state.get_piece(Move.to(_move))))
	if Chess.to_position_name(Move.to(_move)) == _state.get_extra(2):
		var captured:int = Move.to(_move) - forward
		output.push_back(ChessEvent.CapturePiece.create(captured, _state.get_piece(captured)))
	if _state.get_extra(5).contains(Chess.to_position_name(Move.to(_move))):
		if _state.get_piece(Move.from(_move)).group == 0:
			if _state.has_piece(Chess.c8) && _state.get_piece(Chess.c8).class_type.get_name() == "King":
				output.push_back(ChessEvent.CapturePiece.create(Chess.c8, _state.get_piece(Chess.c8)))
			if _state.has_piece(Chess.g8) && _state.get_piece(Chess.g8).class_type.get_name() == "King":
				output.push_back(ChessEvent.CapturePiece.create(Chess.g8, _state.get_piece(Chess.g8)))
		else:
			if _state.has_piece(Chess.c1) && _state.get_piece(Chess.c1).class_type.get_name() == "King":
				output.push_back(ChessEvent.CapturePiece.create(Chess.c1, _state.get_piece(Chess.c1)))
			if _state.has_piece(Chess.g1) && _state.get_piece(Chess.g1).class_type.get_name() == "King":
				output.push_back(ChessEvent.CapturePiece.create(Chess.g1, _state.get_piece(Chess.g1)))

	if Move.extra(_move):
		match Move.extra(_move):
			81:
				output.push_back(ChessEvent.AddPiece.create(Move.to(_move), Piece.create(PieceInterfaceQueen, _state.get_piece(Move.from(_move)).group)))
			82:
				output.push_back(ChessEvent.AddPiece.create(Move.to(_move), Piece.create(PieceInterfaceRook, _state.get_piece(Move.from(_move)).group)))
			78:
				output.push_back(ChessEvent.AddPiece.create(Move.to(_move), Piece.create(PieceInterfaceKnight, _state.get_piece(Move.from(_move)).group)))
			66:
				output.push_back(ChessEvent.AddPiece.create(Move.to(_move), Piece.create(PieceInterfaceBishop, _state.get_piece(Move.from(_move)).group)))
		output.push_back(ChessEvent.CapturePiece.create(Move.from(_move), _state.get_piece(Move.from(_move))))
	else:
		output.push_back(ChessEvent.MovePiece.create(Move.from(_move), Move.to(_move)))
	return output

static func get_valid_move(_state:ChessState, _from:int) -> PackedInt32Array:
	var output:PackedInt32Array = []
	var group:int = _state.get_piece(_from).group
	var forward:int = -16 if _state.get_piece(_from).group == 0 else 16
	var on_start:bool = group == 0 && _from / 16 == 6 || group == 1 && _from / 16 == 1
	var to:int = _from + forward
	var to_2:int = _from + forward * 2
	var to_l:int = to + 1
	var to_r:int = to + -1
	var can_en_passant:bool = _state.get_extra(2) != "-" && (group == 0 && _state.get_extra(2)[1] == "6" || group == 1 && _state.get_extra(2)[1] == "3")
	if !(to & 0x88) && !_state.has_piece(to):
		if group == 0 && to / 16 == 0 || group == 1 && to / 16 == 7:
			output.push_back(Move.create(_from, to, 81))
			output.push_back(Move.create(_from, to, 82))
			output.push_back(Move.create(_from, to, 78))
			output.push_back(Move.create(_from, to, 66))
		else:
			output.push_back(Move.create(_from, to, 0))
		if on_start && !_state.has_piece(to_2):
			output.push_back(Move.create(_from, to_2, 0))
	if !(to_l & 0x88) && (_state.has_piece(to_l) && group != _state.get_piece(to_l).group || can_en_passant && Chess.to_position_name(to_l) == _state.get_extra(2)):
		if group == 0 && to_l / 16 == 0 || group == 1 && to_l / 16 == 7:
			output.push_back(Move.create(_from, to_l, 1))
			output.push_back(Move.create(_from, to_l, 2))
			output.push_back(Move.create(_from, to_l, 3))
			output.push_back(Move.create(_from, to_l, 4))
		else:
			output.push_back(Move.create(_from, to_l, 0))
	if !(to_r & 0x88) && (_state.has_piece(to_r) && group != _state.get_piece(to_r).group || can_en_passant && Chess.to_position_name(to_r) == _state.get_extra(2)):
		if group == 0 && to_r / 16 == 0 || group == 1 && to_r / 16 == 7:
			output.push_back(Move.create(_from, to_r, 1))
			output.push_back(Move.create(_from, to_r, 2))
			output.push_back(Move.create(_from, to_r, 3))
			output.push_back(Move.create(_from, to_r, 4))
		else:
			output.push_back(Move.create(_from, to_r, 0))
	return output
