extends InspectableItem
class_name Chessboard

signal move_played()
@onready var fallback_piece:Actor = load("res://scene/piece_shrub.tscn").instantiate()
var pieces:Dictionary = {}
var backup_piece:Array = []
var mouse_start_position_name:String = ""
var mouse_moved:bool = false
var state:State = null
var valid_move:Dictionary[int, Array] = {}
var valid_premove:Dictionary[int, Array] = {}
var selected:int = -1
var premove:int = -1
var chessboard_piece:Dictionary[int, Actor] = {}
var king_instance:Array[Actor] = [null, null]
var confirm_move:int = 0

func _ready() -> void:
	reserve_piece_instance()
	super._ready()

func reserve_piece_instance() -> void:	# 最好交由外部来负责棋子的准备
	add_piece_instance(load("res://scene/piece_king_white.tscn").instantiate(), Vector3($h1.position.x + 0.2, 0, $h1.position.z))
	add_piece_instance(load("res://scene/piece_queen_white.tscn").instantiate(), Vector3($h1.position.x + 0.3, 0, $h1.position.z))
	add_piece_instance(load("res://scene/piece_queen_white.tscn").instantiate(), Vector3($h1.position.x + 0.4, 0, $h1.position.z))
	add_piece_instance(load("res://scene/piece_rook_white.tscn").instantiate(), Vector3($h2.position.x + 0.2, 0, $h2.position.z))
	add_piece_instance(load("res://scene/piece_rook_white.tscn").instantiate(), Vector3($h2.position.x + 0.3, 0, $h2.position.z))
	add_piece_instance(load("res://scene/piece_knight_white.tscn").instantiate(), Vector3($h3.position.x + 0.2, 0, $h3.position.z))
	add_piece_instance(load("res://scene/piece_knight_white.tscn").instantiate(), Vector3($h3.position.x + 0.3, 0, $h3.position.z))
	add_piece_instance(load("res://scene/piece_bishop_white.tscn").instantiate(), Vector3($h4.position.x + 0.2, 0, $h4.position.z))
	add_piece_instance(load("res://scene/piece_bishop_white.tscn").instantiate(), Vector3($h4.position.x + 0.3, 0, $h4.position.z))
	add_piece_instance(load("res://scene/piece_pawn_white.tscn").instantiate(), Vector3($h5.position.x + 0.2, 0, $h5.position.z))
	add_piece_instance(load("res://scene/piece_pawn_white.tscn").instantiate(), Vector3($h5.position.x + 0.3, 0, $h5.position.z))
	add_piece_instance(load("res://scene/piece_pawn_white.tscn").instantiate(), Vector3($h6.position.x + 0.2, 0, $h6.position.z))
	add_piece_instance(load("res://scene/piece_pawn_white.tscn").instantiate(), Vector3($h6.position.x + 0.3, 0, $h6.position.z))
	add_piece_instance(load("res://scene/piece_pawn_white.tscn").instantiate(), Vector3($h7.position.x + 0.2, 0, $h7.position.z))
	add_piece_instance(load("res://scene/piece_pawn_white.tscn").instantiate(), Vector3($h7.position.x + 0.3, 0, $h7.position.z))
	add_piece_instance(load("res://scene/piece_pawn_white.tscn").instantiate(), Vector3($h8.position.x + 0.2, 0, $h8.position.z))
	add_piece_instance(load("res://scene/piece_pawn_white.tscn").instantiate(), Vector3($h8.position.x + 0.3, 0, $h8.position.z))
	for i in 10:
		add_piece_instance(load("res://scene/piece_checker_1_white.tscn").instantiate(), Vector3(0, 0, 0), true)
	for i in 10:
		add_piece_instance(load("res://scene/piece_checker_2_white.tscn").instantiate(), Vector3(0, 0, 0), true)
	for i in 10:
		add_piece_instance(load("res://scene/piece_checker_3_white.tscn").instantiate(), Vector3(0, 0, 0), true)
	add_piece_instance(load("res://scene/piece_checker_4_white.tscn").instantiate(), Vector3(0, 0, 0), true)
	add_piece_instance(load("res://scene/piece_king_black.tscn").instantiate(), Vector3($a8.position.x - 0.2, 0, $a8.position.z))
	add_piece_instance(load("res://scene/piece_queen_black.tscn").instantiate(), Vector3($a8.position.x - 0.3, 0, $a8.position.z))
	add_piece_instance(load("res://scene/piece_queen_black.tscn").instantiate(), Vector3($a8.position.x - 0.4, 0, $a8.position.z))
	add_piece_instance(load("res://scene/piece_rook_black.tscn").instantiate(), Vector3($a7.position.x - 0.2, 0, $a7.position.z))
	add_piece_instance(load("res://scene/piece_rook_black.tscn").instantiate(), Vector3($a7.position.x - 0.3, 0, $a7.position.z))
	add_piece_instance(load("res://scene/piece_knight_black.tscn").instantiate(), Vector3($a6.position.x - 0.2, 0, $a6.position.z))
	add_piece_instance(load("res://scene/piece_knight_black.tscn").instantiate(), Vector3($a6.position.x - 0.3, 0, $a6.position.z))
	add_piece_instance(load("res://scene/piece_bishop_black.tscn").instantiate(), Vector3($a5.position.x - 0.2, 0, $a5.position.z))
	add_piece_instance(load("res://scene/piece_bishop_black.tscn").instantiate(), Vector3($a5.position.x - 0.3, 0, $a5.position.z))
	add_piece_instance(load("res://scene/piece_pawn_black.tscn").instantiate(), Vector3($a4.position.x - 0.2, 0, $a4.position.z))
	add_piece_instance(load("res://scene/piece_pawn_black.tscn").instantiate(), Vector3($a4.position.x - 0.3, 0, $a4.position.z))
	add_piece_instance(load("res://scene/piece_pawn_black.tscn").instantiate(), Vector3($a3.position.x - 0.2, 0, $a3.position.z))
	add_piece_instance(load("res://scene/piece_pawn_black.tscn").instantiate(), Vector3($a3.position.x - 0.3, 0, $a3.position.z))
	add_piece_instance(load("res://scene/piece_pawn_black.tscn").instantiate(), Vector3($a2.position.x - 0.2, 0, $a2.position.z))
	add_piece_instance(load("res://scene/piece_pawn_black.tscn").instantiate(), Vector3($a2.position.x - 0.3, 0, $a2.position.z))
	add_piece_instance(load("res://scene/piece_pawn_black.tscn").instantiate(), Vector3($a1.position.x - 0.2, 0, $a1.position.z))
	add_piece_instance(load("res://scene/piece_pawn_black.tscn").instantiate(), Vector3($a1.position.x - 0.3, 0, $a1.position.z))
	for i in 10:
		add_piece_instance(load("res://scene/piece_checker_1_black.tscn").instantiate(), Vector3(0, 0, 0), true)
	for i in 10:
		add_piece_instance(load("res://scene/piece_checker_2_black.tscn").instantiate(), Vector3(0, 0, 0), true)
	for i in 10:
		add_piece_instance(load("res://scene/piece_checker_3_black.tscn").instantiate(), Vector3(0, 0, 0), true)
	add_piece_instance(load("res://scene/piece_checker_4_black.tscn").instantiate(), Vector3(0, 0, 0), true)

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
	var keys:Array = chessboard_piece.keys()
	for key:int in keys:
		move_piece_instance_to_backup(key)
	for i:int in range(128):
		if !state.has_piece(i):
			continue
		move_piece_instance_from_backup(i, state.get_piece(i))
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
			move_piece_instance_to_backup(event["to"])
			move_piece_instance(event["from"], event["to"])
		"promotion":
			move_piece_instance_to_backup(event["from"])
			move_piece_instance_from_backup(event["to"], event["piece"])
		"move":
			move_piece_instance(event["from"], event["to"])
		"castle":
			move_piece_instance(event["from_king"], event["to_king"])
			move_piece_instance(event["from_rook"], event["to_rook"])
		"en_passant":
			move_piece_instance(event["from"], event["to"])
			move_piece_instance_to_backup(event["captured"])
		"grafting":
			graft_piece_instance(event["from"], event["to"])

