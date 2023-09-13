extends TileMap

class_name Board

const OBJ_YOUWIN = preload("res://objects/YouWin.tscn")
const OBJ_GAMEOVER = preload("res://objects/GameOver.tscn")

const EXPORT_AREA : Rect2 = Rect2(0, 0, 18, 9)
const SHAKE_COEFFICIENT : float = 4.0
const TILE_SIZE : float = 16.0

onready var timer_fire_finished = $Timer_FireFinished
onready var timer_explosions_finished = $Timer_ExplosionsFinished
onready var camera = $Camera

onready var mover_controller : Node = $Controllers/MoverController
onready var teleport_controller : Node = $Controllers/TeleportController
onready var trapdoor_controller : Node = $Controllers/TrapdoorController
onready var hourglass_controller : Node = $Controllers/HourglassController
onready var fire_controller : Node = $Controllers/FireController
onready var ice_controller : Node = $Controllers/IceController
onready var bomb_controller : Node = $Controllers/BombController
onready var pressure_plate_controller : Node = $Controllers/PressurePlateController
onready var dog_controller : Node = $Controllers/DogController
onready var inlaw_controller : Node = $Controllers/InlawController

var player
var partner
var ui

var camera_offset : Vector2 = Vector2.ZERO
var camera_shake_amount : float = 0.0

var current_phase : int

var par : int

var tiles_burned : Array

func is_wall_at(board_position : Vector2) -> bool:
	var cell_id : int = get_cell(board_position.x, board_position.y)
	return cell_id != 0

func is_space_free(board_position : Vector2) -> bool:
	# Check for blocker objects
	for current_object in get_tree().get_nodes_in_group("board_object"):
		if current_object.board_position == board_position and current_object.is_blocker():
			return false
	return is_wall_at(board_position)

func is_space_burnable(board_position : Vector2) -> bool:
	for current_object in get_tree().get_nodes_in_group("fire"):
		if current_object.board_position == board_position:
			return false
	return is_space_free(board_position)

func update_ui() -> void:
	var got_flowers : bool = false
	for flower in get_tree().get_nodes_in_group("flower"):
		if flower.collected:
			got_flowers = true
	var fire_time : int = 99
	for flamethrower in get_tree().get_nodes_in_group("flamethrower"):
		fire_time = min(fire_time, flamethrower.turns_until_fire)
	ui.got_flowers = got_flowers
	ui.turns_until_next_fire = fire_time
	ui.steps_taken = player.steps_taken
	ui.par = par
	ui.update()

# Yes, it's a bit monolithic, but I can't divide it into multiple functions because of the way yield works.
# Maybe I'll do *another* refactoring at some point.
func player_moved() -> void:
	# First of all, reset the mover's "shunt" status
	mover_controller.reset_shunt_status()
	yield(get_tree().create_timer(0.1), "timeout")
	# Are any hourglasses active? (We only want this to happen once per turn, hence why it isn't in objects_act)
	hourglass_controller.tick()
	if hourglass_controller.can_act():
		hourglass_controller.act()
		yield(get_tree().create_timer(0.25), "timeout")
	if dog_controller.can_act():
		dog_controller.act()
		#yield(get_tree().create_timer(0.25), "timeout")
	if inlaw_controller.can_act():
		inlaw_controller.act()
	trapdoor_controller.tick()
	# Keep making the objects act until a state of equilibrium is reached
	var acted : bool = true
	while acted:
		acted = false
		# Anyone standing on a pressure plate?
		if pressure_plate_controller.can_act():
			pressure_plate_controller.act()
			acted = true
		# Is anyone standing on a trapdoor?
		if trapdoor_controller.can_act():
			yield(get_tree().create_timer(0.25), "timeout")
			trapdoor_controller.act()
			acted = true
		# Check that no-one's on a mover
		if mover_controller.can_act():
			yield(get_tree().create_timer(0.25), "timeout")
			mover_controller.act()
			acted = true
		# Has anyone moved into a teleporter?
		if teleport_controller.can_act():
			yield(get_tree().create_timer(0.25), "timeout")
			teleport_controller.act()
			acted = true
			yield(get_tree().create_timer(0.5), "timeout")
		# Do the dogs/inlaws need to react to the player moving?
		if acted:
			dog_controller.check_for_player_after_move()
			inlaw_controller.try_to_catch_player()
	# Now deal with the flamethrowers, and anything they might trigger
	fire_controller.tick()
	update_ui()
	# Are any of them ready to fire?
	if fire_controller.can_fire():
		# Boom!
		var fire_time : float = fire_controller.make_fires_and_return_burn_time(self)
		# Wait until all the fire has finished
		yield(get_tree().create_timer(fire_time + 0.5), "timeout")
		# Was any ice touched by the fire just now?
		if ice_controller.can_act():
			ice_controller.act()
		# Bombs
		if bomb_controller.can_act():
			bomb_controller.act()
			yield(get_tree().create_timer(0.25), "timeout")
	update_ui()
	player_move_start()

