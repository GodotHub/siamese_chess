extends "res://src/level/outside.gd"

var taken:bool = false

func _ready() -> void:
	super._ready()
	var data:Dictionary = Progress.get_table("res://scene/level/outside_3.tscn")
	if data.has("taken"):
		taken = data["taken"]
	if taken:
		$card_item.visible = false
	interact_list[0x10] = {"": add_card}

func add_card() -> void:
	if taken:
		return
	taken = true
	Progress.set_table("res://scene/level/outside_3.tscn", {"taken": taken})
	$card_item.visible = false
	var card:CardTarot = CardTarot.new()
	card.cover = load("res://assets/texture/piece_bishop.svg")
	card.piece = "n".unicode_at(0)
	card.actor = load("res://scene/actor/piece_bishop_black.tscn").instantiate().set_larger_scale()
	HoldCard.add_card(card)
	Dialog.push_dialog("", "你获得了一张卡牌", false, false, false)
