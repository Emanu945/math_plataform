extends Node

@onready var dialog_box_scene = preload("res://cenas/dialog_box.tscn")

var message_lines : Array[String] = []
var current_line = 0

var dialog_box
var dialog_box_position := Vector2.ZERO

var is_message_active := false
var can_advance_message := false
var current_area: Area2D
var audio_player: AudioStreamPlayer2D

func start_message(position: Vector2, lines: Array[String], area: Area2D = null, player: AudioStreamPlayer2D = null):
	var in_area = false
	if area:
		for body in area.get_overlapping_bodies():
			if body.is_in_group("player"):
				in_area = true
				break
	print("Tentativa de iniciar diálogo - Na área: ", in_area, " | Corpos: ", area.get_overlapping_bodies() if area else "Nenhuma área")
	if is_message_active or not in_area:
		print("Diálogo bloqueado - Já ativo ou fora da área")
		return
	
	message_lines = lines
	dialog_box_position = position
	current_area = area
	audio_player = player
	show_text()
	is_message_active = true
	print("Diálogo iniciado - Linha: ", message_lines[current_line])

func show_text():
	dialog_box = dialog_box_scene.instantiate()
	dialog_box.text_display_finished.connect(_on_all_text_displayed)
	get_tree().root.add_child(dialog_box)
	dialog_box.global_position = dialog_box_position
	dialog_box.display_text(message_lines[current_line])
	can_advance_message = false
	if audio_player and not audio_player.playing:
		audio_player.play()
		print("Som tocado para linha: ", message_lines[current_line])

func _on_all_text_displayed():
	can_advance_message = true
	print("Texto exibido, pronto para avançar")

func _unhandled_input(event):
	if not is_message_active:
		return
	
	var in_area = false
	if current_area:
		for body in current_area.get_overlapping_bodies():
			if body.is_in_group("player"):
				in_area = true
				break
	print("Evento advance_message - Tecla: ", event.is_action_pressed("advance_message"), " | Na área: ", in_area, " | Corpos: ", current_area.get_overlapping_bodies() if current_area else "Nenhuma área")
	if not in_area:
		print("Bloqueado - Jogador fora da área")
		return

	if event.is_action_pressed("interact") and can_advance_message:
		print("Avançando para próxima linha: ", current_line + 1)
		dialog_box.queue_free()
		current_line += 1
		if current_line >= message_lines.size():
			end_dialogue()
			return
		show_text()

func _process(delta: float) -> void:
	if is_message_active and current_area:
		var in_area = false
		for body in current_area.get_overlapping_bodies():
			if body.is_in_group("player"):
				in_area = true
				break
		if not in_area:
			end_dialogue()
			print("Diálogo encerrado - Jogador saiu da área")

func end_dialogue():
	if is_message_active:
		dialog_box.queue_free()
		is_message_active = false
		current_line = 0
		message_lines.clear()
		audio_player = null
		current_area = null
		print("Diálogo finalizado")
