extends RigidBody2D

@onready var sprite: Sprite2D = $Sprite2D

@export var number: int = 0
@export var target_position: Vector2 = Vector2.ZERO

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
var is_held: bool = false
var player: Node = null

func _ready() -> void:
	if number >= 0 and number < number_textures.size():
		sprite.texture = number_textures[number]
	else:
		print("Erro: Número inválido para o bloco: ", number)
		number = 0
		sprite.texture = number_textures[number]
	lock_rotation = true
	z_index = 0
	sprite.centered = true  # Garante que o sprite esteja centralizado
	print("Bloco ", number, " inicializado - Posição alvo: ", target_position, 
		  " | Sprite centralizado: ", sprite.centered)

func _physics_process(delta: float) -> void:
	if is_held and player:
		freeze = true
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
			await get_tree().create_timer(0.2).timeout
			set_collision_mask_value(1, true)

func _input(event):
	pass

func is_player_nearby() -> bool:
	var player_node = get_tree().get_first_node_in_group("player")
	if player_node:
		var distance_to_player = global_position.distance_to(player_node.global_position)
		print("Distância ao jogador: ", distance_to_player)
		return distance_to_player < 40
	print("Jogador não encontrado!")
	return false

func get_number() -> int:
	return number
