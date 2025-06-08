extends Object
class_name PieceInterface

static func get_name() -> String:
	return "Null"
static func create_instance(_from:int, _group:int) -> PieceInstance:
	return null
static func create_event(_state:ChessState, _move:int) -> Array[ChessEvent]:
	return []
static func get_valid_move(_state:ChessState, _from:int) -> PackedInt32Array:
	return []
