extends Label

var time_elapsed

var is_paused


# Called when the node enters the scene tree for the first time.
func _ready():
	is_paused = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !is_paused:
		time_elapsed += delta
		modify_time_shown()


func reset_timer():
	time_elapsed = 0.0
	is_paused = false


func pause_timer():
	is_paused = true


func unpause_timer():
	is_paused = false


func modify_time_shown():
	var hours = int(time_elapsed / 3600)
	var remaining_time = int(time_elapsed) % 3600
	var minutes = int(remaining_time / 60)
	var seconds = int(remaining_time % 60)
	
	if hours > 0:
		text = "Time: " + "%02d:%02d:%02d" % [hours, minutes, seconds]
	else:
		text = "Time: " + "%02d:%02d" % [minutes, seconds]
