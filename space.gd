extends Node3D
"""
class_name game_manager

signal toggle_game_paused(is_paused:bool)
var game_paused: bool = false:
	get:
		return game_paused
	set(value):
		game_paused = value
		get_tree().paused = game_paused
		emit_signal("toggle_game_paused",game_paused)

func _input(event):
	if(event.is_action_pressed("ui_accept")):
		game_paused = !game_paused
"""
func _process(delta):
	var pause = $gui/pause
	pause.hide()
