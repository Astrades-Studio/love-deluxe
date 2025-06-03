@icon("uid://bx8wu1qdi8vu7")
class_name TraumaDetector3D extends Area3D

@export var camera: CameraShake3D

func _ready():
	monitoring = false
	monitorable = true
	collision_layer = GameGlobals.shakeables_collision_layer
	collision_mask = 0 


func add_trauma(time: float, amount: float):
	if camera:
		camera.trauma(time, amount)


func enable():
	set_deferred("monitorable", true)
	

func disable():
	set_deferred("monitorable", false)
