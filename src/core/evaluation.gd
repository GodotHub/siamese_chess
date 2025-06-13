extends Object
class_name Evaluation	# 接口

static func get_end_type(_state:ChessState) -> String:
	return ""

static func parse(_str:String) -> ChessState:
	return null

static func stringify(_state:ChessState) -> String:
	return ""

static func get_piece_instance(_by:int, _piece:int) -> PieceInstance:
	return null

static func generate_premove(_state:ChessState, _group:int) -> PackedInt32Array:
	return []

static func generate_move(_state:ChessState, _group:int) -> PackedInt32Array:
	return []

static func apply_move(_state:ChessState, _move:int) -> void:
	pass

static func evaluate_add(_state:ChessState, _by:int, _piece:int) -> int:
	return 0

static func evaluate_move(_state:ChessState, _from:int, _to:int) -> int:
	return 0

static func evaluate_capture(_state:ChessState, _by:int) -> int:
	return 0

static func get_valid_move(_state:ChessState, _group:int) -> PackedInt32Array:
	return []

static func search(_output:Dictionary[int, int], _state:ChessState, _is_timeup:Callable, _group:int = 0) -> void:
	pass
