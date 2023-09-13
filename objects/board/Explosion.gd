extends Node2D

const ANIM_SPEED : float = 20.0
const TILE_SIZE : float = 16.0

onready var anim_index : float = 0.0
var board_position : Vector2
var board

onready var sprite_north = $Sprite_North
onready var sprite_south = $Sprite_South
onready var sprite_west = $Sprite_West
onready var sprite_east = $Sprite_East

func refresh_on_board() -> void:
	position = board_position * TILE_SIZE

func _process(delta : float) -> void:
	anim_index += delta * ANIM_SPEED
	if anim_index >= sprite_north.hframes:
		queue_free()
	else:
		for sprite in [sprite_north, sprite_south, sprite_west, sprite_east]:
			sprite.frame = int(anim_index)

func _ready() -> void:
	refresh_on_board()
	if board.is_space_free(board_position + Vector2.UP):
		sprite_north.show()
	if board.is_space_free(board_position + Vector2.DOWN):
		sprite_south.show()
	if board.is_space_free(board_position + Vector2.LEFT):
		sprite_west.show()
	if board.is_space_free(board_position + Vector2.RIGHT):
		sprite_east.show()
