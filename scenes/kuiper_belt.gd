extends Node2D
class_name KuiperBelt

const ASTEROID_LARGE : Texture2D = preload("uid://brjn5qgrdvl6x")
const ASTEROID_SMALL : Texture2D = preload("uid://bfny3ygk7m5on")

var asteroids : Array[Sprite2D] = []

var count := 100
var speed := 30

var height := 100.0

var max_left : float 
var max_right : float

var initial_scale := 0.5
var final_scale := 3.0


func _ready() -> void:
	if GameGlobals.current_level == GameGlobals.LevelNumber.URANUS_KUIPER:
		# Set the width and height based on the current level
		_spawn_asteroids()

		show()
	else:
		hide()


func _process(delta: float) -> void:
	_move_asteroids_left(delta)


func _spawn_asteroids() -> void:
	max_left = to_local(Vector2(GameGlobals.BOTTOM_LEFT.x - 200, 0)).x
	max_right = to_local(Vector2(GameGlobals.BOTTOM_RIGHT.x + 200, 0)).x
	for i in range(count):
		var asteroid := Sprite2D.new()
		asteroid.texture = ASTEROID_LARGE if randi() % 2 == 0 else ASTEROID_SMALL
		asteroid.position = Vector2(randf_range(max_left, max_right), randf_range(-height /2, height /2))
		asteroid.scale = Vector2(initial_scale, initial_scale)
		asteroid.modulate = Color.GRAY
		add_child(asteroid)
		asteroids.append(asteroid)


func _move_asteroids_left(delta: float) -> void:
	for asteroid in asteroids:
		asteroid.position.x -= speed * delta
		# wrap position to the right side if it goes off screen
		if asteroid.position.x < max_left:
			asteroid.position.x = max_right + randf_range(10, 50)
			

func update_asteroids(percentage_travelled: float) -> void:
	for asteroid in asteroids:
		# Update the scale based on the percentage travelled
		var new_scale : float = lerp(initial_scale, final_scale, percentage_travelled)
		asteroid.scale = Vector2(new_scale, new_scale)
		
