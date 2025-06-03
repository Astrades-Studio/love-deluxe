extends Sprite2D

@export var speed : float = 10.
@export var screen_center : Node2D
@export var growth_rate : float = 1.

const SCREEN_RADIUS := 256.
var initial_size := 0.5
var final_size := 1.5
var direction := Vector2.ZERO

# This node is a star that moves from the center of the screen to the edges
# and grows in size as it moves.

func _ready() -> void:
	# Set the initial size of the star
	scale = Vector2(initial_size, initial_size)
	# Set the position of the star to the center of the screen
	global_position = screen_center.global_position
	# Set the rotation of the star to a random angle
	rotation = randf_range(0, 2 * PI)
	# Set the speed of the star to a random value
	speed = randf_range(0.5, 1.5) * speed
	# Set the direction of the star to a random value
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()

func _process(delta: float) -> void:
	# Move the star in the direction of the screen edge
	position += direction * speed * delta
	# Grow the star in size until it reaches the final size at the edge of the screen
	if scale.x < final_size:
		# Calculate the growth rate based on the distance to the screen edge
		var distance_to_edge = SCREEN_RADIUS - position.length()
		growth_rate = (final_size - initial_size) / distance_to_edge
		# Update the scale of the star
		# Ensure the scale does not exceed the final size
		var _scale = clamp(scale.x + growth_rate * delta, initial_size, final_size)
		scale = Vector2(_scale, _scale)
	
	# Increase speed towards the edge of the screen
	if position.length() < SCREEN_RADIUS:
		speed += growth_rate * delta

	# Check if the star is outside the screen bounds
	if position.length() > SCREEN_RADIUS:
		queue_free() # Remove the star from the scene
