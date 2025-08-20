extends Node2D
class_name ChessboardFlat

var piece_path:Dictionary = {
	"K": "res://assets/texture/cburnett/wK.svg",
	"Q": "res://assets/texture/cburnett/wQ.svg",
	"R": "res://assets/texture/cburnett/wR.svg",
	"B": "res://assets/texture/cburnett/wB.svg",
	"N": "res://assets/texture/cburnett/wN.svg",
	"P": "res://assets/texture/cburnett/wP.svg",
	"k": "res://assets/texture/cburnett/bK.svg",
	"q": "res://assets/texture/cburnett/bQ.svg",
	"r": "res://assets/texture/cburnett/bR.svg",
	"b": "res://assets/texture/cburnett/bB.svg",
	"n": "res://assets/texture/cburnett/bN.svg",
	"p": "res://assets/texture/cburnett/bP.svg"
}

var state:State = null
var upper_left:Vector2 = Vector2(52, 52)
var pieces:Array[Sprite2D] = []

func _ready() -> void:
	state = RuleStandard.create_initial_state()
	draw()

func draw() -> void:
	var piece_position:PackedInt32Array = state.get_all_pieces()
	for by:int in piece_position:
		var by_piece:int = state.get_piece(by)
		var piece_texture:Texture = load(piece_path[String.chr(by_piece)])
		var piece_instance:Sprite2D = Sprite2D.new()
		piece_instance.position = upper_left + Vector2(by % 16, by / 16) * 128
		piece_instance.texture = piece_texture
		piece_instance.centered = false
		add_child(piece_instance)

func set_state(_state:State) -> void:
	state = _state.duplicate()
