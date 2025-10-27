extends Area2D

# Asegúrate de que esta ruta sea la correcta para tu win_screen
const WIN_SCREEN_SCENE = preload("res://src/hud/win_screen.tscn")

@export var level_id : int = 1

var level_finished = false

func _on_body_entered(body: Node2D):
	if level_finished or not body.is_in_group("player"):
		return

	level_finished = true
	SaveManager.complete_level(level_id)
	show_win_screen()


func show_win_screen():
	var win_screen_instance = WIN_SCREEN_SCENE.instantiate()
	
	# --- ¡LÍNEA CLAVE AÑADIDA! ---
	# Le pasamos el ID de este nivel a la pantalla de victoria.
	win_screen_instance.completed_level_id = level_id
	
	get_tree().root.add_child(win_screen_instance)
	get_tree().paused = true 
	
	print("¡NIVEL " + str(level_id) + " COMPLETADO!")
