extends "res://src/outside.gd"

func _ready() -> void:
	super._ready()
	$level.interact_list[0x12] = {"对话": interact_with_carnation}
	$level.title[0x12] = "康乃馨"
	$level.interact_list[0x13] = {"对话": interact_with_carnation}
	$level.title[0x13] = "康乃馨"
	$level.interact_list[0x23] = {"对话": interact_with_carnation}
	$level.title[0x23] = "康乃馨"
	$level.interact_list[0x33] = {"对话": interact_with_carnation}
	$level.title[0x33] = "康乃馨"
	$level.interact_list[0x32] = {"对话": interact_with_carnation}
	$level.title[0x32] = "康乃馨"

func interact_with_carnation() -> void:
	Dialog.push_dialog("……", true, true)
	$player.force_set_camera($level/camera_carnation)
	await Dialog.on_next
	$player.force_set_camera($level/camera)
