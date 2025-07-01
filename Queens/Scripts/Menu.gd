extends Control

const levels_scene = "res://Scenes/Levels.tscn"
const credits_scene = "res://Scenes/Credits.tscn"

func _on_start_pressed() -> void:
	AudioManager.play_button_sound()
	get_tree().change_scene_to_file(levels_scene)

func _on_credits_pressed() -> void:
	AudioManager.play_button_sound()
	get_tree().change_scene_to_file(credits_scene)

func _on_exit_pressed() -> void:
	AudioManager.play_button_sound()
	get_tree().quit()
