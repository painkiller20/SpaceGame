extends Sprite2D

const SPEED = 800
var direction = false
var start_position = 0
var velocity = Vector2();
var lifespan = 4

func _ready():
	scale = Vector2(.1,.1)
func _init(d, ls=400):
	direction = d
	lifespan = ls

func _physics_process(delta):
	if start_position==0:
		start_position = position.x
	if direction:
		if position.x < start_position - lifespan:
			queue_free()
		else:
			position.x -= 15 
	else:
		if position.x > start_position + lifespan:
			queue_free()
		else:
			position.x  += 15
	move_toward(position.x,direction,position.x)

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
	
func destroy():
	queue_free()
