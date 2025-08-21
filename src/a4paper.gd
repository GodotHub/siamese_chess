extends InspectableItem

var document:Document = null

func _ready() -> void:
	if is_instance_valid(document):
		$sub_viewport.add_child(document)

func set_document(_document:Document) -> void:
	if is_instance_valid(document):
		$sub_viewport.remove_child(document)
	document = _document
	$sub_viewport.add_child(document)
