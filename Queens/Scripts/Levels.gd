extends Control

const menu_scene = "res://Scenes/Menu.tscn"
const game_scene = "res://Scenes/Game.tscn"

func _on_level_1_pressed() -> void:
	AudioManager.play_button_sound()
	load_level_scene("res://Levels/Level1.csv")

func _on_level_2_pressed() -> void:
	AudioManager.play_button_sound()
	load_level_scene("res://Levels/Level2.csv")

func _on_level_3_pressed() -> void:
	AudioManager.play_button_sound()
	load_level_scene("res://Levels/Level3.csv")

func _on_back_pressed() -> void:
	AudioManager.play_button_sound()
	get_tree().change_scene_to_file(menu_scene)

func load_level_scene(file: String):

	var scene = preload(game_scene).instantiate()
	scene.colors_file = file
	get_tree().root.add_child(scene)
	
	get_tree().current_scene.queue_free()
	get_tree().current_scene = scene
