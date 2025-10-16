extends Node3D

class Level:
	var state:State = null
	var chessboard:Chessboard = null
	var in_battle:bool = false
	func ready() -> void:
		if meta.has("actor"):
			for by:int in meta["actor"]:
				chessboard.add_piece_instance(meta["actor"][by], by)
		for i:int in 128:
			if !state.has_piece(i) || chessboard.chessboard_piece.has(i):
				continue
			match String.chr(state.get_piece(i)):
				"X":
					chessboard.add_piece_instance(load("res://scene/shrub.tscn").instantiate(), i)
				"Y":
					chessboard.add_piece_instance(load("res://scene/tree.tscn").instantiate(), i)

	func process() -> void:
		if meta.has("teleport"):
			for from:int in meta["teleport"]:
				if state.has_piece(from):
					meta["teleport"][from]["level"].state.add_piece(meta["teleport"][from]["to"], state.get_piece(from))
					state.capture_piece(from)
					chessboard.move_piece_instance_to_other(from, meta["teleport"][from]["to"], meta["teleport"][from]["level"].chessboard)
					meta["teleport"][from]["level"].chessboard.set_valid_move(RuleStandard.generate_valid_move(meta["teleport"][from]["level"].state, 1))
	var meta:Dictionary = {}

var level_1:Level = Level.new()
var level_2:Level = Level.new()
var level_3:Level = Level.new()
var level_4:Level = Level.new()
var level_5:Level = Level.new()

var ai:AI = null
var history_state:PackedInt32Array = []

func _ready() -> void:
	level_1.state = RuleStandard.parse("1Y2k1Y1/1X4X1/1X4X1/1Y4Y1/1X4X1/1X4X1/1Y4Y1/1X4X1 w - - 0 1")
	level_1.chessboard = create_chessboard(level_1.state, Vector3(0, 0, 0))
	level_1.meta = {
		"teleport": {
			Chess.to_x88(59): {
				"level": level_2,
				"to": Chess.to_x88(3)
			},
			Chess.to_x88(60): {
				"level": level_2,
				"to": Chess.to_x88(4)
			},
		},
		"actor": {
			Chess.to_x88(4):  load("res://scene/cheshire.tscn").instantiate(),
		}
	}
	level_2.state = RuleStandard.parse("1Y4Y1/1X4X1/1X4X1/1Yz3Y1/1X4X1/1X4X1/1Y4Y1/1X4X1 w - - 0 1")
	level_2.chessboard = create_chessboard(level_2.state, Vector3(0, 0, 18))
	level_2.meta = {
		"teleport": {
			Chess.to_x88(3): {
				"level": level_1,
				"to": Chess.to_x88(59)
			},
			Chess.to_x88(4): {
				"level": level_1,
				"to": Chess.to_x88(60)
			},
			Chess.to_x88(59): {
				"level": level_3,
				"to": Chess.to_x88(3)
			},
			Chess.to_x88(60): {
				"level": level_3,
				"to": Chess.to_x88(4)
			}
		},
		"actor": {
			Chess.to_x88(26): load("res://scene/carnation.tscn").instantiate().set_direction(PI / 2)
		}
	}
	level_3.state = RuleStandard.parse("1X4X1/XY4YX/8/8/8/8/YYYYYYYY/8 w - - 0 1")
	level_3.chessboard = create_chessboard(level_3.state, Vector3(0, 0, 36))
	level_3.meta = {
		"teleport": {
			Chess.to_x88(3): {
				"level": level_2,
				"to": Chess.to_x88(59)
			},
			Chess.to_x88(4): {
				"level": level_2,
				"to": Chess.to_x88(60)
			},
			Chess.to_x88(31): {
				"level": level_4,
				"to": Chess.to_x88(24)
			},
			Chess.to_x88(39): {
				"level": level_4,
				"to": Chess.to_x88(32)
			},
			Chess.to_x88(24): {
				"level": level_5,
				"to": Chess.to_x88(31)
			},
			Chess.to_x88(32): {
				"level": level_5,
				"to": Chess.to_x88(39)
			}
		}
	}
	level_4.state = RuleStandard.parse("8/8/8/8/8/8/8/8 w - - 0 1")
	level_4.chessboard = create_chessboard(level_4.state, Vector3(18, 0, 36))
	level_4.meta = {
		"teleport": {
			Chess.to_x88(31): {
				"level": level_3,
				"to": Chess.to_x88(24)
			},
			Chess.to_x88(39): {
				"level": level_3,
				"to": Chess.to_x88(32)
			}
		}
	}
	level_5.state = RuleStandard.parse("8/8/8/8/8/8/8/8 w - - 0 1")
	level_5.chessboard = create_chessboard(level_5.state, Vector3(-18, 0, 36))
	level_5.meta = {
		"teleport": {
			Chess.to_x88(31): {
				"level": level_3,
				"to": Chess.to_x88(24)
			},
			Chess.to_x88(39): {
				"level": level_3,
				"to": Chess.to_x88(32)
			}
		}
	}
	ai = PastorAI.new()
	ai.set_max_depth(100)
	ai.set_think_time(3)
	$player.set_initial_interact($interact)
	level_1.ready()
	level_2.ready()
	level_3.ready()
	level_4.ready()
	level_5.ready()
	explore(level_1)
	explore(level_2)
	explore(level_3)
	explore(level_4)
	explore(level_5)

