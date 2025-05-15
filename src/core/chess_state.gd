extends Object
class_name ChessState

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


static func create_from_fen(fen:String) -> ChessState:
	var piece_mapping:Dictionary = {
		"K": {"class": "res://src/core/piece_interface_king.gd", "group": 0},
		"Q": {"class": "res://src/core/piece_interface_queen.gd", "group": 0},
		"R": {"class": "res://src/core/piece_interface_rook.gd", "group": 0},
		"N": {"class": "res://src/core/piece_interface_knight.gd", "group": 0},
		"B": {"class": "res://src/core/piece_interface_bishop.gd", "group": 0},
		"P": {"class": "res://src/core/piece_interface_pawn.gd", "group": 0},
		"k": {"class": "res://src/core/piece_interface_king.gd", "group": 1},
		"q": {"class": "res://src/core/piece_interface_queen.gd", "group": 1},
		"r": {"class": "res://src/core/piece_interface_rook.gd", "group": 1},
		"n": {"class": "res://src/core/piece_interface_knight.gd", "group": 1},
		"b": {"class": "res://src/core/piece_interface_bishop.gd", "group": 1},
		"p": {"class": "res://src/core/piece_interface_pawn.gd", "group": 1},
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
			state.current[Chess.to_position_name(pointer)] = Piece.create(load(piece_mapping[fen_splited[0][i]]["class"]), piece_mapping[fen_splited[0][i]]["group"])
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
