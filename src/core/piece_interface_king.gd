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

static func create_event(state:ChessState, move:Move) -> Array[ChessEvent]:
	var output:Array[ChessEvent] = []
	if state.has_piece(move.position_name_to):
		output.push_back(ChessEvent.CapturePiece.create(move.position_name_to, state.get_piece(move.position_name_to)))
	if move.position_name_to in state.get_extra(5):
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
	if state.get_piece(move.position_name_from).group == 0:
		var castle_text:String = ("k" if state.get_extra(1).contains("k") else "") + ("q" if state.get_extra(1).contains("q") else "")
		output.push_back(ChessEvent.ChangeExtra.create(1, state.get_extra(1), castle_text))
	else:
		var castle_text:String = ("K" if state.get_extra(1).contains("K") else "") + ("Q" if state.get_extra(1).contains("Q") else "")
		output.push_back(ChessEvent.ChangeExtra.create(1, state.get_extra(1), castle_text))
	output.push_back(ChessEvent.MovePiece.create(move.position_name_from, move.position_name_to))
	if move.extra:
		if move.position_name_to == "g1":
			output.push_back(ChessEvent.MovePiece.create(move.extra, "f1"))
		if move.position_name_to == "c1":
			output.push_back(ChessEvent.MovePiece.create(move.extra, "d1"))
		if move.position_name_to == "g8":
			output.push_back(ChessEvent.MovePiece.create(move.extra, "f8"))
		if move.position_name_to == "c8":
			output.push_back(ChessEvent.MovePiece.create(move.extra, "d8"))
		# 在move.position_name_from到move.position_name_to之间设置king_passant
		var piece_position_from:Vector2i = Chess.to_piece_position(move.position_name_from)
		var piece_position_to:Vector2i = Chess.to_piece_position(move.position_name_to)
		var king_passant:String = ""
		for i:int in range(piece_position_from.x, piece_position_to.x + (1 if piece_position_from.x < piece_position_to.x else -1), 1 if piece_position_from.x < piece_position_to.x else -1):
			for j:int in range(piece_position_from.y, piece_position_to.y + (1 if piece_position_from.y < piece_position_to.y else -1), 1 if piece_position_from.y < piece_position_to.y else -1):
				king_passant += Chess.to_position_name(Vector2(i, j))
		output.push_back(ChessEvent.ChangeExtra.create(5, state.get_extra(5), king_passant))
	return output

static func get_valid_move(state:ChessState, position_name_from:String) -> Array[Move]:
	var directions:PackedVector2Array = [Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1)]
	var output:Array[Move] = []
	for iter:Vector2i in directions:
		var position_name_to:String = Chess.direction_to(position_name_from, iter)
		if !position_name_to || state.has_piece(position_name_to) && state.get_piece(position_name_from).group == state.get_piece(position_name_to).group:
			continue
		output.push_back(Move.create(position_name_from, position_name_to, "", "Default"))
	return output
