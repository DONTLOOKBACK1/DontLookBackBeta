extends Node

var master_bus_index: int
var music_bus_index: int
var sfx_bus_index: int

func _ready() -> void:
	master_bus_index = AudioServer.get_bus_index("Master")
	music_bus_index = AudioServer.get_bus_index("Music")
	sfx_bus_index = AudioServer.get_bus_index("SFX")
	print("--- AudioManager: _ready() ---")
	if music_bus_index == -1:
		push_error("No se encontró el bus de audio 'Music'.")
	if sfx_bus_index == -1:
		push_error("No se encontró el bus de audio 'SFX'.")

# --- SETTERS (MODIFICADOS) ---
# Ahora tienen un "interruptor" para decidir si deben guardar.
# Por defecto, siempre guardan.

func set_master_volume(linear_value: float, save_after_set: bool = true) -> void:
	print("AudioManager: set_master_volume() a: ", linear_value)
	AudioServer.set_bus_volume_db(master_bus_index, linear_to_db(linear_value))
	
	# Si el interruptor está encendido, guardamos
	if save_after_set:
		SaveManager.save_game()

func set_music_volume(linear_value: float, save_after_set: bool = true) -> void:
	print("AudioManager: set_music_volume() a: ", linear_value)
	AudioServer.set_bus_volume_db(music_bus_index, linear_to_db(linear_value))
	
	if save_after_set:
		SaveManager.save_game()

func set_sfx_volume(linear_value: float, save_after_set: bool = true) -> void:
	print("AudioManager: set_sfx_volume() a: ", linear_value)
	AudioServer.set_bus_volume_db(sfx_bus_index, linear_to_db(linear_value))
	
	if save_after_set:
		SaveManager.save_game()

# --- GETTERS (Sin cambios) ---

func get_master_volume() -> float:
	var db = AudioServer.get_bus_volume_db(master_bus_index)
	return db_to_linear(db)

func get_music_volume() -> float:
	var db = AudioServer.get_bus_volume_db(music_bus_index)
	return db_to_linear(db)

func get_sfx_volume() -> float:
	var db = AudioServer.get_bus_volume_db(sfx_bus_index)
	return db_to_linear(db)
