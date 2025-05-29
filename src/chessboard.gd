extends InspectableItem
class_name Chessboard

signal move_played(move:Move)
signal press_timer()

var mouse_start_position_name:String = ""
var mouse_moved:bool = false
var chess_state:ChessState = null
var valid_move:Dictionary[String, Array] = {}
var selected_position_name:String = ""
var piece_instance:Dictionary[String, PieceInstance] = {}

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
	for key:String in piece_instance:
		piece_instance[key].queue_free()
	piece_instance.clear()
	var pieces:Dictionary = chess_state.pieces
	for key:String in pieces:
		var instance:PieceInstance = chess_state.get_piece_instance(key)
		instance.chessboard = self
		piece_instance[key] = instance
		$pieces.add_child(instance)

func get_position_name(_position:Vector3) -> String:
	var chess_pos:Vector2i = Vector2i(int(_position.x + 4) / 1, int(_position.z + 4) / 1)
	return "%c%d" % [chess_pos.x + 97, chess_pos.y + 1]

func convert_name_to_position(_position_name:String) -> Vector3:
	return get_node(_position_name).position

func tap_position(position_name:String) -> void:
	$canvas.clear_select_position()
	if !is_instance_valid(chess_state) || chess_state.get_extra(0) == "w":
		return
	if selected_position_name:
		confirm_move(selected_position_name, position_name)
		selected_position_name = ""
		return
	if !chess_state.has_piece(position_name) || !valid_move.has(position_name):
		return
	for iter:Move in valid_move[position_name]:
		$canvas.draw_select_position($canvas.convert_name_to_position(iter.position_name_to))
	selected_position_name = position_name

func finger_on_position(position_name:String) -> void:
	if !position_name:
		$canvas.clear_pointer_position()
		return
	$canvas.draw_pointer_position($canvas.convert_name_to_position(position_name))

func finger_up() -> void:
	$canvas.clear_pointer_position()

func confirm_move(position_name_from:String, position_name_to:String) -> void:
	if !position_name_from || !position_name_to || !valid_move.has(position_name_from):
		return
	var move_list:Array = valid_move[position_name_from].filter(func (move:Move) -> bool: return position_name_to == move.position_name_to)
	if move_list.size() == 0:
		return
	elif move_list.size() > 1:
		var decision_list:PackedStringArray = []
		for iter:Move in move_list:
			decision_list.push_back(iter.comment)
		var decision_instance:Decision = Decision.create_decision_instance(decision_list, true)
		add_child(decision_instance)
		await decision_instance.decided
		if decision_instance.selected_index == -1:
			return
		execute_move(move_list[decision_instance.selected_index])
	else:
		execute_move(move_list[0])
	$canvas.clear_select_position()

func execute_move(move:Move) -> void:
	chess_state.apply_event(chess_state.create_event(move))
	$canvas.clear_move_position()
	$canvas.draw_move_position($canvas.convert_name_to_position(move.position_name_from))
	$canvas.draw_move_position($canvas.convert_name_to_position(move.position_name_to))
	move_played.emit(move)
	press_timer.emit()

func set_valid_move(move_list:Array[Move]) -> void:
	valid_move.clear()
	for move:Move in move_list:
		if !valid_move.has(move.position_name_from):
			valid_move[move.position_name_from] = []
		valid_move[move.position_name_from].push_back(move)

func add_piece_instance(position_name:String) -> void:
	var instance:PieceInstance = chess_state.get_piece_instance(position_name)
	instance.chessboard = self
	piece_instance[position_name] = instance
	$pieces.add_child(instance)

func move_piece_instance(position_name_from:String, position_name_to:String) -> void:
	var instance:PieceInstance = piece_instance[position_name_from]
	instance.move(position_name_to)
	piece_instance.erase(position_name_from)
	piece_instance[position_name_to] = instance

func remove_piece_instance(position_name:String) -> void:
	var instance:PieceInstance = piece_instance[position_name]
	piece_instance.erase(position_name)
	instance.queue_free()
