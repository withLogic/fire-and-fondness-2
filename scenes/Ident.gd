extends Control

onready var logo = $Logo
onready var tween = $Tween
onready var audio = $Audio_Tone

func _ready():	
	yield(get_tree().create_timer(0.75), "timeout")
	tween.interpolate_property(logo, "modulate", Color.black, Color.white, 0.25, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.0)
	tween.interpolate_property(logo, "modulate", Color.white, Color.black, 0.25, Tween.TRANS_LINEAR, Tween.EASE_OUT, 1.0)
	tween.start()
	audio.play()
	yield(get_tree().create_timer(1.5), "timeout")
	get_tree().change_scene("res://scenes/TitleScreen.tscn")
