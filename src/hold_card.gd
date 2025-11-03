extends CanvasLayer

var card_list:PackedStringArray = []
var mouse_moved:bool = false

func _ready() -> void:
	pass

func _unhandled_input(_event:InputEvent) -> void:
	if _event is InputEventMouseButton:
		if _event.pressed && _event.button_index == MOUSE_BUTTON_LEFT:
			mouse_moved = false
			var flag:bool = false
			for iter:Sprite2D in $card_list:
				if iter.get_rect().has_point(iter.to_local(_event.position)):
					select_card(0)
					flag = true
					break
			if !flag:
				play_card(0)
		elif !_event.pressed && mouse_moved && _event.button_index == MOUSE_BUTTON_LEFT:
			play_card(0)
	
	if _event is InputEventMouseMotion:
		pass


func select_card(index:int) -> void:
	pass

func play_card(index:int) -> void:
	pass