func create_chessboard(_state:State, pos:Vector3) -> Chessboard:
	var new_chessboard:Chessboard = load("res://scene/chessboard_large.tscn").instantiate()
	add_child(new_chessboard)
	$interact.inspectable_item.push_back(new_chessboard)
	new_chessboard.global_position = pos
	new_chessboard.set_state(_state)
	new_chessboard.connect("clicked", move_player.bind(pos))
	return new_chessboard

func explore(level:Level) -> void:
	while true:	# 有棋子再说
		if level.state.get_bit("a".unicode_at(0)):
			level.chessboard.set_valid_move(RuleStandard.generate_valid_move(level.state, 1))
			level.chessboard.set_valid_premove([])
			await level.chessboard.move_played
			RuleStandard.apply_move(level.state, level.chessboard.confirm_move)
			await level.chessboard.animation_finished
			level.process.call()
		else:
			await level.chessboard.clicked

func move_player(pos:Vector3) -> void:
	var tween:Tween = create_tween()
	tween.tween_property($player, "global_position", pos, 0.3).set_trans(Tween.TRANS_SINE)

func versus(level:Level) -> void:
	while RuleStandard.get_end_type(level.state) == "":
		level.chessboard.set_valid_move([])
		level.chessboard.set_valid_premove(RuleStandard.generate_premove(level.state, 1))
		ai.set_think_time(3)
		ai.start_search(level.state, 0, history_state, Callable())
		if ai.is_searching():
			await ai.search_finished
		var move:int = ai.get_search_result()
		
		var test_state:State = level.state.duplicate()
		var variation:PackedInt32Array = ai.get_principal_variation()
		var text:String = ""
		for iter:int in variation:
			var move_name:String = RuleStandard.get_move_name(test_state, iter)
			text += move_name + " "
			RuleStandard.apply_move(test_state, iter)
		print(text)
		
		history_state.push_back(level.state.get_zobrist())
		RuleStandard.apply_move(level.state, move)
		level.chessboard.execute_move(move)
		if RuleStandard.get_end_type(level.state) != "":
			break
		level.chessboard.set_valid_move(RuleStandard.generate_valid_move(level.state, 1))
		level.chessboard.set_valid_premove([])
		ai.set_think_time(INF)
		ai.start_search(level.state, 1, history_state, Callable())
		await level.chessboard.move_played
		history_state.push_back(level.state.get_zobrist())
		RuleStandard.apply_move(level.state, level.chessboard.confirm_move)
		ai.stop_search()
		if ai.is_searching():
			await ai.search_finished
	match RuleStandard.get_end_type(level.state):
		"checkmate_black":
			for by:int in 128:
				if level.state.has_piece(by) && Chess.group(level.state.get_piece(by)) == 0:
					level.state.capture_piece(by)
					level.chessboard.chessboard_piece[by].captured()
		"checkmate_white":
			for by:int in 128:
				if level.state.has_piece(by) && Chess.group(level.state.get_piece(by)) == 1:
					level.state.capture_piece(by)
					level.chessboard.chessboard_piece[by].captured()
