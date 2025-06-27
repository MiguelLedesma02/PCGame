extends Node

#Referencias a Nodos
@onready var main = get_tree().get_root().get_node("Main")

#Globales
const BOARD_SIZE = 8
var board = []

#Vectores de Hilos
var row_threads = []
var col_threads = []
var color_threads = []

#Mutex de Hilos
var row_mtx
var col_mtx
var color_mtx

func _ready():
	#Se inicializa el tablero
	board = main.get_board()
	
	#Se crean los semáforos
	create_mutex()

func cell_updated():
	
	var only_one_crown_row = false
	var only_one_crown_col = false
	var only_one_crown_color = false

	var rows_ok = 0
	var columns_ok = 0
	var colors_ok = 0

	#Se crean los hilos
	create_threads()

	#Se crea un hilo para cada fila, columna y color
	for i in range(BOARD_SIZE):
		row_threads[i].start(count_crowns_in_row.bind(i))
		col_threads[i].start(count_crowns_in_column.bind(i))
		color_threads[i].start(count_crowns_in_color.bind(i))

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

func create_threads():

	for i in range(BOARD_SIZE):
		row_threads.append(Thread.new())
		col_threads.append(Thread.new())
		color_threads.append(Thread.new())

	return

func destroy_threads():

	row_threads.clear()
	col_threads.clear()
	color_threads.clear()

	return

func create_mutex():

	row_mtx = Mutex.new()
	col_mtx = Mutex.new()
	color_mtx = Mutex.new()

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

func count_crowns_in_color(c: int):

	var one_crown = false
	var crowns = 0
	var color
	
	color = get_color_by_id(c)

	for i in range(BOARD_SIZE):
		for j in range(BOARD_SIZE):

			if board[i][j].getColor() == color && board[i][j].getHasCrown():
				crowns = crowns + 1

	if crowns == 1:
		one_crown = true

	return one_crown

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
