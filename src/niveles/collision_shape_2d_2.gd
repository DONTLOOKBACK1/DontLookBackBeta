extends Area2D # Puede ser StaticBody2D, Area2D, o lo que sea tu objeto

func _ready():
	# Verificamos si el jugador ya superó el nivel 8.
	# Como tu SaveManager suma 1 al completar, si terminas el 8, 
	# unlocked_level será 9.
	if SaveManager.unlocked_level > 8:
		print("Juego completado: Eliminando barrera secreta")
		queue_free() # Esto elimina el objeto del juego inmediatamente
