extends Node3D

var cur_player: int = 0
var cur_epoch: int = 0
var ai: PastorAI = PastorAI.new()
var state: State = null

@export var epoch: int = 0
@onready var chessboard: Chessboard = $"../chessboard"

func init_state() -> void:
	state = RuleStandard.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
	chessboard.set_state(state.duplicate())

func init_ai() -> void:
	ai.max_depth = 5

func on_play_pressed() -> void:
	init_state()
	init_ai()
	
