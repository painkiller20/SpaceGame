extends CharacterBody3D


@onready var bullet=[$bullet,$bullet2]
@onready var main = $Challenger2
var Bullet = load("res://assets/bullet/bullet.tscn")
@export var MAX_SPEED = 30
@export var GRAVITY = -20.0
@export var JUMP_SPEED = 10.0
@export var ACCELERATION = .75
var cooldown = 0
const COOLDOWN = 8
@export var pitch_speed = 1.5
@export var roll_speed = 1.9 
@export var yaw_speed = .75
@export var input_responce = 8.0
var inputVector = Vector3()

@onready var _spring_arm = $SpringArm


var forward_speed = 0
var pitch_input = 0
var roll_input = 0
var yaw_input = 0 
'''
func get_input(delta):
	if Input.is_action_just_pressed("throttle_down"):
		forward_speed= move_toward(forward_speed,MAX_SPEED,ACCELERATION * delta)
	if Input.is_action_just_pressed("throttle_up"):
		forward_speed= move_toward(forward_speed,-MAX_SPEED,ACCELERATION * delta)
		if  (transform.origin > Vector3(0,0,0)):
			forward_speed= move_toward(0,0,0)
	pitch_input = move_toward(pitch_input,Input.get_action_strength("pitch_up") - Input.get_action_strength("pitch_down"),input_responce * delta)
	roll_input =  move_toward(roll_input,Input.get_action_strength("roll_left") - Input.get_action_strength("roll_right"),input_responce * delta)
	yaw_input =  move_toward(yaw_input,Input.get_action_strength("yaw_left") - Input.get_action_strength("yaw_right"),input_responce * delta)
	#yaw_input= roll_input
'''
'''
func _physics_process(delta):
	var move_direction:= Vector3.ZERO
	get_input(delta)
	transform.basis = transform.basis.rotated(transform.basis.z, roll_input * roll_speed * delta)
	transform.basis = transform.basis.rotated(transform.basis.x, pitch_input * pitch_speed * delta)
	transform.basis = transform.basis.rotated(transform.basis.y, yaw_input * yaw_speed * delta)
	transform.basis = transform.basis.orthonormalized()
	velocity = -transform.basis.z * forward_speed
	move_and_collide(velocity * delta)
	transform.origin.x = clamp(transform.origin.x, -10,10)
	transform.origin.y = clamp(transform.origin.y, -10,15)

	if Input.is_action_just_pressed("ui_accept"):
		for i in bullet:
			var bullet = Bullet.instantiate()
			main.add_child(bullet)
			bullet.transform = i.transform
			bullet.velocity = bullet.transform.basis.z * 600
'''
func _physics_process(delta):
	inputVector.x = Input.get_action_strength("ui_left")- Input.get_action_strength("ui_right")
	inputVector.y = Input.get_action_strength("ui_up")- Input.get_action_strength("ui_down")
	inputVector  = inputVector.normalized()
	velocity.x= move_toward(velocity.x, inputVector.x * MAX_SPEED, ACCELERATION)
	velocity.y= move_toward(velocity.y, inputVector.y * MAX_SPEED, ACCELERATION)
	rotation_degrees.z = velocity.x * -2
	rotation_degrees.x = velocity.y / -2
	rotation_degrees.y = -velocity.x / -2
	move_and_slide()
	transform.origin.x = clamp(transform.origin.x, -15,15)
	transform.origin.y = clamp(transform.origin.y, -15,15)
	if Input.is_action_just_pressed("yaw_left")and cooldown <= 0:
		cooldown = COOLDOWN * delta
		for i in bullet:
			var bullet = Bullet.instantiate()
			add_child(bullet)
			bullet.transform = i.transform
			bullet.velocity = bullet.transform.basis.z * 600
		
	#cooldown
	if cooldown > 0:
		cooldown -= delta
