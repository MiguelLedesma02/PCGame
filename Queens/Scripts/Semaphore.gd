extends Node

var locked = false

func acquire():
	while locked:
		await get_tree().process_frame  # Espera un frame
	locked = true

func release():
	locked = false
