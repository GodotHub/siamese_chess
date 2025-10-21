extends Path3D
class_name MarkerTeleport

@export var from_level:Level = null
@export var to_level:Level = null

func _ready() -> void:
	var from:int = Chess.to_position_int(from_level.chessboard.get_position_name(global_position))
	var to:int = Chess.to_position_int(to_level.chessboard.get_position_name(to_global(curve.get_point_position(curve.get_point_count() - 1))))
	from_level.teleport.get_or_add(from, {"to": 0, "level": null})["to"] = to
	from_level.teleport.get_or_add(from, {"to": 0, "level": null})["level"] = to_level
	to_level.teleport.get_or_add(to, {"to": 0, "level": null})["to"] = from
	to_level.teleport.get_or_add(to, {"to": 0, "level": null})["level"] = from_level
