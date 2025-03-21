extends Control


signal start_requested
signal settings_requested
signal quit_requested


func _on_start_pressed():
	start_requested.emit()
	$gamesound.play()
#func _on_settings_pressed():
#	settings_requested.emit()


func _on_quit_pressed():
	quit_requested.emit()


func _on_settings_2_pressed():
	pass # Replace with function body.

func _process(delta):
	pass


