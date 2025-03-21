extends Node

#const Settings = preload("res://settings.gd")

@onready var _main_menu = $main_menu


var _game

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_main_menu_start_requested():
	assert(_game == null)
	_main_menu.hide()
	var game_scene : PackedScene = load("res://test.tscn")
	_game = game_scene.instantiate()
	add_child(_game)


func _on_main_menu_quit_requested():
	get_tree().quit()
	_game.queue_free()
	_game = null
	_main_menu.show()
