extends Object
class_name PieceInterface

static func get_name() -> String:
	return "Null"
static func create_instance(_position_name:String, _group:int) -> PieceInstance:
	return null
static func execute_move(_state:ChessState, _move:Move) -> void:
	pass
static func get_valid_move(_state:ChessState, _position_name_from:String) -> Array[Move]:
	return []
static func get_value() -> float:
	return 0