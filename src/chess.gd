extends Node

class Piece:
	var class_type:Object = PieceInterface
	var group:int = 0
	var instance:PieceInstance = null

func create_piece(_class_type:Object, _group:int) -> Piece:
	var new_piece:Piece = Piece.new()
	new_piece.class_type = _class_type
	new_piece.group = _group
	return new_piece

class PieceInterface:
	static func create_instance(_position_name:String, _group:int) -> PieceInstance:
		return null
	static func execute_navi(_state:ChessState, _position_name_from:String, _position_name_to:String) -> void:
		pass
	static func get_valid_navi(_state:ChessState, _position_name_from:String) -> PackedStringArray:
		return []
	static func get_attack_position(_state:ChessState, _position_name_from:String) -> PackedStringArray:
		return []

class PieceKing extends PieceInterface:
	static func create_instance(position_name:String, group:int) -> PieceInstance:
		var packed_scene:PackedScene = load("res://scene/piece_king.tscn")
		var instance:PieceInstance = packed_scene.instantiate()
		instance.position_name = position_name
		instance.group = group
		return instance

	static func execute_navi(state:ChessState, position_name_from:String, position_name_to:String) -> void:
		if state.has_piece(position_name_to):
			state.capture_piece(position_name_to)
		state.move_piece(position_name_from, position_name_to)

	static func get_valid_navi(state:ChessState, position_name_from:String) -> PackedStringArray:
		var directions:PackedVector2Array = [Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1)]
		var answer:PackedStringArray = []
		for iter:Vector2i in directions:
			var position_name_to:String = Chess.direction_to(position_name_from, iter)
			if !position_name_to || state.has_piece(position_name_to) && state.get_piece(position_name_from).group == state.get_piece(position_name_to).group:
				continue
			answer.push_back(position_name_to)
		return answer
	static func get_attack_position(state:ChessState, position_name_from:String) -> PackedStringArray:
		var directions:PackedVector2Array = [Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1)]
		var answer:PackedStringArray = []
		for iter:Vector2i in directions:
			var position_name_to:String = Chess.direction_to(position_name_from, iter)
			if !position_name_to:
				continue
			answer.push_back(position_name_to)
		return answer

class PieceQueen extends PieceInterface:
	static func create_instance(position_name:String, group:int) -> PieceInstance:
		var packed_scene:PackedScene = load("res://scene/piece_queen.tscn")
		var instance:PieceInstance = packed_scene.instantiate()
		instance.position_name = position_name
		instance.group = group
		return instance

	static func execute_navi(state:ChessState, position_name_from:String, position_name_to:String) -> void:
		if state.has_piece(position_name_to):
			state.capture_piece(position_name_to)
		state.move_piece(position_name_from, position_name_to)

	static func get_valid_navi(state:ChessState, position_name_from:String) -> PackedStringArray:
		var directions:PackedVector2Array = [Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1)]
		var answer:PackedStringArray = []
		for iter:Vector2i in directions:
			var position_name_to:String = Chess.direction_to(position_name_from, iter)
			while position_name_to && (!state.has_piece(position_name_to) || state.get_piece(position_name_from).group != state.get_piece(position_name_to).group):
				answer.push_back(position_name_to)
				if state.has_piece(position_name_to) && state.get_piece(position_name_from).group != state.get_piece(position_name_to).group:
					break
				position_name_to = Chess.direction_to(position_name_to, iter)
		return answer
	static func get_attack_position(state:ChessState, position_name_from:String) -> PackedStringArray:
		var directions:PackedVector2Array = [Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1)]
		var answer:PackedStringArray = []
		for iter:Vector2i in directions:
			var position_name_to:String = Chess.direction_to(position_name_from, iter)
			while position_name_to:
				answer.push_back(position_name_to)
				if state.has_piece(position_name_to):
					break
				position_name_to = Chess.direction_to(position_name_to, iter)
		return answer

