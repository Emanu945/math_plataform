extends StaticBody2D

const message = preload("res://sfx/message.wav")
@onready var anim: AnimatedSprite2D = $anim_npc
@onready var texture: Sprite2D = $texture
@onready var area: Area2D = $Area2D
@onready var message_sound = AudioStreamPlayer.new()

# Diálogos iniciais (configuráveis por nível no inspetor)
@export var initial_lines: Array[String] = [
	"Nossos números foram roubados",  # Padrão do nível 1
	"Como posso saber quanto é 4+5?",
	"Preciso da resposta correta dentro do baú"
]

# Diálogos de sucesso (configuráveis por nível no inspetor)
@export var success_lines: Array[String] = [
	"Obrigado! Você encontrou o número 9!",  # Padrão do nível 1
	"Agora sei que 4+5 é 9!",
	"Você é um verdadeiro herói!"
]

var current_lines: Array[String]
var block_deposited: bool = false

func _ready() -> void:
	message_sound.stream = message
	add_child(message_sound)
	if anim:
		anim.play("idle_npc")
	else:
		print("Erro: AnimatedSprite2D 'anim_npc' não encontrado!")
	if texture:
		texture.hide()
	else:
		print("Erro: Sprite2D 'texture' não encontrado!")
	
	# Inicializa current_lines com o valor do inspetor
	current_lines = initial_lines.duplicate()  # Usa uma cópia para evitar alterações no original
	print("NPC inicializado - Diálogos iniciais do inspetor: ", initial_lines)
	print("Current lines inicial: ", current_lines)

func _physics_process(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player and anim:
		var player_pos = player.global_position
		var npc_pos = global_position
		if player_pos.x < npc_pos.x:
			anim.scale.x = -1
		else:
			anim.scale.x = 1

func _on_area_2d_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		if texture:
			texture.show()
		print("Jogador entrou na área do NPC - Texture visível")

func _on_area_2d_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		if texture:
			texture.hide()
		print("Jogador saiu da área do NPC - Texture escondida")
		if DialogManager.is_message_active:
			DialogManager.end_dialogue()

func _unhandled_input(event):
	var bodies = area.get_overlapping_bodies()
	var in_area = false
	for body in bodies:
		if body.is_in_group("player"):
			in_area = true
			break
	print("Evento de entrada NPC - Pressionado: ", event.is_action_pressed("interact"), " | Na área: ", in_area, " | Diálogo ativo: ", DialogManager.is_message_active)
	if not in_area or not event.is_action_pressed("interact"):
		return
	if not DialogManager.is_message_active:
		print("NPC interagido - Iniciando diálogo com linhas: ", current_lines)
		if texture:
			texture.hide()
		if message_sound:
			DialogManager.start_message(global_position, current_lines, area)
		else:
			DialogManager.start_message(global_position, current_lines, area)

func _on_block_deposited():
	block_deposited = true
	current_lines = success_lines.duplicate()  # Usa uma cópia do success_lines do inspetor
	if anim:
		anim.play("dialog_npc")
		print("NPC agora está feliz! - Diálogos de sucesso: ", current_lines)
