extends InspectableItem

var history:PackedStringArray = ["", ""]

func push_move(move:int) -> void:
	history.push_back("%x" % move)
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
