extends Node3D

var state:State = null
var initial_state:State = null
@onready var chessboard = $chessboard

func _ready() -> void:
	$player.set_initial_interact($interact)
	chessboard.add_default_piece_set()
	chessboard.connect("move_played", receive_move)
	while !is_instance_valid(state):
		var text_input_instance:TextInput = TextInput.create_text_input_instance("输入FEN格式的布局：", "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
		add_child(text_input_instance)
		await text_input_instance.confirmed
		state = RuleStandard.parse(text_input_instance.text)
	initial_state = state.duplicate()
	chessboard.set_state(state.duplicate())
	update_move()

func _unhandled_input(event:InputEvent) -> void:
	if event is InputEventKey && event.is_pressed() && event.keycode == KEY_R:
		reset()

func receive_move() -> void:
	RuleStandard.apply_move(state, chessboard.confirm_move)
	update_move()

func update_move() -> void:
	var move_list:PackedInt32Array = RuleStandard.generate_valid_move(state, state.get_turn())
	var premove_list:PackedInt32Array = RuleStandard.generate_premove(state, 1 - state.get_turn())
	chessboard.set_valid_move(move_list)
	chessboard.set_valid_premove(premove_list)

func reset() -> void:
	state = initial_state.duplicate()
	chessboard.set_state(initial_state)
	update_move()
