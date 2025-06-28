extends Control

#Referencias a Archivos
var colors_file

#Referencias a Nodos
@onready var press_button_audio: AudioStreamPlayer = $BackButton/PressButtonAudio
@onready var grid = $CenterContainer/GridContainer

const levels_scene = "res://Scenes/Levels.tscn"

#Generales
const BOARD_SIZE = 8
var board = []
var colors = []

func _ready():

	#Se obtienen los colores del tablero
	get_board_colors()

	#Se crea el tablero
	create_board()

	return

func get_board():
	return board

func get_board_colors():

	var file = FileAccess.open(colors_file, FileAccess.READ)

	if file == null:
		print("Error al abrir el archivo.")

	while not file.eof_reached():
		var line = file.get_line()
		line = line.replace('"', '')
		var values = line.strip_edges().split(",", false)

		for i in range(values.size()):
			values[i] = values[i].strip_edges()

		colors.append(values)

	file.close()

	return

func create_board():

	#Se inicializa el tablero
	board.resize(BOARD_SIZE)

	#Se crean las celdas
	for i in range(BOARD_SIZE):
		board[i] = []

		for j in range(BOARD_SIZE):
			var cell = create_cell(i, j, colors[i][j])
			board[i].append(cell)

	return

func create_cell(row: int, col: int, color: String):

	var cell_scene = preload("res://Scenes/Cell.tscn")
	var cell = cell_scene.instantiate()

	grid.add_child(cell)
	cell.row = row
	cell.col = col
	cell.set_color(color)

	return cell

func _on_back_pressed() -> void:
	press_button_audio.playing = true
	get_tree().change_scene_to_file(levels_scene)
