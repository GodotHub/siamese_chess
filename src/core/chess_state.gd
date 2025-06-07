extends RefCounted
class_name ChessState

enum ExtraType 
{
	TURN = 0,
	CASTLE = 1,
	EN_PASSANT = 2,
	TO_DRAW = 3,
	STEP = 4,
	KING_PASSANT = 5,
}

signal piece_added(position_name:String)
signal piece_moved(position_name_from:String, position_name_to:String)
signal piece_removed(position_name:String)
var pieces:Dictionary[String, Piece] = {}
var extra:PackedStringArray = []
var zobrist:int = 0

static func get_piece_mapping() -> Dictionary:
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
			"猫": {"class": "res://src/core/piece_interface_cat.gd", "group": 0},
			"#": {"class": "res://src/core/piece_interface_shrub.gd", "group": 0},
			"k": {"class": "res://src/core/piece_interface_king.gd", "group": 1},
			"q": {"class": "res://src/core/piece_interface_queen.gd", "group": 1},
			"r": {"class": "res://src/core/piece_interface_rook.gd", "group": 1},
			"n": {"class": "res://src/core/piece_interface_knight.gd", "group": 1},
			"b": {"class": "res://src/core/piece_interface_bishop.gd", "group": 1},
			"p": {"class": "res://src/core/piece_interface_pawn.gd", "group": 1},
			"貓": {"class": "res://src/core/piece_interface_cat.gd", "group": 1},
			"$": {"class": "res://src/core/piece_interface_shrub.gd", "group": 1},
		}
		file_mapping.store_string(JSON.stringify(piece_mapping, "\t"))	# 注意排版，玩家会看的
		file_mapping.close()
	else:
		piece_mapping = JSON.parse_string(file_mapping.get_as_text())
		file_mapping.close()
	return piece_mapping

static func create_from_fen(fen:String) -> ChessState:
	var piece_mapping:Dictionary = get_piece_mapping()
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
			state.add_piece(Chess.to_position_name(pointer), Piece.create(load(piece_mapping[fen_splited[0][i]]["class"]), piece_mapping[fen_splited[0][i]]["group"]))
			pointer.x += 1
		else:
			return null
	if pointer.x != 8 || pointer.y != 0:
		return null
	if !(fen_splited[1] in ["w", "b"]):
		return null
	if !fen_splited[5].is_valid_int():
		return null
	state.reserve_extra(6)
	for i:int in range(1, fen_splited.size()):
		state.set_extra(i - 1, fen_splited[i])
	return state

static func zobrist_hash_piece(piece:Piece, position_name:String) -> int:
	seed(("%s%d%s" % [piece.class_type.get_name(), piece.group, position_name]).hash())
	return randi() + randi() << 32

static func zobrist_hash_extra(_index:int, _extra:String) -> int:
	seed(("%d%s" % [_index, _extra]).hash())
	return randi() + randi() << 32

func stringify() -> String:
	var piece_mapping:Dictionary = get_piece_mapping()
	var abbrevation_mapping:Dictionary = {}
	for abbrevation:String in piece_mapping:
		var path:String = piece_mapping[abbrevation]["class"]
		var group:int = piece_mapping[abbrevation]["group"]
		abbrevation_mapping[path + ":%d" % group] = abbrevation
	var null_counter:int = 0
	var chessboard:PackedStringArray = []
	for i:int in range(7, -1, -1):
		var line:String = ""
		for j:int in range(8):
			var position_name:String = Chess.to_position_name(Vector2i(j, i))
			if pieces.has(position_name):
				if null_counter:
					line += "%d" % null_counter
					null_counter = 0
				line += abbrevation_mapping[pieces[position_name].class_type.resource_path + ":%d" % pieces[position_name].group]
			else:
				null_counter += 1
		if null_counter:
			line += "%d" % null_counter
			null_counter = 0
		chessboard.append(line)
	var output:PackedStringArray = ["/".join(chessboard)]
	output.append_array(extra)
	return " ".join(output)

func duplicate() -> ChessState:
	var new_state:ChessState = ChessState.new()
	new_state.pieces = pieces.duplicate(true)
	new_state.extra = extra.duplicate()
	new_state.zobrist = zobrist
	return new_state

static func is_equal(state_a:ChessState, state_b:ChessState) -> bool:
	return state_a.pieces == state_b.pieces

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

func create_event(move:Move, simplified:bool = false) -> Array[ChessEvent]:
	var output:Array[ChessEvent] = []
	if !simplified:
		if pieces[move.position_name_from].group == 1:
			output.push_back(ChessEvent.ChangeExtra.create(4, get_extra(4), "%d" % (get_extra(5).to_int() + 1)))
			output.push_back(ChessEvent.ChangeExtra.create(0, get_extra(0), "w"))
		elif pieces[move.position_name_from].group == 0:
			output.push_back(ChessEvent.ChangeExtra.create(0, get_extra(0), "b"))
	output.append_array(pieces[move.position_name_from].class_type.create_event(self, move))
	if get_extra(2) != "-":
		output.push_back(ChessEvent.ChangeExtra.create(2, get_extra(2), "-"))
	if get_extra(5) != "-":
		output.push_back(ChessEvent.ChangeExtra.create(5, get_extra(5), "-"))
	return output

func apply_event(events:Array[ChessEvent]) -> void:
	for iter:ChessEvent in events:
		iter.apply_change(self)

func rollback_event(events:Array[ChessEvent]) -> void:
	for i:int in range(events.size() - 1, -1, -1):
		events[i].rollback_change(self)

func add_piece(_position_name:String, _piece:Piece) -> void:	# 作为吃子的逆运算
	pieces[_position_name] = _piece
	zobrist ^= zobrist_hash_piece(_piece, _position_name)
	piece_added.emit(_position_name)

func capture_piece(_position_name:String) -> void:
	if pieces.has(_position_name):
		zobrist ^= zobrist_hash_piece(pieces[_position_name], _position_name)
		pieces.erase(_position_name)	# 虽然大多数情况是攻击者移到被攻击者上，但是吃过路兵是例外，后续可能会出现类似情况，所以还是得手多一下
		piece_removed.emit(_position_name)

func move_piece(_position_name_from:String, _position_name_to:String) -> void:
	var _piece:Piece = get_piece(_position_name_from)
	zobrist ^= zobrist_hash_piece(_piece, _position_name_from)
	zobrist ^= zobrist_hash_piece(_piece, _position_name_to)
	pieces.erase(_position_name_from)
	pieces[_position_name_to] = _piece
	piece_moved.emit(_position_name_from, _position_name_to)

func get_extra(index:int) -> String:
	if index < extra.size():
		return extra[index]
	return "-"

func set_extra(index:int, value:String) -> void:
	if index < extra.size():
		zobrist ^= zobrist_hash_extra(index, extra[index])
		zobrist ^= zobrist_hash_extra(index, value)
		extra[index] = value

func reserve_extra(size:int) -> void:	# 预留空间
	while extra.size() < size:
		zobrist ^= zobrist_hash_extra(extra.size(), "-")
		extra.push_back("-")

func get_all_move(group:int) -> Array[Move]:	# 指定阵营
	var output:Array[Move] = []
	for position_name_from:String in pieces:
		if group == pieces[position_name_from].group:	# 当前阵营
			output.append_array(pieces[position_name_from].class_type.get_valid_move(self, position_name_from))
	return output
