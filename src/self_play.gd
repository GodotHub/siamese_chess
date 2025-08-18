extends Node3D

var cur_player: int = 0
var cur_epoch: int = 0
var sample_cache: Array[Dictionary] = []
var sample: Array[Dictionary] = []

@export var epoch: int = 0
@onready var chessboard: Chessboard = $"../chessboard"
@onready var white: Violet = $a
@onready var black: Violet = $b

func play():
	var is_end: bool = false
	for i in range(0, epoch):
		while true:
			is_end = await go(white)
			add_sample_cache()
			if is_end:
				add_sample()
				break
			await get_tree().create_timer(0.5).timeout
			is_end = await go(black)
			add_sample_cache()
			if is_end:
				add_sample()
				break
	sample_save_json()
	
func search(ai_node: Violet) -> int:
	ai_node.ai.start_search(chessboard.state, ai_node.group, INF, Callable())
	await ai_node.ai.search_finished
	return ai_node.ai.get_search_result()
	
func go(ai_node: Violet) -> bool:
	var move = await search(ai_node)
	chessboard.execute_move(move)
	return end() != -1

func add_sample():
	sample.append_array(sample_cache)
	sample_cache.clear()

func add_sample_cache():
	sample_cache.append({"x": RuleStandard.stringify(chessboard.state)})
	var score = end();
	if score != -1:
		for i in range(0, sample_cache.size()):
			sample_cache[i]["y"] = score

func sample_save_json():
	var json_str: String = JSON.stringify(sample)
	var file = FileAccess.open("user://sample.json", FileAccess.WRITE)
	file.store_string(json_str)
	file.close()

func on_button_start_pressed() -> void:
	play()
	pass # Replace with function body.

func end():
	var end_type = RuleStandard.get_end_type(chessboard.state);
	if end_type == "checkmate_white":
		return 1
	elif end_type == "checkmate_black":
		return 0
	elif end_type == "stalemate_black" or end_type == "stalemate_white" or \
		end_type == "threefold_repetition" or end_type == "50_moves":
		return 0.5
	else:
		return -1
