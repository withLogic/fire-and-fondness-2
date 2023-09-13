extends Control

onready var menu = $Center/Menu
onready var logo = $Logo
onready var copyright = $Label_Copyright
onready var credits = $Credits

onready var active = true

func _ready() -> void:
	menu.items = {
		"main_menu": {
			"type": "menu",
			"children": ["play", "settings", "credits", "quit"]
		},
		"play": {
			"type": "button",
			"label": "Play"
		},
		"settings": {
			"label": "Settings",
			"type": "menu",
			"children": ["game", "video", "audio", "back"],
			"parent": "main_menu"
		},
		"game": {
			"label": "Game",
			"type": "menu",
			"children": ["player_avatar", "partner_avatar", "show_ui", "skip_tutorials", "back"],
			"parent": "settings"
		},
		"show_ui": {
			"label": "Show UI",
			"type": "variable",
			"variable_name": "show_ui"
		},
		"skip_tutorials": {
			"label": "Skip Tutorials",
			"type": "variable",
			"variable_name": "skip_tutorials"
		},
		"player_avatar": {
			"label": "Player Avatar",
			"type": "variable",
			"variable_name": "player_avatar"
		},
		"partner_avatar": {
			"label": "Partner Avatar",
			"type": "variable",
			"variable_name": "partner_avatar"
		},
		"video": {
			"label": "Video",
			"type": "menu",
			"children": ["backgrounds", "fullscreen", "screen_scale", "camera_shake", "colour_blind_assist", "show_cursor", "back"],
			"parent": "settings"
		},
		"fullscreen": {
			"label": "Fullscreen",
			"type": "variable",
			"variable_name": "fullscreen"
		},
		"show_cursor": {
			"label": "Show Mouse Cursor",
			"type": "variable",
			"variable_name": "show_cursor"
		},
		"screen_scale": {
			"label": "Screen Scale",
			"type": "variable",
			"variable_name": "screen_scale"
		},
		"camera_shake": {
			"label": "Camera Shake",
			"type": "variable",
			"variable_name": "camera_shake"
		},
		"colour_blind_assist": {
			"label": "Colour Blind Assist",
			"type": "variable",
			"variable_name": "colour_blind_assist"
		},
		"backgrounds": {
			"label": "Backgrounds",
			"type": "menu",
			"children": ["background_enabled", "background_palette", "background_speed", "back"],
			"parent": "video"
		},
		"background_enabled": {
			"label": "BG Enabled",
			"type": "variable",
			"variable_name": "background_enabled"
		},
		"background_palette": {
			"label": "BG Palette",
			"type": "variable",
			"variable_name": "background_palette"
		},
		"background_speed": {
			"label": "BG Speed",
			"type": "variable",
			"variable_name": "background_speed"
		},
		"audio": {
			"label": "Audio",
			"type": "menu",
			"children": ["sfx_volume", "bgm_volume", "ui_volume", "back"],
			"parent": "settings"
		},
		"sfx_volume": {
			"label": "SFX",
			"type": "variable",
			"variable_name": "sfx_volume"
		},
		"bgm_volume": {
			"label": "Music",
			"type": "variable",
			"variable_name": "bgm_volume"
		},
		"ui_volume": {
			"label": "UI",
			"type": "variable",
			"variable_name": "ui_volume"
		},
		"credits": {
			"type": "button",
			"label": "Credits"
		},
		"quit": {
			"type": "button",
			"label": "Quit"
		},
		"back": {
			"type": "button",
			"label": "Back"
		}
	}
	menu.variables = {
		"skip_tutorials": {"type": "tickbox", "value": Settings.skip_tutorials},
		"show_ui": {"type": "tickbox", "value": Settings.show_ui},
		"colour_blind_assist": {"type": "select", "options": ["None", "Palette", "Flags"], "value": Settings.colour_blind_assist},
		"player_avatar": {"type": "avatar", "value": Settings.player_avatar},
		"partner_avatar": {"type": "avatar", "value": Settings.partner_avatar},
		"fullscreen": {"type": "tickbox", "value": Settings.fullscreen},
		"show_cursor": {"type": "tickbox", "value": Settings.show_cursor},
		"screen_scale": {"type": "select", "options": ["1x", "2x", "3x", "4x"], "value": Settings.screen_scale},
		"camera_shake": {"type": "select", "options": ["None", "Subtle", "Intense", "Extreme", "Silly"], "value": Settings.camera_shake},
		"background_enabled": {"type": "tickbox", "value": Settings.background_enabled},
		"background_palette": {"type": "select", "options": ["Muted", "Fiery", "Earthy", "Envious"], "value": Settings.background_palette},
		"background_speed": {"type": "select", "options": ["0.00x", "0.25x", "0.50x", "0.75x", "1.00x", "1.25x", "1.50x", "1.75x", "2.00x"], "value": Settings.background_speed},
		"sfx_volume": {"type": "volume", "value": Settings.sfx_volume},
		"bgm_volume": {"type": "volume", "value": Settings.bgm_volume},
		"ui_volume": {"type": "volume", "value": Settings.ui_volume}
	}
	# If this is the web version, remove various desktop-only items
	if OS.has_feature("web"):
		menu.items["main_menu"]["children"].remove(
			menu.items["main_menu"]["children"].find("quit")
		)
		for item in ["fullscreen", "screen_scale"]:
			menu.items["video"]["children"].remove(
				menu.items["video"]["children"].find(item)
			)
	menu.current_item = "main_menu"
	menu.resize(true)
	Overlay.transition_in()
	credits.connect("close_credits", self, "close_credits")
	SoundMaster.change_layer_immediately(0)
	SoundMaster.play_title_music()

