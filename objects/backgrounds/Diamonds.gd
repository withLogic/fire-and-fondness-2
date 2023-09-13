extends Node2D

const SPRITE_PIXEL = preload("res://sprites/pixel.png")

var time : float = 0.0

func _draw() -> void:
	if not Settings.background_enabled: return
	#var number_of_colours : int = Settings.get_background_colours().size()
	#var color_index : int = int(floor(fmod(time, 2.0 * number_of_colours) / 2.0))
	var fore_color : Color = Settings.get_background_colours()[0]
	var back_color : Color = Color.black
	draw_rect(Rect2(-64, -64, 640, 360), back_color if fmod(time, 4.0) > 2.0 else fore_color)
	for y in range(0, 5):
		for x in range(0, 8):
			var transform : Vector2 = Vector2(x*45, y*45) + Vector2(22.5, 22.5)
			var rotate : float = deg2rad(45.0)
			var scale : float = fmod(time, 2.0)
			scale = clamp(scale - ((x+y)/12.0), 0.0, 2.0) * 56.0
			var colour : Color = fore_color if fmod(time, 4.0) > 2.0 else back_color
			draw_set_transform(transform, rotate, Vector2.ONE * scale)
			draw_texture(SPRITE_PIXEL, Vector2(-0.5, -0.5), colour)

func _process(delta):
	time += delta * Settings.get_background_speed_amount()
	update()
