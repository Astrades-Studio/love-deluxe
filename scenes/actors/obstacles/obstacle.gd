extends Area2D
class_name Obstacle

var direction := Vector2.ZERO
var perspective_speed := 0.0

@onready var current_level: Level = get_tree().get_first_node_in_group("Level")

## How much speed accumulates towards the bottom of the screen
@export var acceleration := 1.05

## How much speed the player loses when touching this
@export var deceleration_on_hit := 50.

@export_enum("none", "mild", "serious", "pickup") var crash_type

## If the item should change behavior when appearing on either side of the road
@export var symmetrical := true

@export var power_up : PowerUp

var initial_y_position := 0.0
var final_y_position := 256.
var final_scale := 1.3

## Variables controlling how the item looks when it spawns over the horizon
var time_far_away := 1.2
var is_far := true
var _pixels_moved_far_away_count := 5
@export var pixels_moved_far_away := 5

var obstacle_speed_multiplier := 0.3
var subpixel_y := 0.0
var default_speed := 20.
var speed_from_afar := 0.1

@onready var obstacle_small: Sprite2D = $ObstacleSmall
@onready var obstacle_large: Sprite2D = $ObstacleLarge


func _ready() -> void:
	use_far_away_sprite()


func use_far_away_sprite():
	obstacle_large.z_index = 1
	obstacle_small.z_index = -1
	obstacle_large.hide()
	obstacle_small.show()

# Flip the sprites depending on the side of the screen
	if global_position.x > GameGlobals.BOTTOM_RIGHT.x / 2.0:
		obstacle_large.flip_h = true
		obstacle_small.flip_h = true
	
# In case of the road sign and other non-symmetrical assets, center them
		if !symmetrical:
			global_position.x - 100
	else:
		if !symmetrical:
			global_position.x + 100


func use_close_sprite():
	initial_y_position = global_position.y
	obstacle_large.show()
	obstacle_small.hide()


func _process(delta):
	if is_zero_approx(current_level.speed):
		return

	# upon spawning, the obstacle moves up X pixels as the distance to the target keeps decreasing
	if is_far:
		# time_far_away -= delta * (current_level.speed / default_speed)
		subpixel_y -= speed_from_afar
		var move = int(subpixel_y)
		if move != 0:
			_pixels_moved_far_away_count -= abs(move)
			position.y += move
			subpixel_y -= move
		if _pixels_moved_far_away_count <= 0:
			_pixels_moved_far_away_count = pixels_moved_far_away
			is_far = false
			use_close_sprite()

		return


	# The current speed of the ship multiplied by acceleration to make things go faster closer to the screen
	# Multiplied by the obstacle speed
	# Multiplied by the target direction and delta
	perspective_speed += current_level.speed * acceleration * obstacle_speed_multiplier
	position += direction * perspective_speed * delta

	if global_position.y > GameGlobals.BOTTOM_RIGHT.y + 100:
		queue_free()
