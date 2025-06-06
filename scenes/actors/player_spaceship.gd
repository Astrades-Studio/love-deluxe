extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D

@export var horizontal_speed := 2.0

func _process(delta: float) -> void:
	global_position.x = clamp(position.x, 0, 256)
	if Input.is_action_pressed("move_left"):
		position.x -= horizontal_speed
	elif Input.is_action_pressed("move_right"):
		position.x += horizontal_speed
	if Input.is_action_pressed("accelerate"):
		Level.accelerate()
	elif Input.is_action_pressed("decelerate"):
		Level.decelerate()



func _on_area_entered(area: Area2D) -> void:
	if area is Obstacle:
		var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(sprite_2d, "modulate", Color.RED, 0.1)
		await tween.finished
		tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(sprite_2d, "modulate", Color.WHITE, 0.1)
		await tween.finished
