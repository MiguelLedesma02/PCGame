extends Control

@onready var press_button_audio: AudioStreamPlayer = $MarginContainer/Levels/PressButtonAudio

var menu_scene = "res://Scenes/Menu.tscn"

func _on_level_1_pressed() -> void:
	press_button_audio.playing = true
	load_level_scene("res://Levels/Level1.csv")

func _on_level_2_pressed() -> void:
	press_button_audio.playing = true
	load_level_scene("res://Levels/Level2.csv")

func _on_level_3_pressed() -> void:
	press_button_audio.playing = true
	load_level_scene("res://Levels/Level3.csv")

func _on_back_pressed() -> void:
	press_button_audio.playing = true
	get_tree().change_scene_to_file(menu_scene)

func load_level_scene(file: String):

	var scene = preload("res://Scenes/Game.tscn").instantiate()
	scene.colors_file = file
	get_tree().root.add_child(scene)
	
	get_tree().current_scene.queue_free()
	get_tree().current_scene = scene
