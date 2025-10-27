# HealthPack.gd
extends Area2D

## Cantidad de vida que se restaurará al ser recogido.
@export var heal_amount: int = 25 


func _on_body_entered(body: Node2D):
	# 1. Verificar si el cuerpo entrante es el jugador
	# Usamos 'has_method' para asegurarnos de que el cuerpo tiene la función 'heal'
	if body.has_method("heal"):
		# 2. Curar al jugador
		body.heal(heal_amount)
		
		# 3. Opcional: Reproducir sonido de recogida
		# if sfx_pickup:
		#	sfx_pickup.play()
		
		# 4. Eliminar el objeto de curación de la escena
		queue_free()
