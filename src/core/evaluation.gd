extends Object
class_name Evaluation	# 接口

static func get_end_type(_state:ChessState) -> String:
	return ""

static func get_piece_instance(_by:int, _piece:int) -> PieceInstance:
	return null

static func generate_move(_state:ChessState, _group:int) -> PackedInt32Array:
	return []

static func create_event(_state:ChessState, _move:int) -> Array[ChessEvent]:
	return []

static func evaluate_events(_state:ChessState, _events:Array[ChessEvent]) -> int:
	return 0

static func search(_state:ChessState, _depth:int = 10, _group:int = 0) -> Dictionary:
	return {}
