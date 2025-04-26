extends Node3D
class_name Chessboard

signal navi_played(position_name_from:String, position_name_to:String)

var chess_state:Chess.ChessState = null
var selected_position_name:String = ""
var piece_instance:Dictionary[String, PieceInstance] = {}

func _ready() -> void:
	chess_state = Chess.ChessState.new()
	chess_state.connect("piece_moved", move_piece_instance)
	chess_state.connect("piece_removed", remove_piece_instance)
	var pieces:Dictionary = chess_state.current
	for key:String in pieces:
		var instance:PieceInstance = chess_state.get_piece_instance(key)
		instance.chessboard = self
		piece_instance[key] = instance
		$pieces.add_child(instance)
	draw_attack_position()

func get_position_name(_position:Vector3) -> String:
	var chess_pos:Vector2i = Vector2i(int(_position.x + 4) / 1, int(_position.z + 4) / 1)
	return "%c%d" % [chess_pos.x + 97, chess_pos.y + 1]

func convert_name_to_position(_position_name:String) -> Vector3:
	return get_node(_position_name).position

func tap_position(position_name:String) -> void:
	$canvas.clear_select_position()
	if selected_position_name:
		confirm_navi(selected_position_name, position_name)
		selected_position_name = ""
		return
	if !chess_state.has_piece(position_name):
		return
	var valid_navi:PackedStringArray = chess_state.get_valid_navi(position_name)
	for iter:String in valid_navi:
		$canvas.draw_select_position($canvas.convert_name_to_position(iter))
	selected_position_name = position_name

func finger_on_position(position_name:String) -> void:
	if !position_name:
		$canvas.clear_pointer_position()
		return
	$canvas.draw_pointer_position($canvas.convert_name_to_position(position_name))

func finger_up() -> void:
	$canvas.clear_pointer_position()

func confirm_navi(position_name_from:String, position_name_to:String) -> void:
	if !position_name_from || !position_name_to || !chess_state.is_navi_valid(position_name_from, position_name_to):
		return
	chess_state.execute_navi(position_name_from, position_name_to)
	$canvas.clear_select_position()
	draw_attack_position()
	navi_played.emit(position_name_from, position_name_to)

func draw_attack_position() -> void:
	$canvas.clear_attack_position()
	for i:int in range(8):
		for j:int in range(8):
			var position_name:String = "%c%d" % [i + 97, j + 1]
			if !chess_state.attack_count.has(position_name):
				continue
			var count:int = chess_state.attack_count[position_name]
			$canvas.draw_attack_position($canvas.convert_name_to_position(position_name), count)

func move_piece_instance(position_name_from:String, position_name_to:String) -> void:
	var instance:PieceInstance = piece_instance[position_name_from]
	instance.move(position_name_to)
	piece_instance.erase(position_name_from)
	piece_instance[position_name_to] = instance

func remove_piece_instance(position_name:String) -> void:
	var instance:PieceInstance = piece_instance[position_name]
	piece_instance.erase(position_name)
	instance.queue_free()
