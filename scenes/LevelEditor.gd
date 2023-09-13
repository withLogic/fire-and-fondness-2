extends Node2D

const SPRITE_ICONS = preload("res://sprites/level_editor_icons.png")
const OBJECT_PLAYER = preload("res://objects/board/Player.tscn")
const OBJECT_PARTNER = preload("res://objects/board/Partner.tscn")
const OBJECT_FLOWER = preload("res://objects/board/Flower.tscn")
const OBJECT_FLAMETHROWER = preload("res://objects/board/Flamethrower.tscn")
const OBJECT_DOOR = preload("res://objects/board/Door.tscn")
const OBJECT_SWITCH = preload("res://objects/board/Switch.tscn")
const OBJECT_MOVER = preload("res://objects/board/Mover.tscn")
const OBJECT_ROTATING_MOVER = preload("res://objects/board/RotatingMover.tscn")
const OBJECT_TELEPORTER = preload("res://objects/board/Teleporter.tscn")
const OBJECT_TELEPORTER_TARGET = preload("res://objects/board/TeleporterTarget.tscn")
const OBJECT_BOMB = preload("res://objects/board/Bomb.tscn")
const OBJECT_ROCK = preload("res://objects/board/Rock.tscn")
const OBJECT_ICE = preload("res://objects/board/Ice.tscn")
const OBJECT_HOURGLASS = preload("res://objects/board/Hourglass.tscn")
const OBJECT_TRAPDOOR = preload("res://objects/board/Trapdoor.tscn")
const OBJECT_PRESSURE_PLATE = preload("res://objects/board/PressurePlate.tscn")
const OBJECT_DOG = preload("res://objects/board/Dog.tscn")
const OBJECT_INLAW = preload("res://objects/board/Inlaw.tscn")

const EDITABLE_AREA : Rect2 = Rect2(1, 1, 18, 9)

const FONT_BUTTON : Font = preload("res://fonts/paragraph_bold.tres")
const FONT_PARAGRAPH : Font = preload("res://fonts/paragraph.tres")
const FONT_UI : Font = preload("res://fonts/ui.tres")

const COLOR_SHADOW : Color = Color("222034")
const COLOR_SHADE_A : Color = Color("847e87")
const COLOR_SHADE_B : Color = Color("595652")

onready var board = $Board
onready var loader = $LevelLoader

enum Mode {FLOOR, PLAYER, PARTNER, FLOWER, FLAMETHROWER, DOOR, SWITCH, MOVER, ROTATING_MOVER, TELEPORTER, TELEPORTER_TARGET, BOMB, ROCK, ICE, HOURGLASS, TRAPDOOR, PRESSURE_PLATE, DOG, INLAW}

var mode_objects = {
	Mode.PLAYER: OBJECT_PLAYER,
	Mode.PARTNER: OBJECT_PARTNER,
	Mode.FLOWER: OBJECT_FLOWER,
	Mode.FLAMETHROWER: OBJECT_FLAMETHROWER,
	Mode.DOOR: OBJECT_DOOR,
	Mode.SWITCH: OBJECT_SWITCH,
	Mode.MOVER: OBJECT_MOVER,
	Mode.ROTATING_MOVER: OBJECT_ROTATING_MOVER,
	Mode.TELEPORTER: OBJECT_TELEPORTER,
	Mode.TELEPORTER_TARGET: OBJECT_TELEPORTER_TARGET,
	Mode.BOMB: OBJECT_BOMB,
	Mode.ROCK: OBJECT_ROCK,
	Mode.ICE: OBJECT_ICE,
	Mode.HOURGLASS: OBJECT_HOURGLASS,
	Mode.TRAPDOOR: OBJECT_TRAPDOOR,
	Mode.PRESSURE_PLATE: OBJECT_PRESSURE_PLATE,
	Mode.DOG: OBJECT_DOG,
	Mode.INLAW: OBJECT_INLAW
}

var object_tooltips = {
	Player: ["(Z): Turn", ""],
	Partner: ["(Z): Turn", ""],
	Door: ["(Z): Change type", "(X): Open/close"],
	Switch: ["(Z): Change type", "(X): Toggle"],
	Mover: ["(Z): Change direction", ""],
	RotatingMover: ["(Z): Change direction", "(X): Change rotation"],
	Teleporter: ["(Z): Change type", ""],
	TeleporterTarget: ["(Z): Change type", ""],
	Hourglass: ["(Z): Change type", ""],
	PressurePlate: ["(Z): Change type", ""]
}

var help = [
	["LMB", "Place object"],
	["RMB", "Remove object"],
	["Mouse wheel", "Next/previous object"],
	["(Z)", "Change object"],
	["(X)", "Change object alt"],
	["(F1)", "Toggle help"],
	["(F2)", "Playtest level"],
	["(F5)", "Save to clipboard"],
	["(F9)", "Load from clipboard"],
	["(F11)", "Clear level"]
]

onready var last_place_pos : Vector2 = Vector2.ZERO
onready var last_place_type : int = -99
onready var show_grid : bool = true
onready var show_help : bool = false

