extends Area2D

@onready var timer := $Timer as Timer

func _ready() -> void:
	if not timer:
		timer = Timer.new()
		timer.name = "Timer"
		add_child(timer)
		timer.wait_time = 0.55
		timer.one_shot = true
		timer.timeout.connect(_on_timer_timeout)
func _on_timer_timeout() -> void:
	Globals.score += 100
	owner.queue_free()
func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		body.velocity.y = body.JUMP_VELOCITY
		timer.start()
		owner.dano()
		print(body.name)
