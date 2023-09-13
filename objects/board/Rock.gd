extends "res://objects/board/BoardObject.gd"

class_name Rock

onready var sprite : Sprite = $Sprite

var destroyed : bool = false

var state_stack : Array

func can_be_destroyed() -> bool:
	return not destroyed

func is_blocker() -> bool:
	return not destroyed

func destroy() -> void:
	destroyed = true
	refresh_on_board()
	SoundMaster.play_sound("rock_break")

func refresh_on_board() -> void:
	position = board_position * TILE_SIZE
	sprite.frame = int(destroyed)

func save_state() -> void:
	state_stack.push_back(destroyed)

func revert_to_previous_state() -> void:
	if state_stack.size() > 1:
		state_stack.pop_back()
	destroyed = state_stack.back()
	refresh_on_board()

func to_json() -> Dictionary:
	return {
		"type": "rock",
		"board_position": [board_position.x, board_position.y],
		"destroyed": destroyed
	}
