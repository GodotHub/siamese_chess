extends "res://src/outside.gd"

var taken:bool = false

func _ready() -> void:
	super._ready()
	$level.interact_list[0x21] = {"": add_card}

func add_card() -> void:
	if taken:
		return
	taken = true
	$level/card_item.visible = false
	var card:CardTarot = CardTarot.new()
	card.cover = load("res://assets/texture/tarot_0.svg")
	card.piece = "n".unicode_at(0)
	card.actor = load("res://scene/cheshire.tscn").instantiate()
	HoldCard.add_card(card)
