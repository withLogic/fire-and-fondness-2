extends Node2D

const SPRITE_ICONS = preload("res://sprites/ui/icons.png")
const FONT_TEXT = preload("res://fonts/ui.tres")

const COLOR_SHADOW : Color = Color("222034")
const COLOR_SHADE_A : Color = Color("847e87")
const COLOR_SHADE_B : Color = Color("595652")

var turns_until_next_fire : int
var steps_taken : int
var par : int

var got_flowers : bool
var show_turn_count : bool

func _draw() -> void:
	if not Settings.show_ui: return
	var flower_pos : float = 8.0
	var step_pos : float = 8.0
	# Turn indicator
	if turns_until_next_fire != 99:
		draw_texture_rect_region(SPRITE_ICONS, Rect2(8, 4, 8, 8), Rect2(0, 0, 8, 8))
		draw_string(FONT_TEXT, Vector2(20, 12), str(turns_until_next_fire), COLOR_SHADOW)
		draw_string(FONT_TEXT, Vector2(19, 11), str(turns_until_next_fire))
		flower_pos = 32.0
	# Flower indicator
	draw_texture_rect_region(SPRITE_ICONS, Rect2(flower_pos, 4, 8, 8), Rect2(8 if got_flowers else 16, 0, 8, 8))
	# Steps (only if level already cleared)
	if show_turn_count:
		draw_texture_rect_region(SPRITE_ICONS, Rect2(flower_pos + 14.0, 5, 8, 8), Rect2(24, 0, 8, 8))
		var steps_reading : String = "%02d" % steps_taken
		var step_padding : float = floor(FONT_TEXT.get_string_size(steps_reading).x)
		draw_string(FONT_TEXT, Vector2(flower_pos + 37 - step_padding, 12), steps_reading, COLOR_SHADOW)
		draw_string(FONT_TEXT, Vector2(flower_pos + 36 - step_padding, 11), steps_reading)
		draw_string(FONT_TEXT, Vector2(flower_pos + 38, 12), "/", COLOR_SHADOW)
		draw_string(FONT_TEXT, Vector2(flower_pos + 37, 11), "/")
		draw_string(FONT_TEXT, Vector2(flower_pos + 44, 12), str(par), COLOR_SHADOW)
		draw_string(FONT_TEXT, Vector2(flower_pos + 43, 11), str(par))
