extends CanvasLayer

# 目前道具系统需要实现以下功能：
# 1、点击卡牌，再点击棋盘中的某一格，以实现摆放棋子
# 2、本身就需要和棋盘进行交互，似乎没有例外
# 3、也可以拖动过去，意味着需要和player场景强关联
# 4、但是摆放棋子需要和Level互动，而非Chessboard
# 5、Means that Chessboard还需要额外的解构，尤其是对棋盘的控制上

signal selected(card:Card)

var card_list:Array[Card] = []
var selected_card:Card = null

func _ready() -> void:
	init_card()
	var i:int = 0
	for iter:Card in card_list:
		var card_instance:TextureRect = TextureRect.new()
		card_instance.texture = iter.cover
		card_instance.set_meta("card", iter)
		$card_list.add_child(card_instance)
		card_instance.connect("gui_input", card_input.bind(card_instance))
		card_instance.position.y = -800
		card_instance.position.x = i * 200
		i += 1

func init_card() -> void:
	var card_1:CardTarot = CardTarot.new()
	card_1.cover = load("res://assets/texture/tarot_2.svg")
	card_1.piece = "q".unicode_at(0)
	card_1.actor = load("res://scene/pastor.tscn").instantiate()
	card_list.push_back(card_1)

func card_input(_event:InputEvent, card_instance:TextureRect) -> void:
	if _event is InputEventMouseButton:
		if _event.pressed && _event.button_index == MOUSE_BUTTON_LEFT:
			select_card(card_instance)

func deselect() -> void:
	selected_card = null
	for iter:TextureRect in $card_list.get_children():
		iter.position.y = -800

# 这里需要切实地让player感知到自己选了这张牌
func select_card(card_instance:TextureRect) -> void:
	var tween:Tween = create_tween()
	if selected_card != card_instance.get_meta("card"):
		selected_card = card_instance.get_meta("card")
		tween.tween_property(card_instance, "position:y", -1000, 0.3).set_trans(Tween.TRANS_SINE)
	else:
		selected_card = null
		tween.tween_property(card_instance, "position:y", -800, 0.3).set_trans(Tween.TRANS_SINE)
	selected.emit(selected_card)
	for iter:TextureRect in $card_list.get_children():
		iter.position.y = -800
