extends Node2D

const OBJ_TUTORIAL = preload("res://objects/Tutorial.tscn")
const OBJ_PAUSE = preload("res://objects/PauseScreen.tscn")
const OBJ_BACKGROUND_CHEVRONS = preload("res://objects/backgrounds/Chevrons.tscn")
const OBJ_BACKGROUND_DIAMONDS = preload("res://objects/backgrounds/Diamonds.tscn")
const OBJ_BACKGROUND_MINES = preload("res://objects/backgrounds/Mines.tscn")
const OBJ_BACKGROUND_WORMS = preload("res://objects/backgrounds/Worms.tscn")
const OBJ_BACKGROUND_CLUSTERS = preload("res://objects/backgrounds/Cluster.tscn")

var backgrounds = {
	"chevrons": OBJ_BACKGROUND_CHEVRONS,
	"diamonds": OBJ_BACKGROUND_DIAMONDS,
	"mines": OBJ_BACKGROUND_MINES,
	"worms": OBJ_BACKGROUND_WORMS,
	"clusters": OBJ_BACKGROUND_CLUSTERS
}

onready var board = $Board
onready var loader = $Loader
onready var ui = $UI/InGameUI

var level_data : Dictionary

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("pause") and board.player.can_move:
		var pause = OBJ_PAUSE.instance()
		add_child(pause)
		get_tree().paused = true
	if event.is_action_pressed("restart_level") and board.player.can_move:
		get_tree().paused = true
		Overlay.transition_out()
		yield(Overlay, "transition_finished")
		get_tree().paused = false
		get_tree().reload_current_scene()

func check_for_tutorials() -> void:
	# Check to see if need to show a tutorial before we get started
	if level_data.has("tutorial") and not Settings.skip_tutorials:
		var tutorial_data : Dictionary = level_data["tutorial"]
		var tutorial_slug : String = level_data["slug"]
		if not GameProgress.is_tutorial_shown(tutorial_slug):
			var tutorial = OBJ_TUTORIAL.instance()
			tutorial.slug = tutorial_slug
			add_child(tutorial)
			tutorial.set_label_title(tutorial_data["title"])
			tutorial.set_label_body(tutorial_data["body"])
			tutorial.resize()
			get_tree().paused = true

func check_for_backgrounds() -> void:
	if level_data.has("background"):
		var background_slug : String = level_data["background"]
		if backgrounds.has(background_slug):
			var background = backgrounds[background_slug].instance()
			add_child(background)

func start_game() -> void:
	check_for_tutorials()
	board.start_game()

func _ready() -> void:
	level_data = Levels.get_level_data(Levels.current_scene)
	loader.load_level(level_data)
	loader.setup_level()
	check_for_backgrounds()
	ui.show_turn_count = GameProgress.is_level_finished(Levels.current_scene)
	board.ui = ui
	board.update_ui()
	SoundMaster.start_ingame_music()
	Overlay.transition_in()
	yield(Overlay, "transition_finished")
	start_game()
