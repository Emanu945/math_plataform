extends CanvasLayer

@onready var animatior: AnimationPlayer = $animatior

func _ready() -> void:
	visible = false
	print("Initialized: Menu hidden, game running")
	# Garante que este nó processe input mesmo quando pausado (Godot 4)
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process_unhandled_input(true)

func _unhandled_input(event: InputEvent) -> void:
	print("Input event received: ", event.as_text())
	if event.is_action_pressed("ui_cancel"):
		print("Esc pressed, current paused state: ", get_tree().paused)
		if get_tree().paused:  # Retomar o jogo
			print("Attempting to resume game")
			if animatior.has_animation("resume_game"):
				animatior.play("resume_game")
				print("Playing 'resume_game' animation")
				await animatior.animation_finished
				print("Animation finished")
			else:
				print("ERROR: 'resume_game' animation not found")
			visible = false
			get_tree().paused = false
			print("Game resumed, paused state: ", get_tree().paused)
		else:  # Pausar o jogo
			print("Attempting to pause game")
			if animatior.has_animation("pause_game"):
				animatior.play("pause_game")
				print("Playing 'pause_game' animation")
			else:
				print("ERROR: 'pause_game' animation not found")
			visible = true
			get_tree().paused = true
			print("Game paused, paused state: ", get_tree().paused)
			print('git')
