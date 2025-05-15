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

func create_state_from_fen(fen:String) -> ChessState:
	var piece_mapping:Dictionary = {
		"K": Chess.create_piece(PieceInterfaceKing, 0),
		"Q": Chess.create_piece(PieceInterfaceQueen, 0),
		"R": Chess.create_piece(PieceInterfaceRook, 0),
		"N": Chess.create_piece(PieceInterfaceKnight, 0),
		"B": Chess.create_piece(PieceInterfaceBishop, 0),
		"P": Chess.create_piece(PieceInterfacePawn, 0),
		"k": Chess.create_piece(PieceInterfaceKing, 1),
		"q": Chess.create_piece(PieceInterfaceQueen, 1),
		"r": Chess.create_piece(PieceInterfaceRook, 1),
		"n": Chess.create_piece(PieceInterfaceKnight, 1),
		"b": Chess.create_piece(PieceInterfaceBishop, 1),
		"p": Chess.create_piece(PieceInterfacePawn, 1),
	}
	var state:ChessState = ChessState.new()
	var pointer:Vector2i = Vector2i(0, 7)
	var fen_splited:PackedStringArray = fen.split(" ")
	if fen_splited.size() < 6:
		return null
	for i:int in range(fen_splited[0].length()):
		if fen_splited[0][i] == "/":
			pointer.x = 0
			pointer.y -= 1
		elif fen_splited[0][i].is_valid_int():
			pointer.x += fen_splited[0][i].to_int()
		elif piece_mapping.has(fen_splited[0][i]):
			state.current[Chess.to_position_name(pointer)] = piece_mapping[fen_splited[0][i]]
			pointer.x += 1
		else:
			return null
	if pointer.x != 8 || pointer.y != 0:
		return null
	if fen_splited[1] == "w":
		state.step = 0
	elif fen_splited[1] == "b":
		state.step = 1
	else:
		return null
	state.castle = (int(fen_splited[2].contains("K")) << 3) + (int(fen_splited[2].contains("Q")) << 2) + (int(fen_splited[2].contains("k")) << 1) + (int(fen_splited[2].contains("q")) << 0)
	state.en_passant = fen_splited[3]
	if !fen_splited[5].is_valid_int():
		return null
	state.step += fen_splited[5].to_int() * 2 - 2
	return state

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

class ChessMoveBranch:
	var branch:ChessMoveBranchNode = null	# 树形结构，只包含步数
	var current_node:ChessMoveBranchNode = null
	func _init() -> void:
		branch = ChessMoveBranchNode.new()
		current_node = branch
		current_node.time = Time.get_unix_time_from_system()

	func set_state(_state:ChessState) -> void:
		if !is_instance_valid(_state):
			return
		current_node.state = _state
		current_node.group = _state.step % 2
	
	func get_state() -> ChessState:
		return current_node.state

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
