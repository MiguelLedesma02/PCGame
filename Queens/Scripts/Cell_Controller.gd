extends Button

#Referencias a Nodos
@onready var crown = $Crown
@onready var main = get_tree().get_root().get_node("Main")

#Generales
var row: int
var col: int
var color: int
var has_crown := false

func _ready():

	pressed.connect(_on_pressed)
	crown.visible = has_crown

func _on_pressed():

	print("Se colocó una corona sobre la celda: (", row, ",", col, ")")
	has_crown = !has_crown
	crown.visible = has_crown
	#main.cell_updated(row, col, color)

func getColor():
	return color

func getHasCrown():
	return has_crown
