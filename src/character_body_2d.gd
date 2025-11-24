extends CharacterBody2D

# --- Señales ---
signal health_updated(new_health)
signal player_died

# --- Variables de Vida ---
@export var max_health: int = 100
@export var health: int = 100:
	set(value):
		health = clamp(value, 0, max_health)
		emit_signal("health_updated", health)

# --- Variables de Inmunidad ---
@export var invincibility_duration: float = 0.5 
var is_invincible: bool = false

# --- Variables de Movimiento ---
@export var speed: float = 300.0
@export var friction: float = 1000.0

@export_group("Salto")
@export var jump_velocity: float = -400.0
@export var jump_gravity_multiplier: float = 2.0

@export_group("Wall Jump (Estilo Hollow Knight)")
@export var wall_slide_speed: float = 150.0
@export var wall_jump_vertical_velocity: float = -450.0
@export var wall_jump_horizontal_velocity: float = 300.0
@export var wall_kick_extra_force: float = 150.0 

@export_group("Agacharse (Crouch)")
@export var crouch_speed_multiplier: float = 0.5

@export_group("Ataque")
@export var attack_damage: int = 10
@export var attack_knockback_strength: float = 200.0

# --- Nodos ---
@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var pivot: Node2D = $Pivot

# --- COLISIONES ---
@onready var stand_collision: CollisionShape2D = $StandCollision
@onready var crouch_collision: CollisionShape2D = $CrouchCollision
@onready var jump_collision: CollisionShape2D = $JumpCollision 

@onready var stand_up_ray_l: RayCast2D = $StandUpRay_L
@onready var stand_up_ray_c: RayCast2D = $StandUpRay_C
@onready var stand_up_ray_r: RayCast2D = $StandUpRay_R

@onready var wall_jump_timer: Timer = $WallJumpTimer
@onready var kick_lock_timer: Timer = $KickLockTimer
@onready var attack_hitbox: Area2D = $Pivot/AttackHitbox

# --- Nodos de Inmunidad ---
@onready var invincibility_timer: Timer = $InvincibilityTimer
@onready var blink_timer: Timer = $BlinkTimer
@onready var damage_sound_player: AudioStreamPlayer = $Audio/DamageSoundPlayer

# --- Variables Internas ---
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

# --- Estados del Personaje ---
var is_wall_sliding: bool = false
var is_crouching: bool = false
var is_attacking: bool = false
var is_in_kick: bool = false
var _knockback_applied_this_attack: bool = false

# --- BUFFER DE PARED ---
var wall_buffer_timer: float = 0.0
# Bajamos un poco el tiempo para que no se sienta "flotante" al salir de la pared
const WALL_BUFFER_TIME: float = 0.1 

func _ready():
	attack_hitbox.body_entered.connect(_on_hitbox_body_entered)
	animation_player.animation_finished.connect(_on_animation_finished)
	kick_lock_timer.connect("timeout", _on_kick_timeout)
	
	invincibility_timer.wait_time = invincibility_duration
	invincibility_timer.connect("timeout", _on_invincibility_timeout)
	blink_timer.connect("timeout", _on_blink_timer_timeout)
	
	await get_tree().process_frame
	emit_signal("health_updated", health)

func _physics_process(delta: float):
	apply_gravity(delta)
	
	# Detectamos paredes y acción antes de mover
	handle_wall_slide_detection()
	handle_wall_slide_action()
	
	handle_attack()
	handle_crouch()
	handle_jump()
	handle_horizontal_movement(delta)
	update_animation()
	
	move_and_slide()
	
	# --- GESTOR DE HITBOXES ---
	manage_hitbox_state()

# -------------------------------------------------------------------------
# --- GESTOR DE HITBOXES ---
# -------------------------------------------------------------------------
func manage_hitbox_state():
	if is_crouching and is_on_floor():
		_set_collision_active("crouch")
		return

	if is_wall_sliding:
		_set_collision_active("stand")
		return

	if not is_on_floor() and not is_wall_sliding:
		if velocity.y < 0:
			_set_collision_active("jump")
		else:
			_set_collision_active("stand")
		return

	_set_collision_active("stand")

func _set_collision_active(type: String):
	match type:
		"stand":
			if stand_collision.disabled: stand_collision.disabled = false
			if not crouch_collision.disabled: crouch_collision.disabled = true
			if not jump_collision.disabled: jump_collision.disabled = true
		"crouch":
			if not stand_collision.disabled: stand_collision.disabled = true
			if crouch_collision.disabled: crouch_collision.disabled = false
			if not jump_collision.disabled: jump_collision.disabled = true
		"jump":
			if not stand_collision.disabled: stand_collision.disabled = true
			if not crouch_collision.disabled: crouch_collision.disabled = true
			if jump_collision.disabled: jump_collision.disabled = false

# -------------------------------------------------------------------------
# --- VIDA Y DAÑO ---
# -------------------------------------------------------------------------
func heal(amount: int): self.health += amount
func take_damage(amount: int):
	if is_invincible: return
	self.health -= amount
	is_invincible = true
	invincibility_timer.start()
	blink_timer.start()
	damage_sound_player.play()
	sprite.modulate = Color.RED
	if health <= 0:
		emit_signal("player_died")
		queue_free()
func _on_blink_timer_timeout(): sprite.visible = not sprite.visible
func _on_invincibility_timeout():
	is_invincible = false
	blink_timer.stop()
	sprite.visible = true
	sprite.modulate = Color.WHITE

# -------------------------------------------------------------------------
# --- GRAVEDAD Y ATAQUE ---
# -------------------------------------------------------------------------
func apply_gravity(delta: float):
	if is_on_floor(): return
	if velocity.y < 0 and not Input.is_action_pressed("ui_accept"):
		velocity.y += gravity * jump_gravity_multiplier * delta
	else:
		velocity.y += gravity * delta

