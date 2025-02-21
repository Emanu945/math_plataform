extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -380.0
const JUMP_SOUND = preload("res://sfx/jump_player.mp3")

@onready var animation := $anim as AnimatedSprite2D
@onready var jump_player= AudioStreamPlayer2D.new()

func _ready() -> void:
	jump_player.stream = JUMP_SOUND
	add_child(jump_player)

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

	move_and_slide()
