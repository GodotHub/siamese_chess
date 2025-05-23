extends RefCounted
class_name ChessEvent

func apply_change(_state:ChessState) -> void:
	pass

func rollback_change(_state:ChessState) -> void:
	pass

class MovePiece extends ChessEvent:
	var position_name_from:String
	var position_name_to:String
	static func create(_position_name_from:String, _position_name_to:String) -> MovePiece:
		var new_event:MovePiece = MovePiece.new()
		new_event.position_name_from = _position_name_from
		new_event.position_name_to = _position_name_to
		return new_event
	func apply_change(_state:ChessState) -> void:
		_state.move_piece(position_name_from, position_name_to)
	func rollback_change(_state:ChessState) -> void:
		_state.move_piece(position_name_to, position_name_from)

class CapturePiece extends ChessEvent:
	var position_name:String
	var piece:Piece
	static func create(_position_name:String, _piece:Piece) -> CapturePiece:
		var new_event:CapturePiece = CapturePiece.new()
		new_event.position_name = _position_name
		new_event.piece = _piece
		return new_event
	func apply_change(_state:ChessState) -> void:
		_state.capture_piece(position_name)
	func rollback_change(_state:ChessState) -> void:
		_state.add_piece(position_name, piece)

class AddPiece extends ChessEvent:
	var position_name:String
	var piece:Piece
	static func create(_position_name:String, _piece:Piece) -> AddPiece:
		var new_event:AddPiece = AddPiece.new()
		new_event.position_name = _position_name
		new_event.piece = _piece
		return new_event
	func apply_change(_state:ChessState) -> void:
		_state.add_piece(position_name, piece)
	func rollback_change(_state:ChessState) -> void:
		_state.capture_piece(position_name)

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
