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
		if not chase_music_player:
			print("¡ERROR! No se encontró el nodo hijo 'ChaseMusicPlayer' en el EventTrigger (START).")


func _on_body_entered(body):
	# 1. Ignoramos todo si no es el jugador
	if not body.is_in_group("player"):
		return

	# 2. Revisa qué modo tiene el trigger
	match mode:
		TriggerMode.START_CHASE:
			# El modo START SÍ es de un solo uso
			if not has_been_triggered:
				has_been_triggered = true
				collision_shape.set_deferred("disabled", true) # Se desactiva para siempre
				start_chase()
		
		TriggerMode.STOP_CHASE:
			# El modo STOP NO es de un solo uso.
			# No revisa 'has_been_triggered'.
			# No desactiva la colisión.
			# Simplemente se ejecuta.
			stop_chase()


# --- Lógica de INICIAR Persecución ---
func start_chase():
	
	# --- ¡AÑADIDO! ---
	# 1. Llama al MusicManager y para la música del nivel.
	MusicManager.stop_music()
	
	# 2. Añadimos el reproductor de música al grupo para poder encontrarlo luego
	chase_music_player.add_to_group(CHASE_MUSIC_GROUP)
	chase_music_player.play()
	
	# 3. Instanciamos la sombra
	var shadow_instance = shadow_scene.instantiate()
	
	# 4. Añadimos la sombra al grupo para poder encontrarla luego
	shadow_instance.add_to_group(SHADOW_GROUP)
	
	# 5. La añadimos a la escena y la posicionamos
	get_parent().add_child(shadow_instance)
	shadow_instance.global_position = spawn_point.global_position


# --- Lógica de DETENER Persecución ---
func stop_chase():
	# 1. Buscamos a TODOS los enemigos en el grupo "chase_enemy" y los eliminamos
	get_tree().call_group(SHADOW_GROUP, "queue_free")
	
	# 2. Buscamos a TODOS los reproductores en el grupo "chase_music" y los paramos
	get_tree().call_group(CHASE_MUSIC_GROUP, "stop")
	
	# --- ¡LÍNEA MODIFICADA! ---
	# 3. Reiniciamos la música del nivel que estaba guardada.
	MusicManager.resume_level_music()
