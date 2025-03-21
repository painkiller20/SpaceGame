extends CharacterBody3D

var spd = randf_range(-20,-50)

func _physics_process(delta):
	move_and_collide(Vector3(0,0,spd))
	if transform.origin.z < -30:
		queue_free()
