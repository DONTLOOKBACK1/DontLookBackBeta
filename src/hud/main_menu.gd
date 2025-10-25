extends Control

# Obtenemos referencias a nuestros botones usando @onready.
# La ruta debe coincidir con tu árbol de escena.
# CORRECTO:
@onready var play_button = $VBoxContainer/CenterContainer/VBoxContainer/PlayButton
@onready var exit_button = $VBoxContainer/CenterContainer/VBoxContainer/ExitButton

func _ready():
	# 1. Conectamos la señal "pressed" (cuando se presiona) del botón
	#    a una función que definiremos.
	play_button.pressed.connect(_on_play_pressed)

	# 2. Hacemos lo mismo para el botón de salir.
	exit_button.pressed.connect(_on_exit_pressed)

# Esta función se ejecutará cuando se presione el botón "Jugar"
func _on_play_pressed():
	# Cargamos la escena de selección de nivel.
	# ¡Asegúrate de que esta ruta sea la que usarás para la siguiente escena!
	get_tree().change_scene_to_file("res://src/hud/level_select.tscn")

# Esta función se ejecutará cuando se presione el botón "Salir"
func _on_exit_pressed():
	# Cierra el juego
	get_tree().quit()
