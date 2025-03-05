extends Node2D

@onready var player := $player as CharacterBody2D
@onready var camera := $camera as Camera2D
@onready var control: Control = $HUD/control
@onready var anim_hud: AnimatedSprite2D = $HUD/control/container/life_container/anim_hud
@onready var blocos = [$Bloco0, $Bloco8, $Bloco9]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.follow_camera(camera)
	player.player_has_died.connect(reload_game)
	control.time_is_up.connect(reload_game)
	Globals.score = 0
	Globals.life = 3
	for bloco in blocos:
		bloco.reached_target.connect(_on_bloco_reached_target)

func _on_bloco_reached_target():
	print("Um bloco chegou à posição correta!")
	check_all_positions()
	
func check_all_positions():
	var all_correct = true
	for bloco in blocos:
		if bloco.global_position.distance_to(bloco.target_position) > 10:
			all_correct = false
			break
			if all_correct:
				print("Todos os blocos estão nas posições corretas!")
func reload_game():
	player.animation.play('hit')
	anim_hud.play('hit_hud')
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
