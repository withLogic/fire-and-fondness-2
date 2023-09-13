extends "res://objects/board/BoardObject.gd"

class_name Character

enum STATE {NORMAL, BURNED, CRUSHED, FALLEN, DOGGED, INLAWED}

onready var state : int = STATE.NORMAL

func is_character() -> bool:
	return true

func is_alive() -> bool:
	return state == STATE.NORMAL

func is_blocker() -> bool:
	return false

func is_flammable() -> bool:
	return is_alive()

func can_fall() -> bool:
	return is_alive()

func can_be_crushed() -> bool:
	return is_alive()

func burn() -> void:
	pass

func fall() -> void:
	pass

func crush() -> void:
	pass

func caught_by_dog() -> void:
	pass

func caught_by_inlaw() -> void:
	pass
