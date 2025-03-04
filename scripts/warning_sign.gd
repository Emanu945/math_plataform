extends Node2D

const READ = preload("res://sfx/message.wav")

@onready var texture: Sprite2D = $texture
@onready var area_sign: Area2D = $area_sign
@onready var read_placa = AudioStreamPlayer2D.new()

const lines : Array[String] = [
	"Olá, aventureiro!",
	"Use A e D para se mover",
	"Espaço para pular",
	"e E para interagir com os objetos",
	"Boa sorte!"
]

func _ready() -> void:
	read_placa.stream = READ
	add_child(read_placa)
func _unhandled_input(event):
	if area_sign.get_overlapping_bodies().size() > 0:
		texture.show()
		if event.is_action_pressed("advance_message") && !DialogManager.is_message_active:
			read_placa.play()
			print("placa lida")
			texture.hide()
			DialogManager.start_message(global_position, lines)
	else:
		texture.hide()
		if DialogManager.dialog_box != null:
			DialogManager.dialog_box.queue_free()
			DialogManager.is_message_active = false
			
