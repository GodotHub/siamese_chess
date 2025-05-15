extends Object
class_name ChessState

signal piece_added(position_name:String)
signal piece_moved(position_name_from:String, position_name_to:String)
signal piece_removed(position_name:String)
var pieces:Dictionary[String, Piece] = {}
var extra:PackedStringArray = ["w", "KQkq", "-", "0", "1", "-"]
var score:int = 0

static func create_from_fen(fen:String) -> ChessState:
	var piece_mapping:Dictionary = {}
	var file_mapping:FileAccess = FileAccess.open("user://mapping.json", FileAccess.READ)
	if !is_instance_valid(file_mapping):
		file_mapping = FileAccess.open("user://mapping.json", FileAccess.WRITE)
		piece_mapping = {
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
		file_mapping.store_string(JSON.stringify(piece_mapping, "\t"))	# 注意排版，玩家会看的
		file_mapping.close()
	else:
		piece_mapping = JSON.parse_string(file_mapping.get_as_text())
		file_mapping.close()
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
			state.pieces[Chess.to_position_name(pointer)] = Piece.create(load(piece_mapping[fen_splited[0][i]]["class"]), piece_mapping[fen_splited[0][i]]["group"])
			pointer.x += 1
		else:
			return null
	if pointer.x != 8 || pointer.y != 0:
		return null
	if !(fen_splited[1] in ["w", "b"]):
		return null
	if !fen_splited[5].is_valid_int():
		return null
	for i:int in range(1, fen_splited.size()):
		state.extra.push_back(fen_splited[i])
	if state.extra.size() == 5:
		state.extra.push_back("-")
	return state

func duplicate() -> ChessState:
	var new_state:ChessState = ChessState.new()
	new_state.pieces = pieces.duplicate(true)
	new_state.extra = extra.duplicate()
	new_state.score = score
	return new_state

func get_piece_instance(position_name:String) -> PieceInstance:
	return pieces[position_name].class_type.create_instance(position_name, pieces[position_name].group)

func get_piece(position_name:String) -> Piece:
	if !position_name || !pieces.has(position_name):
		return null
	return pieces[position_name]

func has_piece(position_name:String) -> bool:
	return pieces.has(position_name)

func is_move_valid(position_name_from:String, position_name_to:String) -> bool:
	if !position_name_from || !position_name_to || !pieces.has(position_name_from):
		return false
	return get_valid_move(position_name_from).has(position_name_to)

func get_valid_move(position_name_from:String) -> Array[Move]:
	if has_piece(position_name_from):
		return pieces[position_name_from].class_type.get_valid_move(self, position_name_from)
	return []

func execute_move(move:Move) -> void:
	if extra[0] == "b":
		extra[5] = "%d" % (extra[5].to_int() + 1)
		extra[0] = "w"
	elif extra[0] == "w":
		extra[0] = "b"
	var last_en_passant:String = extra[3]
	var last_king_passant:String = extra[6]
	if has_piece(move.position_name_from):
		pieces[move.position_name_from].class_type.execute_move(self, move)
	if last_en_passant == extra[3]:
		extra[3] = "-"
	if last_king_passant == extra[6]:
		extra[6] = "-"

func add_piece(_position_name:String, _piece:Piece) -> void:	# 作为吃子的逆运算
	pieces[_position_name] = _piece
	score += _piece.class_type.get_value() * (1 if _piece.group == 0 else -1)
	piece_added.emit(_position_name)

func capture_piece(_position_name:String) -> void:
	if pieces.has(_position_name):
		score -= pieces[_position_name].class_type.get_value() * (1 if pieces[_position_name].group == 0 else -1)
		pieces.erase(_position_name)	# 虽然大多数情况是攻击者移到被攻击者上，但是吃过路兵是例外，后续可能会出现类似情况，所以还是得手多一下
		piece_removed.emit(_position_name)

func move_piece(_position_name_from:String, _position_name_to:String) -> void:
	var _piece:Piece = get_piece(_position_name_from)
	pieces.erase(_position_name_from)
	pieces[_position_name_to] = _piece
	piece_moved.emit(_position_name_from, _position_name_to)

func get_score() -> float:
	return score

func get_all_move(group:int) -> Array[Move]:	# 指定阵营
	var output:Array[Move] = []
	for position_name_from:String in pieces:
		if group == pieces[position_name_from].group:	# 当前阵营
			var piece_move_list:Array[Move] = pieces[position_name_from].class_type.get_valid_move(self, position_name_from)
			for move:Move in piece_move_list:
				output.push_back(move)
	return output
