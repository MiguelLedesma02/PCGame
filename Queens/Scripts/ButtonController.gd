extends Button

@export var target_label: Label

func _on_mouse_entered() -> void:
	target_label.modulate.a = 0.5

func _on_mouse_exited() -> void:
	target_label.modulate.a = 1.0
