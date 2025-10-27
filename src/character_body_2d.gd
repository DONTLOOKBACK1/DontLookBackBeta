extends CharacterBody2D

# --- Señales ---
signal health_updated(new_health)
signal player_died # Señal para anunciar que el jugador ha muerto

# --- Variables de Vida ---
@export var max_health: int = 100
@export var health: int = 100:
	set(value):
		health = clamp(value, 0, max_health)
		emit_signal("health_updated", health)

# --- Variables de Movimiento ---
@export var speed: float = 300.0
@export var friction: float = 1000.0

@export_group("Salto")
@export var jump_velocity: float = -400.0
@export var jump_gravity_multiplier: float = 2.0

@export_group("Wall Jump")
@export var wall_slide_gravity_multiplier: float = 0.5
@export var max_wall_slide_speed: float = 150.0
@export var wall_jump_velocity: Vector2 = Vector2(250.0, -450.0)
@export var wall_crawl_speed: float = 100.0 # <-- NUEVO: Velocidad de trepado

@export_group("Agacharse (Crouch)")
@export var crouch_speed_multiplier: float = 0.5

@export_group("Ataque")
@export var attack_damage: int = 10
@export var attack_knockback_strength: float = 200.0

# --- Nodos ---
@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var pivot: Node2D = $Pivot
@onready var stand_collision: CollisionShape2D = $StandCollision
@onready var crouch_collision: CollisionShape2D = $CrouchCollision
@onready var stand_up_ray_l: RayCast2D = $StandUpRay_L
@onready var stand_up_ray_c: RayCast2D = $StandUpRay_C
@onready var stand_up_ray_r: RayCast2D = $StandUpRay_R
@onready var wall_jump_timer: Timer = $WallJumpTimer
@onready var attack_hitbox: Area2D = $Pivot/AttackHitbox

# --- Variables Internas ---
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

# --- Estados del Personaje ---
var is_wall_sliding: bool = false
var is_crouching: bool = false
var is_attacking: bool = false
var _knockback_applied_this_attack: bool = false
var _jump_initiated: bool = false


func _ready():
	attack_hitbox.body_entered.connect(_on_hitbox_body_entered)
	animation_player.animation_finished.connect(_on_animation_finished)
	await get_tree().process_frame
	emit_signal("health_updated", health)


func _physics_process(delta: float):
	# MODIFICADO: Orden de llamadas
	handle_wall_slide() # 1. Detecta si estamos en la pared
	handle_wall_crawl(delta) # 2. NUEVO: Maneja el movimiento vertical en la pared
	apply_gravity(delta) # 3. Aplica gravedad (si no estamos en pared o suelo)
	
	handle_attack()
	handle_crouch()
	handle_jump()
	handle_horizontal_movement(delta)
	update_animation()
	move_and_slide()

# --- DAÑO Y VIDA ---
func heal(amount: int):
	self.health += amount

func take_damage(amount: int):
	self.health -= amount
	if health <= 0:
		emit_signal("player_died") # Emite la señal de muerte
		queue_free() # Elimina el nodo del jugador de la escena

# --- GRAVEDAD ---
func apply_gravity(delta: float):
	# MODIFICADO: Añadimos "or is_wall_sliding"
	if is_on_floor() or is_wall_sliding: return
	
	if velocity.y < 0 and not Input.is_action_pressed("ui_accept"):
		velocity.y += gravity * jump_gravity_multiplier * delta
	else:
		velocity.y += gravity * delta

# --- ATAQUE ---
func handle_attack():
	if Input.is_action_just_pressed("attack") and is_on_floor() and not is_attacking and not is_crouching:
		is_attacking = true
		_knockback_applied_this_attack = false

func _enable_hitbox():
	attack_hitbox.get_child(0).disabled = false

func _disable_hitbox():
	attack_hitbox.get_child(0).disabled = true

func _on_hitbox_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(attack_damage)
		if not _knockback_applied_this_attack:
			velocity.x = -pivot.scale.x * attack_knockback_strength
			_knockback_applied_this_attack = true

func _on_animation_finished(anim_name):
	if anim_name == "attack":
		is_attacking = false

