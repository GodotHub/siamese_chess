extends Node3D

var engine:ChessEngine = null
var history_state:PackedInt32Array = []

func _ready() -> void:
	$player.set_initial_interact($interact)

func move_player(pos:Vector3) -> void:
	var tween:Tween = create_tween()
	tween.tween_property($player, "global_position", pos, 0.3).set_trans(Tween.TRANS_SINE)
