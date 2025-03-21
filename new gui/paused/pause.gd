extends Control
'''
@export var Game_manager: game_manager
# Called when the node enters the scene tree for the first time.
func _ready():
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
func _on_game_manage_toggle_game_paused(is_paused:bool):
	if(is_paused):
		show()
	else:
		hide()
'''
