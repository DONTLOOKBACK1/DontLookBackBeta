extends Area2D

# La ruta a tu escena de victoria (Asegúrate de que la ruta sea correcta)
const WIN_SCREEN_SCENE = preload("res://src/hud/win_screen.tscn")

# Bandera para evitar múltiples activaciones
var level_finished = false


# ¡IMPORTANTE!: Esta función debe estar conectada a la señal 'body_entered' del Area2D.
func _on_body_entered(body: Node2D):
	
	# 1. Verifica si ya terminamos o si el cuerpo que entró NO es el jugador.
	if level_finished or not body.is_in_group("player"):
		return

	# 2. Marcamos el nivel como completado
	level_finished = true
	
	# 3. Llamar a la función que muestra la pantalla de victoria
	show_win_screen()


func show_win_screen():
	# 1. Creamos una instancia de la pantalla de victoria
	var win_screen_instance = WIN_SCREEN_SCENE.instantiate()
	
	# 2. Añadimos la instancia a la escena principal (normalmente al nodo raíz del nivel)
	# Usar get_tree().root asegura que se muestre por encima de todo.
	get_tree().root.add_child(win_screen_instance)
	
	# Opcional: Pausar el juego
	get_tree().paused = true 
	# (Si pausas el juego, necesitarás despausarlo en el script de WinScreen cuando
	# el jugador presione el botón "Continuar")
	
	print("¡NIVEL COMPLETADO!")
