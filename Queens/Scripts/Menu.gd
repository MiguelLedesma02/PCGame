extends Control

@onready var start_audio: AudioStreamPlayer = $MarginContainer/Buttons/Start/AudioStreamPlayer
@onready var credits_audio: AudioStreamPlayer = $MarginContainer/Buttons/Credits/AudioStreamPlayer
@onready var exit_audio: AudioStreamPlayer = $MarginContainer/Buttons/Exit/AudioStreamPlayer

var main_scene = "res://Scenes/Main.tscn"

func _on_start_pressed() -> void:
	start_audio.playing = true
	get_tree().change_scene_to_file(main_scene)


func _on_credits_pressed() -> void:
	credits_audio.playing = true
	pass # Replace with function body.


func _on_exit_pressed() -> void:
	exit_audio.playing = true
	get_tree().quit()
