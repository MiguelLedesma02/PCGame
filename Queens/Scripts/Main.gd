extends Control

#Referencias a Archivos
var colors_file = "res://Settings/Colors.csv"

#Referencias a Nodos
@onready var grid = $CenterContainer/GridContainer

#Vectores de Hilos
var row_threads = []
var col_threads = []
var color_threads = []

#Mutex de Hilos
var row_mtx
var col_mtx
var color_mtx

#Generales
const BOARD_SIZE = 8
var board = []
var colors = []

func _ready():

	#Se obtienen los colores del tablero
	get_board_colors()

	#Se crea el tablero
	create_board()

	#Se crean los semáforos
	create_mutex()

	return

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

func create_threads():

	for i in range(BOARD_SIZE):
		row_threads.append(Thread.new())
		col_threads.append(Thread.new())
		color_threads.append(Thread.new())

	return

func destroy_threads():

	row_threads = []
	col_threads = []
	color_threads = []
	
	return

func create_mutex():

	row_mtx = Mutex.new()
	col_mtx = Mutex.new()
	color_mtx = Mutex.new()

	return

func cell_updated():
	
	var only_one_crown_row = false
	var only_one_crown_col = false
	var only_one_crown_color = false

	var rows_ok = 0
	var columns_ok = 0
	var colors_ok = 8 #TODO: Este dato es para debug. Modificar

	#Se crean los hilos
	create_threads()

	#Se crea un hilo para cada fila, columna y color
	for i in range(BOARD_SIZE):
		row_threads[i].start(count_crowns_in_row.bind(i))
		col_threads[i].start(count_crowns_in_column.bind(i))
		#TODO: Falta las regiones de color

	for i in range(BOARD_SIZE):

		if row_threads[i].is_started():
			row_mtx.lock()
			only_one_crown_row = row_threads[i].wait_to_finish()
			if only_one_crown_row:
				rows_ok += 1
			row_mtx.unlock()

		if col_threads[i].is_started():
			col_mtx.lock()
			only_one_crown_col = col_threads[i].wait_to_finish()
			if only_one_crown_col:
				columns_ok += 1
			col_mtx.unlock()

		if color_threads[i].is_started():
			color_mtx.lock()
			only_one_crown_color = color_threads[i].wait_to_finish()
			if only_one_crown_color:
				colors_ok += 1
			color_mtx.unlock()

	if rows_ok == BOARD_SIZE && columns_ok == BOARD_SIZE && colors_ok == BOARD_SIZE:
			print("Has ganado!")

	#Se destruyen los hilos
	destroy_threads()

	return

func count_crowns_in_row(row: int):

	var one_crown = false
	var crowns = 0

	for i in range(BOARD_SIZE):

		if board[row][i].getHasCrown():
			crowns = crowns + 1

	if crowns == 1:
		one_crown = true

	return one_crown

func count_crowns_in_column(col: int):

	var one_crown = false
	var crowns = 0

	for i in range(BOARD_SIZE):

		if board[i][col].getHasCrown():
			crowns = crowns + 1

	if crowns == 1:
		one_crown = true

	return one_crown

func count_crowns_in_color(color: String):

	var one_crown = false
	var crowns = 0

	for i in range(BOARD_SIZE):
		for j in range(BOARD_SIZE):

			if board[i][j].getColor() == color && board[i][j].getHasCrown():
				crowns = crowns + 1

	if crowns == 1:
		one_crown = true

	return one_crown