class PieceRook extends PieceInterface:
	static func create_instance(position_name:String, group:int) -> PieceInstance:
		var packed_scene:PackedScene = load("res://scene/piece_rook.tscn")
		var instance:PieceInstance = packed_scene.instantiate()
		instance.position_name = position_name
		instance.group = group
		return instance

	static func execute_navi(state:ChessState, position_name_from:String, position_name_to:String) -> void:
		if state.has_piece(position_name_to):
			state.capture_piece(position_name_to)
		state.move_piece(position_name_from, position_name_to)

	static func get_valid_navi(state:ChessState, position_name_from:String) -> PackedStringArray:
		var directions:PackedVector2Array = [Vector2i(-1, 0), Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, 0)]
		var answer:PackedStringArray = []
		for iter:Vector2i in directions:
			var position_name_to:String = Chess.direction_to(position_name_from, iter)
			while position_name_to && (!state.has_piece(position_name_to) || state.get_piece(position_name_from).group != state.get_piece(position_name_to).group):
				answer.push_back(position_name_to)
				if state.has_piece(position_name_to) && state.get_piece(position_name_from).group != state.get_piece(position_name_to).group:
					break
				position_name_to = Chess.direction_to(position_name_to, iter)
		return answer
	static func get_attack_position(state:ChessState, position_name_from:String) -> PackedStringArray:
		var directions:PackedVector2Array = [Vector2i(-1, 0), Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, 0)]
		var answer:PackedStringArray = []
		for iter:Vector2i in directions:
			var position_name_to:String = Chess.direction_to(position_name_from, iter)
			while position_name_to:
				answer.push_back(position_name_to)
				if state.has_piece(position_name_to):
					break
				position_name_to = Chess.direction_to(position_name_to, iter)
		return answer

class PieceBishop extends PieceInterface:
	static func create_instance(position_name:String, group:int) -> PieceInstance:
		var packed_scene:PackedScene = load("res://scene/piece_bishop.tscn")
		var instance:PieceInstance = packed_scene.instantiate()
		instance.position_name = position_name
		instance.group = group
		return instance

	static func execute_navi(state:ChessState, position_name_from:String, position_name_to:String) -> void:
		if state.has_piece(position_name_to):
			state.capture_piece(position_name_to)
		state.move_piece(position_name_from, position_name_to)

	static func get_valid_navi(state:ChessState, position_name_from:String) -> PackedStringArray:
		var directions:PackedVector2Array = [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]
		var answer:PackedStringArray = []
		for iter:Vector2i in directions:
			var position_name_to:String = Chess.direction_to(position_name_from, iter)
			while position_name_to && (!state.has_piece(position_name_to) || state.get_piece(position_name_from).group != state.get_piece(position_name_to).group):
				answer.push_back(position_name_to)
				if state.has_piece(position_name_to) && state.get_piece(position_name_from).group != state.get_piece(position_name_to).group:
					break
				position_name_to = Chess.direction_to(position_name_to, iter)
		return answer
	static func get_attack_position(state:ChessState, position_name_from:String) -> PackedStringArray:
		var directions:PackedVector2Array = [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]
		var answer:PackedStringArray = []
		for iter:Vector2i in directions:
			var position_name_to:String = Chess.direction_to(position_name_from, iter)
			while position_name_to:
				answer.push_back(position_name_to)
				if state.has_piece(position_name_to):
					break
				position_name_to = Chess.direction_to(position_name_to, iter)
		return answer

class PieceKnight extends PieceInterface:
	static func create_instance(position_name:String, group:int) -> PieceInstance:
		var packed_scene:PackedScene = load("res://scene/piece_knight.tscn")
		var instance:PieceInstance = packed_scene.instantiate()
		instance.position_name = position_name
		instance.group = group
		return instance

	static func execute_navi(state:ChessState, position_name_from:String, position_name_to:String) -> void:
		if state.has_piece(position_name_to):
			state.capture_piece(position_name_to)
		state.move_piece(position_name_from, position_name_to)

	static func get_valid_navi(state:ChessState, position_name_from:String) -> PackedStringArray:
		var directions:PackedVector2Array = [Vector2i(1, 2), Vector2i(2, 1), Vector2i(-1, 2), Vector2i(-2, 1), Vector2i(1, -2), Vector2i(2, -1), Vector2i(-1, -2), Vector2i(-2, -1)]
		var answer:PackedStringArray = []
		for iter:Vector2i in directions:
			var position_name_to:String = Chess.direction_to(position_name_from, iter)
			if !position_name_to || state.has_piece(position_name_to) && state.get_piece(position_name_from).group == state.get_piece(position_name_to).group:
				continue
			answer.push_back(position_name_to)
		return answer
	static func get_attack_position(state:ChessState, position_name_from:String) -> PackedStringArray:
		var directions:PackedVector2Array = [Vector2i(1, 2), Vector2i(2, 1), Vector2i(-1, 2), Vector2i(-2, 1), Vector2i(1, -2), Vector2i(2, -1), Vector2i(-1, -2), Vector2i(-2, -1)]
		var answer:PackedStringArray = []
		for iter:Vector2i in directions:
			var position_name_to:String = Chess.direction_to(position_name_from, iter)
			if !position_name_to:
				continue
			answer.push_back(position_name_to)
		return answer

