extends Button

#Referencias a Nodos
@onready var main = get_tree().get_root().get_node("Main")
@onready var color_rect = $ColorRect
@onready var crown = $Crown

#Generales
var row: int
var col: int
var color: String
var has_crown := false

func _ready():

	pressed.connect(_on_pressed)
	crown.visible = has_crown

func _on_pressed():

	print("Se colocó una corona sobre la celda: (", row, ",", col, ")")
	has_crown = !has_crown
	crown.visible = has_crown
	#main.cell_updated(row, col, color)

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
	return color_rect.color

func getHasCrown():
	return has_crown
