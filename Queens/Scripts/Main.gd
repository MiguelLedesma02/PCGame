extends Control

#Referencias a Archivos
var colors_file

#Referencias a Nodos
@onready var grid = $CenterContainer/GridContainer
@onready var help_popup = $HelpPopUp
@onready var undo_button = $UndoButton
@onready var help_button = $HelpButton
@onready var back_button = $BackButton/Back
@onready var audio_player = $Board/AudioStreamPlayer
@onready var music_button = $MusicButton
@onready var background_board = $BackgroundBoard

const levels_scene = "res://Scenes/Levels.tscn"

#Generales
const BOARD_SIZE = 8
var board = []
var colors = []
var music_on = true
const music_on_db = 0
const music_off_db = -80

#Timer
@onready var timer_label = $TimerLabel
@onready var game_timer = $Timer
var time_elapsed = 0  # en segundos

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
	AudioManager.play_button_sound()
	get_tree().change_scene_to_file(levels_scene)


func _on_undo_button_pressed() -> void:
	AudioManager.play_button_sound()
	for row in board:
		for cell in row:
			cell.clear()
	

func _on_timer_timeout() -> void:
	time_elapsed += 1

	var minutes = int(time_elapsed / 60)
	var seconds = int(time_elapsed % 60)

	var time_str = "%02d:%02d" % [minutes, seconds]
	timer_label.text = time_str


func _on_help_pressed() -> void:
	help_popup.visible = true
	help_button.disabled = true
	back_button.disabled = true
	undo_button.disabled = true
	music_button.disabled = true
	background_board.visible = false
	grid.visible = false

func _on_continue_button_pressed() -> void:
	help_popup.visible = false
	help_button.disabled = false
	back_button.disabled = false
	undo_button.disabled = false
	music_button.disabled = false
	background_board.visible = true
	grid.visible = true

func _on_music_button_pressed() -> void:
	if music_on:
		audio_player.volume_db = music_off_db
		music_on = false
	else:
		audio_player.volume_db = music_on_db
		music_on = true
		
	
