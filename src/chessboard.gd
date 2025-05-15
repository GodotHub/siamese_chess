extends Node3D
class_name Chessboard

signal move_played(move:Chess.Move)

var chess_state:Chess.ChessState = null
var valid_move:Dictionary[String, Array] = {}
var selected_position_name:String = ""
var selected_extra:int = 0
var piece_instance:Dictionary[String, PieceInstance] = {}


func set_state(_state:Chess.ChessState) -> void:
	chess_state = _state
	chess_state.connect("piece_added", add_piece_instance)
	chess_state.connect("piece_moved", move_piece_instance)
	chess_state.connect("piece_removed", remove_piece_instance)
	var pieces:Dictionary = chess_state.current
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
	if !is_instance_valid(chess_state) || chess_state.step % 2 == 0:
		return
	if selected_position_name:
		confirm_move(selected_position_name, position_name)
		selected_position_name = ""
		return
	if !chess_state.has_piece(position_name) || !valid_move.has(position_name):
		return
	for iter:Chess.Move in valid_move[position_name]:
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
	var move_list:Array = valid_move[position_name_from].filter(func (move:Chess.Move) -> bool: return position_name_to == move.position_name_to)
	if move_list.size() == 0:
		return
	elif move_list.size() > 1:
		var decision_list:PackedStringArray = []
		for iter:Chess.Move in move_list:
			decision_list.push_back(iter.comment)
		var decision_instance:Decision = Decision.create_decision_instance(decision_list)
		decision_instance.connect("decided", set_action)
		add_child(decision_instance)
		await decision_instance.decided
		if selected_extra == -1:
			return
		execute_move(move_list[selected_extra])
	else:
		execute_move(move_list[selected_extra])
	$canvas.clear_select_position()

func set_action(action:int) -> void:
	selected_extra = action

func execute_move(move:Chess.Move) -> void:
	chess_state.execute_move(move)
	move_played.emit(move)

func set_valid_move(move_list:Array[Chess.Move]) -> void:
	valid_move.clear()
	for move:Chess.Move in move_list:
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
