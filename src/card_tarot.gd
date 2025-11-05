extends Card
class_name CardTarot

# 用卡牌的时候，通常需要指定哪个棋盘中的哪个位置上
var piece:int = 0
var actor:Actor = null

func parse(text:String):
	var dict:Dictionary = JSON.parse_string(text)
	cover = load(dict["cover"])
	piece = dict["piece"]
	actor = load(dict["actor"]).instantiate()

func use_card(chessboard:Chessboard, by:int) -> void:	# 单纯加人就是了，按道理也应当算作一步棋（非战斗时）
	chessboard.state.add_piece(by, piece)
	chessboard.add_piece_instance(actor, by)
