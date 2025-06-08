extends RefCounted
class_name ChessEvent

func apply_change(_state:ChessState) -> void:
	pass

func rollback_change(_state:ChessState) -> void:
	pass

class MovePiece extends ChessEvent:
	var from:int
	var to:int
	static func create(_from:int, _to:int) -> MovePiece:
		var new_event:MovePiece = MovePiece.new()
		new_event.from = _from
		new_event.to = _to
		return new_event
	func apply_change(_state:ChessState) -> void:
		_state.move_piece(from, to)
	func rollback_change(_state:ChessState) -> void:
		_state.move_piece(to, from)

class CapturePiece extends ChessEvent:
	var by:int
	var piece:Piece
	static func create(_by:int, _piece:Piece) -> CapturePiece:
		var new_event:CapturePiece = CapturePiece.new()
		new_event.by = _by
		new_event.piece = _piece
		return new_event
	func apply_change(_state:ChessState) -> void:
		_state.capture_piece(by)
	func rollback_change(_state:ChessState) -> void:
		_state.add_piece(by, piece)

class AddPiece extends ChessEvent:
	var by:int
	var piece:Piece
	static func create(_by:int, _piece:Piece) -> AddPiece:
		var new_event:AddPiece = AddPiece.new()
		new_event.by = _by
		new_event.piece = _piece
		return new_event
	func apply_change(_state:ChessState) -> void:
		_state.add_piece(by, piece)
	func rollback_change(_state:ChessState) -> void:
		_state.capture_piece(by)

class ChangeExtra extends ChessEvent:
	var index:int
	var before:String
	var after:String
	static func create(_index:int, _before:String, _after:String) -> ChangeExtra:
		var new_event:ChangeExtra = ChangeExtra.new()
		new_event.index = _index
		new_event.before = _before
		new_event.after = _after
		return new_event
	func apply_change(_state:ChessState) -> void:
		_state.set_extra(index, after)
	func rollback_change(_state:ChessState) -> void:
		_state.set_extra(index, before)
