extends InspectableItem
class_name Chessboard

signal move_played(move:int)
signal press_timer()

var mouse_start_position_name:String = ""
var mouse_moved:bool = false
var chess_state:ChessState = null
var valid_move:Dictionary[int, Array] = {}
var selected:int = -1
var piece_instance:Dictionary[int, PieceInstance] = {}

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

func set_state(_state:ChessState) -> void:
	$canvas.clear_move_position()
	$canvas.clear_select_position()
	chess_state = _state
	chess_state.connect("piece_added", add_piece_instance)
	chess_state.connect("piece_moved", move_piece_instance)
	chess_state.connect("piece_removed", remove_piece_instance)
	for key:int in piece_instance:
		piece_instance[key].queue_free()
	piece_instance.clear()
	var pieces:Array = chess_state.pieces
	for i:int in range(pieces.size()):
		if !pieces[i]:
			continue
		var instance:PieceInstance = chess_state.get_piece_instance(i)
		instance.chessboard = self
		piece_instance[i] = instance
		$pieces.add_child(instance)

func get_position_name(_position:Vector3) -> String:
	var chess_pos:Vector2i = Vector2i(int(_position.x + 4) / 1, int(_position.z + 4) / 1)
	return "%c%d" % [chess_pos.x + 97, chess_pos.y + 1]

func convert_name_to_position(_position_name:String) -> Vector3:
	return get_node(_position_name).position

func tap_position(position_name:String) -> void:
	$canvas.clear_select_position()
	var by:int = Chess.to_int(position_name)
	if !is_instance_valid(chess_state) || chess_state.get_extra(0) == "w":
		return
	if selected != -1:
		confirm_move(selected, by)
		selected = -1
		return
	if !chess_state.has_piece(by) || !valid_move.has(by):
		return
	for iter:int in valid_move[by]:
		$canvas.draw_select_position($canvas.convert_name_to_position(Chess.to_position_name(Move.to(iter))))
	selected = by

func finger_on_position(position_name:String) -> void:
	if !position_name:
		$canvas.clear_pointer_position()
		return
	$canvas.draw_pointer_position($canvas.convert_name_to_position(position_name))

func finger_up() -> void:
	$canvas.clear_pointer_position()

func confirm_move(from:int, to:int) -> void:
	if from & 0x88 || to & 0x88 || !valid_move.has(from):
		return
	var move_list:PackedInt32Array = valid_move[from].filter(func (move:int) -> bool: return to == Move.to(move))
	if move_list.size() == 0:
		return
	elif move_list.size() > 1:
		var decision_list:PackedStringArray = []
		for iter:int in move_list:
			decision_list.push_back("%c" % Move.extra(iter))
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
	chess_state.apply_move(move)
	$canvas.clear_move_position()
	$canvas.draw_move_position($canvas.convert_name_to_position(Chess.to_position_name(Move.from(move))))
	$canvas.draw_move_position($canvas.convert_name_to_position(Chess.to_position_name(Move.to(move))))
	move_played.emit(move)
	press_timer.emit()

func set_valid_move(move_list:PackedInt32Array) -> void:
	valid_move.clear()
	for move:int in move_list:
		if !valid_move.has(Move.from(move)):
			valid_move[Move.from(move)] = []
		valid_move[Move.from(move)].push_back(move)

func add_piece_instance(by:int) -> void:
	var instance:PieceInstance = chess_state.get_piece_instance(by)
	instance.chessboard = self
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