func handle_attack():
	if Input.is_action_just_pressed("attack") and is_on_floor() and not is_attacking and not is_crouching:
		is_attacking = true
		_knockback_applied_this_attack = false
func _enable_hitbox(): attack_hitbox.get_child(0).disabled = false
func _disable_hitbox(): attack_hitbox.get_child(0).disabled = true
func _on_hitbox_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(attack_damage)
		if not _knockback_applied_this_attack:
			velocity.x = -pivot.scale.x * attack_knockback_strength
			_knockback_applied_this_attack = true
func _on_animation_finished(anim):
	if anim == "attack": is_attacking = false

# -------------------------------------------------------------------------
# --- PAREDES (CORREGIDO: Ya no hace slide infinito) ---
# -------------------------------------------------------------------------
func handle_wall_slide_detection():
	if not wall_jump_timer.is_stopped():
		is_wall_sliding = false
		return

	# 1. Detección física: ¿Realmente hay pared AHORA?
	var is_touching_climbable_now = false
	if is_on_wall():
		for i in get_slide_collision_count():
			var col = get_slide_collision(i)
			if col.get_collider().is_in_group("climbable"):
				is_touching_climbable_now = true
				break
	
	# 2. Gestión del buffer: SOLO LLENAR SI TOCAMOS FÍSICAMENTE
	# (Aquí estaba el error antes, ahora está arreglado)
	if is_touching_climbable_now:
		wall_buffer_timer = WALL_BUFFER_TIME
	else:
		# Si no tocamos pared, el tiempo se agota inevitablemente
		wall_buffer_timer -= get_process_delta_time()

	# 3. Inputs
	var direction = Input.get_axis("ui_left", "ui_right")
	var wall_normal = get_wall_normal()
	
	if wall_normal == Vector2.ZERO and wall_buffer_timer > 0:
		wall_normal = Vector2(-pivot.scale.x, 0)

	var pushing_into_wall = (sign(direction) == -sign(wall_normal.x)) and direction != 0

	# 4. Decisión
	# Si se acabó el tiempo del buffer (porque se acabó la pared), is_wall_sliding muere.
	if wall_buffer_timer > 0:
		is_wall_sliding = pushing_into_wall and not Input.is_action_pressed("ui_down")
	else:
		is_wall_sliding = false

func handle_wall_slide_action():
	if is_wall_sliding and not is_on_floor():
		if velocity.y > wall_slide_speed:
			velocity.y = wall_slide_speed

# -------------------------------------------------------------------------
# --- CROUCH ---
# -------------------------------------------------------------------------
func handle_crouch():
	if is_attacking: return
	var crouch_input := Input.is_action_pressed("crouch")

	if crouch_input and is_on_floor() and not is_crouching:
		is_crouching = true
		animation_player.play("crouch_down")

	elif not crouch_input and is_crouching:
		if not stand_up_ray_l.is_colliding() and not stand_up_ray_c.is_colliding() and not stand_up_ray_r.is_colliding():
			is_crouching = false
			animation_player.play("crouch_up")

# -------------------------------------------------------------------------
# --- SALTO + WALL JUMP ---
# -------------------------------------------------------------------------
func handle_jump():
	if is_attacking or is_crouching: return
	if not Input.is_action_just_pressed("ui_accept"): return

	if is_wall_sliding:
		var wall_normal = get_wall_normal()
		if wall_normal == Vector2.ZERO: wall_normal = Vector2(-pivot.scale.x, 0)
			
		var direction = Input.get_axis("ui_left", "ui_right")
		
		wall_buffer_timer = 0
		
		velocity.y = wall_jump_vertical_velocity
		
		if sign(direction) == -sign(wall_normal.x):
			velocity.x = wall_normal.x * wall_jump_horizontal_velocity
		else:
			velocity.x = wall_normal.x * (wall_jump_horizontal_velocity + wall_kick_extra_force)
		
		is_in_kick = true
		kick_lock_timer.start()
		wall_jump_timer.start()
		is_wall_sliding = false
		
		_set_collision_active("jump")
		return

	if is_on_floor():
		velocity.y = jump_velocity
		_set_collision_active("jump")

# -------------------------------------------------------------------------
# --- MOVIMIENTO Y ANIMACIÓN ---
# -------------------------------------------------------------------------
func handle_horizontal_movement(delta: float):
	if is_in_kick:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		return
	if is_attacking or (is_wall_sliding and not is_on_floor()):
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		return
	var direction := Input.get_axis("ui_left", "ui_right")
	var current_speed := speed
	if is_crouching: current_speed *= crouch_speed_multiplier
	if direction:
		velocity.x = direction * current_speed
		sprite.flip_h = direction < 0
		pivot.scale.x = direction
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)

func _on_kick_timeout(): is_in_kick = false

func update_animation():
	var new_anim := ""
	var current := animation_player.current_animation
	if current in ["attack", "crouch_down", "crouch_up"]: return
	if is_attacking: new_anim = "attack"
	
	elif is_wall_sliding or wall_buffer_timer > 0.05:
		new_anim = "wall_slide"
		var wall_normal = get_wall_normal()
		if wall_normal != Vector2.ZERO:
			sprite.flip_h = wall_normal.x > 0
			pivot.scale.x = -wall_normal.x
			
	elif is_on_floor():
		if is_crouching: new_anim = "crouch_walk" if velocity.x != 0 else "crouch_idle"
		else: new_anim = "run" if velocity.x != 0 else "default"
	else:
		new_anim = "jump" if velocity.y < 0 else "fall"
		
	if new_anim != "" and new_anim != current: animation_player.play(new_anim)
