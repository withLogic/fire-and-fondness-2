extends Node

func reset_shunt_status() -> void:
	for mover in get_tree().get_nodes_in_group("mover"):
		mover.reset_shunt_status()

func can_act() -> bool:
	for mover in get_tree().get_nodes_in_group("mover"):
		if mover.can_act():
			return true
	return false

func act() -> void:
	var moved : Array = []
	for mover in get_tree().get_nodes_in_group("mover"):
		if mover.can_act():
			var movee = mover.get_movee()
			if not moved.has(movee):
				mover.act()
				moved.append(movee)
