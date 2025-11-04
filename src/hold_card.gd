extends CanvasLayer

# 目前道具系统需要实现以下功能：
# 1、点击卡牌，再点击棋盘中的某一格，以实现摆放棋子
# 2、本身就需要和棋盘进行交互，似乎没有例外
# 3、也可以拖动过去，意味着需要和player场景强关联
# 4、但是摆放棋子需要和Level互动，而非Chessboard
# 5、Means that Chessboard还需要额外的解构，尤其是对棋盘的控制上

signal selected(type:String)

var card_list:Array[Card] = []

func _ready() -> void:
	pass

func _unhandled_input(_event:InputEvent) -> void:
	# 好像只要点下左键点到卡牌之后，剩下的处理就和卡牌无关了
	if _event is InputEventMouseButton:
		if _event.pressed && _event.button_index == MOUSE_BUTTON_LEFT:
			for iter:Sprite2D in $card_list.get_children():
				if iter.get_rect().has_point(iter.to_local(_event.position)):
					select_card(iter)
					get_viewport().set_input_as_handled()
					break

# 这里需要切实地让player感知到自己选了这张牌
func select_card(card:Sprite2D) -> void:
	selected.emit()
	for iter:Sprite2D in $card_list.get_children():
		iter.position.y = 0
	var tween:Tween = create_tween()
	tween.tween_property(card, "position:y", -100, 0.3).set_trans(Tween.TRANS_SINE)
