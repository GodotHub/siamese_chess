extends PieceInterface
class_name PieceInterfaceShrub

static func get_name() -> String:
	return "Shrub"

static func create_instance(position_name:String, group:int) -> PieceInstance:
	var packed_scene:PackedScene = load("res://scene/piece_shrub.tscn")
	var instance:PieceInstance = packed_scene.instantiate()
	instance.position_name = position_name
	instance.group = group
	return instance

static func create_event(_state:ChessState, move:Move) -> Array[ChessEvent]:
	var output:Array[ChessEvent] = []
	output.push_back(ChessEvent.MovePiece.create(move.position_name_from, move.position_name_to))
	return output

static func get_valid_move(_state:ChessState, _position_name_from:String) -> Array[Move]:
	return []
