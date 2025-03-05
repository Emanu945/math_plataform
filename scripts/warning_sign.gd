extends Node2D

const READ = preload("res://sfx/message.wav")

@onready var texture: Sprite2D = $texture
@onready var area_sign: Area2D = $area_sign
@onready var read_placa: AudioStreamPlayer2D = AudioStreamPlayer2D.new()

const lines : Array[String] = [
	"Olá, aventureiro!",
	"Use A e D para se mover",
	"Espaço para pular",
	"e E para interagir com os objetos",
	"Boa sorte!"
]

func _ready() -> void:
	texture.hide()
	read_placa.stream = READ
	add_child(read_placa)
	area_sign.body_entered.connect(_on_area_sign_body_entered)
	area_sign.body_exited.connect(_on_area_sign_body_exited)
	print("Placa inicializada - Conexões de sinais feitas")

func _on_area_sign_body_entered(body):
	if body.is_in_group("player"):
		texture.show()
		print("Jogador entrou na área - Texture visível")

func _on_area_sign_body_exited(body):
	if body.is_in_group("player"):
		texture.hide()
		print("Jogador saiu da área - Texture escondida")
		if DialogManager.is_message_active:
			DialogManager.end_dialogue()

func _unhandled_input(event):
	var bodies = area_sign.get_overlapping_bodies()
	var in_area = false
	for body in bodies:
		if body.is_in_group("player"):
			in_area = true
			break
	print("Evento interact - Tecla: ", event.is_action_pressed("interact"), " | Na área: ", in_area, " | Corpos: ", bodies)
	if not in_area or not event.is_action_pressed("interact"):
		return  # Bloqueia se fora da área ou não é "interact"
	if not DialogManager.is_message_active:
		print("Placa lida")
		texture.hide()
		DialogManager.start_message(global_position, lines, area_sign, read_placa)
