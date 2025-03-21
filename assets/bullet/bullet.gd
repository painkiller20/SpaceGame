extends CharacterBody3D

var KillParticles = preload("res://assets/bullet/KillParticles.tscn")
var a=0
@onready var main = get_tree().current_scene
@onready var explodeSound = $EnemyExplode

func _physics_process(delta):
	move_and_slide()


func _on_area_3d_body_entered(body):
	if body.is_in_group("Enemies"):
		var particles = KillParticles.instantiate()
		add_child(particles)
		particles.transform.origin = transform.origin
		body.queue_free()
		a=a+1
		explodeSound.play()
		visible = false
		$Area3D/CollisionShape3D.disabled = true


func _on_timer_timeout():
	$OmniLight3D.visible = false
