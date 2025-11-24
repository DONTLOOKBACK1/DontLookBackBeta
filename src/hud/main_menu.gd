extends Control

# --- AGREGA ESTA LÍNEA AL PRINCIPIO ---
# Esto creará una casilla en el Inspector para que arrastres el archivo
@export var escena_nivel : PackedScene 

@onready var play_button = $VBoxContainer/CenterContainer/VBoxContainer/PlayButton
@onready var config_button = $VBoxContainer/CenterContainer/VBoxContainer/ConfigButton
@onready var exit_button = $VBoxContainer/CenterContainer/VBoxContainer/ExitButton

func _ready():
	MusicManager.play_music() 
	play_button.pressed.connect(_on_play_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	config_button.pressed.connect(_on_config_pressed)

func _on_play_pressed():
	# --- CAMBIA ESTA LÍNEA ---
	# En lugar de usar la ruta de texto "res://...", usamos la variable
	if escena_nivel:
		get_tree().change_scene_to_packed(escena_nivel)
	else:
		print("ERROR: No has asignado la escena en el Inspector")

func _on_exit_pressed():
	get_tree().quit()

func _on_config_pressed():
	# (Puedes hacer lo mismo para el menú de configuración si quieres)
	get_tree().change_scene_to_file("res://src/hud/config_menu.tscn")
