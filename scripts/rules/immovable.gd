extends BaseAlienRule
class_name Immovable

@export var required_item_id: String

func can_move(alien) -> bool:
	return false
