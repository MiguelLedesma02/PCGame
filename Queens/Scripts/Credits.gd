extends Control

const menu_scene = "res://Scenes/Menu.tscn"

func _on_back_pressed() -> void:
	AudioManager.play_button_sound()
	get_tree().change_scene_to_file(menu_scene)
