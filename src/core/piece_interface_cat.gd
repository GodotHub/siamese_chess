extends PieceInterface
class_name PieceInterfaceCat

const directions:PackedInt32Array = [-17, -16, -15, -1, 1, 15, 16, 17]

static func get_name() -> String:
	return "Cat"

static func create_instance(from:int, group:int) -> PieceInstance:
	var packed_scene:PackedScene = load("res://scene/piece_feral_cat.tscn")
	var instance:PieceInstance = packed_scene.instantiate()
	instance.position_name = Chess.to_position_name(from)
	instance.group = group
	return instance

static func create_event(_state:ChessState, _move:int) -> Array[ChessEvent]:
	var output:Array[ChessEvent] = []
	output.push_back(ChessEvent.MovePiece.create(Move.from(_move), Move.to(_move)))
	return output

static func get_valid_move(_state:ChessState, _from:int) -> PackedInt32Array:
	var output:PackedInt32Array = []
	for iter:int in directions:
		var to:int = _from + iter
		if to & 0x88 || _state.has_piece(to) && _state.get_piece(_from).group == _state.get_piece(to).group:
			continue
		output.push_back(Move.create(_from, to, 0))
	return output
