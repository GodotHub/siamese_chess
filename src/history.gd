extends Document

var state:State = null
var history:PackedStringArray = []

func set_state(_state:State) -> void:
	state = _state.duplicate()
	history.clear()
	update_table()

func push_move(move:int) -> void:
	if history.size() >= 60:
		return
	history.push_back(RuleStandard.get_move_name(state, move))
	RuleStandard.apply_move(state, move)
	update_table()

func update_table() -> void:
	$chessboard_flat.set_state(state)
	for i:int in range(history.size()):
		if i % 2 == 0:
			get_node("white/label_%d" % (i / 2 + 1)).text = history[i]
		else:
			get_node("black/label_%d" % (i / 2 + 1)).text = history[i]

func add_blank_line() -> void:
	history.push_back("")
	history.push_back("")
