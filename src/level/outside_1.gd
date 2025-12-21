extends "res://src/level/outside.gd"


func _ready() -> void:
	super._ready()
	interact_list[0x12] = {"对话": interact_with_carnation}
	title[0x12] = "康乃馨"
	interact_list[0x13] = {"对话": interact_with_carnation}
	title[0x13] = "康乃馨"
	interact_list[0x23] = {"对话": interact_with_carnation}
	title[0x23] = "康乃馨"
	interact_list[0x33] = {"对话": interact_with_carnation}
	title[0x33] = "康乃馨"
	interact_list[0x32] = {"对话": interact_with_carnation}
	title[0x32] = "康乃馨"

func interact_with_carnation() -> void:
	$player.force_set_camera($camera_carnation)
	match randi() % 2:
		0:
			Dialog.push_dialog("这片区域只有两块石头，其中一块在我身后。", "", true, true)
			await Dialog.on_next
			Dialog.push_dialog("被石头挡住的去路，需要侧身通过。", "", true, true)
			$player.force_set_camera($camera_carnation_2)
			await Dialog.on_next
		1:
			Dialog.push_dialog("您有和玉兰打过招呼吗？", "", true, true)
			await Dialog.on_next
			Dialog.push_dialog("期待您能和他过过招。", "", true, true)
			await Dialog.on_next
	$player.force_set_camera($camera)
	change_state.call_deferred("explore_idle")
