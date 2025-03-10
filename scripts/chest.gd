extends StaticBody2D

const sound_c = preload("res://sfx/chest_open.wav")
const sound_i = preload("res://sfx/not_correct.wav")
@onready var anim_chest: AnimatedSprite2D = $anim_chest
@onready var area: Area2D = $Area2D
@onready var correct = AudioStreamPlayer.new()
@onready var incorrect = AudioStreamPlayer.new()

# Dois números corretos que o baú aceita (pode conter duplicatas)
@export var correct_numbers: Array[int] = [0, 0]  # Exemplo: [5, 5] para aceitar dois blocos 5

# Rastreia quais blocos foram depositados
var deposited_numbers: Array[int] = []

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
	print("Baú inicializado - Números corretos: ", correct_numbers)

func _on_area_2d_body_entered(body: Node) -> void:
	print("Corpo entrou na área do baú: ", body.name, " | Grupos: ", body.get_groups())
	if body.is_in_group("block"):
		if body.has_method("get_number"):
			var block_number = body.get_number()
			print("Bloco detectado no baú - Número: ", block_number, " | Correto: ", correct_numbers)
			
			# Verifica se o número do bloco está na lista de corretos e se ainda há espaço
			if block_number in correct_numbers and deposited_numbers.size() < correct_numbers.size():
				# Verifica se ainda há ocorrências disponíveis desse número
				var remaining_slots = correct_numbers.count(block_number) - deposited_numbers.count(block_number)
				if remaining_slots > 0:
					print("Bloco correto depositado: ", block_number)
					deposited_numbers.append(block_number)
					Globals.score += 100
					body.queue_free()  # Remove o bloco da cena
					correct.play()
					
					# Verifica se todos os blocos foram depositados
					if deposited_numbers.size() == correct_numbers.size():
						print("Todos os blocos corretos depositados!")
						anim_chest.play("open_chest")
						emit_signal("block_deposited")
					else:
						print("Ainda falta(m) ", correct_numbers.size() - deposited_numbers.size(), " bloco(s): ", correct_numbers.filter(func(n): return deposited_numbers.count(n) < correct_numbers.count(n)))
				else:
					print("Bloco correto, mas já depositado o número máximo de vezes: ", block_number)
					incorrect.play()
			else:
				print("Bloco incorreto ou baú cheio - Rejeitado")
				incorrect.play()
		else:
			print("Erro: O bloco não tem a função 'get_number'!")

func _on_area_2d_body_exited(body: Node) -> void:
	if body.is_in_group("block"):
		print("Bloco saiu da área do baú - Número: ", body.get_number() if body.has_method("get_number") else "N/A")
