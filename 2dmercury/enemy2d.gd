extends Node2D
@onready var bullet = preload("res://2dmercury/bullet.tscn")
var b 
var dir  = Vector2.ZERO

func _physics_process(delta):
	if $RayCast2D.is_colliding():
		if $Timer.is_stopped():
			$Timer.start()
	else:
		if not $Timer.is_stopped():
			$Timer.stop()

func shoot(dir):
	b = bullet.instantiate()
	b.init(dir,800)
	b.global_position = $Marker2D.global_position

func _on_area_2d_body_entered(body):
	body.get_parent().queue_free()
	queue_free()


func _on_timer_timeout():
	shoot(true)
