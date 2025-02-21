extends CharacterBody2D


const SPEED = 900.0
const JUMP_VELOCITY = -400.0

@onready var wall_detector := $wall_detector as RayCast2D
@onready var animation := $anim as AnimatedSprite2D

var direction := -1

func dano():
	animation.play("hit")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		animation.scale.x = direction
		
	if wall_detector.is_colliding():
		direction *= -1
		wall_detector.scale.x = -1
	if direction == 1:
		animation.scale.x = true
	else:
		animation.scale.x = false
		
		
	velocity.x = direction * SPEED * delta
	animation.scale.x = -direction
	wall_detector.scale.x = -direction
	move_and_slide()
