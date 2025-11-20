# Pinchos.gd
extends Area2D

# Puedes ajustar cuánto daño hacen estos pinchos
# desde el inspector de Godot.
@export var damage_amount: int = 25


# Esta es la función que conectaremos a la señal "body_entered"
func _on_body_entered(body):
	
	# 1. Comprobamos si el cuerpo que entró está en el grupo "player".
	#    (Asegúrate de haber puesto tu nodo Jugador en ese grupo).
	if body.is_in_group("player"):
		
		# 2. Comprobamos si el cuerpo (jugador) tiene la función "take_damage".
		#    Tu script de jugador SÍ la tiene, pero esto es una buena práctica
		#    para evitar que el juego crashee si otra cosa entra.
		if body.has_method("take_damage"):
			
			# 3. Llamamos a esa función en el script del jugador y le pasamos el daño.
			body.take_damage(damage_amount)
