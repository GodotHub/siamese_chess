extends InspectableItem
class_name Chessboard

signal move_played(move:int)
signal press_timer()

var mouse_start_position_name:String = ""
var mouse_moved:bool = false
var state:State = null
var valid_move:Dictionary[int, Array] = {}
var valid_premove:Dictionary[int, Array] = {}
var selected:int = -1
var premove:int = -1
var piece_instance:Dictionary[int, PieceInstance] = {}
var rule_standard:RuleStandard = RuleStandard.new()

func _ready() -> void:
	for iter:Node in get_children():
		if iter is Area3D:
			iter.add_user_signal("input")
			iter.connect("input", input)

func input(_from:Node3D, _to:Area3D, _event:InputEvent, _event_position:Vector3, _normal:Vector3) -> void:
	if _event is InputEventMouseButton:
		if _event.pressed && _event.button_index == MOUSE_BUTTON_LEFT:
			finger_on_position(_to.get_name())
			tap_position(_to.get_name())
			mouse_moved = false
			mouse_start_position_name = _to.get_name()
		elif !_event.pressed && mouse_moved && _event.button_index == MOUSE_BUTTON_LEFT:
			tap_position(_to.get_name())
			finger_up()
	if _event is InputEventMouseMotion:
		var position_name:String = _to.get_name()
		if mouse_start_position_name != position_name:
			mouse_moved = true
		finger_on_position(position_name)

func set_state(_state:State) -> void:
	$canvas.clear_move_position()
	$canvas.clear_select_position()
	state = _state
	for key:int in piece_instance:
		piece_instance[key].queue_free()
	piece_instance.clear()
	for i:int in range(128):
		if !state.has_piece(i):
			continue
		add_piece_instance(i, state.get_piece(i))

func get_position_name(_position:Vector3) -> String:
	var chess_pos:Vector2i = Vector2i(int(_position.x + 4) / 1, int(_position.z + 4) / 1)
	return "%c%d" % [chess_pos.x + 97, chess_pos.y + 1]

func convert_name_to_position(_position_name:String) -> Vector3:
	return get_node(_position_name).position

func tap_position(position_name:String) -> void:
	$canvas.clear_select_position()
	$canvas.clear_premove_position()
	premove = -1
	var by:int = Chess.to_position_int(position_name)
	if !is_instance_valid(state):
		return
	if state.get_extra(0) == 1:
		if selected != -1:
			confirm_move(selected, by)
			selected = -1
			return
		if !state.has_piece(by) || !valid_move.has(by):
			return
		for iter:int in valid_move[by]:
			$canvas.draw_select_position($canvas.convert_name_to_position(Chess.to_position_name(Chess.to(iter))))
	else:
		if selected != -1:
			confirm_premove(selected, by)
			selected = -1
			return
		if !state.has_piece(by) || !valid_premove.has(by):
			return
		for iter:int in valid_premove[by]:
			$canvas.draw_premove_position($canvas.convert_name_to_position(Chess.to_position_name(Chess.to(iter))))
	selected = by

func finger_on_position(position_name:String) -> void:
	if !position_name:
		$canvas.clear_pointer_position()
		return
	$canvas.draw_pointer_position($canvas.convert_name_to_position(position_name))

func finger_up() -> void:
	$canvas.clear_pointer_position()

func confirm_premove(from:int, to:int) -> void:
	if from & 0x88 || to & 0x88 || !valid_premove.has(from):
		return
	var move_list:PackedInt32Array = valid_premove[from].filter(func (move:int) -> bool: return to == Chess.to(move))
	if move_list.size() == 0:
		return
	elif move_list.size() > 1:
		var decision_list:PackedStringArray = []
		for iter:int in move_list:
			decision_list.push_back("%c" % Chess.extra(iter))
		var decision_instance:Decision = Decision.create_decision_instance(decision_list, true)
		add_child(decision_instance)
		await decision_instance.decided
		if decision_instance.selected_index == -1:
			return
		premove = move_list[decision_instance.selected_index]
	else:
		premove = move_list[0]
	$canvas.clear_select_position()
	$canvas.clear_premove_position()
	$canvas.draw_premove_position($canvas.convert_name_to_position(Chess.to_position_name(from)))
	$canvas.draw_premove_position($canvas.convert_name_to_position(Chess.to_position_name(to)))

