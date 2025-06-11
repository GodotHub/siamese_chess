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
var pieces:PackedInt32Array = []
var extra:PackedStringArray = []
var history:PackedInt64Array = []
var evaluation:Object = null
var zobrist:int = 0

static func create_from_fen(fen:String) -> ChessState:
	var state:ChessState = ChessState.new()
	state.pieces.resize(128)
	state.pieces.fill(0)
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
		elif fen_splited[0][i]:
			state.add_piece(pointer.x + pointer.y * 16, fen_splited[0].unicode_at(i))
			pointer.x += 1
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

static func zobrist_hash_piece(piece:int, from:int) -> int:
	var key:int = piece + (from << 8)
	seed(key)
	return randi()

static func zobrist_hash_extra(_index:int, _extra:String) -> int:
	var key:int = _index + _extra.hash()
	seed(key)
	return randi()

func stringify() -> String:
	var null_counter:int = 0
	var chessboard:PackedStringArray = []
	for i:int in range(8):
		var line:String = ""
		for j:int in range(8):
			if pieces[i * 16 + j]:
				if null_counter:
					line += "%d" % null_counter
					null_counter = 0
				line += char(pieces[i * 16 + j])
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
	new_state.pieces = pieces.duplicate()
	new_state.extra = extra.duplicate()
	new_state.evaluation = evaluation
	new_state.zobrist = zobrist
	return new_state

static func is_equal(state_a:ChessState, state_b:ChessState) -> bool:
	return state_a.pieces == state_b.pieces

func get_piece_instance(to:int) -> PieceInstance:
	return evaluation.get_piece_instance(to, pieces[to])

func get_piece(to:int) -> int:
	if to & 0x88:
		return 0
	return pieces[to]

func has_piece(to:int) -> bool:
	return !(to & 0x88) && pieces[to]

func create_event(move:int) -> Array[ChessEvent]:
	return evaluation.create_event(self, move)

func apply_event(events:Array[ChessEvent]) -> void:
	for iter:ChessEvent in events:
		iter.apply_change(self)

func rollback_event(events:Array[ChessEvent]) -> void:
	for i:int in range(events.size() - 1, -1, -1):
		events[i].rollback_change(self)

func add_piece(_to:int, _piece:int) -> void:	# 作为吃子的逆运算
	pieces[_to] = _piece
	zobrist ^= zobrist_hash_piece(_piece, _to)
	piece_added.emit(_to)

func capture_piece(_by:int) -> void:
	if has_piece(_by):
		zobrist ^= zobrist_hash_piece(pieces[_by], _by)
		pieces[_by] = 0	# 虽然大多数情况是攻击者移到被攻击者上，但是吃过路兵是例外，后续可能会出现类似情况，所以还是得手多一下
		piece_removed.emit(_by)

func move_piece(_from:int, _to:int) -> void:
	var _piece:int = get_piece(_from)
	zobrist ^= zobrist_hash_piece(_piece, _from)
	zobrist ^= zobrist_hash_piece(_piece, _to)
	pieces[_to] = pieces[_from]
	pieces[_from] = 0
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
	return evaluation.generate_move(self, group)
