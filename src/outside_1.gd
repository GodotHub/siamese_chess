extends "res://src/outside.gd"

func _ready() -> void:
	super._ready()
	$level.interact_list[0x12] = {"对话": interact_with_carnation}
	$level.interact_list[0x13] = {"对话": interact_with_carnation}
	$level.interact_list[0x23] = {"对话": interact_with_carnation}
	$level.interact_list[0x33] = {"对话": interact_with_carnation}
	$level.interact_list[0x32] = {"对话": interact_with_carnation}

func interact_with_carnation() -> void:
	Dialog.push_dialog("……", true, true)
	await Dialog.on_next
