extends RefCounted
class_name Card

# 卡牌本身的数据结构
# 	Demo目前也就只有摆放在棋盘上的卡牌，毕竟……Demo……
#	卡牌本身有封面这一信息，除了信息以外，还有对应的棋子
#	棋盘中的部分机关和卡牌有关联，它不一定是摆放棋子
#   然后加上杂七杂八的和战斗无关的卡牌
#   因此使用继承

var cover:Texture2D = null

var use_directly:bool = false

func parse(_str:String):
	pass

func use_card_on_chessboard(_chessboard:Chessboard, _by:int) -> void:
	pass

func use_card_directly() -> void:
	pass
