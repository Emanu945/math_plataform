extends CharacterBody2D

const SPEED = 250.0
const JUMP_VELOCITY = -380.0
const JUMP_SOUND = preload("res://sfx/jump_player.mp3")
const HIT_SOUND = preload("res://sfx/hit_player.wav")

var golpe := Vector2.ZERO
@onready var animation := $anim as AnimatedSprite2D
@onready var jump_player = AudioStreamPlayer2D.new()
@onready var hit_sound = AudioStreamPlayer2D.new()
@onready var remote_transform := $Remote as RemoteTransform2D
@onready var timer := $Timer as Timer
@onready var anim_hud: AnimatedSprite2D = $"../HUD/control/container/life_container/anim_hud"
@onready var area: Area2D = $Area2D

@export var block_offset: Vector2 = Vector2(3, 0)  # Distância base do centro do jogador ao centro do bloco
var held_block: Node2D = null
var is_facing_right: bool = true
var last_direction: float = 0.0  # Para detectar mudança de direção

signal player_has_died()

func _ready() -> void:
	jump_player.stream = JUMP_SOUND
	hit_sound.stream = HIT_SOUND
	add_child(jump_player)
	add_child(hit_sound)
	
	if not timer:
		timer = Timer.new()
		timer.name = "Timer"
		add_child(timer)
		timer.wait_time = 0.55
		timer.one_shot = true
		timer.timeout.connect(_on_timer_timeout)
	
	if not area:
		print("Erro: 'Area2D' não encontrada no jogador!")
	
	animation.centered = true
	print("Jogador inicializado - Sprite centralizado: ", animation.centered)

func _on_timer_timeout() -> void:
	owner.queue_free()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		animation.play("jump")
		anim_hud.play("idle_hud")

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animation.play("jump")
		anim_hud.play("idle_hud")
		jump_player.play()

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		animation.play("run")
		anim_hud.play("idle_hud")
		animation.scale.x = direction
		is_facing_right = direction > 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		animation.play("idle")
		anim_hud.play("idle_hud")

	# Detecta mudança de direção e força print
	if held_block and direction != last_direction:
		print("Mudança de direção detectada - Direção atual: ", direction, " | Última direção: ", last_direction)
		print_direction_info()
		last_direction = direction

	if golpe != Vector2.ZERO:
		velocity = golpe
		animation.play("hit")
		anim_hud.play("hit_hud")
	elif Globals.life == 0:
		animation.play("hit")
		anim_hud.play("hit_hud")
		timer.start()
		queue_free()
		emit_signal("player_has_died")

	move_and_slide()

	if held_block:
		update_block_position()
	else:
		print("Held_block é null - Não atualizando posição do bloco")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and not held_block:
		if area:
			var bodies = area.get_overlapping_bodies()
			for body in bodies:
				if body.is_in_group("block"):
					held_block = body
					held_block.is_held = true
					held_block.player = self
					held_block.freeze = true
					held_block.set_collision_layer_value(1, false)
					held_block.set_collision_mask_value(1, false)
					held_block.linear_velocity = Vector2.ZERO
					print("Bloco segurado: ", held_block.name)
					print_direction_info()  # Mostra info ao pegar
					break
		else:
			print("Erro: Não foi possível detectar blocos - 'Area2D' está ausente!")
	elif event.is_action_pressed("interact") and held_block:
		held_block.is_held = false
		held_block.set_collision_layer_value(1, true)
		held_block.set_collision_mask_value(1, true)
		held_block.freeze = false
		held_block = null
		print("Bloco solto")

func update_block_position() -> void:
	var player_half_width = 8  # Metade da largura do jogador (16 / 2)
	var block_half_width = 8  # Metade da largura do bloco (16 / 2)
	var total_offset = block_offset.x + player_half_width + block_half_width  # 3 + 8 + 8 = 19
	var offset = Vector2(total_offset, block_offset.y) if is_facing_right else Vector2(-total_offset, block_offset.y)
	
	# Ajuste fino da compensação à esquerda
	if not is_facing_right:
		offset.x += player_half_width  # +8 em vez de +16 para teste
	
	held_block.global_position = global_position + offset
	held_block.global_position.y = global_position.y  # Alinhamento vertical

func print_direction_info() -> void:
	if held_block:
		var offset = held_block.global_position - global_position
		print("Direção: ", is_facing_right, 
			  " | Posição do jogador: ", global_position, 
			  " | Posição do bloco: ", held_block.global_position, 
			  " | Offset aplicado: ", offset)
	else:
		print("Erro: Held_block é null ao tentar printar direção!")

func follow_camera(camera: Camera2D) -> void:
	var camera_path = camera.get_path()
	remote_transform.remote_path = camera_path

func dano(golpe_force := Vector2.ZERO, duration := 0.25):
	Globals.life -= 1
	hit_sound.play()
	if golpe_force != Vector2.ZERO:
		golpe = golpe_force
		var golpe_tween := get_tree().create_tween()
		golpe_tween.tween_property(self, "golpe", Vector2.ZERO, duration)
	print("Vida restante: ", Globals.life)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		if $ray_right.is_colliding():
			dano(Vector2(-200, -200))
		elif $ray_left.is_colliding():
			dano(Vector2(200, 200))
