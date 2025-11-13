extends Node3D

var engine:ChessEngine = null
var history_state:PackedInt32Array = []

func _ready() -> void:
	$player.force_set_camera($level/camera)
