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
	var comment:String
	func stringify() -> String:
		return position_name_from + "|" + position_name_to + "|" + extra + "|" + comment

func parse_move(move_str:String) -> Move:
	var str_list:PackedStringArray = move_str.split("|")
	return Chess.create_move(str_list[0], str_list[1], str_list[2], str_list[3])

func create_move(position_name_from:String, position_name_to:String, extra:String, comment:String) -> Move:
	var new_move:Move = Move.new()
	new_move.position_name_from = position_name_from
	new_move.position_name_to = position_name_to
	new_move.extra = extra
	new_move.comment = comment
	return new_move

func create_state_from_fen(fen:String) -> void:
	for i:int in range(fen.length()):
		pass

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
		if move.position_name_to in state.king_passant:
			# 直接拿下国王判定胜利吧（唉）
			if state.get_piece(move.position_name_from).group == 0:
				state.capture_piece("c8")
				state.capture_piece("g8")	# 两边全吃了也行，虽然不够优雅
			else:
				state.capture_piece("c1")
				state.capture_piece("g1")

		if state.get_piece(move.position_name_from).group == 0:
			state.castle &= 3
		else:
			state.castle &= 12
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
			# 在move.position_name_from到move.position_name_to之间设置king_passant
			var piece_position_from:Vector2i = Chess.to_piece_position(move.position_name_from)
			var piece_position_to:Vector2i = Chess.to_piece_position(move.position_name_to)
			state.king_passant = []
			for i:int in range(piece_position_from.x, piece_position_to.x + (1 if piece_position_from.x < piece_position_to.x else -1), 1 if piece_position_from.x < piece_position_to.x else -1):
				for j:int in range(piece_position_from.y, piece_position_to.y + (1 if piece_position_from.y < piece_position_to.y else -1), 1 if piece_position_from.y < piece_position_to.y else -1):
					state.king_passant.push_back(Chess.to_position_name(Vector2(i, j)))

	static func get_valid_move(state:ChessState, position_name_from:String) -> Array[Move]:
		var directions:PackedVector2Array = [Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1)]
		var output:Array[Move] = []
		for iter:Vector2i in directions:
			var position_name_to:String = Chess.direction_to(position_name_from, iter)
			if !position_name_to || state.has_piece(position_name_to) && state.get_piece(position_name_from).group == state.get_piece(position_name_to).group:
				continue
			output.push_back(Chess.create_move(position_name_from, position_name_to, "", "Default"))
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
		if move.position_name_to in state.king_passant:
			# 直接拿下国王判定胜利吧（唉）
			if state.get_piece(move.position_name_from).group == 0:
				state.capture_piece("c8")
				state.capture_piece("g8")
			else:
				state.capture_piece("c1")
				state.capture_piece("g1")

		state.move_piece(move.position_name_from, move.position_name_to)

	static func get_valid_move(state:ChessState, position_name_from:String) -> Array[Move]:
		var directions:PackedVector2Array = [Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1)]
		var output:Array[Move] = []
		for iter:Vector2i in directions:
			var position_name_to:String = Chess.direction_to(position_name_from, iter)
			while position_name_to && (!state.has_piece(position_name_to) || state.get_piece(position_name_from).group != state.get_piece(position_name_to).group):
				output.push_back(Chess.create_move(position_name_from, position_name_to, "", "Default"))
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
		if Chess.to_piece_position(move.position_name_from).x >= 4:
			state.castle &= 7 if state.get_piece(move.position_name_from).group == 0 else 13
		elif Chess.to_piece_position(move.position_name_from).x <= 3:
			state.castle &= 11 if state.get_piece(move.position_name_from).group == 0 else 15
		if state.has_piece(move.position_name_to):
			state.capture_piece(move.position_name_to)
		if move.position_name_to in state.king_passant:
			# 直接拿下国王判定胜利吧（唉）
			if state.get_piece(move.position_name_from).group == 0:
				state.capture_piece("c8")
				state.capture_piece("g8")
			else:
				state.capture_piece("c1")
				state.capture_piece("g1")
		state.move_piece(move.position_name_from, move.position_name_to)

	static func get_valid_move(state:ChessState, position_name_from:String) -> Array[Move]:
		var directions:PackedVector2Array = [Vector2i(-1, 0), Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, 0)]
		var output:Array[Move] = []
		for iter:Vector2i in directions:
			var position_name_to:String = Chess.direction_to(position_name_from, iter)
			while position_name_to && (!state.has_piece(position_name_to) || state.get_piece(position_name_from).group != state.get_piece(position_name_to).group):
				output.push_back(Chess.create_move(position_name_from, position_name_to, "", "Default"))
				if state.has_piece(position_name_to) && state.get_piece(position_name_from).group != state.get_piece(position_name_to).group:
					break
				position_name_to = Chess.direction_to(position_name_to, iter)
				if state.has_piece(position_name_to) && state.get_piece(position_name_from).group == state.get_piece(position_name_to).group && state.get_piece(position_name_to).class_type.get_name() == "King":
					var group:int = state.get_piece(position_name_to).group
					if Chess.to_piece_position(position_name_from).x >= 4 && (group == 0 && (state.castle & 0x8) || group == 1 && (state.castle & 0x2)):
						output.push_back(Chess.create_move(position_name_to, "g" + ("1" if group == 0 else "8"), position_name_from, "Short Castling"))
					elif Chess.to_piece_position(position_name_from).x <= 3 && (group == 0 && (state.castle & 0x4) || group == 1 && (state.castle & 0x1)):
						output.push_back(Chess.create_move(position_name_to, "c" + ("1" if group == 0 else "8"), position_name_from, "Long Castling"))
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
		if move.position_name_to in state.king_passant:
			# 直接拿下国王判定胜利吧（唉）
			if state.get_piece(move.position_name_from).group == 0:
				state.capture_piece("c8")
				state.capture_piece("g8")
			else:
				state.capture_piece("c1")
				state.capture_piece("g1")
		state.move_piece(move.position_name_from, move.position_name_to)

	static func get_valid_move(state:ChessState, position_name_from:String) -> Array[Move]:
		var directions:PackedVector2Array = [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]
		var output:Array[Move] = []
		for iter:Vector2i in directions:
			var position_name_to:String = Chess.direction_to(position_name_from, iter)
			while position_name_to && (!state.has_piece(position_name_to) || state.get_piece(position_name_from).group != state.get_piece(position_name_to).group):
				output.push_back(Chess.create_move(position_name_from, position_name_to, "", "Default"))
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
		if move.position_name_to in state.king_passant:
			# 直接拿下国王判定胜利吧（唉）
			if state.get_piece(move.position_name_from).group == 0:
				state.capture_piece("c8")
				state.capture_piece("g8")
			else:
				state.capture_piece("c1")
				state.capture_piece("g1")
		state.move_piece(move.position_name_from, move.position_name_to)

	static func get_valid_move(state:ChessState, position_name_from:String) -> Array[Move]:
		var directions:PackedVector2Array = [Vector2i(1, 2), Vector2i(2, 1), Vector2i(-1, 2), Vector2i(-2, 1), Vector2i(1, -2), Vector2i(2, -1), Vector2i(-1, -2), Vector2i(-2, -1)]
		var output:Array[Move] = []
		for iter:Vector2i in directions:
			var position_name_to:String = Chess.direction_to(position_name_from, iter)
			if !position_name_to || state.has_piece(position_name_to) && state.get_piece(position_name_from).group == state.get_piece(position_name_to).group:
				continue
			output.push_back(Chess.create_move(position_name_from, position_name_to, "", "Default"))
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
		if move.position_name_to in state.king_passant:
			# 直接拿下国王判定胜利吧（唉）
			if state.get_piece(move.position_name_from).group == 0:
				state.capture_piece("c8")
				state.capture_piece("g8")
			else:
				state.capture_piece("c1")
				state.capture_piece("g1")
		if move.extra:
			match move.extra:
				"Q":
					state.add_piece(move.position_name_to, Chess.create_piece(PieceQueen, state.get_piece(move.position_name_from).group))
				"R":
					state.add_piece(move.position_name_to, Chess.create_piece(PieceRook, state.get_piece(move.position_name_from).group))
				"N":
					state.add_piece(move.position_name_to, Chess.create_piece(PieceKnight, state.get_piece(move.position_name_from).group))
				"B":
					state.add_piece(move.position_name_to, Chess.create_piece(PieceBishop, state.get_piece(move.position_name_from).group))
			state.capture_piece(move.position_name_from)
		else:
			state.move_piece(move.position_name_from, move.position_name_to)

	static func get_valid_move(state:ChessState, position_name_from:String) -> Array[Move]:
		var output:Array[Move] = []
		var forward:Vector2i = Vector2i(0, 1) if state.get_piece(position_name_from).group == 0 else Vector2i(0, -1)
		var on_start:bool = state.get_piece(position_name_from).group == 0 && position_name_from[1] == "2" || state.get_piece(position_name_from).group == 1 && position_name_from[1] == "7"
		var position_name_to:String = Chess.direction_to(position_name_from, forward)
		var position_name_to_2:String = Chess.direction_to(position_name_from, forward * 2)
		var position_name_to_l:String = Chess.direction_to(position_name_to, Vector2i(1, 0))
		var position_name_to_r:String = Chess.direction_to(position_name_to, Vector2i(-1, 0))
		if position_name_to && !state.has_piece(position_name_to):
			if state.get_piece(position_name_from).group == 0 && position_name_to[1] == "8" || state.get_piece(position_name_from).group == 1 && position_name_to[1] == "1":
				output.push_back(Chess.create_move(position_name_from, position_name_to, "Q", "Promote to Queen"))
				output.push_back(Chess.create_move(position_name_from, position_name_to, "R", "Promote to Rook"))
				output.push_back(Chess.create_move(position_name_from, position_name_to, "N", "Promote to Knight"))
				output.push_back(Chess.create_move(position_name_from, position_name_to, "B", "Promote to Bishop"))
			else:
				output.push_back(Chess.create_move(position_name_from, position_name_to, "", "Default"))
			if on_start && !state.has_piece(position_name_to_2):
				output.push_back(Chess.create_move(position_name_from, position_name_to_2, "", "Default"))
		if position_name_to_l && (state.has_piece(position_name_to_l) && state.get_piece(position_name_from).group != state.get_piece(position_name_to_l).group || position_name_to_l == state.en_passant):
			if state.get_piece(position_name_from).group == 0 && position_name_to_l[1] == "8" || state.get_piece(position_name_from).group == 1 && position_name_to_l[1] == "1":
				output.push_back(Chess.create_move(position_name_from, position_name_to_l, "Q", "Promote to Queen"))
				output.push_back(Chess.create_move(position_name_from, position_name_to_l, "R", "Promote to Rook"))
				output.push_back(Chess.create_move(position_name_from, position_name_to_l, "N", "Promote to Knight"))
				output.push_back(Chess.create_move(position_name_from, position_name_to_l, "B", "Promote to Bishop"))
			else:
				output.push_back(Chess.create_move(position_name_from, position_name_to_l, "", "Default"))
		if position_name_to_r && (state.has_piece(position_name_to_r) && state.get_piece(position_name_from).group != state.get_piece(position_name_to_r).group || position_name_to_r == state.en_passant):
			if state.get_piece(position_name_from).group == 0 && position_name_to_r[1] == "8" || state.get_piece(position_name_from).group == 1 && position_name_to_r[1] == "1":
				output.push_back(Chess.create_move(position_name_from, position_name_to_r, "Q", "Promote to Queen"))
				output.push_back(Chess.create_move(position_name_from, position_name_to_r, "R", "Promote to Rook"))
				output.push_back(Chess.create_move(position_name_from, position_name_to_r, "N", "Promote to Knight"))
				output.push_back(Chess.create_move(position_name_from, position_name_to_r, "B", "Promote to Bishop"))
			else:
				output.push_back(Chess.create_move(position_name_from, position_name_to_r, "", "Default"))
		return output
	static func get_value() -> float:
		return 1

