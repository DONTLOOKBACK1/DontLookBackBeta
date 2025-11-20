# GameOverScreen.gd
extends Control

# Esta variable la debe establecer el script del Nivel
var current_level_id: int = 1

# --- Nodos de los botones ---
@onready var retry_button = $CenterContainer/VBoxContainer/RetryButton
@onready var menu_button = $CenterContainer/VBoxContainer/MenuButton

# --- ¡FUNCIÓN AÑADIDA! ---
# Necesitas esta función para conectar tus botones al script


func _on_retry_button_pressed() -> void:
	# Quitamos la pausa
	get_tree().paused = false
	
	# Paramos la música de "Game Over"
	MusicManager.stop_music()
	
	# Recargamos el MISMO nivel
	var level_path = "res://src/niveles/nivel_" + str(current_level_id) + ".tscn"
	get_tree().change_scene_to_file(level_path)
	
	SaveManager.is_in_game_level = true


# --- ¡FUNCIÓN MODIFICADA! ---
func _on_menu_button_pressed() -> void:
	# Quitamos la pausa
	get_tree().paused = false
	
	# --- ¡AQUÍ ESTÁ LA LÍNEA QUE FALTA! ---
	# Llama a la función que restaura la música del menú.
	MusicManager.play_music()
	
	# Cambiamos a la pantalla de menú principal
	get_tree().change_scene_to_file("res://src/hud/main_menu.tscn")
	
	# Le decimos al SaveManager que ya NO estamos en un nivel
	SaveManager.is_in_game_level = false
