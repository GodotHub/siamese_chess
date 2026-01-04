extends Control

func _ready() -> void:
	$texture_rect/label_value_obtain.text = "%d" % get_meta("obtain")
	$texture_rect/label_value_wins.text = "%d" % get_meta("wins")
	$texture_rect/button.connect("button_up", on_button_pressed)

func on_button_pressed() -> void:
	Loading.change_scene("res://scene/level/hotel_room.tscn", {}, 1)
