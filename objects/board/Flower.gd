extends "res://objects/board/BoardObject.gd"

const SPRITE_FLOWER = preload("res://sprites/flower.png")
const SPRITE_ASH = preload("res://sprites/ash.png")

onready var sprite : Sprite = $Sprite

var collected : bool = false
var burned : bool = false

var state_stack : Array

func is_flammable() -> bool:
	return not burned and not collected

func burn() -> void:
	burned = true
	refresh_on_board()

func collect() -> void:
	SoundMaster.play_sound("flower_pickup")
	collected = true
	refresh_on_board()

func refresh_on_board() -> void:
	position = board_position * TILE_SIZE
	if burned:
		sprite.texture = SPRITE_ASH
	else:
		sprite.texture = SPRITE_FLOWER
	if collected:
		sprite.hide()
	else:
		sprite.show()

func save_state() -> void:
	state_stack.push_back([burned, collected])

func revert_to_previous_state() -> void:
	if state_stack.size() > 1:
		state_stack.pop_back()
	burned = state_stack.back()[0]
	collected = state_stack.back()[1]
	refresh_on_board()

func to_json() -> Dictionary:
	return {
		"type": "flower",
		"board_position": [board_position.x, board_position.y]
	}