class PiecePawn extends PieceInterface:
	static func create_instance(position_name:String, group:int) -> PieceInstance:
		var packed_scene:PackedScene = load("res://scene/piece_pawn.tscn")
		var instance:PieceInstance = packed_scene.instantiate()
		instance.position_name = position_name
		instance.group = group
		return instance

	static func execute_navi(state:ChessState, position_name_from:String, position_name_to:String) -> void:
		if state.has_piece(position_name_to):
			state.capture_piece(position_name_to)
		state.move_piece(position_name_from, position_name_to)

	static func get_valid_navi(state:ChessState, position_name_from:String) -> PackedStringArray:
		var answer:PackedStringArray = []
		var forward:Vector2i = Vector2i(0, 1) if state.get_piece(position_name_from).group == 0 else Vector2i(0, -1)
		var on_start:bool = state.get_piece(position_name_from).group == 0 && position_name_from[1] == "2" || state.get_piece(position_name_from).group == 1 && position_name_from[1] == "7"
		var position_name_to:String = Chess.direction_to(position_name_from, forward)
		var position_name_to_2:String = Chess.direction_to(position_name_from, forward * 2)
		var position_name_to_l:String = Chess.direction_to(position_name_to, Vector2i(1, 0))
		var position_name_to_r:String = Chess.direction_to(position_name_to, Vector2i(-1, 0))
		if !state.has_piece(position_name_to):
			answer.push_back(position_name_to)
			if on_start && !state.has_piece(position_name_to_2):
				answer.push_back(position_name_to_2)
		if state.has_piece(position_name_to_l) && state.get_piece(position_name_from).group != state.get_piece(position_name_to_l).group:
			answer.push_back(position_name_to_l)
		if state.has_piece(position_name_to_r) && state.get_piece(position_name_from).group != state.get_piece(position_name_to_r).group:
			answer.push_back(position_name_to_r)
		return answer
	static func get_attack_position(state:ChessState, position_name_from:String) -> PackedStringArray:
		var forward:Vector2i = Vector2i(0, 1) if state.get_piece(position_name_from).group == 0 else Vector2i(0, -1)
		var position_name_to:String = Chess.direction_to(position_name_from, forward)
		if !position_name_to:
			return []
		var position_name_to_l:String = Chess.direction_to(position_name_to, Vector2i(1, 0))
		var position_name_to_r:String = Chess.direction_to(position_name_to, Vector2i(-1, 0))
		var answer:PackedStringArray = []
		if position_name_to_l:
			answer.push_back(position_name_to_l)
		if position_name_to_r:
			answer.push_back(position_name_to_r)
		return answer

class ChessEvent:
	var step:int = 0	# 步数

class ChessEventMove extends ChessEvent:
	var position_name_from:String = ""
	var position_name_to:String = ""

class ChessEventCapture extends ChessEvent:	# 记录被删除的棋子，方便撤销
	var position_name:String = ""
	var captured_piece:Piece = null

func create_chess_event_move(_step:int, _position_name_from:String, _position_name_to:String) -> ChessEventMove:
	var new_event:ChessEventMove = ChessEventMove.new()
	new_event.step = _step
	new_event.position_name_from = _position_name_from
	new_event.position_name_to = _position_name_to
	return new_event

func create_chess_event_capture(_step:int, _position_name:String, _captured_piece:Piece) -> ChessEventCapture:
	var new_event:ChessEventCapture = ChessEventCapture.new()
	new_event.step = _step
	new_event.position_name = _position_name
	new_event.captured_piece = _captured_piece
	return new_event

