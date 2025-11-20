extends Node

var unlocked_level = 1
var save_path = ""
const PAUSE_MENU_SCENE = preload("res://src/hud/pause_menu.tscn")
var pause_menu_instance = null
var is_in_game_level = false

func _ready():
	print("--- SaveManager: _ready() ---")
	var documents_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
	var game_save_dir = "LevelSevenStudios/DontLookBack"
	var full_dir_path = documents_dir.path_join(game_save_dir)
	DirAccess.make_dir_recursive_absolute(full_dir_path)
	save_path = full_dir_path.path_join("progreso.save")
	print("Ruta de guardado: ", save_path)
	load_game()

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel") and is_in_game_level:
		if get_tree().paused:
			unpause_game()
		else:
			pause_game()

# --- Funciones de Guardado ---

func save_game():
	print("--- SaveManager: save_game() LLAMADO ---")
	var config = ConfigFile.new()
	
	config.set_value("progreso", "unlocked_level", unlocked_level)
	
	# MODIFICADO: Quitamos el 'if'
	var music_val = AudioManager.get_music_volume()
	var sfx_val = AudioManager.get_sfx_volume()
	print("Guardando valor de Music: ", music_val)
	print("Guardando valor de SFX: ", sfx_val)
	
	config.set_value("audio", "master_vol", AudioManager.get_master_volume())
	config.set_value("audio", "music_vol", music_val)
	config.set_value("audio", "sfx_vol", sfx_val)

	var err = config.save(save_path)
	if err != OK:
		print("!!! ERROR AL GUARDAR ARCHIVO!!!")
	else:
		print("--- SaveManager: ¡Archivo guardado con éxito! ---")


func load_game():
	print("--- SaveManager: load_game() LLAMADO ---")
	var config = ConfigFile.new()
	if not FileAccess.file_exists(save_path):
		print("No se encontró archivo de guardado. Usando valores por defecto.")
		return
	
	var err = config.load(save_path)
	if err != OK:
		print("!!! ERROR AL LEER ARCHIVO DE GUARDADO!!!")
		return
	
	print("Archivo de guardado cargado.")
	unlocked_level = config.get_value("progreso", "unlocked_level", 1)
	
	# MODIFICADO: Quitamos el 'if' y pasamos 'false' a los setters
	var master_vol = config.get_value("audio", "master_vol", 1.0)
	var music_vol = config.get_value("audio", "music_vol", 1.0)
	var sfx_vol = config.get_value("audio", "sfx_vol", 1.0)
	
	print("Aplicando valor de Music cargado: ", music_vol)
	print("Aplicando valor de SFX cargado: ", sfx_vol)
	
	# ¡Aquí está la magia! pasamos 'false' para que NO vuelva a guardar.
	AudioManager.set_master_volume(master_vol, false)
	AudioManager.set_music_volume(music_vol, false)
	AudioManager.set_sfx_volume(sfx_vol, false)


func complete_level(level_completed):
	if level_completed == unlocked_level:
		unlocked_level += 1
		print("--- SaveManager: Nivel completado, guardando... ---")
		save_game()

# --- Funciones de Pausa (sin cambios) ---

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
	get_tree().change_scene_to_file("res://src/hud/main_menu.tscn")
	is_in_game_level = false
