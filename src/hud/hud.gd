extends Control

# ¡IMPORTANTE: Asegúrate de que esta ruta a tus sprites sea correcta!
const HEALTH_FULL = preload("res://assets/hud/100.png")
const HEALTH_75 = preload("res://assets/hud/75.png")
const HEALTH_50 = preload("res://assets/hud/50.png")
const HEALTH_25 = preload("res://assets/hud/25.png")
const HEALTH_EMPTY = preload("res://assets/hud/0.png")

# Esta ruta funciona porque tu escena hud.tscn está bien estructurada.
@onready var health_sprite: TextureRect = $CanvasLayer/HealthSprite

# Esta función se conecta a la señal "health_updated" del personaje.
func _on_character_body_2d_health_updated(new_health: int):
	if new_health > 75:
		health_sprite.texture = HEALTH_FULL
	elif new_health > 50:
		health_sprite.texture = HEALTH_75
	elif new_health > 25:
		health_sprite.texture = HEALTH_50
	elif new_health > 0:
		health_sprite.texture = HEALTH_25
	else:
		health_sprite.texture = HEALTH_EMPTY