func player_move_start() -> void:
	# Did we just cook?
	if has_player_lost():
		yield(get_tree().create_timer(1.0), "timeout")
		game_over()
	# Wait... did we just win?
	elif has_player_won():
		yield(get_tree().create_timer(0.25), "timeout")
		player_won()
	# Is the player trapped? If so, the game can't progress
	elif not player.can_do_something():
		yield(get_tree().create_timer(1.0), "timeout")
		game_over()
	# Nope, the game's still on.
	else:
		get_tree().call_group("board_object", "save_state")
		player.can_move = true

func has_player_won() -> bool:
	if player.board_position == partner.board_position:
		return true
	return false

func has_player_lost() -> bool:
	for character in get_tree().get_nodes_in_group("character"):
		if not character.is_alive():
			return true
	return partner.burned

func get_flowers_collected() -> int:
	var result : int = 0
	for flower in get_tree().get_nodes_in_group("flower"):
		if flower.collected:
			result += 1
	return result

func get_flowers_total() -> int:
	return get_tree().get_nodes_in_group("flower").size()

func player_won() -> void:
	if not Levels.currently_editing:
		GameProgress.update_level_progress(
			Levels.current_scene,
			player.steps_taken, get_flowers_collected() > 0
		)
	SoundMaster.stop_all_sounds()
	var youwin = OBJ_YOUWIN.instance()
	youwin.steps_taken = player.steps_taken
	youwin.par = par
	youwin.flowers_collected = get_flowers_collected()
	youwin.flowers_total = get_flowers_total()
	add_child(youwin)
	get_tree().paused = true

func get_game_over_type() -> int:
	# Has the player met with a horrible fate?
	match player.state:
		Character.STATE.BURNED:
			return GameOver.CauseOfGameOver.PLAYER_BURNED
		Character.STATE.FALLEN:
			return GameOver.CauseOfGameOver.PLAYER_FALLEN
		Character.STATE.CRUSHED:
			return GameOver.CauseOfGameOver.PLAYER_CRUSHED
		Character.STATE.DOGGED:
			return GameOver.CauseOfGameOver.CAUGHT_BY_DOG
		Character.STATE.INLAWED:
			return GameOver.CauseOfGameOver.CAUGHT_BY_INLAW
	# Has their loved one come down with a bad case of notaliveitis?
	if partner.burned == true:
		return GameOver.CauseOfGameOver.PARTNER_DIED
	# Check that no dogs were harmed in the making of this gameover
	for dog in get_tree().get_nodes_in_group("dog"):
		if not dog.is_alive():
			return GameOver.CauseOfGameOver.DOG_DIED
	# Check that no in-laws were harmed in the making of this gameover
	for inlaw in get_tree().get_nodes_in_group("inlaw"):
		if not inlaw.is_alive():
			return GameOver.CauseOfGameOver.INLAW_DIED
	# Maybe there are no possible moves for the player
	if not player.can_do_something():
		return GameOver.CauseOfGameOver.NO_POSSIBLE_MOVES
	# It's game over, but we can't tell why. (This probably shouldn't happen.)
	return GameOver.CauseOfGameOver.DEFAULT

func game_over() -> void:
	SoundMaster.stop_all_sounds()
	var gameover = OBJ_GAMEOVER.instance()
	gameover.quip_type = get_game_over_type()
	add_child(gameover)
	get_tree().paused = true

func start_game() -> void:
	# Save the starting state
	get_tree().call_group("board_object", "save_state")
	player.can_move = true

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("undo"):
		if player.can_move:
			get_tree().call_group("board_object", "revert_to_previous_state")
			yield(get_tree().create_timer(0.05), "timeout") # janky hack, m8
			update_ui()
			SoundMaster.play_sound("rewind")

func shake_camera() -> void:
	camera_shake_amount = 1.0

func _process(delta : float) -> void:
	if camera_shake_amount > 0.0:
		camera_shake_amount -= delta / 2.0
		camera.position = (camera_offset * TILE_SIZE) + Vector2(randf() - 0.5, randf() - 0.5) * Settings.get_camera_shake_amount() * pow(camera_shake_amount, 5.0)
	if camera_shake_amount <= 0.0:
		camera.position = camera_offset * TILE_SIZE

func get_map_size() -> Vector2:
	var result : Vector2 = Vector2.ZERO
	for tile in get_used_cells():
		if get_cellv(tile) == 0:
			continue
		result.x = max(result.x, tile.x+1)
		result.y = max(result.y, tile.y+1)
	return result

func level_to_json() -> Dictionary:
	var map_size : Vector2 = get_map_size()
	var tiles : Array = []
	for y in map_size.y:
		var row : Array = []
		for x in map_size.x:
			row.append(get_cell(x, y))
		tiles.append(row)
	var board_objects : Array = []
	for current_object in get_tree().get_nodes_in_group("board_object"):
		board_objects.append(current_object.to_json())
	return {
		"slug": "sXeY",
		"supertitle": "Season X, Episode Y",
		"title": "Level title here",
		"subtitle": "Witty quip here",
		"par": 99,
		"next": "end",
		"background": "none",
		"camera_offset": [0, 0],
		"tiles": tiles,
		"objects": board_objects
	}
