extends CharacterBody2D

const SPEED = 280.0
const JUMP_VELOCITY = -380.0
const JUMP_SOUND = preload("res://sfx/jump_player.mp3")
const HIT_SOUND = preload("res://sfx/hit_player.wav")


var golpe := Vector2.ZERO
@export var player_life := 2
@onready var animation := $anim as AnimatedSprite2D
@onready var jump_player = AudioStreamPlayer2D.new()
@onready var hit_sound = AudioStreamPlayer2D.new()
@onready var remote_transform := $Remote as RemoteTransform2D
@onready var timer := $Timer as Timer

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
func _on_timer_timeout() -> void:
	owner.queue_free()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		animation.play("jump")

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animation.play("jump")
		jump_player.play()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left","ui_right")
	if direction:
		velocity.x = direction * SPEED
		animation.play("run")
		animation.scale.x = direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		animation.play("idle")
	if golpe != Vector2.ZERO:
		velocity = golpe
		animation.play("hit")
	elif player_life < 0:
		animation.play("hit")
		timer.start()
		queue_free()
		
	move_and_slide()

func follow_camera(camera):
	var camera_path = camera.get_path()
	remote_transform.remote_path = camera_path
func dano(golpe_force := Vector2.ZERO, duration := 0.25):
	player_life -= 1
	hit_sound.play()
	if golpe_force != Vector2.ZERO:
		golpe = golpe_force
		
		var golpe_tween := get_tree().create_tween()
		golpe_tween.tween_property(self,"golpe", Vector2.ZERO,duration)
		print(player_life)
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		if $ray_right.is_colliding():
				dano(Vector2(-200,-200))
		elif $ray_left.is_colliding():
				dano(Vector2(200,200))
	pass # Replace with function body.
