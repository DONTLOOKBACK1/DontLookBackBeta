extends Node2D

@export var camera: Camera2D
@export var room_width: int = 1152

# Esta función se activa al moverte hacia la DERECHA (a la habitación 2)
func _on_derecha_entered_from_left():
	print("Moviendo cámara a la habitación 2")
	# El cálculo correcto para la habitación 2
	var nueva_pos_x = room_width + (room_width / 2)
	camera.position.x = nueva_pos_x

# Esta función se activa al moverte hacia la IZQUIERDA (de vuelta a la habitación 1)
func _on_izquierda_entered_from_right():
	print("Volviendo a la habitación 1")
	# El cálculo correcto para la habitación 1
	var nueva_pos_x = room_width / 2
	camera.position.x = nueva_pos_x
