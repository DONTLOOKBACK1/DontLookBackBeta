extends CharacterBody2D

# --- Estados de la IA ---
enum State { PATROL, CHASE, ATTACK }
var current_state = State.PATROL

# --- Variables ---
@export var patrol_speed: float = 60.0
@export var chase_speed: float = 120.0
@export var attack_range: float = 50.0
@export var chase_stop_threshold: float = 5.0
@export var attack_damage: int = 10
@export var contact_damage: int = 5
@export var health: int = 30

var direction: int = 1 # 1 para la derecha, -1 para la izquierda
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var player = null

# --- Nodos ---
@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var pivot: Node2D = $Pivot
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_hitbox: Area2D = $Pivot/AttackHitbox
@onready var contact_hurtbox: Area2D = $ContactHurtbox
@onready var attack_cooldown: Timer = $AttackCooldown
@onready var wall_detector: RayCast2D = $WallDetector
@onready var edge_detector: RayCast2D = $EdgeDetector


func _ready():
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)
	attack_hitbox.body_entered.connect(_on_attack_hitbox_body_entered)
	contact_hurtbox.body_entered.connect(_on_contact_hurtbox_body_entered)
	animation_player.animation_finished.connect(_on_animation_finished)


func _physics_process(delta: float):
	if not is_on_floor():
		velocity.y += gravity * delta
	
	match current_state:
		State.PATROL:
			patrol_logic()
		State.CHASE:
			chase_logic()
		State.ATTACK:
			attack_logic()
	
	move_and_slide()

# --- Lógica de Estados ---

func patrol_logic():
	if animation_player.current_animation != "run":
		animation_player.play("run")
	
	if is_on_floor() and (wall_detector.is_colliding() or not edge_detector.is_colliding()):
		flip_direction()
		
	velocity.x = direction * patrol_speed

func chase_logic():
	if player == null:
		current_state = State.PATROL
		return
	
	if animation_player.current_animation != "run":
		animation_player.play("run")
	
	var direction_to_player = global_position.direction_to(player.global_position)
	var horizontal_distance = abs(player.global_position.x - global_position.x)
	
	if horizontal_distance < chase_stop_threshold:
		velocity.x = 0
	else:
		var new_direction = sign(direction_to_player.x)
		# Si la dirección cambia, volteamos también los RayCasts
		if new_direction != direction:
			wall_detector.target_position.x *= -1
			edge_detector.target_position.x *= -1
		
		direction = new_direction
		sprite.flip_h = direction < 0
		pivot.scale.x = direction
		velocity.x = direction * chase_speed
	
	if global_position.distance_to(player.global_position) < attack_range:
		current_state = State.ATTACK

func attack_logic():
	velocity.x = 0
	if attack_cooldown.is_stopped():
		animation_player.play("attack")
		attack_cooldown.start(1.5)
	
	if player and global_position.distance_to(player.global_position) > attack_range * 1.2:
		current_state = State.CHASE

# --- Funciones de Señales y Métodos ---

func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		player = body
		current_state = State.CHASE

func _on_detection_area_body_exited(body):
	if body.is_in_group("player"):
		player = null
		current_state = State.PATROL

func _enemy_enable_hitbox():
	attack_hitbox.get_child(0).disabled = false
	
func _enemy_disable_hitbox():
	attack_hitbox.get_child(0).set_deferred("disabled", true)

func _on_attack_hitbox_body_entered(body):
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(attack_damage)
		_enemy_disable_hitbox()

func _on_contact_hurtbox_body_entered(body):
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(contact_damage)

func _on_animation_finished(anim_name):
	if anim_name == "attack":
		if player and global_position.distance_to(player.global_position) <= attack_range:
			current_state = State.ATTACK
		else:
			current_state = State.CHASE

func flip_direction():
	direction *= -1
	sprite.flip_h = not sprite.flip_h
	pivot.scale.x *= -1
	# Volteamos los RayCasts para que siempre apunten hacia adelante
	wall_detector.target_position.x *= -1
	edge_detector.target_position.x *= -1

func take_damage(amount: int):
	health -= amount
	print("Enemigo golpeado! Vida restante: ", health)
	if health <= 0:
		queue_free()
