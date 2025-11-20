extends Area2D

# Esta función se ejecuta una sola vez cuando el área es creada.
func _ready() -> void:
	# Conectamos la señal 'body_entered' (cuando algo entra)
	# a nuestra función _on_body_entered.
	#
	# Nota: También puedes hacer esto desde el Inspector de Nodos
	# seleccionando el Area2D, yendo a la pestaña "Nodo" -> "Señales",
	# haciendo doble clic en "body_entered" y conectándola a este script.
	connect("body_entered", _on_body_entered)

# Esta función se llama automáticamente cuando un PhysicsBody2D entra.
func _on_body_entered(body: Node2D) -> void:
	
	# 1. Verificamos si el cuerpo que entró está en el grupo "player"
	#    (Asegúrate de que tu jugador esté en este grupo)
	if body.is_in_group("player"):
		
		# 2. Verificamos si tiene el método "take_damage"
		if body.has_method("take_damage"):
			
			# 3. ¡Lo llamamos con un número gigante para matarlo al instante!
			body.take_damage(99999)
