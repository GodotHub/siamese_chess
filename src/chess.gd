extends Node

class Piece:
	var class_type:Object = PieceInterface
	var group:int = 0

func create_piece(_class_type:Object, _group:int) -> Piece:
	var new_piece:Piece = Piece.new()
	new_piece.class_type = _class_type
	new_piece.group = _group
	return new_piece

class Move:
	var position_name_from:String
	var position_name_to:String
	var extra:String

func create_move(position_name_from:String, position_name_to:String, extra:String) -> Move:
	var new_move:Move = Move.new()
	new_move.position_name_from = position_name_from
	new_move.position_name_to = position_name_to
	new_move.extra = extra
	return new_move

class PieceInterface:
	static func get_name() -> String:
		return "Null"
	static func create_instance(_position_name:String, _group:int) -> PieceInstance:
		return null
	static func execute_move(_state:ChessState, _move:Move) -> void:
		pass
	static func get_valid_move(_state:ChessState, _position_name_from:String) -> Array[Move]:
		return []
	static func get_value() -> float:
		return 0

class PieceKing extends PieceInterface:
	static func get_name() -> String:
		return "King"

	static func create_instance(position_name:String, group:int) -> PieceInstance:
		var packed_scene:PackedScene = load("res://scene/piece_king.tscn")
		var instance:PieceInstance = packed_scene.instantiate()
		instance.position_name = position_name
		instance.group = group
		return instance

	static func execute_move(state:ChessState, move:Move) -> void:
		if state.has_piece(move.position_name_to):
			state.capture_piece(move.position_name_to)
		if state.get_piece(move.position_name_from).group == 0:
			state.castle |= 3
		else:
			state.castle |= 12
		state.move_piece(move.position_name_from, move.position_name_to)
		if move.extra:
			if move.position_name_to == "g1":
				state.move_piece(move.extra, "f1")
			if move.position_name_to == "c1":
				state.move_piece(move.extra, "d1")
			if move.position_name_to == "g8":
				state.move_piece(move.extra, "f8")
			if move.position_name_to == "c8":
				state.move_piece(move.extra, "d8")

	static func get_valid_move(state:ChessState, position_name_from:String) -> Array[Move]:
		var directions:PackedVector2Array = [Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1)]
		var output:Array[Move] = []
		for iter:Vector2i in directions:
			var position_name_to:String = Chess.direction_to(position_name_from, iter)
			if !position_name_to || state.has_piece(position_name_to) && state.get_piece(position_name_from).group == state.get_piece(position_name_to).group:
				continue
			output.push_back(Chess.create_move(position_name_from, position_name_to, ""))
		return output
	static func get_value() -> float:
		return 1000

class PieceQueen extends PieceInterface:
	static func get_name() -> String:
		return "Queen"

	static func create_instance(position_name:String, group:int) -> PieceInstance:
		var packed_scene:PackedScene = load("res://scene/piece_queen.tscn")
		var instance:PieceInstance = packed_scene.instantiate()
		instance.position_name = position_name
		instance.group = group
		return instance

	static func execute_move(state:ChessState, move:Move) -> void:
		if state.has_piece(move.position_name_to):
			state.capture_piece(move.position_name_to)
		state.move_piece(move.position_name_from, move.position_name_to)

	static func get_valid_move(state:ChessState, position_name_from:String) -> Array[Move]:
		var directions:PackedVector2Array = [Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1)]
		var output:Array[Move] = []
		for iter:Vector2i in directions:
			var position_name_to:String = Chess.direction_to(position_name_from, iter)
			while position_name_to && (!state.has_piece(position_name_to) || state.get_piece(position_name_from).group != state.get_piece(position_name_to).group):
				output.push_back(Chess.create_move(position_name_from, position_name_to, ""))
				if state.has_piece(position_name_to) && state.get_piece(position_name_from).group != state.get_piece(position_name_to).group:
					break
				position_name_to = Chess.direction_to(position_name_to, iter)
		return output

	static func get_value() -> float:
		return 9

