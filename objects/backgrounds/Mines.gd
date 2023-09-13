extends Node2D

var time : float = 0.0

func _draw() -> void:
	if not Settings.background_enabled: return
	for x in range(0, 15):
		var scroll : Vector2 = Vector2(time*5.0, 0.0).posmodv(Vector2(288, 128)) + Vector2(16, 0)
		for y in range(0, 5):
			var stretch_a : float = cos(time + PI) if x % 2 == 0 else sin(time)
			var stretch_b : float = sin(time + PI) if x % 2 == 0 else cos(time)
			var offset : float = 0 if x % 2 == 0 else 0.5
			draw_set_transform(Vector2(x*48, (y+offset)*48)-scroll, 0.0, Vector2.ONE * 8)
			var points : PoolVector2Array
			var colors : PoolColorArray
			points.append(Vector2(1, 0))
			points.append(Vector2(1.5 + stretch_a, 1.5 + stretch_a))
			points.append(Vector2(0, 1))
			points.append(Vector2(-1.5 - stretch_b, 1.5 + stretch_b))
			points.append(Vector2(-1, 0))
			points.append(Vector2(-1.5 - stretch_a, -1.5 - stretch_a))
			points.append(Vector2(0, -1))
			points.append(Vector2(1.5 + stretch_b, -1.5 - stretch_b))
			var colour_index : int = x % Settings.get_background_colours().size()
			for i in range(0, points.size()):
				colors.append(Settings.get_background_colours()[colour_index])
			draw_polygon(points, colors)

func _process(delta : float) -> void:
	time += delta * Settings.get_background_speed_amount()
	update()