class ChessMoveBranch:
	var branch:ChessMoveBranchNode = null	# 树形结构，只包含步数
	var current_node:ChessMoveBranchNode = null
	func _init() -> void:
		branch = ChessMoveBranchNode.new()
		current_node = branch
		current_node.time = Time.get_unix_time_from_system()

	func create_branch(node:ChessMoveBranchNode, move:Move) -> ChessMoveBranchNode:
		var test_state:ChessState = node.state.duplicate()
		var group:int = test_state.get_piece(move.position_name_from).group
		test_state.execute_move(move)
		var next_branch_node:ChessMoveBranchNode = ChessMoveBranchNode.new()
		next_branch_node.state = test_state
		next_branch_node.time = Time.get_unix_time_from_system()
		next_branch_node.parent = node
		next_branch_node.group = 1 if group == 0 else 0
		node.children[move.stringify()] = next_branch_node
		if test_state.score > 100 || test_state.score < -100:
			node.dead = true
			next_branch_node.dead = true
			# TODO: 可以搜一下空着，空着没有吃王则判定逼和
		set_score(next_branch_node, test_state.score)
		return next_branch_node

	func execute_move(move:Move) -> void:
		if current_node.children.has(move.stringify()):
			current_node = current_node.children[move.stringify()]
		else:
			current_node = create_branch(current_node, move)

	func search(current_branch_node:ChessMoveBranchNode = null, depth:int = 2) -> void:
		if !is_instance_valid(current_branch_node):
			current_branch_node = current_node
		var move_list:Array[Move] = current_branch_node.state.get_all_move(current_branch_node.group)
		for move:Move in move_list:
			if !current_branch_node.children.has(move.stringify()):
				create_branch(current_branch_node, move)
			if depth && !current_branch_node.dead:	# 死棋不用继续搜
				search(current_branch_node.children[move.stringify()], depth - 1)

	func set_score(branch_node:ChessMoveBranchNode, score:float, is_leaf:bool = true) -> void:
		if is_leaf || branch_node.group == 1 && score < branch_node.score || branch_node.group == 0 && score > branch_node.score:
			branch_node.score = score
			if is_instance_valid(branch_node.parent):
				set_score(branch_node.parent, score, false)
	
	func get_best_move() -> Move:
		var best_move:Move = null
		for iter:String in current_node.children:
			if !current_node.children[iter].dead && (!is_instance_valid(best_move) || current_node.group == 1 && current_node.children[iter].score < current_node.children[best_move.stringify()].score || current_node.group == 0 && current_node.children[iter].score > current_node.children[best_move.stringify()].score):
				best_move = Chess.parse_move(iter)
		print_score(current_node)
		return best_move
	
	func print_score(branch_node:ChessMoveBranchNode, depth:int = 0) -> void:
		for iter_str:String in branch_node.children:
			var iter_move:Move = Chess.parse_move(iter_str)
			print(" ".repeat(depth) + iter_move.position_name_from + iter_move.position_name_to + ": " + ("%f" % branch_node.children[iter_str].score))
			#print_score(branch_node.children[iter], depth + 1)
		print("-----")


