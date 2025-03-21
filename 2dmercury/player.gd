extends CharacterBody2D

const GRAVITY =800
const JUMP_FORCE=-500
const MOVE_SPEED = 200
const SHOOT_FORCE = 800
var b

@onready var animationplayer = $AnimatedSprite
@onready var bullet = preload("res://2dmercury/bullet.tscn")
#var velocity  Vector2.ZERO
var is_jumping = false
  




func shoot():
	var dir  = Vector2.ZERO
	if Input.is_action_pressed("ui_down"):
		b = bullet.instantiate()
		b.init(dir)
		get_parent().add_child(b)
		b.global_position = $Marker2D.global_position



func _physics_process(delta:float)->void:
	shoot()
	var move_direction  = Vector2.ZERO	
	if Input.is_action_pressed("ui_right"):
		move_direction.x +=1 
		animationplayer.play("Run")
		$AnimatedSprite.flip_h = false
	if Input.is_action_pressed("ui_left"):
		move_direction.x -=1
		animationplayer.play("Run")
		$AnimatedSprite.flip_h = true
	velocity.x = move_direction.x *MOVE_SPEED
	
	if is_on_floor() and Input.is_action_just_pressed("ui_up"):
		velocity.y = JUMP_FORCE
		is_jumping = true
	if is_jumping and not is_on_floor():
		is_jumping = false
	velocity.y += GRAVITY *delta
	move_and_slide()
	








'''
var gravity:=5

const SPEED = 100
const acceleration = 500
const friction = 500
var b
@onready var animationplayer = $AnimatedSprite
@onready var bullet = preload("res://2dmercury/bullet.gd")


# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func shoot():
	if Input.is_action_pressed("roll_left"):
		b = bullet.instantiate()
		get_parent().add_child(b)
		b.global_position = $Marker2D.global_position

func _physics_process(delta):
	shoot()
	gravity+=10
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") -  Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") -  Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()

	if input_vector !=Vector2.ZERO:
		if input_vector.x>0:
			animationplayer.play("Run")
			$AnimatedSprite.flip_h = false
		else:
			animationplayer.play("Run")
			$AnimatedSprite.flip_h = true
		if input_vector.y<0 :
			animationplayer.play("Jump")
			gravity = -3
		input_vector.y = gravity
		velocity = velocity.move_toward(input_vector * SPEED, acceleration * delta)
		velocity += input_vector * acceleration *delta


		#velocity = velocity.clamp(SPEED, 0)
	else:
		animationplayer.play("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	move_and_slide()
'''






'''
const GRAVITY = 9.8
const SPEED = 10
const MAX_SPEED = 200
const JUMP_HEIGHT = 500

const acceleration = 500
const FIREBALL = preload("res://2dmercury/bullet.tscn")
const FIREBALL_POWER = preload("res://2dmercury/bulletpower.tscn")
const Globals = preload("res://script/Globals.gd")

var motion = Vector2();
var is_dead = false;

var fireball_power = 1

@export var enemy_kill_count = 0
@export var player_health = 3

func reset_stats():
	enemy_kill_count = 0
	player_health = 3

signal taking_damage

func read():
	$ShootSound.loop = false

func _physics_process(delta):
	
	if is_dead == false:
		if Input.is_key_pressed(KEY_ESCAPE):
			get_tree().quit()

		motion.y += GRAVITY
	
		if Input.is_action_pressed("ui_right"):
			motion.x += SPEED
			$AnimatedSprite.play("Run")
			$AnimatedSprite.flip_h = false
			velocity = velocity.move_toward(motion , acceleration * delta)
			if sign($Marker2D.position.x) == -1:
				$Marker2D.position.x *= -1
		elif Input.is_action_pressed("ui_left"):
			motion.x -= SPEED
			$AnimatedSprite.play("Run")
			$AnimatedSprite.flip_h = true
			if sign($Marker2D.position.x) == 1:
				$Marker2D.position.x *= -1
		else:
			motion.x = move_toward(motion.x, 0, 0.1)
			if motion.y < GRAVITY:
				$AnimatedSprite.play("Jump")
			if motion.y > GRAVITY:
				$AnimatedSprite.play("Fall")
			if int(motion.y) == int(GRAVITY):
				$AnimatedSprite.play("Idle")

		if motion.x > MAX_SPEED:
			motion.x = MAX_SPEED
		if motion.x < -MAX_SPEED:
			motion.x = -MAX_SPEED
		if is_on_floor():	
			if Input.is_action_just_pressed("ui_up"):
				motion.y -= JUMP_HEIGHT	
				
				
		if Input.is_action_just_pressed("ui_focus_next"):			
			$ShootSound.play()
			
			var fireball = FIREBALL.instance()
						
			if fireball_power == 1:
				fireball = FIREBALL.instance()
			elif fireball_power == 2: 
				fireball = FIREBALL_POWER.instance()
			
			if sign($Marker2D.position.x) == 1:
				fireball.set_fireball_direction(1)
			else:
				fireball.set_fireball_direction(-1)
			
			get_parent().add_child(fireball)			
			
			fireball.position = $Marker2D.global_position
			
		move_and_slide();
#		 move_and_slide()
		
#		if get_slide_count() > 0:
#			for i in range(get_slide_count()):
#				if "Enemy" in get_slide_collision(i).collider.name:
#					damage()

func damage():	
	print(player_health)
	if player_health == 1:
		dead()
	else:
		$AnimatedSprite.play("TakingDamage")
		player_health -= 1
		emit_signal("taking_damage")
	
func dead():
	is_dead = true
	motion = Vector2(0, 0)
	$AnimatedSprite.play("Dead")
	
	self.translate(Vector2(0, -10))
	if $CollisionShape2D != null:
		$CollisionShape2D.queue_free()
		
	$Timer.start()	
	enemy_kill_count = 0

func _on_Timer_timeout():
	get_tree().change_scene("res://TitleScreen.tscn")

func powerup():
	fireball_power = 2

'''

















'''
const SPEED = 100
const acceleration = 500
const friction = 500
@onready var animationplayer = $AnimationPlayer


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") -  Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") -  Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	if input_vector !=Vector2.ZERO:
		if input_vector.x>0:
			animationplayer.play("run")
		else:
			animationplayer.play("run")
		velocity = velocity.move_toward(input_vector * SPEED, acceleration * delta)
		velocity += input_vector * acceleration *delta
		#velocity = velocity.clamp(SPEED, 0)

	else:
		animationplayer.play("idle_right")
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	move_and_slide()
'''