class ChessState:
	var state_name:String = "test"
	var current:Dictionary[String, Piece] = {}
	var history:PackedStringArray = []	# 仅记录着法
	var history_buffer:Array = []	# 详细记录所有变动
	var attack_count:Dictionary[String, int] = {}	# 分两位：黑方攻击和白方攻击
	func _init() -> void:
		current = {
			"a1": Chess.create_piece(PieceRook, 0),
			"b1": Chess.create_piece(PieceKnight, 0),
			"c1": Chess.create_piece(PieceBishop, 0),
			"d1": Chess.create_piece(PieceQueen, 0),
			"e1": Chess.create_piece(PieceKing, 0),
			"f1": Chess.create_piece(PieceBishop, 0),
			"g1": Chess.create_piece(PieceKnight, 0),
			"h1": Chess.create_piece(PieceRook, 0),
			"a2": Chess.create_piece(PiecePawn, 0),
			"b2": Chess.create_piece(PiecePawn, 0),
			"c2": Chess.create_piece(PiecePawn, 0),
			"d2": Chess.create_piece(PiecePawn, 0),
			"e2": Chess.create_piece(PiecePawn, 0),
			"f2": Chess.create_piece(PiecePawn, 0),
			"g2": Chess.create_piece(PiecePawn, 0),
			"h2": Chess.create_piece(PiecePawn, 0),
			"a8": Chess.create_piece(PieceRook, 1),
			"b8": Chess.create_piece(PieceKnight, 1),
			"c8": Chess.create_piece(PieceBishop, 1),
			"d8": Chess.create_piece(PieceQueen, 1),
			"e8": Chess.create_piece(PieceKing, 1),
			"f8": Chess.create_piece(PieceBishop, 1),
			"g8": Chess.create_piece(PieceKnight, 1),
			"h8": Chess.create_piece(PieceRook, 1),
			"a7": Chess.create_piece(PiecePawn, 1),
			"b7": Chess.create_piece(PiecePawn, 1),
			"c7": Chess.create_piece(PiecePawn, 1),
			"d7": Chess.create_piece(PiecePawn, 1),
			"e7": Chess.create_piece(PiecePawn, 1),
			"f7": Chess.create_piece(PiecePawn, 1),
			"g7": Chess.create_piece(PiecePawn, 1),
			"h7": Chess.create_piece(PiecePawn, 1),
		}
		update_attack()
	func get_piece_instance(position_name:String) -> PieceInstance:
		var instance:PieceInstance = current[position_name].instance
		if is_instance_valid(instance):
			return instance
		instance = current[position_name].class_type.create_instance(position_name, current[position_name].group)
		current[position_name].instance = instance
		return instance

	func get_piece(position_name:String) -> Piece:
		if !position_name || !current.has(position_name):
			return null
		return current[position_name]

	func is_navi_valid(position_name_from:String, position_name_to:String) -> bool:
		if !position_name_from || !position_name_to || !current.has(position_name_from):
			return false
		return get_valid_navi(position_name_from).has(position_name_to)

	func get_valid_navi(position_name_from:String) -> PackedStringArray:
		if has_piece(position_name_from):
			return current[position_name_from].class_type.get_valid_navi(self, position_name_from)
		return []

	func execute_navi(position_name_from:String, position_name_to:String) -> void:
		if has_piece(position_name_from):
			current[position_name_from].class_type.execute_navi(self, position_name_from, position_name_to)
		history.push_back(position_name_from + "->" + position_name_to)

	func has_piece(position_name:String) -> bool:
		return current.has(position_name)

	func capture_piece(position_name:String) -> void:
		history_buffer.push_back(Chess.create_chess_event_capture(history.size(), position_name, current[position_name]))
		var instance:PieceInstance = get_piece(position_name).instance
		if is_instance_valid(instance):
			instance.queue_free()
		current.erase(position_name)

	func move_piece(position_name_from:String, position_name_to:String) -> void:
		history_buffer.push_back(Chess.create_chess_event_move(history.size(), position_name_from, position_name_to))
		var piece:Piece = get_piece(position_name_from)
		current.erase(position_name_from)
		current[position_name_to] = piece
		update_attack()
		var instance:PieceInstance = piece.instance
		if is_instance_valid(instance):
			instance.move(position_name_to)
	
	func update_attack() -> void:
		attack_count.clear()
		for key:String in current:
			var attack_position:PackedStringArray = current[key].class_type.get_attack_position(self, key)
			for iter:String in attack_position:
				if !attack_count.has(iter):
					attack_count[iter] = 0
				attack_count[iter] += 1 << (0 if current[key].group == 0 else 6)

var current_chessboard:Chessboard = null
@onready var test_state:ChessState = ChessState.new()

func to_piece_position(position_name:String) -> Vector2i:
	var position_name_buffer:PackedByteArray = position_name.to_ascii_buffer()
	return Vector2i(position_name_buffer[0] - 97, position_name_buffer[1] - 49)

func to_position_name(piece_position:Vector2i) -> String:
	if piece_position.x < 0 || piece_position.x > 7 || piece_position.y < 0 || piece_position.y > 7:
		return ""
	return "%c%c" % [piece_position.x + 97, piece_position.y + 49]

func direction_to(position_name_from:String, direction:Vector2i) -> String:
	return to_position_name(to_piece_position(position_name_from) + direction)

func change_chessboard(next:String) -> void:
	if is_instance_valid(current_chessboard):
		current_chessboard.queue_free()
	var packed_scene:PackedScene = load("res://scene/chessboard_%s.tscn" % next)
	current_chessboard = packed_scene.instantiate()
	get_tree().root.add_child(current_chessboard)

func get_current_chessboard() -> Chessboard:
	return current_chessboard
  
func set_current_chessboard(_chessboard:Chessboard) -> void:
	current_chessboard = _chessboard

func get_chess_state() -> ChessState:
	return test_state
