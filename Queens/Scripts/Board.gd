extends Node

#Referencias a Nodos
@onready var main = get_tree().get_root().get_node("Main")

@onready var background_board = $"../BackgroundBoard"
@onready var container_board = $"../CenterContainer"
@onready var popup_congratulations = $"../PopUpCongratulations"
@onready var undo_button = $"../UndoButton"
@onready var help_button = $"../HelpButton"
@onready var music_button = $"../MusicButton"
@onready var timer_scene = get_tree().get_root().get_node("Main")

#Globales
const BOARD_SIZE = 8
var board = []
var game_time = 0.0
const url_sheet = "https://script.google.com/macros/s/AKfycbxeDrmfad-CVwbeJ73dk_2fGG0TACWjNaF_03R3V1Kh2W3DfyG5ZLb-c3-mIwz1GHA4/exec"

#Vectores de Hilos
var row_threads = []
var col_threads = []
var color_threads = []
var diag_threads = []

# Almacena posiciones conflictivas detectadas por cada tipo de validación
var invalid_positions = []

#Mutex de Hilos
var row_mtx
var col_mtx
var color_mtx
var diag_mtx
var invalid_positions_mtx

var rows_ok = 0
var columns_ok = 0
var colors_ok = 0
var diagonals_ok = 0

func _ready():
	#Se inicializa el tablero
	board = main.get_board()
	$AudioStreamPlayer.play()
	#Se crean los semáforos
	create_mutex()

func cell_updated():
	rows_ok = 0
	columns_ok = 0
	colors_ok = 0
	diagonals_ok = 0
	
	reset_all_crowns_color()
	
	invalid_positions.clear()

	#Se crean los hilos
	create_threads()

	#Se inicia la ejecución de cada hilo para que corran concurrentemente
	for i in range(BOARD_SIZE):
		row_threads[i].start(count_crowns_in_row.bind(i))
		col_threads[i].start(count_crowns_in_column.bind(i))
		color_threads[i].start(count_crowns_in_color.bind(i))
		diag_threads[i].start(validate_diagonals.bind(i))
		
	for i in range(BOARD_SIZE):
		if row_threads[i].is_started(): row_threads[i].wait_to_finish()
		if col_threads[i].is_started(): col_threads[i].wait_to_finish()
		if color_threads[i].is_started(): color_threads[i].wait_to_finish()
		if diag_threads[i].is_started(): diag_threads[i].wait_to_finish()
	
	destroy_threads()

	mark_invalid_crowns(invalid_positions)
	
	if rows_ok == BOARD_SIZE && columns_ok == BOARD_SIZE && colors_ok == BOARD_SIZE and diagonals_ok == BOARD_SIZE:
		win_game()

	return

func create_threads():

	for i in range(BOARD_SIZE):
		row_threads.append(Thread.new())
		col_threads.append(Thread.new())
		color_threads.append(Thread.new())
		diag_threads.append(Thread.new())

	return

func destroy_threads():

	row_threads.clear()
	col_threads.clear()
	color_threads.clear()
	diag_threads.clear()

	return

func create_mutex():

	row_mtx = Mutex.new()
	col_mtx = Mutex.new()
	color_mtx = Mutex.new()
	diag_mtx = Mutex.new()
	invalid_positions_mtx = Mutex.new()

	return

func count_crowns_in_row(row: int):

	var crowns = 0

	for i in range(BOARD_SIZE):

		if board[row][i].getHasCrown():
			crowns = crowns + 1

	if crowns > 1:
		for i in range(BOARD_SIZE):
			if board[row][i].getHasCrown():
				invalid_positions_mtx.lock()
				invalid_positions.append(Vector2(row, i))
				invalid_positions_mtx.unlock()
	
	if crowns == 1:
		row_mtx.lock()
		rows_ok += 1
		row_mtx.unlock()

