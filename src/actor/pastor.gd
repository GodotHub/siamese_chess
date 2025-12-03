extends Actor

func _ready() -> void:
	$animation_tree.get("parameters/playback").start("battle_idle")

func play_animation(anim:String) -> void:
	$animation_tree.get("parameters/playback").start(anim)
