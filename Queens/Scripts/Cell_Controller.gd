extends Button

#Referencias a Nodos
@onready var main = get_tree().get_root().get_node("Main")
@onready var color_rect = $ColorRect
@onready var crown = $Crown
@onready var cross = $Cross

#Generales
var row: int
var col: int
var color: String
var has_crown := false
var has_cross := false

func _ready():

	crown.visible = has_crown
	cross.visible = has_cross

func _gui_input(event):

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_on_left_pressed()

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_on_right_pressed()

func _on_left_pressed():

	var board = main.get_node("Board")

	#Se coloca la corona y se quita la cruz
	has_crown = !has_crown
	crown.visible = has_crown
	if has_cross:
		has_cross = false
		cross.visible = has_cross

	board.cell_updated()

func _on_right_pressed():

	#Se coloca la cruz y se quita la corona
	has_cross = !has_cross
	cross.visible = has_cross
	if has_crown:
		has_crown = false
		crown.visible = has_crown

func set_color(c: String):

	color = c

	if color == "VIOLETA":
		color_rect.color = Color8(187, 163, 226)
	if color == "AZUL":
		color_rect.color = Color8(150, 190, 255)
	if color == "GRIS C":
		color_rect.color = Color8(223, 223, 223)
	if color == "GRIS O":
		color_rect.color = Color8(185, 178, 158)
	if color == "VERDE C":
		color_rect.color = Color8(230, 243, 136)
	if color == "VERDE O":
		color_rect.color = Color8(179, 223, 160)
	if color == "NARANJA C":
		color_rect.color = Color8(255, 201, 146)
	if color == "NARANJA O":
		color_rect.color = Color8(255, 123, 96)

func getColor():
	return color

func getHasCrown():
	return has_crown
