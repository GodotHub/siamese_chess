extends Control

@onready var rich_text_label:RichTextLabel = $rich_text_label

func _ready() -> void:
	var thread:Thread = Thread.new()
	thread.start(make_database)

func make_database() -> void:
	var transposition_table:TranspositionTable = TranspositionTable.new()
	transposition_table.reserve(1 << 20)
	var chess_state:ChessState = EvaluationStandard.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
	var main_variation:PackedInt32Array = []
	EvaluationStandard.search(chess_state, 0, main_variation, transposition_table, Callable(), 10, debug_output)
	#$pastor.transposition_table = transposition_table
	transposition_table.save_file("user://standard_opening.fa")

func debug_output(text:String) -> void:
	rich_text_label.append_text(text)
