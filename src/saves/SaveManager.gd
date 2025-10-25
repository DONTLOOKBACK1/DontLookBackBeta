extends Node

# --- Variables de Progreso ---
var unlocked_level = 1
var save_path = ""

# --- Variables de Pausa (MODIFICADA) ---
const PAUSE_MENU_SCENE = preload("res://src/hud/pause_menu.tscn") # <-- RUTA CORREGIDA
var pause_menu_instance = null
var is_in_game_level = false

func _ready():
	var documents_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
	var game_save_dir = "LevelSevenStudios/DontLookBack"
	var full_dir_path = documents_dir.path_join(game_save_dir)
	DirAccess.make_dir_recursive_absolute(full_dir_path)
	save_path = full_dir_path.path_join("progreso.save")
	load_game()

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel") and is_in_game_level:
		if get_tree().paused:
			unpause_game()
		else:
			pause_game()

# --- Funciones de Guardado (Sin cambios) ---

func save_game():
	var config = ConfigFile.new()
	config.set_value("progreso", "unlocked_level", unlocked_level)
	var err = config.save(save_path)
	if err != OK:
		print("ERROR al guardar en:", save_path)

func load_game():
	var config = ConfigFile.new()
	if not FileAccess.file_exists(save_path):
		return
	var err = config.load(save_path)
	if err == OK:
		unlocked_level = config.get_value("progreso", "unlocked_level", 1)

func complete_level(level_completed):
	if level_completed == unlocked_level:
		unlocked_level += 1
		save_game()

# --- Funciones de Pausa (MODIFICADA) ---

func pause_game():
	get_tree().paused = true
	if pause_menu_instance == null:
		pause_menu_instance = PAUSE_MENU_SCENE.instantiate()
		get_tree().root.add_child(pause_menu_instance)

func unpause_game():
	get_tree().paused = false
	if pause_menu_instance != null:
		pause_menu_instance.queue_free()
		pause_menu_instance = null

func quit_to_menu():
	get_tree().paused = false
	if pause_menu_instance != null:
		pause_menu_instance.queue_free()
		pause_menu_instance = null
	
	# --- LÍNEA CLAVE AÑADIDA ---
	# Justo antes de volver al menú, le decimos que ponga la música
	MusicManager.play_music()
	# -----------------------------
	
	# Cambiamos la escena de vuelta al menú
	get_tree().change_scene_to_file("res://src/hud/main_menu.tscn")
	
	is_in_game_level = false
	get_tree().paused = false
	if pause_menu_instance != null:
		pause_menu_instance.queue_free()
		pause_menu_instance = null
	
	# Cambiamos la escena de vuelta al menú
	get_tree().change_scene_to_file("res://src/hud/main_menu.tscn") # <-- RUTA CORREGIDA
	
	is_in_game_level = false
