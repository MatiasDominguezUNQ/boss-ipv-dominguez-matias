extends Control

signal  cooldown_timeout()

@export var duration: int
@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar
@onready var cooldown: Timer = $Cooldown

var tween: Tween

func _ready():
	hide()
	cooldown.wait_time = duration
	texture_progress_bar.value = 0 

func start_timer():
	if tween:
		tween.kill()
	cooldown.stop()
	cooldown.wait_time = duration  
	cooldown.start()
	texture_progress_bar.value = 0 
	modulate.a = 1.0
	show()
	var tween = create_tween()
	tween.tween_property(texture_progress_bar, "value", texture_progress_bar.max_value, duration)

func _process(delta):
	if cooldown.is_stopped() == false:
		var elapsed = cooldown.time_left
		var total = cooldown.wait_time
		texture_progress_bar.value = (1.0 - elapsed / total) * texture_progress_bar.max_value

func _on_timer_timeout():
	emit_signal("cooldown_timeout")
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	await tween.finished
	hide()
	modulate.a = 1.0
