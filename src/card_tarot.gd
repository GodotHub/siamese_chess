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

func use_card_on_chessboard(_chessboard:Chessboard, _by:int) -> void:	# 单纯加人就是了，按道理也应当算作一步棋（非战斗时）
	_chessboard.state.add_piece(_by, piece)
	_chessboard.add_piece_instance(actor, _by)
	by = _by
	chessboard = _chessboard
	use_directly = true

func use_card_directly() -> void:
	chessboard.remove_piece_instance(actor)
	chessboard.state.capture_piece(by)
	use_directly = false
