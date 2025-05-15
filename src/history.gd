extends Node3D

var history:PackedStringArray = ["", ""]
var state:ChessState = null

func push_move(move:Move) -> void:
	history.push_back(move.position_name_from + "->" + move.position_name_to + " " + move.comment)
	update_table()

func update_table() -> void:
	$sub_viewport/rich_text_label.text = "[table=3]"
	for i:int in range(history.size()):
		if i % 2 == 0:
			$sub_viewport/rich_text_label.text += "[cell]%d[/cell]" % (i / 2)
		$sub_viewport/rich_text_label.text += "[cell]%s[/cell]" % history[i]

func add_blank_line() -> void:
	history.push_back("")
	history.push_back("")
