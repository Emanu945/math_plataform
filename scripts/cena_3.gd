extends Node2D

@onready var player := $player as CharacterBody2D
@onready var camera := $camera as Camera2D
@onready var control: Control = $HUD/control
@onready var anim_hud: AnimatedSprite2D = $HUD/control/container/life_container/anim_hud
@onready var blocos = [$Bloco9, $Bloco8, $Bloco5]
@onready var bau3 = $chest3
@onready var bau8 = $chest8
@onready var bau2 = $chest2
@onready var npc = $npc
@onready var npc2 = $npc2
@onready var npc3 = $npc3

func _ready() -> void:
	# Validação dos baús
	if not bau3:
		print("Erro: 'chest9' não encontrado na cena!")
	elif not bau3.has_signal("block_deposited"):
		print("Erro: 'chest9' não tem o sinal 'block_deposited'!")
	if not bau8:
		print("Erro: 'chest8' não encontrado na cena!")
	elif not bau8.has_signal("block_deposited"):
		print("Erro: 'chest8' não tem o sinal 'block_deposited'!")
	if not bau2:
		print("Erro: 'chest5' não encontrado na cena!")
	elif not bau2.has_signal("block_deposited"):
		print("Erro: 'chest5' não tem o sinal 'block_deposited'!")

	# Validação dos NPCs
	if not npc:
		print("Erro: 'npc' não encontrado na cena!")
	elif not npc.has_method("_on_block_deposited"):
		print("Erro: 'npc' não tem o método '_on_block_deposited'!")
	if not npc2:
		print("Erro: 'npc2' não encontrado na cena!")
	elif not npc2.has_method("_on_block_deposited"):
		print("Erro: 'npc2' não tem o método '_on_block_deposited'!")
	if not npc3:
		print("Erro: 'npc3' não encontrado na cena!")
	elif not npc3.has_method("_on_block_deposited"):
		print("Erro: 'npc3' não tem o método '_on_block_deposited'!")

	# Conexões com validação
	if bau8 and npc and bau8.has_signal("block_deposited") and npc.has_method("_on_block_deposited"):
		bau8.block_deposited.connect(npc._on_block_deposited)
		bau8.block_deposited.connect(_on_bau8_deposited)
		print("Conexões de 'chest9' realizadas com sucesso!")
	else:
		print("Falha ao conectar 'chest9' - Verifique baú ou NPC!")

	if bau3 and npc2 and bau3.has_signal("block_deposited") and npc2.has_method("_on_block_deposited"):
		bau3.block_deposited.connect(npc2._on_block_deposited)
		bau3.block_deposited.connect(_on_bau3_deposited)
		print("Conexões de 'chest8' realizadas com sucesso!")
	else:
		print("Falha ao conectar 'chest8' - Verifique baú ou NPC!")

	if bau2 and npc3 and bau2.has_signal("block_deposited") and npc3.has_method("_on_block_deposited"):
		bau2.block_deposited.connect(npc3._on_block_deposited)
		bau2.block_deposited.connect(_on_bau2_deposited)
		print("Conexões de 'chest5' realizadas com sucesso!")
	else:
		print("Falha ao conectar 'chest5' - Verifique baú ou NPC!")

	# Outras inicializações
	if player and camera:
		player.follow_camera(camera)
	if player:
		player.player_has_died.connect(reload_game)
	if control:
		control.time_is_up.connect(reload_game)
	Globals.score = 0
	Globals.life = 3
	for bloco in blocos:
		if bloco:
			bloco.reached_target.connect(_on_bloco_reached_target)
		else:
			print("Erro: Um dos blocos está null!")

func _on_bloco_reached_target():
	print("Um bloco chegou à posição correta!")
	check_all_positions()

func _on_bau8_deposited():
	print("Baú 8 ativado!")

func _on_bau3_deposited():
	print("Baú 3 ativado!")

func _on_bau2_deposited():
	print("Baú 2 ativado!")

func check_all_positions():
	var all_correct = true
	for bloco in blocos:
		if bloco.global_position.distance_to(bloco.target_position) > 10:
			all_correct = false
			break
	if all_correct:  # Corrigido: Identação estava errada no original
		print("Todos os blocos estão nas posições corretas!")

func reload_game():
	if player and anim_hud:
		player.animation.play('hit')
		anim_hud.play('hit_hud')
		await get_tree().create_timer(1.0).timeout
		get_tree().reload_current_scene()

func _process(delta: float) -> void:
	pass
