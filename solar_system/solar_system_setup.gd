
const StellarBody = preload("./stellar_body.gd")
const Settings = preload("res://settings.gd")

const VolumetricAtmosphereScene = preload("res://addons/zylann.atmosphere/planet_atmosphere.tscn")
const BigRock1Scene = preload("res://props/big_rocks/big_rock1.obj")
const Rock1Scene = preload("res://props/rocks/rock1.tscn")
const GrassScene = preload("res://props/grass/grass.tscn")

const SunMaterial = preload("./materials/sun_yellow.tres")
'''
const PlanetRockyMaterial = preload("res://solar_system/materials/planet_material_rocky.tres")
const PlanetGrassyMaterial = preload("res://solar_system/materials/planet_material_grassy.tres")'''
const WaterSeaMaterial = preload("res://solar_system/materials/water_sea_material.tres")
#const RockMaterial = preload("res://props/rocks/rock_material.tres")

const Pebble1Mesh = preload("res://props/pebbles/pebble1.obj")
const Rock1Mesh = preload("res://props/rocks/rock1.obj")
const BigRock1Mesh = preload("res://props/big_rocks/big_rock1.obj")

#const BasePlanetVoxelGraph = preload("res://solar_system/voxel_graph_planet_v4.tres")

const EarthDaySound = preload("res://sounds/earth_surface_day.ogg")
const EarthNightSound = preload("res://sounds/earth_surface_night.ogg")
const WindSound = preload("res://sounds/wind.ogg")

const SAVE_FOLDER_PATH = "debug_data"
const LARGE_SCALE = 10.0


static func create_solar_system_data(settings: Settings) -> Array:
	var bodies = []
	
	var sun = StellarBody.new()
	sun.type = StellarBody.TYPE_SUN
	sun.radius = 2000.0
	sun.self_revolution_time = 60.0
	sun.orbit_revolution_time = 60.0
	sun.name = "Sun"
	bodies.append(sun)
	
	var planet = StellarBody.new()
	planet.name = "Mercury"
	planet.type = StellarBody.TYPE_ROCKY
	planet.radius = 900.0
	planet.parent_id = 0
	planet.distance_to_parent = 14400.0
	planet.self_revolution_time = 10.0 * 60.0
	planet.orbit_revolution_time = 50.0 * 60.0
	planet.atmosphere_color = Color(1.0, 0.4, 0.1)
	planet.orbit_revolution_progress = -0.1
	planet.day_ambient_sound = WindSound
	bodies.append(planet)

	planet = StellarBody.new()
	planet.name = "Earth"
	planet.type = StellarBody.TYPE_ROCKY
	planet.radius = 1800.0
	planet.parent_id = 0
	planet.distance_to_parent = 25600.0
	planet.self_revolution_time = 10.0 * 60.0
	planet.orbit_revolution_time = 150.0 * 60.0
	planet.atmosphere_color = Color(0.3, 0.5, 1.0)
	planet.orbit_revolution_progress = 0.0
	planet.day_ambient_sound = EarthDaySound
	planet.night_ambient_sound = EarthNightSound
	planet.sea = true
	var earth_id = len(bodies)
	bodies.append(planet)

	planet = StellarBody.new()
	planet.name = "Moon"
	planet.type = StellarBody.TYPE_ROCKY
	planet.radius = 600.0
	planet.parent_id = earth_id
	# The moon should not be too close, otherwise referential change
	# will overlap and physics will break. Every planet is a static body
	# and only the reference one is not moving, so its a problem is the
	# moon is still moving while we reach it.
	planet.distance_to_parent = 7500.0
	planet.self_revolution_time = 10.0 * 60.0
	planet.orbit_revolution_time = 10.0 * 60.0
	planet.atmosphere_color = Color(0.2, 0.2, 0.2)
	planet.orbit_revolution_progress = 0.25
	planet.day_ambient_sound = WindSound
	bodies.append(planet)

	planet = StellarBody.new()
	planet.name = "Mars"
	planet.type = StellarBody.TYPE_ROCKY
	planet.radius = 1280.0
	planet.parent_id = 0
	planet.distance_to_parent = 48000.0
	planet.self_revolution_time = 10.0 * 60.0
	planet.orbit_revolution_time = 100.0 * 60.0
	planet.atmosphere_color = Color(1.2, 0.8, 0.5)
	planet.orbit_revolution_progress = 0.1
	planet.day_ambient_sound = WindSound
	bodies.append(planet)

	planet = StellarBody.new()
	planet.name = "Jupiter"
	planet.type = StellarBody.TYPE_GAS
	planet.radius = 3000.0
	planet.parent_id = 0
	planet.distance_to_parent = 70400.0
	planet.self_revolution_time = 8.0 * 60.0
	planet.orbit_revolution_time = 300.0 * 60.0
	planet.atmosphere_color = Color(0.8, 0.6, 0.4)
	planet.day_ambient_sound = WindSound
	bodies.append(planet)
	
	var scale = 1.0
	if settings.world_scale_x10:
		scale = LARGE_SCALE

	for body in bodies:
		body.radius *= scale
		var speed = body.distance_to_parent * TAU / body.orbit_revolution_time
		body.distance_to_parent *= scale
		body.orbit_revolution_time = body.distance_to_parent * TAU / speed
	
	return bodies