class PieceRook extends PieceInterface:
	static func get_name() -> String:
		return "Rook"

	static func create_instance(position_name:String, group:int) -> PieceInstance:
		var packed_scene:PackedScene = load("res://scene/piece_rook.tscn")
		var instance:PieceInstance = packed_scene.instantiate()
		instance.position_name = position_name
		instance.group = group
		return instance

	static func execute_move(state:ChessState, move:Move) -> void:
		if state.has_piece(move.position_name_to):
			state.capture_piece(move.position_name_to)
		state.move_piece(move.position_name_from, move.position_name_to)

	static func get_valid_move(state:ChessState, position_name_from:String) -> Array[Move]:
		var directions:PackedVector2Array = [Vector2i(-1, 0), Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, 0)]
		var output:Array[Move] = []
		for iter:Vector2i in directions:
			var position_name_to:String = Chess.direction_to(position_name_from, iter)
			while position_name_to && (!state.has_piece(position_name_to) || state.get_piece(position_name_from).group != state.get_piece(position_name_to).group):
				output.push_back(Chess.create_move(position_name_from, position_name_to, ""))
				if state.has_piece(position_name_to) && state.get_piece(position_name_from).group != state.get_piece(position_name_to).group:
					break
				position_name_to = Chess.direction_to(position_name_to, iter)
				if state.has_piece(position_name_to) && state.get_piece(position_name_from).group == state.get_piece(position_name_to).group && state.get_piece(position_name_to).class_type.get_name() == "King":
					var group:int = state.get_piece(position_name_to).group
					if iter == Vector2i(-1, 0) && (group == 0 && (state.castle & 0x8) || group == 1 && (state.castle & 0x2)):
						output.push_back(Chess.create_move(position_name_to, "g" + ("1" if group == 0 else "8"), position_name_from))
					elif iter == Vector2i(1, 0) && (group == 0 && (state.castle & 0x4) || group == 1 && (state.castle & 0x1)):
						output.push_back(Chess.create_move(position_name_to, "c" + ("1" if group == 0 else "8"), position_name_from))
		return output

	static func get_value() -> float:
		return 5

class PieceBishop extends PieceInterface:
	static func get_name() -> String:
		return "Bishop"

	static func create_instance(position_name:String, group:int) -> PieceInstance:
		var packed_scene:PackedScene = load("res://scene/piece_bishop.tscn")
		var instance:PieceInstance = packed_scene.instantiate()
		instance.position_name = position_name
		instance.group = group
		return instance

	static func execute_move(state:ChessState, move:Move) -> void:
		if state.has_piece(move.position_name_to):
			state.capture_piece(move.position_name_to)
		state.move_piece(move.position_name_from, move.position_name_to)

	static func get_valid_move(state:ChessState, position_name_from:String) -> Array[Move]:
		var directions:PackedVector2Array = [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]
		var output:Array[Move] = []
		for iter:Vector2i in directions:
			var position_name_to:String = Chess.direction_to(position_name_from, iter)
			while position_name_to && (!state.has_piece(position_name_to) || state.get_piece(position_name_from).group != state.get_piece(position_name_to).group):
				output.push_back(Chess.create_move(position_name_from, position_name_to, ""))
				if state.has_piece(position_name_to) && state.get_piece(position_name_from).group != state.get_piece(position_name_to).group:
					break
				position_name_to = Chess.direction_to(position_name_to, iter)
		return output

	static func get_value() -> float:
		return 3.5

class PieceKnight extends PieceInterface:
	static func get_name() -> String:
		return "Knight"

	static func create_instance(position_name:String, group:int) -> PieceInstance:
		var packed_scene:PackedScene = load("res://scene/piece_knight.tscn")
		var instance:PieceInstance = packed_scene.instantiate()
		instance.position_name = position_name
		instance.group = group
		return instance

	static func execute_move(state:ChessState, move:Move) -> void:
		if state.has_piece(move.position_name_to):
			state.capture_piece(move.position_name_to)
		state.move_piece(move.position_name_from, move.position_name_to)

	static func get_valid_move(state:ChessState, position_name_from:String) -> Array[Move]:
		var directions:PackedVector2Array = [Vector2i(1, 2), Vector2i(2, 1), Vector2i(-1, 2), Vector2i(-2, 1), Vector2i(1, -2), Vector2i(2, -1), Vector2i(-1, -2), Vector2i(-2, -1)]
		var output:Array[Move] = []
		for iter:Vector2i in directions:
			var position_name_to:String = Chess.direction_to(position_name_from, iter)
			if !position_name_to || state.has_piece(position_name_to) && state.get_piece(position_name_from).group == state.get_piece(position_name_to).group:
				continue
			output.push_back(Chess.create_move(position_name_from, position_name_to, ""))
		return output

	static func get_value() -> float:
		return 3.5

