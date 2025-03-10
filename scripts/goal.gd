extends Area2D

@onready var transition: CanvasLayer = $"../transition"
@export var next_level: String = ""
@onready var anim_door: AnimatedSprite2D = $anim_door

# Lista de baús configurada com chest9 por padrão
@export var chests: Array[NodePath] = ["../chest9"]

func _ready() -> void:
	if next_level == "":
		print("Aviso: 'next_level' não configurado na área de transição!")
	# Validação inicial dos baús
	for chest_path in chests:
		var chest = get_node_or_null(chest_path)
		if not chest:
			print("Aviso: Baú não encontrado no caminho: ", chest_path)
		elif not chest.has_node("anim_chest"):
			print("Aviso: Baú não tem 'anim_chest' no caminho: ", chest_path)
		else:
			print("Baú encontrado: ", chest.name)

func _on_body_entered(body: Node2D) -> void:
	print("Player dentro - Nome: ", body.name)
	if body.name == "player" and next_level != "":
		if are_all_chests_full():
			print("Todos os baús estão cheios - Iniciando transição para: ", next_level)
			transition.change_scene(next_level)
		else:
			print("Transição bloqueada - Nem todos os baús estão cheios!")
	else:
		print("Nenhuma cena carregada ou corpo não é o jogador")

func are_all_chests_full() -> bool:
	if chests.is_empty():
		print("Erro: Nenhum baú configurado na lista 'chests'!")
		return false
	
	for chest_path in chests:
		var chest = get_node_or_null(chest_path)
		if not chest:
			print("Erro: Baú não encontrado em: ", chest_path)
			return false
		var anim_chest = chest.get_node_or_null("anim_chest")
		if not anim_chest or not anim_chest is AnimatedSprite2D:
			print("Erro: 'anim_chest' inválido ou ausente em: ", chest_path)
			return false
		if anim_chest.animation != "open_chest":  # Verifica se o baú está "cheio"
			print("Baú não está cheio: ", chest.name, " | Animação atual: ", anim_chest.animation)
			return false
	
	
	print("Todos os baús estão cheios!")
	anim_door.play("open_door")
	return true
