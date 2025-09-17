extends InspectableItem
class_name Chessboard

signal move_played()
var piece_mapping:Dictionary = {
	"K": load("res://scene/piece_king_white.tscn").instantiate(),
	"Q": load("res://scene/piece_queen_white.tscn").instantiate(),
	"R": load("res://scene/piece_rook_white.tscn").instantiate(),
	"N": load("res://scene/piece_knight_white.tscn").instantiate(),
	"B": load("res://scene/piece_bishop_white.tscn").instantiate(),
	"P": load("res://scene/piece_pawn_white.tscn").instantiate(),
	"W": load("res://scene/piece_checker_1_white.tscn").instantiate(),
	"X": load("res://scene/piece_checker_2_white.tscn").instantiate(),
	"Y": load("res://scene/piece_checker_3_white.tscn").instantiate(),
	"Z": load("res://scene/piece_checker_4_white.tscn").instantiate(),
	"k": load("res://scene/piece_king_black.tscn").instantiate(),
	"q": load("res://scene/piece_queen_black.tscn").instantiate(),
	"r": load("res://scene/piece_rook_black.tscn").instantiate(),
	"n": load("res://scene/piece_knight_black.tscn").instantiate(),
	"b": load("res://scene/piece_bishop_black.tscn").instantiate(),
	"p": load("res://scene/piece_pawn_black.tscn").instantiate(),
	"w": load("res://scene/piece_checker_1_black.tscn").instantiate(),
	"x": load("res://scene/piece_checker_2_black.tscn").instantiate(),
	"y": load("res://scene/piece_checker_3_black.tscn").instantiate(),
	"z": load("res://scene/piece_checker_4_black.tscn").instantiate(),
}
var mouse_start_position_name:String = ""
var mouse_moved:bool = false
var state:State = null
var valid_move:Dictionary[int, Array] = {}
var valid_premove:Dictionary[int, Array] = {}
var selected:int = -1
var premove:int = -1
var piece_instance:Dictionary[int, Actor] = {}
var king_instance:Array[Actor] = [null, null]
var confirm_move:int = 0

func _ready() -> void:
	super._ready()

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
	state = _state.duplicate()
	for key:int in piece_instance:
		piece_instance[key].queue_free()
	piece_instance.clear()
	for i:int in range(128):
		if !state.has_piece(i):
			continue
		add_piece_instance(i, state.get_piece(i))
	#king_instance[0].set_warning(RuleStandard.is_check(state, 1))
	#king_instance[1].set_warning(RuleStandard.is_check(state, 0))

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
	if selected != -1:
		check_move(selected, by)
		check_premove(selected, by)
		selected = -1
		return
	if !state.has_piece(by) || !valid_move.has(by) && !valid_premove.has(by):
		return
	if valid_move.has(by):
		for iter:int in valid_move[by]:
			$canvas.draw_select_position($canvas.convert_name_to_position(Chess.to_position_name(Chess.to(iter))))
	if valid_premove.has(by):
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

func check_premove(from:int, to:int) -> void:
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

func check_move(from:int, to:int) -> void:
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
	confirm_move = move
	var event:Dictionary = RuleStandard.apply_move_custom(state, move)
	receive_event(event)
	RuleStandard.apply_move(state, move)
	$canvas.clear_select_position()
	$canvas.clear_premove_position()
	$canvas.clear_move_position()
	$canvas.draw_move_position($canvas.convert_name_to_position(Chess.to_position_name(Chess.from(move))))
	$canvas.draw_move_position($canvas.convert_name_to_position(Chess.to_position_name(Chess.to(move))))
	#king_instance[0].set_warning(RuleStandard.is_check(state, 1))
	#king_instance[1].set_warning(RuleStandard.is_check(state, 0))
	selected = -1
	move_played.emit()

func set_valid_move(move_list:PackedInt32Array) -> void:
	valid_move.clear()
	for move:int in move_list:
		if move == premove:
			execute_move.call_deferred(premove)
			premove = -1
			return
		if !valid_move.has(Chess.from(move)):
			valid_move[Chess.from(move)] = []
		valid_move[Chess.from(move)].push_back(move)

func set_valid_premove(move_list:PackedInt32Array) -> void:
	valid_premove.clear()
	for move:int in move_list:
		if !valid_premove.has(Chess.from(move)):
			valid_premove[Chess.from(move)] = []
		valid_premove[Chess.from(move)].push_back(move)

func receive_event(event:Dictionary) -> void:
	match event["type"]:	# 暂时的做法
		"capture":
			remove_piece_instance(event["to"])
			move_piece_instance(event["from"], event["to"])
		"promotion":
			remove_piece_instance(event["from"])
			add_piece_instance(event["to"], event["piece"])
		"move":
			move_piece_instance(event["from"], event["to"])
		"castle":
			move_piece_instance(event["from_king"], event["to_king"])
			move_piece_instance(event["from_rook"], event["to_rook"])
		"en_passant":
			move_piece_instance(event["from"], event["to"])
			remove_piece_instance(event["captured"])
		"grafting":
			graft_piece_instance(event["from"], event["to"])

func add_piece_instance(by:int, piece:int) -> void:
	var instance:Actor = piece_mapping[char(piece)].duplicate()
	piece_instance[by] = instance
	if piece == "K".unicode_at(0):
		king_instance[0] = instance
	if piece == "k".unicode_at(0):
		king_instance[1] = instance
	$pieces.add_child(instance)
	instance.global_position = get_node(Chess.to_position_name(by)).global_position

func move_piece_instance(from:int, to:int) -> void:
	var instance:Actor = piece_instance[from]
	if state.has_piece(to):
		instance.capturing(get_node(Chess.to_position_name(to)).global_position)
	else:
		instance.move(get_node(Chess.to_position_name(to)).global_position)
	piece_instance.erase(from)
	piece_instance[to] = instance

func graft_piece_instance(from:int, to:int) -> void:
	var instance_1:Actor = piece_instance[from]
	var instance_2:Actor = piece_instance[to]
	piece_instance.erase(from)
	piece_instance.erase(to)
	instance_1.move(get_node(Chess.to_position_name(to)).global_position)
	instance_2.move(get_node(Chess.to_position_name(from)).global_position)
	piece_instance[from] = instance_2
	piece_instance[to] = instance_1

func remove_piece_instance(by:int) -> void:
	var instance:Actor = piece_instance[by]
	instance.captured()
	piece_instance.erase(by)

func set_enabled(enabled:bool) -> void:
	super.set_enabled(enabled)
	if !enabled:
		$canvas.clear_select_position()
		$canvas.clear_premove_position()
		$canvas.clear_pointer_position()
		selected = -1
