extends Object
class_name Evaluation	# 接口

static func get_end_type(_state:ChessState) -> String:
	return ""

static func evaluate_events(_state:ChessState, _events:Array[ChessEvent]) -> int:
	return 0

static func search(_state:ChessState, _depth:int = 10, _group:int = 0) -> Dictionary:
	return {}
