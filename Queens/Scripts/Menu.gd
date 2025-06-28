extends Control

@onready var press_button_audio: AudioStreamPlayer = $MarginContainer/Buttons/PressButtonAudio

var levels_scene = "res://Scenes/Levels.tscn"
var credits_scene = "res://Scenes/Credits.tscn"

func _on_start_pressed() -> void:
	press_button_audio.playing = true
	get_tree().change_scene_to_file(levels_scene)


func _on_credits_pressed() -> void:
	press_button_audio.playing = true
	#get_tree().change_scene_to_file(credits_scene)


func _on_exit_pressed() -> void:
	press_button_audio.playing = true
	get_tree().quit()
