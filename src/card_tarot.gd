extends Card
class_name CardTarot

# 用卡牌的时候，通常需要指定哪个棋盘中的哪个位置上
var piece:int = 0
var actor:Actor = null
var by:int = -1
var chessboard:Chessboard = null

func parse(text:String):
	var dict:Dictionary = JSON.parse_string(text)
	cover = load(dict["cover"])
	piece = dict["piece"]
	actor = load(dict["actor"]).instantiate()

func reset() -> void:
	use_directly = false
	if is_instance_valid(chessboard):
		chessboard.remove_piece_instance(actor)
		chessboard = null
		actor.unpromote()

func use_card_on_chessboard(_chessboard:Chessboard, _by:int) -> void:
	_chessboard.state.add_piece(_by, piece)
	_chessboard.add_piece_instance(actor, _by)
	by = _by
	chessboard = _chessboard
	use_directly = true

func use_card_directly() -> void:
	chessboard.remove_piece_instance(actor)
	chessboard.state.capture_piece(by)
	actor.unpromote()
	chessboard = null
	use_directly = false

func show_up(_instance:Control) -> void:
	if use_directly:
		_instance.position.y = -700
	else:
		_instance.position.y = -600
