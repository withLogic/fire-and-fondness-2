extends "res://objects/board/BoardObject.gd"

class_name Trapdoor

const OBJ_SMOKE = preload("res://objects/Smoke.tscn")

const ANIM_SPEED : float = 10.0
const EFFECT_ANIM_SPEED : float = 15.0

onready var sprite : Sprite = $Sprite
onready var tween : Tween = $Tween

enum STATE {NORMAL, TRIPPED, OPEN}

onready var state : int = STATE.NORMAL

var state_stack : Array

func emit_smoke() -> void:
	var smoke : Sprite = OBJ_SMOKE.instance()
	smoke.global_position = sprite.global_position
	smoke.velocity = Vector2(0.0, -96.0)
	get_parent().add_child(smoke)

func get_characters_stepping_on() -> Array:
	var results : Array = []
	for character in get_tree().get_nodes_in_group("character"):
		if character.board_position == board_position and character.can_fall():
			results.append(character)
	return results

func tick() -> void:
	if state == STATE.TRIPPED:
		state = STATE.OPEN
		SoundMaster.play_sound("trapdoor_open")
		refresh_on_board()
		sprite.scale = Vector2(0.75, 1.0)
		tween.interpolate_property(sprite, "scale", Vector2(0.75, 1.0), Vector2.ONE, 0.25, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		tween.start()

func can_act() -> bool:
	match state:
		STATE.NORMAL:
			if not get_characters_stepping_on().empty():
				return true
		STATE.OPEN:
			if not get_characters_stepping_on().empty():
				return true
	return false

func act() -> void:
	match state:
		STATE.NORMAL:
			if not get_characters_stepping_on().empty():
				state = STATE.TRIPPED
				SoundMaster.play_sound("trapdoor_click")
				tween.interpolate_property(sprite, "offset", Vector2(0, 1), Vector2.ZERO, 0.25, Tween.TRANS_CUBIC, Tween.EASE_OUT)
				tween.start()
		STATE.OPEN:
			for characters in get_characters_stepping_on():
				characters.fall()
				emit_smoke()

func refresh_on_board() -> void:
	position = board_position * TILE_SIZE
	sprite.frame = 1 if state == STATE.OPEN else 0

func save_state() -> void:
	state_stack.push_back(state)

func revert_to_previous_state() -> void:
	if state_stack.size() > 1:
		state_stack.pop_back()
	state = state_stack.back()
	refresh_on_board()

func to_json() -> Dictionary:
	return {
		"type": "trapdoor",
		"board_position": [board_position.x, board_position.y]
	}
