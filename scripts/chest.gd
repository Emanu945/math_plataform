extends StaticBody2D

const sound_c = preload("res://sfx/chest_open.wav")
const sound_i = preload("res://sfx/not_correct.wav")
@onready var anim_chest: AnimatedSprite2D = $anim_chest
@onready var area: Area2D = $Area2D
@onready var correct = AudioStreamPlayer.new()
@onready var incorrect = AudioStreamPlayer.new()

@export var correct_number: int = 0

signal block_deposited

func _ready() -> void:
	correct.stream = sound_c
	incorrect.stream = sound_i
	add_child(correct)
	add_child(incorrect)
	if anim_chest:
		anim_chest.play("idle_chest")
	else:
		print("Erro: AnimatedSprite2D 'anim_chest' não encontrado no baú!")
	print("Baú inicializado - Número correto: ", correct_number)

func _on_area_2d_body_entered(body: Node) -> void:
	print("Corpo entrou na área do baú: ", body.name, " | Grupos: ", body.get_groups())
	if body.is_in_group("block"):
		if body.has_method("get_number"):  # Verifica se a função existe
			var block_number = body.get_number()
			print("Bloco detectado no baú - Número: ", block_number, " | Correto: ", correct_number)
			if block_number == correct_number:
				print("Bloco correto depositado!")
				anim_chest.play("open_chest")
				correct.play()
				emit_signal("block_deposited")
				body.queue_free()
			else:
				print("Bloco incorreto - Rejeitado")
				incorrect.play()
		else:
			print("Erro: O bloco não tem a função 'get_number'!")
	else:
		print("Corpo não é um bloco!")

func _on_area_2d_body_exited(body: Node) -> void:
	if body.is_in_group("block"):
		print("Bloco saiu da área do baú - Número: ", body.get_number() if body.has_method("get_number") else "N/A")
