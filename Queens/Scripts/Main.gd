extends Control

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
const BOARD_SIZE = 9
var board = []

func _ready():

	#Se crea el tablero
	create_board()

	#Se crean los hilos
	create_threads()

	#Se crean los semáforos
	create_semaphores()

func create_board():

	#Se inicializa el tablero
	board.resize(BOARD_SIZE)

	#Se crean las celdas
	for i in range(BOARD_SIZE):
		board[i] = []

		for j in range(BOARD_SIZE):
			var cell = create_cell(i, j, 1) #TODO: Falta setear el color
			board[i].append(cell)

func create_cell(row: int, col: int, color: int):

	var cell_scene = preload("res://Scenes/Cell.tscn")
	var cell = cell_scene.instantiate()

	grid.add_child(cell)
	cell.row = row
	cell.col = col
	cell.color = color

	return cell

func create_threads():

	for i in range(BOARD_SIZE):
		row_threads.append(Thread.new())
		col_threads.append(Thread.new())
		color_threads.append(Thread.new())

	return

func create_semaphores():
	
	var semaphore_scene = preload("res://Scenes/Semaphore.tscn")

	row_mtx = semaphore_scene.instantiate()
	col_mtx = semaphore_scene.instantiate()
	color_mtx = semaphore_scene.instantiate()

	return

func cell_updated(row: int, col: int, color: int):
	
	var crowns_row = 0
	var crowns_col = 0
	var crowns_color = 0
	
	for i in range(BOARD_SIZE):
		row_threads[row].start(self, "count_crowns_in_row", [row])
		col_threads[col].start(self, "count_crowns_in_column", [col])
		color_threads[color].start(self, "count_crowns_in_color", [color])
		
		if row_threads[row].is_alive():
			row_mtx.adquire()
			crowns_row = row_threads[row].wait_to_finish()
			row_mtx.release()
		if col_threads[col].is_alive():
			col_mtx.adquire()
			crowns_col = col_threads[col].wait_to_finish()
			col_mtx.release()
		if color_threads[color].is_alive():
			color_mtx.adquire()
			crowns_color = color_threads[color].wait_to_finish()
			color_mtx.release()
	
	if crowns_row == BOARD_SIZE && crowns_col == BOARD_SIZE && crowns_color == BOARD_SIZE:
			print("Has ganado!")
	
func count_crowns_in_row(row: int):

	var crowns = 0

	for i in range(BOARD_SIZE):

		if board[row][i].getHasCrown():
			crowns = crowns + 1

	return crowns

func count_crowns_in_column(col: int):

	var crowns = 0

	for i in range(BOARD_SIZE):

		if board[i][col].getHasCrown():
			crowns = crowns + 1

	return crowns

func count_crowns_in_color(color: int):

	var crowns = 0

	for i in range(BOARD_SIZE):
		for j in range(BOARD_SIZE):

			if board[i][j].getColor() == color && board[i][j].getHasCrown():
				crowns = crowns + 1

	return crowns
