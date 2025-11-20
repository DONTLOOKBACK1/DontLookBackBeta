extends Area2D

# Límite de la cámara (ajustar en el Inspector)
@export var nuevo_limite_izquierdo: int = -500

# CORRECCIÓN: Aquí solo definimos el TIPO de dato (CollisionShape2D o Node2D)
# No pongas la ruta $"..." aquí. La asignarás visualmente en el Inspector.
@export var obstaculo_a_eliminar: CollisionShape2D

func _on_body_entered(body):
	# Verificamos si es "CharacterBody2D" (Tu Player) Y si ya pasó el nivel 8
	if body.name == "CharacterBody2D" and SaveManager.unlocked_level > 8:
		
		# 1. Cambiar la cámara
		var camara = body.find_child("*Camera2D*", true, false)
		if camara:
			camara.limit_left = nuevo_limite_izquierdo
			print("Cámara extendida")
		
		# 2. Eliminar la colisión
		if obstaculo_a_eliminar:
			obstaculo_a_eliminar.queue_free()
			print("Obstáculo eliminado")
			
		# 3. Borramos el Area2D
		queue_free()
