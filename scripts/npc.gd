extends StaticBody2D

const message = preload("res://sfx/message.wav")
@onready var anim: AnimatedSprite2D = $anim_npc  # Sprite animado do NPC
@onready var texture: Sprite2D = $texture  # Textura adicional que aparece na área
@onready var area: Area2D = $Area2D  # Área para interação
@onready var message_sound = AudioStreamPlayer.new()

var initial_lines: Array[String] = [
	"Nossos números foram roubados",
	"Como posso saber quanto é 4+5?",
	"Preciso da resposta correta dentro do baú"
]
var success_lines: Array[String] = [
	"Obrigado! Você encontrou o número 9!",
	"Agora sei que 4+5 é 9!",
	"Você é um verdadeiro herói!"
]
var current_lines: Array[String] = initial_lines
var block_deposited: bool = false

func _ready() -> void:
	texture.hide()
	message_sound.stream = message
	add_child(message_sound)
	if anim:
		anim.play("idle_npc")  # Animação inicial do NPC
	else:
		print("Erro: AnimatedSprite2D 'anim_npc' não encontrado!")

func _physics_process(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player and anim:
		var player_pos = player.global_position
		var npc_pos = global_position
		if player_pos.x < npc_pos.x:
			anim.scale.x = -1  # Vira para a esquerda
		else:
			anim.scale.x = 1  # Vira para a direita

func _on_area_2d_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		texture.show()  # Mostra a textura quando o jogador entra
		print("Jogador entrou na área do NPC1 - Texture visível")

func _on_area_2d_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		texture.hide()  # Esconde a textura quando o jogador sai
		print("Jogador saiu da área do NPC1 - Texture escondida")
		if DialogManager.is_message_active:
			DialogManager.end_dialogue()

func _unhandled_input(event):
	var bodies = area.get_overlapping_bodies()
	var in_area = false
	for body in bodies:
		if body.is_in_group("player"):
			in_area = true
			break
	print("Evento de entrada NPC1 - Pressionado: ", event.is_action_pressed("interact"), " | Na área: ", in_area, " | Corpos: ", bodies)
	if not in_area or not event.is_action_pressed("interact"):
		return  # Bloqueia se fora da área ou não é "interact"
	if not DialogManager.is_message_active:
		print("NPC1 interagido - Iniciando diálogo com linhas: ", current_lines)
		if texture:
			texture.hide()  # Esconde a textura ao iniciar o diálogo
		if message_sound:
			DialogManager.start_message(global_position, current_lines, area)
		else:
			DialogManager.start_message(global_position, current_lines, area)

func _on_block_deposited():
	block_deposited = true
	current_lines = success_lines
	if anim:
		anim.play('dialog_npc')  # Muda para a animação do NPC "feliz"
		print("NPC1 agora está feliz!")
