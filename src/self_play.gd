extends Node3D

var cur_player: int = 0
var cur_epoch: int = 0
var white: PastorAI = PastorAI.new()
var black: PastorAI = PastorAI.new()
var state: State = null

@export var epoch: int = 0
@onready var chessboard: Chessboard = $"../chessboard"

func init_state() -> void:
	state = RuleStandard.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
	if FileAccess.file_exists("user://standard_opening.fa"):
		white.get_transposition_table().load_file("user://standard_opening.fa")
	else:
		white.get_transposition_table().reserve(1 << 20)
	chessboard.set_state(state.duplicate())

func init_ai() -> void:
	white.max_depth = 5
	black.max_depth = 5

func on_play_pressed() -> void:
	init_state()
	init_ai()
	
