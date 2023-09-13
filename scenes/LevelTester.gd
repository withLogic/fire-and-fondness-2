extends Node2D

onready var board = $Board
onready var loader = $Loader
onready var ui = $UI/InGameUI

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene("res://scenes/LevelEditor.tscn")

func _ready():
	if Levels.currently_editing:
		loader.load_level(Levels.editing_level)
		loader.setup_level()
		board.ui = ui
		board.start_game()
