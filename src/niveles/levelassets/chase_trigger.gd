# EventTrigger.gd
extends Area2D

# --- Constantes para Grupos ---
const SHADOW_GROUP = "chase_enemy"
const CHASE_MUSIC_GROUP = "chase_music"

# --- Modo del Trigger ---
enum TriggerMode { START_CHASE, STOP_CHASE }
@export var mode: TriggerMode = TriggerMode.START_CHASE

# --- Variables para START_CHASE ---
@export_group("Start Chase Settings")
@export var shadow_scene: PackedScene
@onready var spawn_point: Marker2D = $SpawnPoint

# --- NUEVO: Control de Música ---
@export_subgroup("Audio Settings")
@export var play_chase_music: bool = true # Si es true, pone música. Si es false, es silencioso.
@onready var chase_music_player: AudioStreamPlayer = $ChaseMusicPlayer

# --- Nodos y Variables Internas ---
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
var has_been_triggered: bool = false


func _ready():
	body_entered.connect(_on_body_entered)
	
	if mode == TriggerMode.START_CHASE:
		if not shadow_scene:
			print("¡ERROR! 'shadow_scene' no está asignada en el EventTrigger (START).")
		if not spawn_point:
			print("¡ERROR! No se encontró el nodo hijo 'SpawnPoint' en el EventTrigger (START).")
		
		# MODIFICADO: Solo damos error del MusicPlayer si tenemos activada la opción de música
		if play_chase_music and not chase_music_player:
			print("¡ERROR! Tienes 'play_chase_music' activado pero no se encontró 'ChaseMusicPlayer'.")


func _on_body_entered(body):
	if not body.is_in_group("player"):
		return

	match mode:
		TriggerMode.START_CHASE:
			if not has_been_triggered:
				has_been_triggered = true
				collision_shape.set_deferred("disabled", true)
				start_chase()
		
		TriggerMode.STOP_CHASE:
			stop_chase()


# --- Lógica de INICIAR Persecución ---
func start_chase():
	
	# --- MODIFICADO: Lógica Condicional de Música ---
	# Solo ejecutamos los cambios de música si la casilla está activada
	if play_chase_music:
		# 1. Paramos la música ambiental
		MusicManager.stop_music()
		
		# 2. Configuramos y reproducimos la música de persecución
		if chase_music_player:
			chase_music_player.add_to_group(CHASE_MUSIC_GROUP)
			chase_music_player.play()
	
	# --- Lógica de Spawn (Se ejecuta siempre) ---
	if shadow_scene:
		var shadow_instance = shadow_scene.instantiate()
		shadow_instance.add_to_group(SHADOW_GROUP)
		get_parent().add_child(shadow_instance)
		shadow_instance.global_position = spawn_point.global_position


# --- Lógica de DETENER Persecución ---
func stop_chase():
	# 1. Eliminar enemigos
	get_tree().call_group(SHADOW_GROUP, "queue_free")
	
	# 2. Parar música de persecución (No importa si no estaba sonando, no dará error)
	get_tree().call_group(CHASE_MUSIC_GROUP, "stop")
	
	# 3. Restaurar música del nivel
	# Nota: Si la música nunca se detuvo (porque play_chase_music era false),
	# resume_level_music simplemente se asegurará de que siga sonando.
	MusicManager.resume_level_music()
