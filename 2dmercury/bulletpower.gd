extends Area2D

const SPEED = 800

var velocity = Vector2();
var direction = 1;

func _ready():
	pass

func set_fireball_direction(dir):
	direction = dir
	
	if dir == -1:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false 

func _physics_process(delta):
	velocity.x = SPEED * delta * direction
	
	translate(velocity)
	$AnimatedSprite2D.play("shoot")




func _on_body_entered(body):
	if "Enemy" in body.name:
		body.dead(1)
		
	queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

