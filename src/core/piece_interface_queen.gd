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

static func create_event(state:ChessState, move:Move) -> Array[ChessEvent]:
	var output:Array[ChessEvent] = []
	if state.has_piece(move.position_name_to):
		output.push_back(ChessEvent.CapturePiece.create(move.position_name_to, state.get_piece(move.position_name_to)))
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
	output.push_back(ChessEvent.MovePiece.create(move.position_name_from, move.position_name_to))
	return output

static func get_valid_move(state:ChessState, position_name_from:String) -> Array[Move]:
	var directions:PackedVector2Array = [Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1)]
	var output:Array[Move] = []
	var from_piece:Piece = state.get_piece(position_name_from)
	for iter:Vector2i in directions:
		var position_name_to:String = Chess.direction_to(position_name_from, iter)
		var to_has_piece:bool = state.has_piece(position_name_to)
		var to_piece:Piece = state.get_piece(position_name_to) if to_has_piece else null
		while position_name_to && (!to_has_piece || from_piece.group != to_piece.group):
			output.push_back(Move.create(position_name_from, position_name_to, "", "Default"))
			if to_has_piece && from_piece.group != to_piece.group:
				break
			position_name_to = Chess.direction_to(position_name_to, iter)
			to_has_piece = state.has_piece(position_name_to)
			to_piece = state.get_piece(position_name_to) if to_has_piece else null
	return output
