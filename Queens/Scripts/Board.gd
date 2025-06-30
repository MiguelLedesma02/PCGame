extends Node

#Referencias a Nodos
@onready var main = get_tree().get_root().get_node("Main")

@onready var background_board = $"../BackgroundBoard"
@onready var container_board = $"../CenterContainer"
@onready var popup_congratulations = $"../PopUpCongratulations"
@onready var undo_button = $"../UndoButton"

#Globales
const BOARD_SIZE = 8
var board = []

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

func _ready():
	#Se inicializa el tablero
	board = main.get_board()
	
	#Se crean los semáforos
	create_mutex()

func cell_updated():
	
	#var only_one_crown_row = false
	#var only_one_crown_col = false
	#var only_one_crown_color = false
	
	reset_all_crowns_color()

	var rows_ok = 0
	var columns_ok = 0
	var colors_ok = 0
	var diagonals_ok = 0
	
	# Resultados de cada hilo - Es un diccionario del tipo {valid, invalid_positions}
	var row_results = []
	var col_results = []
	var color_results = []
	var diag_results = []
	
	invalid_positions.clear()

	#Se crean los hilos
	create_threads()

	#Se crea un hilo para cada fila, columna y color
	for i in range(BOARD_SIZE):
		row_threads[i].start(count_crowns_in_row.bind(i))
		col_threads[i].start(count_crowns_in_column.bind(i))
		color_threads[i].start(count_crowns_in_color.bind(i))
		diag_threads[i].start(validate_diagonals.bind(i))

	for i in range(BOARD_SIZE):

		if row_threads[i].is_started():
			row_mtx.lock()
			var row_result = row_threads[i].wait_to_finish()
			row_results.append(row_result)
			row_mtx.unlock()

		if col_threads[i].is_started():
			col_mtx.lock()
			var col_result = col_threads[i].wait_to_finish()
			col_results.append(col_result)
			col_mtx.unlock()

		if color_threads[i].is_started():
			color_mtx.lock()
			var color_result = color_threads[i].wait_to_finish()
			color_results.append(color_result)
			color_mtx.unlock()
			
		if diag_threads[i].is_started():
			diag_mtx.lock()
			var diag_result = diag_threads[i].wait_to_finish()
			diag_results.append(diag_result)
			diag_mtx.unlock()
	
	destroy_threads()
	
	# Procesar resultados: marcar coronas inválidas y contar OK
	# Cada resultado es un dict con keys:
	#   "valid" : bool
	#   "invalid_positions" : Array of Vector2(row, col)
	
	for i in range(BOARD_SIZE):
		if i < row_results.size():
			if row_results[i]["valid"]:
				rows_ok += 1
			else:
				invalid_positions.append_array(row_results[i]["invalid_positions"])
		if i < col_results.size():
			if col_results[i]["valid"]:
				columns_ok += 1
			else:
				invalid_positions.append_array(col_results[i]["invalid_positions"])
		if i < color_results.size():
			if color_results[i]["valid"]:
				colors_ok += 1
			else:
				invalid_positions.append_array(color_results[i]["invalid_positions"])
		if i < diag_results.size():
			if diag_results[i]["valid"]:
				diagonals_ok += 1
			else:
				invalid_positions.append_array(diag_results[i]["invalid_positions"])

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

	return

func count_crowns_in_row(row: int):

	var invalid_pos = []
	var crowns = 0

	for i in range(BOARD_SIZE):

		if board[row][i].getHasCrown():
			crowns = crowns + 1

	if crowns > 1:
		for i in range(BOARD_SIZE):
			if board[row][i].getHasCrown():
				invalid_pos.append(Vector2(row, i))

	return {
		"valid": crowns == 1,
		"invalid_positions": invalid_pos
	}

func count_crowns_in_column(col: int):

	var invalid_pos = []
	var crowns = 0

	for i in range(BOARD_SIZE):

		if board[i][col].getHasCrown():
			crowns = crowns + 1

	if crowns > 1:
		for i in range(BOARD_SIZE):
			if board[i][col].getHasCrown():
				invalid_pos.append(Vector2(i, col))

	return {
		"valid": crowns == 1,
		"invalid_positions": invalid_pos
	}

func count_crowns_in_color(c: int):

	var invalid_pos = []
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
					invalid_pos.append(Vector2(i, j))

	return {
		"valid": crowns == 1,
		"invalid_positions": invalid_pos
	}

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
			unique_pos.append(pos)

	return {
		"valid": not conflicts_found,
		"invalid_positions": unique_pos
	}

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
	undo_button.visible= false
	popup_congratulations.visible = true
	main.get_node("Timer").stop()
	
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
