extends PieceInterface
class_name PieceInterfaceKing

const directions:PackedInt32Array = [-17, -16, -15, -1, 1, 15, 16, 17]

static func get_name() -> String:
	return "King"

static func create_instance(from:int, group:int) -> PieceInstance:
	var packed_scene:PackedScene = load("res://scene/piece_king.tscn")
	var instance:PieceInstance = packed_scene.instantiate()
	instance.position_name = Chess.to_position_name(from)
	instance.group = group
	return instance

static func create_event(_state:ChessState, _move:int) -> Array[ChessEvent]:
	var output:Array[ChessEvent] = []
	if _state.has_piece(Move.to(_move)):
		output.push_back(ChessEvent.CapturePiece.create(Move.to(_move), _state.get_piece(Move.to(_move))))
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
	if _state.get_piece(Move.from(_move)).group == 0:
		var castle_text:String = ("k" if _state.get_extra(1).contains("k") else "") + ("q" if _state.get_extra(1).contains("q") else "")
		output.push_back(ChessEvent.ChangeExtra.create(1, _state.get_extra(1), castle_text))
	else:
		var castle_text:String = ("K" if _state.get_extra(1).contains("K") else "") + ("Q" if _state.get_extra(1).contains("Q") else "")
		output.push_back(ChessEvent.ChangeExtra.create(1, _state.get_extra(1), castle_text))
	output.push_back(ChessEvent.MovePiece.create(Move.from(_move), Move.to(_move)))
	if Move.extra(_move):
		var king_passant:String = ""
		if Move.to(_move) == Chess.g1:
			output.push_back(ChessEvent.MovePiece.create(Chess.h1, Chess.f1))
			king_passant = "e1f1g1"
		if Move.to(_move) == Chess.c1:
			output.push_back(ChessEvent.MovePiece.create(Chess.a1, Chess.d1))
			king_passant = "e1d1c1"
		if Move.to(_move) == Chess.g8:
			output.push_back(ChessEvent.MovePiece.create(Chess.h8, Chess.f8))
			king_passant = "e8f8g8"
		if Move.to(_move) == Chess.c8:
			output.push_back(ChessEvent.MovePiece.create(Chess.a8, Chess.d8))
			king_passant = "e8d8c8"
		output.push_back(ChessEvent.ChangeExtra.create(5, _state.get_extra(5), king_passant))
	return output

static func get_valid_move(_state:ChessState, _from:int) -> PackedInt32Array:
	var output:PackedInt32Array = []
	for iter:int in directions:
		var to:int = _from + iter
		if to & 0x88 || _state.has_piece(to) && _state.get_piece(_from).group == _state.get_piece(to).group:
			continue
		output.push_back(Move.create(_from, to, 0))
	return output
