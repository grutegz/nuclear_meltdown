extends Control

var time_elapsed: float = 0.0
var is_running: bool = false

func _ready() -> void:
	$timer.wait_time = 0.1
	update_display(0.0)

func start() -> void:
	is_running = true
	$timer.start()

func stop() -> void:
	is_running = false
	$timer.stop()

func reset() -> void:
	time_elapsed = 0.0
	update_display(0.0)

func _on_timer_timeout() -> void:
	if is_running:
		time_elapsed += $timer.wait_time
		update_display(time_elapsed)

func update_display(time: float) -> void:
	var minutes = int(time / 60)
	var seconds = fmod(time, 60)
	$time_label.text = "%02d:%02d" % [minutes, int(seconds)]
