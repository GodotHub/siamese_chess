extends Node3D

var state:State = null
var initial_state:State = null
@onready var chessboard = $chessboard

func _ready() -> void:
	$player.force_set_camera($camera_3d)
	chessboard.connect("clicked_move", receive_move)
	chessboard.set_enabled(true)
	while !is_instance_valid(state):
		var text_input_instance:TextInput = TextInput.create_text_input_instance("输入FEN格式的布局：", "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
		add_child(text_input_instance)
		await text_input_instance.confirmed
		state = RuleStandard.parse(text_input_instance.text)
	initial_state = state.duplicate()
	chessboard.set_state(state.duplicate())
	chessboard.add_default_piece_set()
	update_move()

func _unhandled_input(event:InputEvent) -> void:
	if event is InputEventKey && event.is_pressed() && event.keycode == KEY_R:
		reset()

func receive_move() -> void:
	await check_move()
	chessboard.execute_move(chessboard.confirm_move)
	RuleStandard.apply_move(state, chessboard.confirm_move)
	update_move()

func update_move() -> void:
	var move_list:PackedInt32Array = RuleStandard.generate_valid_move(state, state.get_turn())
	chessboard.set_valid_move(move_list)

func check_move() -> bool:
	var from:int = Chess.from(chessboard.confirm_move)
	var to:int = Chess.to(chessboard.confirm_move)
	var valid_move:Dictionary = chessboard.valid_move
	if from & 0x88 || to & 0x88 || !valid_move.has(from):
		return false
	var move_list:PackedInt32Array = valid_move[from].filter(func (move:int) -> bool: return to == Chess.to(move))
	if move_list.size() == 0:
		return false
	elif move_list.size() > 1:
		return await select_move(move_list)
	else:
		chessboard.confirm_move = move_list[0]
		return true

func select_move(move_list:PackedInt32Array) -> bool:
	var decision_list:PackedStringArray = []
	var decision_to_move:Dictionary = {}
	for iter:int in move_list:
		decision_list.push_back("%c" % Chess.extra(iter))
		decision_to_move[decision_list[-1]] = iter
	decision_list.push_back("cancel")
	Dialog.push_selection(decision_list, true, true)
	await Dialog.on_next
	if Dialog.selected == "cancel":
		return false
	else:
		chessboard.confirm_move = decision_to_move[Dialog.selected]
		return true

func reset() -> void:
	state = initial_state.duplicate()
	chessboard.set_state(initial_state)
	update_move()
