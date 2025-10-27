extends Node

# Variables para guardar los índices de los buses.
var master_bus_index: int
var music_bus_index: int
var sfx_bus_index: int

func _ready() -> void:
	# Obtenemos el índice de cada bus por su nombre.
	master_bus_index = AudioServer.get_bus_index("Master")
	music_bus_index = AudioServer.get_bus_index("Music")
	sfx_bus_index = AudioServer.get_bus_index("SFX")
	
	# Asegúrate de que los buses existen, si no, da un error claro
	if music_bus_index == -1:
		push_error("No se encontró el bus de audio 'Music'. Revisa la pestaña 'Audio'.")
	if sfx_bus_index == -1:
		push_error("No se encontró el bus de audio 'SFX'. Revisa la pestaña 'Audio'.")


# --- SETTERS (Para tus sliders de opciones) ---
# Reciben un valor lineal (0.0 a 1.0)

func set_master_volume(linear_value: float) -> void:
	# Usamos la función interna de Godot para convertir a decibelios
	AudioServer.set_bus_volume_db(master_bus_index, linear_to_db(linear_value))

func set_music_volume(linear_value: float) -> void:
	AudioServer.set_bus_volume_db(music_bus_index, linear_to_db(linear_value))

func set_sfx_volume(linear_value: float) -> void:
	AudioServer.set_bus_volume_db(sfx_bus_index, linear_to_db(linear_value))


# --- GETTERS (Para que tus sliders muestren el valor actual) ---
# Devuelven un valor lineal (0.0 a 1.0)

func get_master_volume() -> float:
	# Usamos la función interna de Godot para convertir de decibelios
	var db = AudioServer.get_bus_volume_db(master_bus_index)
	return db_to_linear(db)

func get_music_volume() -> float:
	var db = AudioServer.get_bus_volume_db(music_bus_index)
	return db_to_linear(db)

func get_sfx_volume() -> float:
	var db = AudioServer.get_bus_volume_db(sfx_bus_index)
	return db_to_linear(db)