var mode_index : int = 0
var mode_index_offset : float = 0

var label_a_text : String = ""
var label_b_text : String = ""

func draw_text_with_shadow(font : Font, text : String, position : Vector2, color : Color) -> void:
	draw_string(font, position + Vector2(1, 1), text, COLOR_SHADOW)
	draw_string(font, position, text, color)

func draw_icons() -> void:
	for i in range(-2, 3):
		var index : int = (mode_index + i) % Mode.size()
		if index < 0: index += Mode.size()
		draw_texture_rect_region(SPRITE_ICONS, Rect2(48 + (i*16) + mode_index_offset, 162, 16, 16), Rect2(index*16, 0, 16, 16))
	draw_rect(Rect2(48, 162, 16, 16), Color.white, false, 2.0)

func _draw() -> void:
	draw_icons()
	draw_rect(Rect2(96, 160, 128, 32), Color.black)
	draw_text_with_shadow(FONT_UI, label_a_text, Vector2(102, 168), COLOR_SHADE_A)
	draw_text_with_shadow(FONT_UI, label_b_text, Vector2(102, 176), COLOR_SHADE_B)
	if show_grid:
		# Draw grid
		for x in range(1, 20):
			draw_line(Vector2(x*16, 16), Vector2(x*16, 10*16), Color(0.1, 0.1, 0.1), 1.1)
		for y in range(1, 11):
			draw_line(Vector2(16, y*16), Vector2(16*19, y*16), Color(0.1, 0.1, 0.1), 1.1)
	# Draw cursor
	var cursor_pos : Vector2 = board.world_to_map(get_global_mouse_position())
	if EDITABLE_AREA.has_point(cursor_pos):
		draw_rect(Rect2(cursor_pos.x*16, cursor_pos.y*16, 16, 16), Color(0.5, 0.5, 0.5), false, 1.5)
	# Draw help
	if show_help:
		draw_rect(Rect2(56, 28, 208, 112), Color.black)
		draw_rect(Rect2(56, 28, 208, 112), COLOR_SHADE_A, false, 1.1)
		for i in range(0, help.size()):
			var help_item : Array = help[i]
			var help_width : float = FONT_UI.get_string_size(help_item[0]).x
			draw_text_with_shadow(FONT_UI, help_item[0], Vector2(128 - help_width, 40 + (i*10)), COLOR_SHADE_B)
			draw_text_with_shadow(FONT_UI, help_item[1], Vector2(136, 40 + (i*10)), COLOR_SHADE_A)
	else:
		draw_text_with_shadow(FONT_UI, "(F1) Help", Vector2(268, 10), COLOR_SHADE_B)

func change_object() -> void:
	var object : Node2D = find_object_to_change()
	if object == null: return
	if object is Player or object is Partner:
		object.flipped = !object.flipped
	if object is Switch or object is Door or object is Hourglass or object is PressurePlate:
		object.door_type += 1
		if object.door_type >= 4:
			object.door_type = 0
	if object is Mover or object is RotatingMover:
		object.direction_index += 1
		if object.direction_index >= 4:
			object.direction_index = 0
	if object is Teleporter or object is TeleporterTarget:
		object.teleporter_type += 1
		if object.teleporter_type >= 4:
			object.teleporter_type = 0
	object.refresh_on_board()

func change_object_alt() -> void:
	var object : Node2D = find_object_to_change()
	if object == null: return
	if object is Door:
		object.open = !object.open
	if object is Switch:
		object.toggled = !object.toggled
	if object is RotatingMover:
		object.turning_direction *= -1
	object.refresh_on_board()

func find_object_to_change() -> Node2D:
	var tile_pos : Vector2 = board.world_to_map(get_global_mouse_position())
	if not EDITABLE_AREA.has_point(tile_pos): return null
	for current_object in get_tree().get_nodes_in_group("board_object"):
		if current_object.board_position == tile_pos:
			return current_object
	return null

func place_floor(pos : Vector2) -> void:
	if last_place_pos == pos and last_place_type == Mode.FLOOR:
		return
	board.set_cellv(pos, rand_range(3, 6))
	board.update_bitmask_region()
	# Make sure we aren't doing this sixty times a second
	last_place_pos = pos
	last_place_type = Mode.FLOOR

func remove_floor(pos : Vector2) -> void:
	if last_place_pos == pos and last_place_type == Mode.FLOOR + 100:
		return
	board.set_cellv(pos, 0)
	board.update_bitmask_region()
	# Make sure we aren't doing this sixty times a second
	last_place_pos = pos
	last_place_type = Mode.FLOOR + 100

func place_object(pos : Vector2) -> void:
	if last_place_pos == pos and last_place_type == mode_index:
		return
	# Delete anything already on this tile
	delete_object(pos)
	var new_object = mode_objects[mode_index].instance()
	new_object.board_position = pos
	new_object.position = pos * 16
	board.add_child(new_object)
	new_object.set_board(board)
	# Make sure we aren't doing this sixty times a second
	last_place_pos = pos
	last_place_type = mode_index
	# Is this a door? Do we need to place a tile?
	if mode_index == Mode.DOOR:
		if new_object.sprite.rotation_degrees == -90:
			board.set_cellv(pos, 1)
		else:
			board.set_cellv(pos, 2)

