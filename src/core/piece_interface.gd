extends Object
class_name PieceInterface

static func get_name() -> String:
	return "Null"
static func create_instance(_position_name:String, _group:int) -> PieceInstance:
	return null
static func create_event(_state:ChessState, _move:Move) -> Array[ChessEvent]:
	return []
static func get_valid_move(_state:ChessState, _position_name_from:String) -> Array[Move]:
	return []
