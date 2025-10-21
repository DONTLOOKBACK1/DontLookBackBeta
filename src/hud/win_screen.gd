extends CanvasLayer


func _on_button_pressed():
	 # 1. CLAVE: Despausar el juego (Permite que el motor procese el cambio de escena)
	get_tree().paused = false
	
	# 2. Eliminar la pantalla de victoria del árbol
	# Esto es buena práctica para limpiar antes de cargar otra escena.
	queue_free() 
	
	# 3. Intentar cambiar la escena y verificar si hubo un error.
	var error = get_tree().change_scene_to_file("res://assets/niveles/nivel_1.tscn")
	
	if error != OK:
		# Si hay un error (ej. ruta incorrecta), Godot lo reportará aquí.
		print("ERROR AL CARGAR ESCENA: ", error)
		print("Ruta usada: res://assets/niveles/nivel_1.tscn")
	else:
		print("Carga de nivel exitosa. El juego debería reanudarse.")
