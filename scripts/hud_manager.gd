extends Control

@onready var score_counter: Label = $container/score_container/score_counter
@onready var timer_counter: Label = $container/timer_container/timer_counter
@onready var life_counter: Label = $container/life_container/life_counter
@onready var clock_timer: Timer = $clock_timer

var minutes = 0
var seconds = 0
@export_range(0,5) var default_minutes := 1
@export_range(0,59) var default_seconds := 0

signal time_is_up()

func _ready() -> void:
	score_counter.text = str("%04d" % Globals.score)
	life_counter.text = str("%02d" % Globals.life)
	timer_counter.text = str("%02d" % default_minutes) + ":" + str("%02d" % default_seconds)
	reset_clock_timer()
	
func _on_clock_timer_timeout() -> void:
	if seconds == 0:
		if minutes > 0:
			minutes -= 1
			seconds = 60
			return
	seconds -= 1
	update_timer_display()

func reset_clock_timer():
	minutes = default_minutes
	seconds = default_seconds
	clock_timer.wait_time = 1.0
	clock_timer.start()
	
func update_timer_display():
	timer_counter.text = str("%02d" % minutes) + ":" + str("%02d" % seconds)
	
func _process(delta: float) -> void:
	score_counter.text = str("%04d" % Globals.score)
	life_counter.text = str("%02d" % Globals.life)
	if minutes == 0 and seconds == 0:
		emit_signal('time_is_up')
