extends InspectableItem

var state:State = null
var history:PackedStringArray = []
var rule:Rule = null

func _ready() -> void:
	rule = RuleStandard.new()

func set_state(_state:State) -> void:
	state = _state.duplicate()
	history.clear()
	update_table()

func push_move(move:int) -> void:
	if history.size() >= 60:
		return
	history.push_back(rule.get_move_name(state, move))
	rule.apply_move(state, move, state.add_piece, state.capture_piece, state.move_piece, state.set_extra, state.push_history, state.change_score)
	update_table()

func update_table() -> void:
	for i:int in range(history.size()):
		if i % 2 == 0:
			get_node("sub_viewport/white/label_%d" % (i / 2 + 1)).text = history[i]
		else:
			get_node("sub_viewport/black/label_%d" % (i / 2 + 1)).text = history[i]

func add_blank_line() -> void:
	history.push_back("")
	history.push_back("")