class ChessMoveBranchNode:
	var state:ChessState = null
	var group:int = 0
	var time:float = 0	# 节点添加时的时间，可以根据父节点和当前节点的时间差来求出思考时间
	var children:Dictionary[String, ChessMoveBranchNode] = {}
	var dead:bool = false # 当前着法出现吃王情况时，标记父节点和本身为dead，没有活的子节点，判定棋局结束
	var score:float = 0	# 这里的score并非ChessState的Score，是经过搜索后相对不片面的评分
	var parent:ChessMoveBranchNode = null

class ChessState:
	signal piece_added(position_name:String)
	signal piece_moved(position_name_from:String, position_name_to:String)
	signal piece_removed(position_name:String)
	var current:Dictionary[String, Piece] = {}
	var notation:PackedStringArray = []
	var step:int = 0
	var castle:int = 15
	var en_passant:String = ""
	var king_passant:PackedStringArray = []	# 易位时经过的格子，由于王车易位的起始位置比较多变，有可能会让王经过更多或更少的格子
	var score:int = 0
	func _init() -> void:
		add_piece("a1", Chess.create_piece(PieceRook, 0))
		add_piece("b1", Chess.create_piece(PieceKnight, 0))
		add_piece("c1", Chess.create_piece(PieceBishop, 0))
		add_piece("d1", Chess.create_piece(PieceQueen, 0))
		add_piece("e1", Chess.create_piece(PieceKing, 0))
		add_piece("f1", Chess.create_piece(PieceBishop, 0))
		add_piece("g1", Chess.create_piece(PieceKnight, 0))
		add_piece("h1", Chess.create_piece(PieceRook, 0))
		add_piece("a2", Chess.create_piece(PiecePawn, 0))
		add_piece("b2", Chess.create_piece(PiecePawn, 0))
		add_piece("c2", Chess.create_piece(PiecePawn, 0))
		add_piece("d2", Chess.create_piece(PiecePawn, 0))
		add_piece("e2", Chess.create_piece(PiecePawn, 0))
		add_piece("f2", Chess.create_piece(PiecePawn, 0))
		add_piece("g2", Chess.create_piece(PiecePawn, 0))
		add_piece("h2", Chess.create_piece(PiecePawn, 0))
		add_piece("a8", Chess.create_piece(PieceRook, 1))
		add_piece("b8", Chess.create_piece(PieceKnight, 1))
		add_piece("c8", Chess.create_piece(PieceBishop, 1))
		add_piece("d8", Chess.create_piece(PieceQueen, 1))
		add_piece("e8", Chess.create_piece(PieceKing, 1))
		add_piece("f8", Chess.create_piece(PieceBishop, 1))
		add_piece("g8", Chess.create_piece(PieceKnight, 1))
		add_piece("h8", Chess.create_piece(PieceRook, 1))
		add_piece("a7", Chess.create_piece(PiecePawn, 1))
		add_piece("b7", Chess.create_piece(PiecePawn, 1))
		add_piece("c7", Chess.create_piece(PiecePawn, 1))
		add_piece("d7", Chess.create_piece(PiecePawn, 1))
		add_piece("e7", Chess.create_piece(PiecePawn, 1))
		add_piece("f7", Chess.create_piece(PiecePawn, 1))
		add_piece("g7", Chess.create_piece(PiecePawn, 1))
		add_piece("h7", Chess.create_piece(PiecePawn, 1))
	
	func duplicate() -> ChessState:
		var new_state:ChessState = ChessState.new()
		new_state.current = current.duplicate(true)
		new_state.notation = notation.duplicate()
		new_state.step = step
		new_state.castle = castle
		new_state.en_passant = en_passant
		new_state.king_passant = king_passant.duplicate()
		new_state.score = score
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
		var last_king_passant:PackedStringArray = king_passant.duplicate()
		if has_piece(move.position_name_from):
			current[move.position_name_from].class_type.execute_move(self, move)
		if last_en_passant == en_passant:
			en_passant = ""
		if last_king_passant == king_passant:
			king_passant = []

	func add_piece(position_name:String, piece:Piece) -> void:	# 作为吃子的逆运算
		current[position_name] = piece
		score += piece.class_type.get_value() * (1 if piece.group == 0 else -1)
		piece_added.emit(position_name)

	func capture_piece(position_name:String) -> void:
		if current.has(position_name):
			score -= current[position_name].class_type.get_value() * (1 if current[position_name].group == 0 else -1)
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

	func get_score() -> float:
		return score
	
	func get_all_move(group:int) -> Array[Move]:	# 指定阵营
		var output:Array[Move] = []
		for position_name_from:String in current:
			if group == current[position_name_from].group:	# 当前阵营
				var piece_move_list:Array[Move] = current[position_name_from].class_type.get_valid_move(self, position_name_from)
				for move:Move in piece_move_list:
					output.push_back(move)
		return output

var current_chessboard:Chessboard = null
@onready var test_state:ChessState = ChessState.new()

func to_piece_position(position_name:String) -> Vector2i:
	if !position_name:
		return Vector2i(-1, -1)
	return Vector2i(position_name.unicode_at(0) - 97, position_name.unicode_at(1) - 49)

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
