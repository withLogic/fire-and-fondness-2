extends Node

const CONFIG_PATH : String = "user://settings.cfg"

const PALETTE_MUTED : Array = [Color("222034"), Color("45283c"), Color("3f3f74")]
const PALETTE_FIERY : Array = [Color("222034"), Color("df7126"), Color("ac3232")]
const PALETTE_EARTHY : Array = [Color("45283c"), Color("663931"), Color("8f563b")]
const PALETTE_ENVIOUS : Array = [Color("524b24"), Color("4b692f"), Color("37946e")]

enum COLOUR_BLIND_ASSIST {NONE, PALETTE, INDICATORS}

var fullscreen : bool
var show_cursor : bool
var screen_scale : int
var camera_shake : int
var background_enabled : bool
var background_palette : int
var background_speed : int
var sfx_volume : float
var bgm_volume : float
var ui_volume : float
var player_avatar : int
var partner_avatar : int
var skip_tutorials : bool
var show_ui : bool
var colour_blind_assist : int

var config : ConfigFile

func get_camera_shake_amount() -> float:
	match camera_shake:
		1: return 4.0
		2: return 8.0
		3: return 16.0
		4: return 32.0
		_: return 0.0

func get_background_speed_amount() -> float:
	return background_speed * 0.25

func get_background_colours() -> Array:
	match background_palette:
		1: return PALETTE_FIERY
		2: return PALETTE_EARTHY
		3: return PALETTE_ENVIOUS
		_: return PALETTE_MUTED
		

func apply_config() -> void:
	if not OS.has_feature("web"):
		OS.window_fullscreen = fullscreen
		OS.window_size = Vector2(640, 360) * (screen_scale + 1)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear2db(sfx_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("BGM"), linear2db(bgm_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("UI"), linear2db(ui_volume))
	if show_cursor:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func load_config() -> void:
	config = ConfigFile.new()
	var err = config.load(CONFIG_PATH)
	if err == ERR_FILE_NOT_FOUND:
		err = config.save(CONFIG_PATH)
	if err == OK:
		player_avatar = config.get_value("game", "player_avatar", 0)
		partner_avatar = config.get_value("game", "partner_avatar", 1)
		show_ui = config.get_value("game", "show_ui", true)
		skip_tutorials = config.get_value("game", "skip_tutorials", false)
		colour_blind_assist = config.get_value("game", "colour_blind_assist", 0)
		fullscreen = config.get_value("graphics", "fullscreen", false)
		show_cursor = config.get_value("graphics", "show_cursor", false)
		screen_scale = config.get_value("graphics", "screen_scale", 1)
		camera_shake = config.get_value("graphics", "camera_shake", 2)
		background_enabled = config.get_value("graphics", "background_enabled", true)
		background_palette = config.get_value("graphics", "background_palette", 0)
		background_speed = config.get_value("graphics", "background_speed", 2)
		sfx_volume = config.get_value("audio", "sfx_volume", 1.0)
		bgm_volume = config.get_value("audio", "bgm_volume", 0.5)
		ui_volume = config.get_value("audio", "ui_volume", 0.5)

func save_config() -> void:
	config.set_value("game", "player_avatar", player_avatar)
	config.set_value("game", "partner_avatar", partner_avatar)
	config.set_value("game", "show_ui", show_ui)
	config.set_value("game", "skip_tutorials", skip_tutorials)
	config.set_value("game", "colour_blind_assist", colour_blind_assist)
	config.set_value("graphics", "fullscreen", fullscreen)
	config.set_value("graphics", "show_cursor", show_cursor)
	config.set_value("graphics", "screen_scale", screen_scale)
	config.set_value("graphics", "camera_shake", camera_shake)
	config.set_value("graphics", "background_enabled", background_enabled)
	config.set_value("graphics", "background_palette", background_palette)
	config.set_value("graphics", "background_speed", background_speed)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.set_value("audio", "bgm_volume", bgm_volume)
	config.set_value("audio", "ui_volume", ui_volume)
	config.save(CONFIG_PATH)

func _enter_tree() -> void:
	load_config()
	yield(get_tree().create_timer(0.25), "timeout")
	apply_config()
	OS.center_window()