class PiecePawn extends PieceInterface:
	static func get_name() -> String:
		return "Pawn"

	static func create_instance(position_name:String, group:int) -> PieceInstance:
		var packed_scene:PackedScene = load("res://scene/piece_pawn.tscn")
		var instance:PieceInstance = packed_scene.instantiate()
		instance.position_name = position_name
		instance.group = group
		return instance

	static func execute_move(state:ChessState, move:Move) -> void:
		var forward:Vector2i = Vector2i(0, 1) if state.get_piece(move.position_name_from).group == 0 else Vector2i(0, -1)
		if Chess.to_piece_position(move.position_name_to) - Chess.to_piece_position(move.position_name_from) == forward * 2:
			state.en_passant = Chess.direction_to(move.position_name_from, forward)
		if state.has_piece(move.position_name_to):
			state.capture_piece(move.position_name_to)
		if move.position_name_to == state.en_passant:
			var captured_position_name:String = Chess.direction_to(move.position_name_to, -forward)
			state.capture_piece(captured_position_name)
		state.move_piece(move.position_name_from, move.position_name_to)

	static func get_valid_move(state:ChessState, position_name_from:String) -> Array[Move]:
		var output:Array[Move] = []
		var forward:Vector2i = Vector2i(0, 1) if state.get_piece(position_name_from).group == 0 else Vector2i(0, -1)
		var on_start:bool = state.get_piece(position_name_from).group == 0 && position_name_from[1] == "2" || state.get_piece(position_name_from).group == 1 && position_name_from[1] == "7"
		var position_name_to:String = Chess.direction_to(position_name_from, forward)
		var position_name_to_2:String = Chess.direction_to(position_name_from, forward * 2)
		var position_name_to_l:String = Chess.direction_to(position_name_to, Vector2i(1, 0))
		var position_name_to_r:String = Chess.direction_to(position_name_to, Vector2i(-1, 0))
		if !state.has_piece(position_name_to):
			output.push_back(Chess.create_move(position_name_from, position_name_to, ""))
			if on_start && !state.has_piece(position_name_to_2):
				output.push_back(Chess.create_move(position_name_from, position_name_to_2, ""))
		if position_name_to_l && (state.has_piece(position_name_to_l) && state.get_piece(position_name_from).group != state.get_piece(position_name_to_l).group || position_name_to_l == state.en_passant):
			output.push_back(Chess.create_move(position_name_from, position_name_to_l, ""))
		if position_name_to_r && (state.has_piece(position_name_to_r) && state.get_piece(position_name_from).group != state.get_piece(position_name_to_r).group || position_name_to_r == state.en_passant):
			output.push_back(Chess.create_move(position_name_from, position_name_to_r, ""))
		return output
	static func get_value() -> float:
		return 1

class RuleInterface:
	static func is_move_valid(_state:ChessState, _move:Move) -> bool:
		return true

class RuleStandard extends RuleInterface:
	static func is_move_valid(_state:ChessState, _move:Move) -> bool:
		return true

class ChessMoveBranch:
	var state:ChessState = null
	var branch:ChessMoveBranchNode = null	# 树形结构，只包含步数
	var current_node:ChessMoveBranchNode = null

	func _init() -> void:
		branch = ChessMoveBranchNode.new()
		current_node = branch
		current_node.time = Time.get_unix_time_from_system()

	func execute_move(move:Move) -> void:
		var next_move:ChessMoveBranchNode = ChessMoveBranchNode.new()
		next_move.state = state.duplicate()
		next_move.time = Time.get_unix_time_from_system()
		next_move.parent = current_node
		next_move.state.execute_move(move)
		current_node.children[move] = next_move
		current_node = next_move	# 来到下一个节点
	
	func dfs(forward_step:int = 10) -> void:
		if forward_step <= 0:
			state.score = state.score_state()	# 叶子节点
			return
		var move_list:Array[Move] = state.get_all_move()
		var best_score:float = 0
		for move:Move in move_list:
			state.execute_move(move)
			dfs(forward_step - 1)
			# 当前分支评价完分数后，跟其他分支比较一下
			if state.step % 2 == 1:	# 子分支位置是轮到对方下棋，意味着余数为1时则是白方造成的结果
				best_score = max(state.score, best_score)	# 这个结果对于白方来讲是score越大越好
			else:
				best_score = min(state.score, best_score)	# 黑方反之
			state.rollback()	# DFS回溯，共享资源需要回到原先状态
		state.score = best_score

