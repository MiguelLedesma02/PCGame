extends Control

var main_scene = "res://Scenes/Main.tscn"

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file(main_scene)


func _on_credits_pressed() -> void:
	pass # Replace with function body.


func _on_exit_pressed() -> void:
	get_tree().quit()
