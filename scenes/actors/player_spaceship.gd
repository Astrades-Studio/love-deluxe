extends Area2D
class_name PlayerSpaceship

@onready var pivot: Node2D = $Pivot
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var ship_sprite: Sprite2D = %ShipSprite
@onready var crash_sprite: Sprite2D = %CrashSprite

@onready var current_level : Level = get_tree().get_first_node_in_group("Level")
@export var horizontal_speed := 2.0

@export var roll_speed := 1.0

var last_movement := 0

func _ready() -> void:
	crash_sprite.hide()

func _process(delta: float) -> void:
	global_position.x = clamp(position.x, 0, 256)
	if Input.is_action_pressed("move_left"):
		position.x -= horizontal_speed
		last_movement = -1
	elif Input.is_action_pressed("move_right"):
		position.x += horizontal_speed
		last_movement = 1
	if Input.is_action_pressed("accelerate"):
		current_level.accelerate()
	elif Input.is_action_pressed("decelerate"):
		current_level.decelerate()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("action_dodge"):
		_dodge()

func _dodge() -> void:
	collision_shape_2d.disabled = true
	if last_movement < 0:
		animation_player.play("dodge")
	else:
		animation_player.play_backwards("dodge")
	await animation_player.animation_finished
	collision_shape_2d.disabled = false

func _on_area_entered(area: Area2D) -> void:
	if area is Obstacle:
		_on_player_hit()


func _on_player_hit():
	current_level.decelerate(current_level.MAX_SPEED)
	
	animation_player.play("crash")
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(ship_sprite, "modulate", Color.RED, 0.1)
	await tween.finished
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(ship_sprite, "modulate", Color.WHITE, 0.1)
	await tween.finished
	
	
