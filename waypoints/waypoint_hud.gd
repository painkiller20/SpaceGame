extends Control

const SolarSystem = preload("res://solar_system/solar_system.gd")
const WaypointTexture = preload("res://gui/waypoint.png")

var _solar_system : SolarSystem

var _labels = []


func set_solar_system(ss : SolarSystem):
	_solar_system = ss


func _process(delta):
	queue_redraw()


func _draw():
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return

	#var body = _solar_system.get_reference_stellar_body()
	var font = get_theme_font("font")

	