# --- PAREDES ---
func handle_wall_slide():
	if not wall_jump_timer.is_stopped():
		is_wall_sliding = false
		return
	var direction = Input.get_axis("ui_left", "ui_right")
	var wall_normal = get_wall_normal()
	if is_wall_sliding:
		if not is_on_wall() or is_on_floor() or Input.is_action_pressed("ui_down") or (direction != 0 and sign(direction) == wall_normal.x):
			is_wall_sliding = false
		return
	is_wall_sliding = false
	if not is_on_floor() and is_on_wall():
		var on_climbable_wall = false
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			if collision.get_collider().is_in_group("climbable"):
				on_climbable_wall = true
				break
		if not on_climbable_wall: return
		if (wall_normal.x > 0 and direction < 0) or (wall_normal.x < 0 and direction > 0):
			is_wall_sliding = true

# --- NUEVA FUNCIÓN DE TREPADO ---
func handle_wall_crawl(delta: float):
	if not is_wall_sliding:
		return # Si no estamos en la pared, no hacemos nada

	# Capturamos el input vertical
	var vertical_input = Input.get_axis("ui_up", "ui_down")
	
	if vertical_input != 0:
		# El jugador está trepando (arriba o abajo)
		velocity.y = vertical_input * wall_crawl_speed
	else:
		# El jugador está "agarrado" (Cling)
		# Aplicamos un deslizamiento lento, al estilo Hollow Knight
		# (Asegúrate de bajar wall_slide_gravity_multiplier y max_wall_slide_speed)
		velocity.y += gravity * wall_slide_gravity_multiplier * delta
		velocity.y = min(velocity.y, max_wall_slide_speed)

# --- AGACHARSE ---
func handle_crouch():
	if is_attacking or _jump_initiated: return
	
	var crouch_input = Input.is_action_pressed("crouch")
	
	if crouch_input and is_on_floor() and not is_crouching:
		is_crouching = true
		stand_collision.disabled = true
		crouch_collision.disabled = false
		animation_player.play("crouch_down")
	
	elif not crouch_input and is_crouching:
		if not stand_up_ray_l.is_colliding() and not stand_up_ray_c.is_colliding() and not stand_up_ray_r.is_colliding():
			is_crouching = false
			stand_collision.disabled = false
			crouch_collision.disabled = true
			animation_player.play("crouch_up")

# --- SALTO ---
func handle_jump():
	if is_attacking or is_crouching: return
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and not _jump_initiated:
		_jump_initiated = true
	if Input.is_action_just_pressed("ui_accept") and is_wall_sliding:
		var wall_normal = get_wall_normal()
		velocity.y = wall_jump_velocity.y
		velocity.x = wall_normal.x * wall_jump_velocity.x
		wall_jump_timer.start()

func _perform_jump():
	velocity.y = jump_velocity
	_jump_initiated = false

# --- MOVIMIENTO HORIZONTAL ---
func handle_horizontal_movement(delta: float):
	# MODIFICADO: Añadimos "or is_wall_sliding"
	if not wall_jump_timer.is_stopped() or is_attacking or is_wall_sliding:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		return
		
	var direction = Input.get_axis("ui_left", "ui_right")
	var current_speed = speed
	if is_crouching:
		current_speed *= crouch_speed_multiplier
	if direction:
		velocity.x = direction * current_speed
		sprite.flip_h = direction < 0
		pivot.scale.x = direction
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)

# --- ANIMACIÓN ---
func update_animation():
	var new_animation = ""
	var current_anim = animation_player.current_animation

	if current_anim in ["attack", "crouch_down", "crouch_up"]:
		return

	if is_attacking:
		new_animation = "attack"
	elif _jump_initiated:
		new_animation = "jump"
	elif is_wall_sliding:
		# MODIFICADO: Lógica para "crawl" vs "cling/slide"
		var vertical_input = Input.get_axis("ui_up", "ui_down")
		if vertical_input != 0:
			new_animation = "wall_crawl" # (Necesitarás esta animación)
		else:
			new_animation = "wall_slide" # (Esta es tu animación de "cling")
		
		var wall_normal = get_wall_normal()
		sprite.flip_h = wall_normal.x > 0
		pivot.scale.x = -wall_normal.x
	elif is_on_floor():
		if is_crouching:
			if velocity.x != 0:
				new_animation = "crouch_walk"
			else:
				new_animation = "crouch_idle"
		else:
			if velocity.x != 0:
				new_animation = "run"
			else:
				new_animation = "default"
	
	if new_animation != "" and current_anim != new_animation:
		animation_player.play(new_animation)
