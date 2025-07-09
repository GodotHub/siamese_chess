extends Node3D

var rule_standard:RuleStandard = RuleStandard.new()
var state:State = null
@onready var chessboard = $chessboard

func _ready() -> void:
	$cheshire.set_initial_camera($camera_3d, $chessboard)
	chessboard.connect("move_played", receive_move)
	while !is_instance_valid(state):
		var text_input_instance:TextInput = TextInput.create_text_input_instance("输入FEN格式的布局：")
		add_child(text_input_instance)
		await text_input_instance.confirmed
		state = rule_standard.parse(text_input_instance.text)
	chessboard.set_state(state.duplicate())
	update_move()

func receive_move(move:int) -> void:
	chessboard.execute_move(move)
	rule_standard.apply_move(state, move, state.add_piece, state.capture_piece, state.move_piece, state.set_extra, state.push_history, state.change_score)
	update_move()

func update_move() -> void:
	var move_list:PackedInt32Array = rule_standard.generate_valid_move(state, state.get_extra(0))
	var premove_list:PackedInt32Array = rule_standard.generate_premove(state, 1 - state.get_extra(0))
	chessboard.set_valid_move(move_list)
	chessboard.set_valid_premove(premove_list)
