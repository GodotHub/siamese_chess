extends Node3D

var line:int = 0
var history:PackedStringArray = ["", ""]

func push_navi(position_name_from:String, position_name_to:String) -> void:
	if history[line * 2 + Chess.get_chess_state().get_piece(position_name_to).group]:
		add_blank_line()
	var add_index = line * 2 +  Chess.get_chess_state().get_piece(position_name_to).group
	var output = position_name_from + "->" + position_name_to
	history[add_index] = output
	update_table()

func update_table() -> void:
	$sub_viewport/rich_text_label.text = "[table=3]"
	for i:int in range(line + 1):
		$sub_viewport/rich_text_label.text += "[cell]%d[/cell][cell]%s[/cell][cell]%s[/cell]" % [i + 1, history[i * 2], history[i * 2 + 1]]

func add_blank_line() -> void:
	history.push_back("")
	history.push_back("")
	line += 1
