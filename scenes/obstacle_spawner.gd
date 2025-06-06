extends Node2D
class_name ObstacleSpawner

@export var obstacle_list : Array[String]
@export var delay_between_obstacles : float = 2.0
var time_elapsed : float = 0.0

var horizon_position = Vector2.ZERO

const SPAWN_OFFSET_WIDTH := 10.


func _ready() -> void:
	pass

func _process(delta: float) -> void:
	time_elapsed += delta

	var random_range := randf_range(-1, 1)

	# Spawn an obstacle every delay_between_obstacles seconds
	if time_elapsed >= delay_between_obstacles:
		time_elapsed = 0.0
		spawn_obstacle()



# El obstaculo spawnea en 0, 0
# Randomizamos el eje X entre -10 y 10
# Tiene que llegar a -128 o +128 en el eje X
# En el eje Y tiene que llegar a 240

func spawn_obstacle():
	var offset_x = randf_range(-SPAWN_OFFSET_WIDTH, SPAWN_OFFSET_WIDTH)
	var destination = Vector2(offset_x, GameGlobals.BOTTOM_RIGHT.y)
	var spawn_pos = horizon_position + Vector2(offset_x, 0)
	var obstacle = load(obstacle_list.pick_random()).instantiate()
	obstacle.position = spawn_pos

	# Destination is the bottom of the screen, extrapolating the horizontal offset so that the obstacle moves downwards at an angle
	var target_bottom_x = remap(offset_x, -SPAWN_OFFSET_WIDTH, SPAWN_OFFSET_WIDTH, (GameGlobals.BOTTOM_LEFT).x, (GameGlobals.BOTTOM_RIGHT).x)
	var target_bottom_y := GameGlobals.BOTTOM_RIGHT.y
	#target_bottom_x = to_global(GameGlobals.BOTTOM_RIGHT).x
	destination = to_local(Vector2(target_bottom_x, target_bottom_y))

	# Calculate movement direction
	obstacle.direction = (destination - spawn_pos).normalized()

	add_child(obstacle)
