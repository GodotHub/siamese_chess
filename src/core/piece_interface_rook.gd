extends PieceInterface
class_name PieceInterfaceRook

const directions:PackedInt32Array = [-1, 1, -16, 16]

static func get_name() -> String:
	return "Rook"

static func create_instance(from:int, group:int) -> PieceInstance:
	var packed_scene:PackedScene = load("res://scene/piece_rook.tscn")
	var instance:PieceInstance = packed_scene.instantiate()
	instance.position_name = Chess.to_position_name(from)
	instance.group = group
	return instance

static func create_event(_state:ChessState, _move:int) -> Array[ChessEvent]:
	var output:Array[ChessEvent] = []
	if Move.from(_move) % 16 >= 4:
		if _state.get_piece(Move.from(_move)).group == 0 && _state.get_extra(1).find("K") != -1:
			output.push_back(ChessEvent.ChangeExtra.create(1, _state.get_extra(1), _state.get_extra(1).erase(_state.get_extra(1).find("K"), 1)))
		elif _state.get_piece(Move.from(_move)).group == 1 && _state.get_extra(1).find("k") != -1:
			output.push_back(ChessEvent.ChangeExtra.create(1, _state.get_extra(1), _state.get_extra(1).erase(_state.get_extra(1).find("k"), 1)))
	elif Move.from(_move) % 16 <= 3:
		if _state.get_piece(Move.from(_move)).group == 0 && _state.get_extra(1).find("Q") != -1:
			output.push_back(ChessEvent.ChangeExtra.create(1, _state.get_extra(1), _state.get_extra(1).erase(_state.get_extra(1).find("Q"), 1)))
		elif _state.get_piece(Move.from(_move)).group == 1 && _state.get_extra(1).find("q") != -1:
			output.push_back(ChessEvent.ChangeExtra.create(1, _state.get_extra(1), _state.get_extra(1).erase(_state.get_extra(1).find("q"), 1)))
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
	output.push_back(ChessEvent.MovePiece.create(Move.from(_move), Move.to(_move)))
	return output

static func get_valid_move(_state:ChessState, _from:int) -> PackedInt32Array:
	var output:PackedInt32Array = []
	var from_piece:Piece = _state.get_piece(_from)
	for iter:int in directions:
		var to:int = _from + iter
		var to_has_piece:bool = _state.has_piece(to)
		var to_piece:Piece = _state.get_piece(to) if to_has_piece else null
		while !(to & 0x88) && (!to_has_piece || from_piece.group != to_piece.group):
			output.push_back(Move.create(_from, to, 0))
			if !(to & 0x88) && to_has_piece && from_piece.group != to_piece.group:
				break
			to += iter
			to_has_piece = _state.has_piece(to)
			to_piece = _state.get_piece(to) if to_has_piece else null
			if to_has_piece && from_piece.group == to_piece.group && to_piece.class_type.get_name() == "King":
				var group:int = to_piece.group
				if _from % 16 >= 4 && (group == 0 && _state.get_extra(1).contains("K") || group == 1 && _state.get_extra(1).contains("k")):
					output.push_back(Move.create(to, Chess.g1 if group == 0 else Chess.g8, 75))
				elif _from % 16 <= 3 && (group == 0 && _state.get_extra(1).contains("Q") || group == 1 && _state.get_extra(1).contains("q")):
					output.push_back(Move.create(to, Chess.c1 if group == 0 else Chess.c8, 81))
	return output