func _on_Menu_variable_changed(variable_name : String) -> void:
	Settings.skip_tutorials = menu.variables["skip_tutorials"]["value"]
	Settings.show_ui = menu.variables["show_ui"]["value"]
	Settings.player_avatar = menu.variables["player_avatar"]["value"]
	Settings.partner_avatar = menu.variables["partner_avatar"]["value"]
	Settings.colour_blind_assist = menu.variables["colour_blind_assist"]["value"]
	Settings.fullscreen = menu.variables["fullscreen"]["value"]
	Settings.show_cursor = menu.variables["show_cursor"]["value"]
	Settings.background_enabled = menu.variables["background_enabled"]["value"]
	Settings.background_speed = menu.variables["background_speed"]["value"]
	Settings.background_palette = menu.variables["background_palette"]["value"]
	Settings.screen_scale = menu.variables["screen_scale"]["value"]
	Settings.camera_shake = menu.variables["camera_shake"]["value"]
	Settings.sfx_volume = menu.variables["sfx_volume"]["value"]
	Settings.bgm_volume = menu.variables["bgm_volume"]["value"]
	Settings.ui_volume = menu.variables["ui_volume"]["value"]
	Settings.apply_config()
	Settings.save_config()

func start_game() -> void:
	if GameProgress.new_game:
		Levels.new_game()
	else:
		get_tree().change_scene("res://scenes/LevelSelect.tscn")

func open_credits() -> void:
	logo.hide()
	menu.hide()
	copyright.hide()
	credits.show()
	menu.active = false

func close_credits() -> void:
	logo.show()
	menu.show()
	copyright.show()
	credits.hide()
	menu.active = true

func _on_Menu_button_pressed(slug : String) -> void:
	match slug:
		"play":
			menu.active = false
			if GameProgress.new_game:
				SoundMaster.fade_out_music()
			else:
				SoundMaster.change_layer(1)
			Overlay.transition_out()
			yield(Overlay, "transition_finished")
			start_game()
		"credits":
			open_credits()
		"quit":
			menu.active = false
			Overlay.transition_out()
			yield(Overlay, "transition_finished")
			get_tree().quit()
