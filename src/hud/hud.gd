extends Control

# Referencia al nodo Sprite2D.
# IMPORTANTE: Asegúrate de haber cambiado el tipo de nodo en la escena a Sprite2D
@onready var health_sprite: Sprite2D = $CanvasLayer/PositionMarker/HealthSprite

func _on_character_body_2d_health_updated(new_health: int):
	# Aquí asumimos que tu Spritesheet está ordenado así:
	# Frame 0 = Vida Llena (100%)
	# Frame 1 = 75%
	# Frame 2 = 50%
	# Frame 3 = 25%
	# Frame 4 = Vacío (0%)
	
	if new_health > 75:
		health_sprite.frame = 0  # Imagen de 100%
	elif new_health > 50:
		health_sprite.frame = 1  # Imagen de 75%
	elif new_health > 25:
		health_sprite.frame = 2  # Imagen de 50%
	elif new_health > 0:
		health_sprite.frame = 3  # Imagen de 25%
	else:
		health_sprite.frame = 3  # Imagen de 0%