class ChessMoveBranchNode:
	var state:ChessState = null
	var time:float = 0	# 节点添加时的时间，可以根据父节点和当前节点的时间差来求出思考时间
	var children:Dictionary[Move, ChessMoveBranchNode] = {}
	var score:float = 0
	var parent:ChessMoveBranchNode = null

class ChessState:
	signal piece_moved(position_name_from:String, position_name_to:String)
	signal piece_removed(position_name:String)
	var current:Dictionary[String, Piece] = {}
	var notation:PackedStringArray = []
	var step:int = 0
	var castle:int = 15
	var en_passant:String = ""
	var king_passant:PackedStringArray = []	# 易位时经过的格子，由于王车易位的起始位置比较多变，有可能会让王经过更多或更少的格子
	var rule:Object = RuleInterface
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
		rule = RuleStandard	# 标准规则
	
	func duplicate() -> ChessState:
		var new_state:ChessState = ChessState.new()
		new_state.current = current.duplicate(true)
		new_state.notation = notation.duplicate()
		new_state.step = step
		new_state.castle = castle
		new_state.en_passant = en_passant
		new_state.king_passant = king_passant
		new_state.rule = rule
		return new_state
	
	func get_piece_instance(position_name:String) -> PieceInstance:
		return current[position_name].class_type.create_instance(position_name, current[position_name].group)

	func get_piece(position_name:String) -> Piece:
		if !position_name || !current.has(position_name):
			return null
		return current[position_name]

	func has_piece(position_name:String) -> bool:
		return current.has(position_name)

	func is_move_valid(position_name_from:String, position_name_to:String) -> bool:
		if !position_name_from || !position_name_to || !current.has(position_name_from):
			return false
		return get_valid_move(position_name_from).has(position_name_to)

	func get_valid_move(position_name_from:String) -> Array[Move]:
		if has_piece(position_name_from):
			return current[position_name_from].class_type.get_valid_move(self, position_name_from)
		return []

	func execute_move(move:Move) -> void:
		step += 1
		var last_en_passant:String = en_passant
		if has_piece(move.position_name_from):
			current[move.position_name_from].class_type.execute_move(self, move)
		if last_en_passant == en_passant:
			en_passant = ""

	func add_piece(position_name:String, piece:Piece) -> void:	# 作为吃子的逆运算
		current[position_name] = piece

	func capture_piece(position_name:String) -> void:
		current.erase(position_name)	# 虽然大多数情况是攻击者移到被攻击者上，但是吃过路兵是例外，后续可能会出现类似情况，所以还是得手多一下
		piece_removed.emit(position_name)

	func move_piece(position_name_from:String, position_name_to:String) -> void:
		var piece:Piece = get_piece(position_name_from)
		current.erase(position_name_from)
		current[position_name_to] = piece
		piece_moved.emit(position_name_from, position_name_to)

	func add_notation(expression:String) -> void:
		notation.push_back(expression)

	func pop_notation() -> void:
		notation.resize(notation.size() - 1)

	func score_state() -> float:
		var sum:float = 0
		for key:String in current:
			sum += current[key].class_type.get_value() * (1 if current[key].group == 0 else -1)
		return sum
	
	func get_all_move(rule_filter:bool = false) -> Array[Move]:
		var output:Array[Move] = []
		var test_state:ChessState = self.duplicate()
		for position_name_from:String in current:
			if step % 2 == current[position_name_from].group:	# 得是其中轮到的一方
				var piece_move_list:Array[Move] = current[position_name_from].class_type.get_valid_move(test_state, position_name_from)
				for move:Move in piece_move_list:
					if !rule_filter || rule.is_move_valid(test_state, move):
						output.push_back(move)
		return output

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
