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
var extra:PackedInt32Array = []
var history:Dictionary = {}
var evaluation:Object = null
var zobrist:int = 0
var score:int = 0

static func zobrist_hash_piece(piece:int, from:int) -> int:
	var key:int = piece + (from << 8)
	seed(key)
	return randi()

static func zobrist_hash_extra(_index:int, _extra:int) -> int:
	var key:int = _index + (_extra) << 8
	seed(key)
	return randi()

func duplicate() -> ChessState:
	var new_state:ChessState = ChessState.new()
	new_state.pieces = pieces.duplicate()
	new_state.extra = extra.duplicate()
	#new_state.history = history.duplicate()
	new_state.score = score
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

func add_piece(_by:int, _piece:int) -> void:	# 作为吃子的逆运算
	pieces[_by] = _piece
	score += evaluation.evaluate_add(self, _by, _piece)
	zobrist ^= zobrist_hash_piece(_piece, _by)
	piece_added.emit(_by)

func capture_piece(_by:int) -> void:
	if has_piece(_by):
		zobrist ^= zobrist_hash_piece(pieces[_by], _by)
		score += evaluation.evaluate_capture(self, _by)
		pieces[_by] = 0	# 虽然大多数情况是攻击者移到被攻击者上，但是吃过路兵是例外，后续可能会出现类似情况，所以还是得手多一下
		piece_removed.emit(_by)

func move_piece(_from:int, _to:int) -> void:
	var _piece:int = get_piece(_from)
	score += evaluation.evaluate_move(self, _from, _to)
	zobrist ^= zobrist_hash_piece(_piece, _from)
	zobrist ^= zobrist_hash_piece(_piece, _to)
	pieces[_to] = pieces[_from]
	pieces[_from] = 0
	piece_moved.emit(_from, _to)

func get_extra(index:int) -> int:
	if index < extra.size():
		return extra[index]
	return -1

func set_extra(index:int, value:int) -> void:
	if index < extra.size():
		#zobrist ^= zobrist_hash_extra(index, extra[index])
		#zobrist ^= zobrist_hash_extra(index, value)
		extra[index] = value

func reserve_extra(size:int) -> void:	# 预留空间
	while extra.size() < size:
		#zobrist ^= zobrist_hash_extra(extra.size(), -1)
		extra.push_back(-1)

func get_all_move(group:int) -> PackedInt32Array:	# 指定阵营
	return evaluation.generate_move(self, group)

func apply_move(_move:int) -> void:
	evaluation.apply_move(self, _move)

func get_relative_score(group:int) -> float:
	return score if group == 0 else -score
