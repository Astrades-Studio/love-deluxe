extends Area2D
class_name PlayerSpaceship

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var current_level : Level = get_tree().get_first_node_in_group("Level")
@export var horizontal_speed := 2.0

func _process(delta: float) -> void:
	global_position.x = clamp(position.x, 0, 256)
	if Input.is_action_pressed("move_left"):
		position.x -= horizontal_speed
	elif Input.is_action_pressed("move_right"):
		position.x += horizontal_speed
	if Input.is_action_pressed("accelerate"):
		current_level.accelerate()
	elif Input.is_action_pressed("decelerate"):
		current_level.decelerate()



func _on_area_entered(area: Area2D) -> void:
	if area is Obstacle:
		var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(sprite_2d, "modulate", Color.RED, 0.1)
		await tween.finished
		tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(sprite_2d, "modulate", Color.WHITE, 0.1)
		await tween.finished
