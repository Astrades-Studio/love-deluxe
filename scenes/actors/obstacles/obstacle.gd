extends Area2D
class_name Obstacle

var direction := Vector2.ZERO
var horizon_position := Vector2(256/2, 240/2)
var perspective_speed := 0.0

@export var acceleration := 1.05

var time_far_away := 1.2
var is_far := true

@onready var obstacle_small: Sprite2D = $ObstacleSmall
@onready var obstacle_large: Sprite2D = $ObstacleLarge

func _ready() -> void:
	use_far_away_sprite()

func use_far_away_sprite():
	obstacle_large.hide()
	obstacle_small.show()

func use_close_sprite():
	obstacle_large.show()
	obstacle_small.hide()


func _process(delta):
	if is_far:
		time_far_away -= delta
		position.y -= 0.1
		if time_far_away < 0:
			is_far = false
			use_close_sprite()
		return
	
	perspective_speed += Level.speed * acceleration
	position += direction * perspective_speed * delta
	#(position - horizon_position).normalized() * speed * delta
	scale += Vector2(0.5, 0.5) * delta
	if global_position.y > GameGlobals.BOTTOM_RIGHT.y + 100:
		queue_free()
