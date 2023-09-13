extends Node

const SAVE_PATH : String = "user://save.json"

var level_progress : Dictionary
var tutorials_shown : Array
var new_game : bool

func init_level(level : String) -> void:
	var level_data : Dictionary = {
		"unlocked": false,
		"finished": false,
		"best_time": -1,
		"got_flowers": false
	}
	level_progress[level] = level_data

func new_game() -> void:
	level_progress = {}
	tutorials_shown = []
	new_game = true
	for season in Levels.seasons:
		for level in Levels.get_season_levels(season):
			init_level(level)
	level_progress["s1e1"]["unlocked"] = true
	save_game()

func load_game() -> void:
	var file : File = File.new()
	if file.file_exists(SAVE_PATH):
		file.open(SAVE_PATH, File.READ)
		var content : String = file.get_as_text()
		file.close()
		var json = JSON.parse(content).result
		level_progress = json["levels"]
		tutorials_shown = json["tutorials"]
		new_game = json["new_game"]
	else:
		new_game()

func save_game() -> void:
	var data : Dictionary = {
		"levels": level_progress,
		"tutorials": tutorials_shown,
		"new_game": new_game
	}
	var json = JSON.print(data)
	var file : File = File.new()
	file.open(SAVE_PATH, File.WRITE)
	file.store_string(json)
	file.close()

func get_level_best_time(level : String) -> int:
	return level_progress[level]["best_time"]

func update_level_progress(level : String, moves : int, flowers_collected : bool) -> void:
	var progress : Dictionary = level_progress[level]
	progress["finished"] = true
	if moves < progress["best_time"] or progress["best_time"] == -1:
		progress["best_time"] = moves
	if flowers_collected:
		progress["got_flowers"] = true
	level_progress[level] = progress
	new_game = false
	# Unlock the next level
	var next : String = Levels.get_next_scene(level)
	if Levels.scene_is_level(next):
		set_level_unlocked(next)
	else:
		# Really janky hack, but... is the scene _after_ the next one a level?
		var second_next : String = Levels.get_next_scene(next)
		if Levels.scene_is_level(second_next):
			set_level_unlocked(second_next)
		# Fine, whatever, just save the game
		else:
			save_game()

func set_level_unlocked(level : String) -> void:
	var progress : Dictionary = level_progress[level]
	progress["unlocked"] = true
	level_progress[level] = progress
	save_game()

func is_level_unlocked(level : String) -> bool:
	return level_progress[level]["unlocked"]

func is_level_finished(level : String) -> bool:
	return level_progress[level]["finished"]

func get_level_beat_par(level : String) -> bool:
	return get_level_best_time(level) <= Levels.get_level_par(level) and get_level_best_time(level) != -1

func get_level_got_flowers(level : String) -> bool:
	return level_progress[level]["got_flowers"]

func is_season_unlocked(season : String) -> bool:
	for level in Levels.get_season_levels(season):
		if is_level_unlocked(level):
			return true
	return false

func get_unlocked_levels_for_season(season : String) -> int:
	var result : int = 0
	for level in Levels.get_season_levels(season):
		if is_level_unlocked(level):
			result += 1
		else:
			break
	return result

func get_unlocked_seasons() -> int:
	var result : int = 0
	for season in Levels.seasons:
		if is_season_unlocked(season):
			result += 1
		else:
			break
	return result

func is_tutorial_shown(tutorial : String) -> bool:
	return tutorials_shown.has(tutorial)

func set_tutorial_shown(tutorial : String):
	tutorials_shown.append(tutorial)

func get_completion_rate() -> float:
	var total : int = 0
	var completed : int = 0
	for level in level_progress:
		if is_level_finished(level): completed += 1
		if get_level_beat_par(level): completed += 1
		if get_level_got_flowers(level): completed += 1
		total += 3
	return float(completed) / float(total)

func is_season_five_unlocked() -> bool:
	return get_completion_rate() >= 0.8

func _ready() -> void:
	load_game()
