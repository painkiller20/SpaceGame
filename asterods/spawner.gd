extends Node3D


@onready var main  = get_tree().current_scene
var asteroid =[
preload("res://assets/enemy_alien.tscn")
]


func spawn():
	randomize()
	var x =randi() % asteroid.size()
	var aster = asteroid[x].instantiate()
	add_child(aster)
	#print(x)
	aster.transform.origin = transform.origin + Vector3(randf_range(-450,450),randf_range(-10,10),0)


func _on_timer_timeout():
	spawn()
