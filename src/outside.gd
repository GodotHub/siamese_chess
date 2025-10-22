extends Node3D

var engine:ChessEngine = null
var history_state:PackedInt32Array = []

func _ready() -> void:
	$level_1.connect("move_camera", $player.move_camera)
	$level_2.connect("move_camera", $player.move_camera)
	$player.move_camera($level_1/camera)
