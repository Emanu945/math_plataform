extends RigidBody2D

@onready var sprite: Sprite2D = $Sprite2D

@export var number: int = 0  # Número do bloco (0-2 para fase 1)
@export var target_position: Vector2 = Vector2.ZERO  # Posição correta

# Texturas para os números 0-2
@export var number_textures: Array[Texture2D] = [
	preload("res://colletables/button_0.png"),
	preload("res://colletables/button_1.png"),
	preload("res://colletables/button_2.png"),
	preload("res://colletables/button_3.png"),
	preload("res://colletables/button_4.png"),
	preload("res://colletables/button_5.png"),
	preload("res://colletables/button_6.png"),
	preload("res://colletables/button_7.png"),
	preload("res://colletables/button_8.png"),
	preload("res://colletables/button_9.png")
]

signal reached_target
var is_held = false
var player: Node
var last_direction: int = -1

func _ready() -> void:
	if number >= 0 and number < number_textures.size():
		sprite.texture = number_textures[number]
	else:
		print("Erro: Número inválido para o bloco: ", number)
		number = 0
		sprite.texture = number_textures[number]
	lock_rotation = true
	z_index = 0
	print("Bloco ", number, " inicializado - Posição alvo: ", target_position)

func _physics_process(delta: float) -> void:
	if is_held:
		freeze = true
		var last_direction = sign(player.animation.scale.x)
		var sprite_width = sprite.texture.get_width() * sprite.scale.x if sprite.texture else 16
		var offset = (8 + sprite_width / 2) * last_direction
		global_position.x = player.global_position.x + (20 * last_direction)
		global_position.y = player.global_position.y
		z_index = 1
	else:
		freeze = false
		z_index = 0
		var distance = global_position.distance_to(target_position)
		if distance < 10:
			global_position = target_position
			emit_signal("reached_target")
			freeze = true
			freeze_mode = FREEZE_MODE_STATIC
			print("Bloco ", number, " chegou à posição correta!")
		else:
			await  get_tree().create_timer(0.2).timeout
			set_collision_mask_value(1,true)

func _input(event):
	var player_near = is_player_nearby()
	print("Evento interact - Tecla: ", event.is_action_pressed("interact"), " | Jogador perto: ", player_near, " | Diálogo ativo: ", DialogManager.is_message_active)
	if event.is_action_pressed("interact") and player_near and not DialogManager.is_message_active:
		player = get_tree().get_first_node_in_group('player')
		last_direction = sign(player.animation.scale.x) if player.animation.scale.x != 0 else (1 if player.scale.x > 0 else -1)
		is_held = true
		print("Bloco ", number, " segurado")
	elif event.is_action_pressed("interact") and is_held:
		is_held = false
		print("Bloco ", number, " solto")
func is_player_nearby() -> bool:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var distance_to_player = global_position.distance_to(player.global_position)
		print("Distância ao jogador: ", distance_to_player)
		return distance_to_player < 20  # Ajuste se necessário
	print("Jogador não encontrado!")
	return false
func get_number() -> int:
	return number  
