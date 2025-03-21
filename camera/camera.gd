extends Camera3D


const CameraHints = preload("./camera_hints.gd")
const Util = preload("../util/util.gd")

const HINTS_NODE_NAME = "CameraHints"

@export var distance_to_target := 5.0
@export var height_modifier := 0.33
@export var target_height_modifier := 1.5
@export var side_offset := 0.0
@export var initial_target : NodePath
# When turned on, the camera will automatically search inside the target for the actual
# anchor to follow, which must have a CameraHints child node
@export var auto_find_camera_anchor = false

var _default_distance_to_target := 5.0
var _default_height_modifier := 0.33
var _default_target_height_modifier := 1.5
var _default_side_offset := 0.0

var _target : Node3D = null
var _target_rigidbody : RigidBody3D = null
var _prev_target_pos := Vector3()
var _max_target_speed := 50.0

var _wait_for_fucking_physics := 0
var _last_ref_change_info = null


func _init():
	_default_distance_to_target = distance_to_target
	_default_height_modifier = height_modifier
	_default_target_height_modifier = target_height_modifier
	_default_side_offset = side_offset


func _ready():
	if initial_target != NodePath():
		set_target(get_node(initial_target))
	
	if get_parent().has_signal("reference_body_changed"):
		get_parent().reference_body_changed.connect(_on_solar_system_reference_body_changed)


func _on_solar_system_reference_body_changed(info):
	_last_ref_change_info = info
	# If the camera follows a rigidbody, referential change is a PITA.
	# We can wait 1 frame for a seamless experience, if the target is actually a separated visual
	# updated from within the end of `_integrate_forces()`. If we were to use the classic approach
	# of the visual being a direct child of the rigidbody,
	# we'd need 2 frames and it would flicker.
	_wait_for_fucking_physics = 1
	
	transform = info.inverse_transform * transform
	_prev_target_pos = info.inverse_transform * _prev_target_pos


func set_target(target: Node3D):
	assert(target != null)
	_target = target
	
	_target_rigidbody = null
	if target is RigidBody3D:
		_target_rigidbody = target
	
	var hints : CameraHints
	if auto_find_camera_anchor:
		hints = Util.find_node_by_type(target, CameraHints)
		if hints != null:
			_target = hints.get_parent()
	
	elif _target.has_node(HINTS_NODE_NAME):
		hints = _target.get_node(HINTS_NODE_NAME)
	
	if hints != null:
		distance_to_target = hints.distance_to_target
		height_modifier = hints.height_modifier
		target_height_modifier = hints.target_height_modifier
		side_offset = hints.side_offset
	else:
		distance_to_target = _default_distance_to_target
		height_modifier = _default_height_modifier
		target_height_modifier = _default_target_height_modifier
		side_offset = _default_side_offset
	
	#var tt = _get_target_transform()
	#_prev_target_pos = tt.origin
	# Not setting `global_transform` because Godot logs an annoyng error
	# when the node is not in the tree, but the meaning is global here
	#transform = _get_ideal_transform(tt)

	near = distance_to_target * 0.1


func _get_ideal_transform(target_transform: Transform3D) -> Transform3D:
	var ct = target_transform
	ct.origin += target_transform.basis * Vector3(
		side_offset, distance_to_target * height_modifier, distance_to_target)
	return ct





func _physics_process(delta: float):
	var prev_trans = transform
	
	# Collision avoidance
	var dss := get_world_3d().direct_space_state
	var ignored := [_target_rigidbody.get_rid()] if _target_rigidbody != null else []
	var ray_query := PhysicsRayQueryParameters3D.new()

	ray_query.exclude = ignored
	var hit := dss.intersect_ray(ray_query)
	if not hit.is_empty():
		#var hit_normal = hit.normal
		pass
