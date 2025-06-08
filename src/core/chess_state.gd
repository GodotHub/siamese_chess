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

signal piece_added(by:int)
signal piece_moved(from:int, to:int)
signal piece_removed(by:int)
var pieces:Array[Piece] = []
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
	state.pieces.resize(128)
	state.pieces.fill(null)
	var pointer:Vector2i = Vector2i(0, 0)
	var fen_splited:PackedStringArray = fen.split(" ")
	if fen_splited.size() < 6:
		return null
	for i:int in range(fen_splited[0].length()):
		if fen_splited[0][i] == "/":
			pointer.x = 0
			pointer.y += 1
		elif fen_splited[0][i].is_valid_int():
			pointer.x += fen_splited[0][i].to_int()
		elif piece_mapping.has(fen_splited[0][i]):
			state.add_piece(pointer.x + pointer.y * 16, Piece.create(load(piece_mapping[fen_splited[0][i]]["class"]), piece_mapping[fen_splited[0][i]]["group"]))
			pointer.x += 1
		else:
			return null
	if pointer.x != 8 || pointer.y != 7:
		return null
	if !(fen_splited[1] in ["w", "b"]):
		return null
	if !fen_splited[5].is_valid_int():
		return null
	state.reserve_extra(6)
	for i:int in range(1, fen_splited.size()):
		state.set_extra(i - 1, fen_splited[i])
	return state

static func zobrist_hash_piece(piece:Piece, from:int) -> int:
	var key:int = piece.class_type.get_name().hash() + from + piece.group
	seed(key)
	return randi()

static func zobrist_hash_extra(_index:int, _extra:String) -> int:
	var key:int = _index + _extra.hash()
	seed(key)
	return randi()

func stringify() -> String:
	var piece_mapping:Dictionary = get_piece_mapping()
	var abbrevation_mapping:Dictionary = {}
	for abbrevation:String in piece_mapping:
		var path:String = piece_mapping[abbrevation]["class"]
		var group:int = piece_mapping[abbrevation]["group"]
		abbrevation_mapping[path + ":%d" % group] = abbrevation
	var null_counter:int = 0
	var chessboard:PackedStringArray = []
	for i:int in range(8):
		var line:String = ""
		for j:int in range(8):
			if is_instance_valid(pieces[i * 16 + j]):
				if null_counter:
					line += "%d" % null_counter
					null_counter = 0
				line += abbrevation_mapping[pieces[i * 16 + j].class_type.resource_path + ":%d" % pieces[i * 16 + j].group]
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

func get_piece_instance(to:int) -> PieceInstance:
	return pieces[to].class_type.create_instance(to, pieces[to].group)

func get_piece(to:int) -> Piece:
	if to & 0x88 || !is_instance_valid(pieces[to]):
		return null
	return pieces[to]

func has_piece(to:int) -> bool:
	return !(to & 0x88) && is_instance_valid(pieces[to])

func get_valid_move(from:int) -> PackedInt32Array:
	if has_piece(from):
		return pieces[from].class_type.get_valid_move(self, from)
	return []

func create_event(move:int, simplified:bool = false) -> Array[ChessEvent]:
	var output:Array[ChessEvent] = []
	var from:int = Move.from(move)
	if !simplified:
		if pieces[from].group == 1:
			output.push_back(ChessEvent.ChangeExtra.create(4, get_extra(4), "%d" % (get_extra(5).to_int() + 1)))
			output.push_back(ChessEvent.ChangeExtra.create(0, get_extra(0), "w"))
		elif pieces[from].group == 0:
			output.push_back(ChessEvent.ChangeExtra.create(0, get_extra(0), "b"))
	output.append_array(pieces[from].class_type.create_event(self, move))
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

func add_piece(_to:int, _piece:Piece) -> void:	# 作为吃子的逆运算
	pieces[_to] = _piece
	zobrist ^= zobrist_hash_piece(_piece, _to)
	piece_added.emit(_to)

func capture_piece(_by:int) -> void:
	if has_piece(_by):
		zobrist ^= zobrist_hash_piece(pieces[_by], _by)
		pieces[_by] = null	# 虽然大多数情况是攻击者移到被攻击者上，但是吃过路兵是例外，后续可能会出现类似情况，所以还是得手多一下
		piece_removed.emit(_by)

func move_piece(_from:int, _to:int) -> void:
	var _piece:Piece = get_piece(_from)
	zobrist ^= zobrist_hash_piece(_piece, _from)
	zobrist ^= zobrist_hash_piece(_piece, _to)
	pieces[_to] = pieces[_from]
	pieces[_from] = null
	piece_moved.emit(_from, _to)

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

func get_all_move(group:int) -> PackedInt32Array:	# 指定阵营
	var output:PackedInt32Array = []
	for from:int in range(128):
		if !has_piece(from):
			continue
		if group == pieces[from].group:	# 当前阵营
			output.append_array(pieces[from].class_type.get_valid_move(self, from))
	return output
