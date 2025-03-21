extends CharacterBody3D


@export var MAX_SPEED = 50
@export var GRAVITY = -20.0
@export var JUMP_SPEED = 10.0
@export var ACCELERATION = 6
@export var pitch_speed = 1.5
@export var roll_speed = 1.9
@export var yaw_speed = .75
@export var input_responce = 8.0

@onready var _spring_arm = $SpringArm
var forward_speed = 0
var pitch_input = 0
var roll_input = 0
var yaw_input = 0 

func get_input(delta):
	if Input.is_action_pressed("throttle_down"):
		forward_speed= move_toward(forward_speed,MAX_SPEED,ACCELERATION * delta)
	if Input.is_action_pressed("throttle_up"):
		forward_speed= move_toward(forward_speed,-MAX_SPEED,ACCELERATION * delta)
	pitch_input = move_toward(pitch_input,Input.get_action_strength("pitch_up") - Input.get_action_strength("pitch_down"),input_responce * delta)
	roll_input =  move_toward(roll_input,Input.get_action_strength("roll_left") - Input.get_action_strength("roll_right"),input_responce * delta)
	#yaw_input =  move_toward(yaw_input,Input.get_action_strength("yaw_left") - Input.get_action_strength("yaw_right"),input_responce * delta)
	yaw_input= roll_input


func _physics_process(delta):
	var move_direction:= Vector3.ZERO
	get_input(delta)
	transform.basis = transform.basis.rotated(transform.basis.z, roll_input * roll_speed * delta)
	transform.basis = transform.basis.rotated(transform.basis.x, pitch_input * pitch_speed * delta)
	transform.basis = transform.basis.rotated(transform.basis.y, yaw_input * yaw_speed * delta)
	transform.basis = transform.basis.orthonormalized()
	velocity = -transform.basis.z * forward_speed
	move_and_collide(velocity * delta)
