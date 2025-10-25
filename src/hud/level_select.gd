extends Control

@onready var level_1_button = $VBoxContainer/Level1Button
@onready var level_2_button = $VBoxContainer/Level2Button
@onready var level_3_button = $VBoxContainer/Level3Button
@onready var back_button = $BackButton

func _ready():
	# Asegurarnos de que la música suene en esta escena
	MusicManager.play_music() 
	
	level_1_button.pressed.connect(_on_level_pressed.bind(1))
	level_2_button.pressed.connect(_on_level_pressed.bind(2))
	level_3_button.pressed.connect(_on_level_pressed.bind(3))
	back_button.pressed.connect(_on_back_pressed)
	actualizar_botones()

func actualizar_botones():
	# Tu Autoload de guardado se llama SaveManager, ¡genial!
	var max_nivel_desbloqueado = SaveManager.unlocked_level
	level_1_button.disabled = false 
	level_2_button.disabled = (max_nivel_desbloqueado < 2)
	level_3_button.disabled = (max_nivel_desbloqueado < 3)

func _on_level_pressed(numero_de_nivel):
	# --- LÍNEA AÑADIDA ---
	# Paramos la música del menú ANTES de cargar el nivel
	MusicManager.stop_music()
	
	# Esta ruta a los niveles (src/niveles) ya estaba bien
	get_tree().change_scene_to_file("res://src/niveles/nivel_" + str(numero_de_nivel) + ".tscn")
	SaveManager.is_in_game_level = true

func _on_back_pressed():
	# Regresa al menú principal (aquí NO paramos la música)
	get_tree().change_scene_to_file("res://src/hud/main_menu.tscn")
