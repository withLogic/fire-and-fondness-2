extends CanvasLayer

onready var menu = $Menu
onready var label_steps = $Grid/Label_Steps_Value
onready var texture_flowers = $Grid/Control/TextureRect_Flowers_Value
onready var label_quip = $Label_Quip
onready var anim_player = $AnimationPlayer

const quips_with_flower : Array = [
	"Rose acquired, sweetheart uncooked. Mission accomplished.",
	"True romance achieved.",
	"You've got the touch! You've got the floweeeer!"
]

const quips_without_flower : Array = [
	"Disregarded roses; escaped burning building.",
	"The flowers were wilting, anyway.",
	"Anna Jarvis would be so proud."
]

var steps_taken : int
var par : int
var flowers_collected : int
var flowers_total : int

func _ready() -> void:
	menu.items = {
		"you_win": {
			"type": "menu",
			"children": [
				"continue",
				"restart",
				"quit"
			]
		},
		"continue": {
			"type": "button",
			"label": "Continue"
		},
		"restart": {
			"type": "button",
			"label": "Restart"
		},
		"quit": {
			"type": "button",
			"label": "Back to Menu"
		}
	}
	menu.current_item = "you_win"
	# Set level stats
	label_steps.text = "%d/%d" % [steps_taken, par]
	texture_flowers.texture.region.position.x = 8 if flowers_collected >= flowers_total else 16
	menu.resize(true)
	SoundMaster.play_sound("you_win")
	SoundMaster.fade_out_music()
	if flowers_collected >= flowers_total:
		label_quip.text = quips_with_flower[rand_range(0, quips_with_flower.size())]
		SoundMaster.play_sound("bgm_win2")
	else:
		label_quip.text = quips_without_flower[rand_range(0, quips_without_flower.size())]
		SoundMaster.play_sound("bgm_win1")
	anim_player.play("appear")

func next_level() -> void:
	Overlay.transition_out()
	yield(Overlay, "transition_finished")
	Levels.goto_scene(Levels.get_next_scene(Levels.current_scene))
	get_tree().paused = false
	queue_free()

func _on_Menu_button_pressed(slug : String) -> void:
	match slug:
		"continue":
			menu.active = false
			next_level()
		"restart":
			menu.active = false
			Overlay.transition_out()
			yield(Overlay, "transition_finished")
			get_tree().paused = false
			get_tree().reload_current_scene()
		"quit":
			menu.active = false
			Overlay.transition_out()
			yield(Overlay, "transition_finished")
			get_tree().paused = false
			get_tree().change_scene("res://scenes/TitleScreen.tscn")