func delete_object(pos : Vector2) -> void:
	if last_place_pos == pos and last_place_type == mode_index + 100:
		return
	for current_object in get_tree().get_nodes_in_group("board_object"):
		if current_object.board_position == pos:
			current_object.queue_free()
	# Make sure we aren't doing this sixty times a second
	last_place_pos = pos
	last_place_type = mode_index + 100

func place_tile() -> void:
	var tile_pos : Vector2 = board.world_to_map(get_global_mouse_position())
	if not EDITABLE_AREA.has_point(tile_pos): return
	match mode_index:
		Mode.FLOOR:
			place_floor(tile_pos)
		_:
			place_object(tile_pos)

func remove_tile() -> void:
	var tile_pos : Vector2 = board.world_to_map(get_global_mouse_position())
	if not EDITABLE_AREA.has_point(tile_pos): return
	match mode_index:
		Mode.FLOOR:
			remove_floor(tile_pos)
		_:
			delete_object(tile_pos)

func clear_level() -> void:
	# Make EVERYTHING a wall!
	for x in range(EDITABLE_AREA.position.x - 2, EDITABLE_AREA.position.x + EDITABLE_AREA.size.x + 2):
		for y in range(EDITABLE_AREA.position.y - 2, EDITABLE_AREA.position.y + EDITABLE_AREA.size.y + 2):
			board.set_cell(x, y, 0)
	board.update_bitmask_region()
	# Get rid of all the objects
	for object in get_tree().get_nodes_in_group("board_object"):
		object.queue_free()

func shift_tiles(direction : Vector2) -> void:
	var temp_map = board.duplicate()
	for x in range(EDITABLE_AREA.position.x, EDITABLE_AREA.position.x + EDITABLE_AREA.size.x):
		for y in range(EDITABLE_AREA.position.y, EDITABLE_AREA.position.y + EDITABLE_AREA.size.y):
			board.set_cell(x, y, 0)
	for coord in temp_map.get_used_cells():
		var tile = temp_map.get_cellv(coord)
		coord += direction
		board.set_cellv(coord, tile)
	board.update_bitmask_region()
	# Now shift the objects themselves
	for object in get_tree().get_nodes_in_group("board_object"):
		object.board_position += direction
		object.refresh_on_board()

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("level_editor_help"):
		show_help = !show_help
		update()
	# If we're looking at the help menu, don't process any other inputs
	if show_help:
		return
	if event.is_action_pressed("move_up"):
		shift_tiles(Vector2.UP)
	if event.is_action_pressed("move_down"):
		shift_tiles(Vector2.DOWN)
	if event.is_action_pressed("move_left"):
		shift_tiles(Vector2.LEFT)
	if event.is_action_pressed("move_right"):
		shift_tiles(Vector2.RIGHT)
	if event.is_action_pressed("level_editor_change_object"):
		change_object()
	if event.is_action_pressed("level_editor_change_object_alt"):
		change_object_alt()
	if event.is_action_pressed("level_editor_next_mode"):
		mode_index += 1
		if mode_index >= Mode.size():
			mode_index = 0
		mode_index_offset = 16.0
	if event.is_action_pressed("level_editor_previous_mode"):
		mode_index -= 1
		if mode_index < 0:
			mode_index = Mode.size() - 1
		mode_index_offset = -16.0
	if event.is_action_pressed("level_editor_toggle_grid"):
		show_grid = !show_grid
	if event.is_action_pressed("level_editor_save"):
		var json = board.level_to_json()
		OS.set_clipboard(JSON.print(json))
	if event.is_action_pressed("level_editor_load"):
		var json = parse_json(OS.get_clipboard())
		if json != null:
			get_tree().call_group("board_object", "queue_free")
			loader.load_level(json)
	if event.is_action_pressed("level_editor_play"):
		Levels.editing_level = board.level_to_json()
		get_tree().change_scene("res://scenes/LevelTester.tscn")
	if event.is_action_pressed("level_editor_clear"):
		clear_level()

func _process(delta : float) -> void:
	# If we're looking at the help menu, don't do any of this
	if show_help:
		return
		
	if Input.is_action_pressed("level_editor_place"):
		place_tile()
	if Input.is_action_pressed("level_editor_remove"):
		remove_tile()
		
	mode_index_offset = lerp(mode_index_offset, 0.0, delta * 15.0)
	
	label_a_text = ""
	label_b_text = ""
	var object_info = find_object_to_change()
	for tooltip_key in object_tooltips:
		if object_info is tooltip_key:
			var info : Array = object_tooltips[tooltip_key]
			label_a_text = info[0]
			label_b_text = info[1]
	
	update()

func _ready() -> void:
	Levels.currently_editing = true
	clear_level()
	if Levels.editing_level != null:
		loader.load_level(Levels.editing_level)
	Overlay.transition_in()
