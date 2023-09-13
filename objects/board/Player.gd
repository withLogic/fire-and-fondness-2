extends "res://objects/board/Character.gd"

class_name Player

const SPRITE_CHARACTERS = preload("res://sprites/characters.png")
const SPRITE_ASH = preload("res://sprites/ash.png")

onready var sprite : Sprite = $Sprite
onready var tween : Tween = $Tween

var can_move : bool
var flipped : bool

var steps_taken : int = 0

var state_stack : Array

signal player_moved

func wiggle(direction : Vector2) -> void:
	tween.interpolate_property(sprite, "offset", Vector2(0, -8) + (direction * 2), Vector2(0, -8), 0.1, Tween.TRANS_SINE)
	var scale_start : Vector2 = Vector2.ONE
	match direction:
		Vector2.UP:
			scale_start = Vector2(1.0, 1.5)
		Vector2.DOWN:
			scale_start = Vector2(1.0, 0.65)
		_:
			scale_start = Vector2(1.5, 1.0)
	sprite.scale = scale_start
	tween.interpolate_property(sprite, "scale", scale_start, Vector2(1.0, 1.0), 0.25, Tween.TRANS_CIRC, Tween.EASE_OUT)
	tween.start()

func burn() -> void:
	sprite.region_enabled = false
	sprite.texture = SPRITE_ASH
	state = STATE.BURNED
	SoundMaster.fade_out_music()

func crush() -> void:
	SoundMaster.play_sound("squish")
	can_move = false
	sprite.hide()
	state = STATE.CRUSHED
	SoundMaster.fade_out_music()

func fall() -> void:
	SoundMaster.play_sound("fall")
	sprite.hide()
	state = STATE.FALLEN
	SoundMaster.fade_out_music()

func caught_by_dog() -> void:
	state = STATE.DOGGED
	SoundMaster.fade_out_music()

func caught_by_inlaw() -> void:
	state = STATE.INLAWED
	SoundMaster.fade_out_music()

func finish_turn() -> void:
	can_move = false
	steps_taken += 1
	emit_signal("player_moved")

# Called every time the player moves, or is moved
func check_for_flowers() -> void:
	for flower in get_tree().get_nodes_in_group("flower"):
		if flower.board_position == board_position and not flower.collected and not flower.burned:
			flower.collect()

func can_do_something() -> bool:
	# Check that we can move in at least one direction
	for direction in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
		if can_move_to(board_position + direction):
			return true
	# If not, are there any interactables we can use?
	var interactive_objects : Array = get_tree().get_nodes_in_group("interactive")
	for current_object in interactive_objects:
		if current_object.board_position == board_position and current_object.is_interactive():
			return true
	# Nope, there's nothing we can do
	return false

func can_move_to(candidate : Vector2) -> bool:
	for character in get_tree().get_nodes_in_group("character"):
		if character.board_position == candidate:
			return false
	return board.is_space_free(candidate)

func try_to_move(move_direction : Vector2) -> void:
	var candidate_position : Vector2 = board_position + move_direction
	if can_move_to(candidate_position):
		SoundMaster.play_sound("player_step")
		board_position = candidate_position
		refresh_on_board()
		check_for_flowers()
		finish_turn()
		# Add a bit of flair to the movement
		wiggle(move_direction * -1)

func try_to_interact() -> void:
	var interactive_objects : Array = get_tree().get_nodes_in_group("interactive")
	for current_object in interactive_objects:
		if current_object.board_position == board_position and current_object.is_interactive():
			current_object.activate()
			finish_turn()
			return

func _input(event : InputEvent) -> void:
	if event is InputEvent and can_move:
		if event.is_action_pressed("move_up"):
			try_to_move(Vector2.UP)
		elif event.is_action_pressed("move_down"):
			try_to_move(Vector2.DOWN)
		elif event.is_action_pressed("move_left"):
			flipped = true
			try_to_move(Vector2.LEFT)
		elif event.is_action_pressed("move_right"):
			flipped = false
			try_to_move(Vector2.RIGHT)
		elif event.is_action_pressed("interact"):
			try_to_interact()

func refresh_on_board() -> void:
	position = board_position * TILE_SIZE
	sprite.region_rect.position.x = Settings.player_avatar * 16
	sprite.flip_h = flipped
	if state == STATE.BURNED:
		sprite.texture = SPRITE_ASH
	else:
		sprite.texture = SPRITE_CHARACTERS

func save_state() -> void:
	state_stack.push_back(
		[board_position, state, steps_taken, flipped]
	)

func revert_to_previous_state() -> void:
	if state_stack.size() > 1:
		state_stack.pop_back()
	board_position = state_stack.back()[0]
	state = state_stack.back()[1]
	steps_taken = state_stack.back()[2]
	flipped = state_stack.back()[3]
	refresh_on_board()

func to_json() -> Dictionary:
	return {
		"type": "player",
		"board_position": [board_position.x, board_position.y],
		"flipped": flipped
	}