func count_crowns_in_column(col: int):

	var crowns = 0

	for i in range(BOARD_SIZE):

		if board[i][col].getHasCrown():
			crowns = crowns + 1

	if crowns > 1:
		for i in range(BOARD_SIZE):
			if board[i][col].getHasCrown():
				invalid_positions_mtx.lock()
				invalid_positions.append(Vector2(i, col))
				invalid_positions_mtx.unlock()

	if crowns == 1:
		col_mtx.lock()
		columns_ok += 1
		col_mtx.unlock()

func count_crowns_in_color(c: int):

	var crowns = 0
	var color
	
	color = get_color_by_id(c)

	for i in range(BOARD_SIZE):
		for j in range(BOARD_SIZE):

			if board[i][j].getColor() == color && board[i][j].getHasCrown():
				crowns = crowns + 1

	if crowns > 1:
		for i in range(BOARD_SIZE):
			for j in range(BOARD_SIZE):
				if board[i][j].getColor() == color and board[i][j].getHasCrown():
					invalid_positions_mtx.lock()
					invalid_positions.append(Vector2(i, j))
					invalid_positions_mtx.unlock()

	if crowns == 1:
		color_mtx.lock()
		colors_ok += 1
		color_mtx.unlock()

func validate_diagonals(row: int):
	var invalid_pos = []
	var conflicts_found = false

	for col in range(BOARD_SIZE):
		if board[row][col].getHasCrown():
			# Revisar diagonales adyacentes
			var diagonals = [
				Vector2(row - 1, col - 1),
				Vector2(row - 1, col + 1),
				Vector2(row + 1, col - 1),
				Vector2(row + 1, col + 1)
			]

			for d in diagonals:
				var r = int(d.x)
				var c = int(d.y)
				if r >= 0 and r < BOARD_SIZE and c >= 0 and c < BOARD_SIZE:
					if board[r][c].getHasCrown():
						conflicts_found = true
						# Agregamos ambas posiciones conflictivas
						invalid_pos.append(Vector2(row, col))
						invalid_pos.append(Vector2(r, c))

	# Eliminamos duplicados en invalid_pos
	var unique_pos = []
	for pos in invalid_pos:
		if not unique_pos.has(pos):
			invalid_positions_mtx.lock()
			invalid_positions.append(pos)
			invalid_positions_mtx.unlock()
	
	if not conflicts_found:
		diag_mtx.lock()
		diagonals_ok += 1
		diag_mtx.unlock()

func get_color_by_id(id: int):

	if id == 0:
		return "VIOLETA"
	if id == 1:
		return "AZUL"
	if id == 2:
		return "GRIS C"
	if id == 3:
		return "GRIS O"
	if id == 4:
		return "VERDE C"
	if id == 5:
		return "VERDE O"
	if id == 6:
		return "NARANJA C"
	if id == 7:
		return "NARANJA O"

func win_game():

	background_board.visible = false
	container_board.visible = false
	undo_button.visible = false
	help_button.visible = false
	music_button.visible = false
	popup_congratulations.visible = true
	main.get_node("Timer").stop()
	update_gsheet("Ganó", timer_scene.time_elapsed)

	
func reset_all_crowns_color():
	for row in range(BOARD_SIZE):
		for col in range(BOARD_SIZE):
			if board[row][col].getHasCrown():
				board[row][col].resetCrown()
				
func mark_invalid_crowns(positions: Array):
	# Marca las coronas en las posiciones dadas como inválidas (rojas)
	for pos in positions:
		var r = int(pos.x)
		var c = int(pos.y)
		if board[r][c].getHasCrown():
			board[r][c].setCrownInvalid()
			
func _process(delta):
	var game_time = timer_scene.time_elapsed
	var nuevo_pitch = 1.0 + (game_time / 60.0) * 0.5
	$AudioStreamPlayer.pitch_scale = clamp(nuevo_pitch, 1.0, 1.5)
		
func update_gsheet(result: String, time: int):
	var data = {
		"jugador": "Jugador 1",
		"resultado": result,
		"tiempo": time,
		"detalles": "Intento desde Godot"
	}
	
	var json_data = JSON.stringify(data)

	$HTTPRequest.request(
		url_sheet,
		["Content-Type: application/json"],
		HTTPClient.METHOD_POST,
		json_data
	)
