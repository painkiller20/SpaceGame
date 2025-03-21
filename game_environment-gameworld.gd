extends Node

const StellarBody = preload("res://solar_system/stellar_body.gd")
const SolarSystemSetup = preload("res://solar_system/solar_system_setup.gd")
const Settings = preload("res://settings.gd")

const CameraScene = preload("../camera/camera.tscn")
const ShipScene = preload("res://new ship/new_ship.tscn")

const BODY_REFERENCE_ENTRY_RADIUS_FACTOR = 3.0
const BODY_REFERENCE_EXIT_RADIUS_FACTOR = 3.1 # Must be higher for hysteresis


class ReferenceChangeInfo:
	var inverse_transform : Transform3D

class LoadingProgress:
	var progress := 0.0
	var message := ""
	var finished := false


signal reference_body_changed(info)
signal loading_progressed(info)
signal exit_to_menu_requested


@onready var _environment : Environment = $WorldEnvironment.environment
@onready var _spawn_point = $SpawnPoint
@onready var _mouse_capture = $MouseCapture
@onready var _hud = $HUD
@onready var _pause_menu = $PauseMenu
@onready var _lens_flare = $LensFlare


var _ship = null

var _bodies := []
var _reference_body_id := 0
var _directional_light : DirectionalLight3D
var _physics_count := 0
var _physics_count_on_last_reference_change = 0
# This is a placeholder instance to allow testing the game without going from the usual main scene.
# It will be overriden in the normal flow.
var _settings := Settings.new()
var _settings_ui : Control

func _ready():
	set_physics_process(false)
	_hud.hide()
	
	_bodies = SolarSystemSetup.create_solar_system_data(_settings)
	
	var progress_info = LoadingProgress.new()
	
	for i in len(_bodies):
		var body : StellarBody = _bodies[i]
		
		progress_info.message = "Generating {0}...".format([body.name])
		progress_info.progress = float(i) / float(len(_bodies))
		loading_progressed.emit(progress_info)
		await get_tree().process_frame


	# Spawn player
	_mouse_capture.capture()
	# Camera must process before the ship so we have to spawn it before...
	var camera = CameraScene.instantiate()
	camera.auto_find_camera_anchor = true
	if _settings.world_scale_x10:
		camera.far *= SolarSystemSetup.LARGE_SCALE
	add_child(camera)
	_ship = ShipScene.instantiate()
	_ship.global_transform = _spawn_point.global_transform
	#_ship.apply_game_settings(_settings)
	add_child(_ship)
	camera.set_target(_ship)
	_hud.show()
	
	set_physics_process(true)

	progress_info.finished = true
	loading_progressed.emit(progress_info)


func set_settings(s: Settings):
	_settings = s


func set_settings_ui(ui: Control):
	_settings_ui = ui


func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and not event.is_echo():
			if event.keycode == KEY_ESCAPE:
				if _settings_ui.visible:
					_settings_ui.hide()
				elif _pause_menu.visible:
					_pause_menu.hide()
					_mouse_capture.capture()
				else:
					_pause_menu.show()


func _physics_process(delta: float):
	# Check when to change referential.
	# Only do so after a few frames elapsed from the last change, because in Godot,
	# physics are deferred in shitty ways even if we presently are in _physics_process
	if _physics_count > 0 and _physics_count - _physics_count_on_last_reference_change > 10:
		if _reference_body_id == 0:
			for i in len(_bodies):
				var body : StellarBody = _bodies[i]
				if body.type == StellarBody.TYPE_SUN:
					# Ignore sun, no point landing there
					continue
				var body_pos = body.node.global_transform.origin
				var d = body_pos.distance_to(_ship.global_transform.origin)
				if d < BODY_REFERENCE_ENTRY_RADIUS_FACTOR * body.radius:
					print("Close to ", body.name, " which is at ", body_pos)
					#set_reference_body(i)
					break
		else:
			var ref_body = _bodies[_reference_body_id]
			var body_pos = ref_body.node.global_transform.origin
			var d = body_pos.distance_to(_ship.global_transform.origin)
			if d > BODY_REFERENCE_EXIT_RADIUS_FACTOR * ref_body.radius:
				pass
				#set_reference_body(0)
	
