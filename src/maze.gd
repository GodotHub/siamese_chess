extends Node3D

var fen:PackedStringArray = [
	"猫##2##1/2#1#3/1##1#1##/4#3/1#1#1##1/1#6/1#1#1##1/3#1#2 w - - 0 1"
]
var chess_state:Array[ChessState] = []

func _ready() -> void:
	chess_state.push_back(ChessState.create_from_fen(fen[0]))
	
