extends PieceInterface
class_name PieceInterfaceCat

static func get_name() -> String:
	return "Cat"

static func create_instance(position_name:String, group:int) -> PieceInstance:
	var packed_scene:PackedScene = load("res://scene/piece_feral_cat.tscn")
	var instance:PieceInstance = packed_scene.instantiate()
	instance.position_name = position_name
	instance.group = group
	return instance

static func create_event(state:ChessState, move:Move) -> Array[ChessEvent]:
	var output:Array[ChessEvent] = []
	output.push_back(ChessEvent.MovePiece.create(move.position_name_from, move.position_name_to))
	return output

static func get_valid_move(state:ChessState, position_name_from:String) -> Array[Move]:
	var directions:PackedVector2Array = [Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1)]
	var output:Array[Move] = []
	for iter:Vector2i in directions:
		var position_name_to:String = Chess.direction_to(position_name_from, iter)
		if !position_name_to || state.has_piece(position_name_to):
			continue
		output.push_back(Move.create(position_name_from, position_name_to, "", "Default"))
	return output
