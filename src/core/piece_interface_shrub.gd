extends PieceInterface
class_name PieceInterfaceShrub

static func get_name() -> String:
	return "Shrub"

static func create_instance(from:int, group:int) -> PieceInstance:
	var packed_scene:PackedScene = load("res://scene/piece_shrub.tscn")
	var instance:PieceInstance = packed_scene.instantiate()
	instance.position_name = Chess.to_position_name(from)
	instance.group = group
	return instance

static func create_event(_state:ChessState, _move:int) -> Array[ChessEvent]:
	var output:Array[ChessEvent] = []
	output.push_back(ChessEvent.MovePiece.create(Move.from(_move), Move.to(_move)))
	return output

static func get_valid_move(_state:ChessState, _from:int) -> PackedInt32Array:
	return []