func add_piece_instance(instance:Actor, initial_position:Vector3 = Vector3(0, 0, 0), hide_piece:bool = false) -> void:
	pieces[instance] = {"initial_position": initial_position, "hide_piece": hide_piece}
	$pieces.add_child(instance)
	if hide_piece:
		instance.visible = false
	instance.position = initial_position
	backup_piece.push_back(instance)

func move_piece_instance_from_backup(by:int, piece:int) -> void:
	var target_piece_instance:Actor = null
	for iter:Actor in backup_piece:
		if iter.piece_type[0] == piece:
			target_piece_instance = iter
			break
	if !target_piece_instance:
		for iter:Actor in backup_piece:
			if iter.piece_type.has(piece):
				target_piece_instance = iter
				break
	if !target_piece_instance:
		var new_instance = fallback_piece.duplicate()
		new_instance.piece_type = [piece]
		add_piece_instance(new_instance, Vector3(0, 0, 0), true)
		target_piece_instance = new_instance
	if target_piece_instance:
		target_piece_instance.visible = true
		backup_piece.erase(target_piece_instance)
		chessboard_piece[by] = target_piece_instance
		if piece == "K".unicode_at(0):
			king_instance[0] = target_piece_instance
		if piece == "k".unicode_at(0):
			king_instance[1] = target_piece_instance
		target_piece_instance.move.call_deferred(get_node(Chess.to_position_name(by)).global_position)

func move_piece_instance(from:int, to:int) -> void:
	var instance:Actor = chessboard_piece[from]
	if state.has_piece(to):
		instance.capturing(get_node(Chess.to_position_name(to)).global_position)
	else:
		instance.move(get_node(Chess.to_position_name(to)).global_position)
	chessboard_piece.erase(from)
	chessboard_piece[to] = instance

func graft_piece_instance(from:int, to:int) -> void:
	var instance_1:Actor = chessboard_piece[from]
	var instance_2:Actor = chessboard_piece[to]
	chessboard_piece.erase(from)
	chessboard_piece.erase(to)
	instance_1.move(get_node(Chess.to_position_name(to)).global_position)
	instance_2.move(get_node(Chess.to_position_name(from)).global_position)
	chessboard_piece[from] = instance_2
	chessboard_piece[to] = instance_1

func move_piece_instance_to_backup(by:int) -> void:
	var instance:Actor = chessboard_piece[by]
	instance.captured()
	chessboard_piece.erase(by)
	backup_piece.push_back(instance)
	instance.visible = !pieces[instance]["hide_piece"]
	instance.move(to_global(pieces[instance]["initial_position"]))

func set_enabled(enabled:bool) -> void:
	super.set_enabled(enabled)
	if !enabled:
		$canvas.clear_select_position()
		$canvas.clear_premove_position()
		$canvas.clear_pointer_position()
		selected = -1
