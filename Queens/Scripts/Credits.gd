extends Control

@onready var press_button_audio: AudioStreamPlayer = $BackButton/PressButtonAudio

var menu_scene = "res://Scenes/Menu.tscn"

func _on_back_pressed() -> void:
	press_button_audio.playing = true
	get_tree().change_scene_to_file(menu_scene)
