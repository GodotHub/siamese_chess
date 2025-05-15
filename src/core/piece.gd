extends Object
class_name Piece

var class_type:Object = PieceInterface
var group:int = 0

static func create(_class_type:Object, _group:int) -> Piece:
	var new_piece:Piece = Piece.new()
	new_piece.class_type = _class_type
	new_piece.group = _group
	return new_piece