func confirm_move(from:int, to:int) -> void:
	if from & 0x88 || to & 0x88 || !valid_move.has(from):
		return
	var move_list:PackedInt32Array = valid_move[from].filter(func (move:int) -> bool: return to == Chess.to(move))
	if move_list.size() == 0:
		return
	elif move_list.size() > 1:
		var decision_list:PackedStringArray = []
		for iter:int in move_list:
			decision_list.push_back("%c" % Chess.extra(iter))
		var decision_instance:Decision = Decision.create_decision_instance(decision_list, true)
		add_child(decision_instance)
		await decision_instance.decided
		if decision_instance.selected_index == -1:
			return
		execute_move(move_list[decision_instance.selected_index])
	else:
		execute_move(move_list[0])
	$canvas.clear_select_position()

func execute_move(move:int) -> void:
	rule_standard.apply_move(state, move, add_piece_instance, remove_piece_instance, move_piece_instance, Callable(), Callable(), Callable())
	rule_standard.apply_move(state, move, state.add_piece, state.capture_piece, state.move_piece, state.set_extra, state.push_history, state.change_score)
	$canvas.clear_select_position()
	$canvas.clear_premove_position()
	$canvas.clear_move_position()
	$canvas.draw_move_position($canvas.convert_name_to_position(Chess.to_position_name(Chess.from(move))))
	$canvas.draw_move_position($canvas.convert_name_to_position(Chess.to_position_name(Chess.to(move))))
	move_played.emit(move)
	press_timer.emit()
	selected = -1

func set_valid_move(move_list:PackedInt32Array) -> void:
	valid_move.clear()
	for move:int in move_list:
		if !valid_move.has(Chess.from(move)):
			valid_move[Chess.from(move)] = []
		valid_move[Chess.from(move)].push_back(move)
	if premove != -1 && valid_move.has(Chess.from(premove)) && valid_move[Chess.from(premove)].has(premove):
		execute_move(premove)
	premove = -1

func set_valid_premove(move_list:PackedInt32Array) -> void:
	valid_premove.clear()
	for move:int in move_list:
		if !valid_premove.has(Chess.from(move)):
			valid_premove[Chess.from(move)] = []
		valid_premove[Chess.from(move)].push_back(move)

func add_piece_instance(by:int, piece:int) -> void:
	const piece_mapping:Dictionary = {
		"K": {"instance": "res://scene/piece_king.tscn", "group": 0},
		"Q": {"instance": "res://scene/piece_queen.tscn", "group": 0},
		"R": {"instance": "res://scene/piece_rook.tscn", "group": 0},
		"N": {"instance": "res://scene/piece_knight.tscn", "group": 0},
		"B": {"instance": "res://scene/piece_bishop.tscn", "group": 0},
		"P": {"instance": "res://scene/piece_pawn.tscn", "group": 0},
		"k": {"instance": "res://scene/piece_king.tscn", "group": 1},
		"q": {"instance": "res://scene/piece_queen.tscn", "group": 1},
		"r": {"instance": "res://scene/piece_rook.tscn", "group": 1},
		"n": {"instance": "res://scene/piece_knight.tscn", "group": 1},
		"b": {"instance": "res://scene/piece_bishop.tscn", "group": 1},
		"p": {"instance": "res://scene/piece_pawn.tscn", "group": 1},
	}
	var instance:PieceInstance = load(piece_mapping[char(piece)]["instance"]).instantiate()
	instance.chessboard = self
	instance.position_name = Chess.to_position_name(by)
	instance.group = piece_mapping[char(piece)]["group"]
	piece_instance[by] = instance
	$pieces.add_child(instance)

func move_piece_instance(from:int, to:int) -> void:
	var instance:PieceInstance = piece_instance[from]
	instance.move(Chess.to_position_name(to))
	piece_instance.erase(from)
	piece_instance[to] = instance

func remove_piece_instance(by:int) -> void:
	var instance:PieceInstance = piece_instance[by]
	piece_instance.erase(by)
	instance.queue_free()
