extends Camera3D


@onready var target: Object =get_parent().get_node("Challenger")
@export var smooth_speed: float 
@export var offset: Vector3 

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (target!= null):
		self.transform.origin = self.transform.origin 
