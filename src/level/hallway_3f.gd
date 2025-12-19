extends Level

func _ready() -> void:
	super._ready()
	var cheshire_by:int = get_meta("by")
	var cheshire_instance:Actor = load("res://scene/actor/cheshire.tscn").instantiate()
	cheshire_instance.position = $chessboard.convert_name_to_position(Chess.to_position_name(cheshire_by))
	title[0x02] = "电梯"
	interact_list[0x02] = {
		"1F": Loading.change_scene.bind("res://scene/level/reception_lobby.tscn", {"by": 1}),
		"2F": Loading.change_scene.bind("res://scene/level/hallway_2f.tscn", {"by": 2})}
	$chessboard.state.add_piece(cheshire_by, "k".unicode_at(0))
	$chessboard.add_piece_instance(cheshire_instance, cheshire_by)
	$player.force_set_camera($camera)