static func _setup_sun(body: StellarBody, root: Node3D) -> DirectionalLight3D:
	var mi = MeshInstance3D.new()
	var mesh = SphereMesh.new()
	mesh.radius = body.radius
	mesh.height = 2.0 * mesh.radius
	mi.mesh = mesh
	mi.material_override = SunMaterial
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(mi)
	
	var directional_light := DirectionalLight3D.new()
	directional_light.shadow_enabled = true
	# The environment in this game is a space background so its very dark. Sky is actually a post
	# effect because you can fly out and its a planet... And still you can also have shadows while
	# in your ship!
	directional_light.shadow_opacity = 0.9
	directional_light.shadow_normal_bias = 0.2
	directional_light.directional_shadow_split_1 = 0.1
	directional_light.directional_shadow_split_2 = 0.2
	directional_light.directional_shadow_split_3 = 0.5
	directional_light.directional_shadow_blend_splits = true
	directional_light.directional_shadow_max_distance = 20000.0
	directional_light.name = "DirectionalLight"
	body.node.add_child(directional_light)
	
	return directional_light


static func _setup_atmosphere(body: StellarBody, root: Node3D, settings: Settings):
	var atmo = VolumetricAtmosphereScene.instantiate()
	#atmo.scale = Vector3(1, 1, 1) * (0.99 * body.radius)
	if settings.world_scale_x10:
		atmo.planet_radius = body.radius * 1.0
		atmo.atmosphere_height = 125.0 * LARGE_SCALE
	else:
		atmo.planet_radius = body.radius * 1.03
		atmo.atmosphere_height = 0.12 * body.radius
	# TODO This is kinda bad to hardcode the path, need to find another robust way
	atmo.sun_path = "/root/Main/GameWorld/Sun/DirectionalLight"
	#atmo.day_color = body.atmosphere_color
	#atmo.night_color = body.atmosphere_color.darkened(0.8)
	var atmo_density = 0.001
	if body.type == StellarBody.TYPE_GAS:
		if settings.world_scale_x10:
			# TODO Need to investigate this, atmosphere currently blows up HDR when large and dense
			atmo_density /= LARGE_SCALE
	atmo.set_shader_param("u_density", atmo_density)
	atmo.set_shader_param("u_attenuation_distance", 50.0)
	atmo.set_shader_param("u_day_color0", body.atmosphere_color)
	atmo.set_shader_param("u_day_color1", 
		body.atmosphere_color.lerp(Color(1,1,1), 0.5))
	atmo.set_shader_param("u_night_color0", body.atmosphere_color.darkened(0.8))
	atmo.set_shader_param("u_night_color1", 
		body.atmosphere_color.darkened(0.8).lerp(Color(1,1,1), 0.0))
	body.atmosphere = atmo
	root.add_child(atmo)


static func _setup_sea(body: StellarBody, root: Node3D):
	var sea_mesh := SphereMesh.new()
	sea_mesh.radius = body.radius * 0.985
	sea_mesh.height = 2.0 * sea_mesh.radius
	var sea_mesh_instance = MeshInstance3D.new()
	sea_mesh_instance.mesh = sea_mesh
	sea_mesh_instance.material_override = WaterSeaMaterial
	root.add_child(sea_mesh_instance)


