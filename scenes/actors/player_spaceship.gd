extends Area2D
class_name PlayerSpaceship

@onready var pivot: Node2D = $Pivot
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var ship_sprite: Sprite2D = %ShipSprite
@onready var crash_sprite: Sprite2D = %CrashSprite
@onready var shaker_component_2d: ShakerComponent2D = $ShakerComponent2D

# SFX
@onready var crash_sfx: AudioStreamPlayer2D = $CrashSFX
@onready var motor_sfx: AudioStreamPlayer2D = $MotorSFX
@onready var jump_sfx: AudioStreamPlayer2D = $JumpSFX



@onready var current_level : Level = get_tree().get_first_node_in_group("Level")
@export var horizontal_speed := 2.0

@export var roll_speed := 1.0

var last_movement := 0

var tilt := 0.0
var tilt_speed := 0.1
var accumulated_x_movement := 0.0

const TOP_TILT := 30.0 # Maximum tilt angle in degrees

func _ready() -> void:
	crash_sprite.hide()
	current_level.speed_changed.connect(_on_speed_changed)
	GlobalGameEvents.game_started.connect(func(): motor_sfx.play())

func _process(_delta: float) -> void:
	if !current_level.driving:
		return
	global_position.x = clamp(position.x, 0, 256)
	var move_axis = Input.get_action_strength("move_left") - Input.get_action_strength("move_right")

	if move_axis > 0:
		accumulated_x_movement -= horizontal_speed
		position.x -= horizontal_speed
		
		if last_movement != -1:
			accumulated_x_movement = 0.0 # Reset if changing direction
			last_movement = -1 # Left, tracked for rolling
	elif move_axis < 0:
		accumulated_x_movement += horizontal_speed
		position.x += horizontal_speed
		
		if last_movement != 1:
			accumulated_x_movement = 0.0 # Reset if changing direction
			last_movement = 1 # Right, tracked for rolling
	else:
		# If no horizontal movement, reset accumulated movement
		accumulated_x_movement = 0.0
	
	# Track how long the player has been moving horizontally
	# Apply a tilt effect based on the last movement
	# Rotate the sprite to a maximum of 30 degrees
	tilt = clamp(lerp(tilt, accumulated_x_movement, tilt_speed), -TOP_TILT, TOP_TILT)
	# Apply the tilt to the sprite node
	ship_sprite.rotation_degrees = tilt

	if Input.is_action_pressed("accelerate"):
		current_level.accelerate()

	elif Input.is_action_pressed("decelerate"):
		current_level.decelerate()


func _unhandled_input(event: InputEvent) -> void:
	if !current_level.driving:
		return
	if event.is_action_pressed("action_dodge"):
		_dodge()


func _dodge() -> void:
	collision_shape_2d.disabled = true
	if last_movement < 0:
		animation_player.play("dodge")
	else:
		animation_player.play_backwards("dodge")
	
	jump_sfx.pitch_scale = randf_range(0.8,1.2)
	jump_sfx.play()
	
	await animation_player.animation_finished
	collision_shape_2d.disabled = false


func _on_area_entered(area: Area2D) -> void:
	if area is Obstacle:
		_on_player_hit(area, area.deceleration_on_hit)


func _on_player_hit(obstacle: Obstacle, deceleration_on_hit: float = current_level.MAX_SPEED):
	current_level.decelerate(deceleration_on_hit)
	crash_sfx.pitch_scale = randf_range(0.8,1.2)
	
	match obstacle.crash_type:
		0: # Dust
			pass
		1: # Mild
			shaker_component_2d.play_shake()
			crash_sfx.play()
		2: # Serious
			shaker_component_2d.play_shake()
			crash_sfx.play()
			animation_player.play("crash")


	#var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	#tween.tween_property(ship_sprite, "modulate", Color.RED, 0.1)
	#await tween.finished
	#tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	#tween.tween_property(ship_sprite, "modulate", Color.WHITE, 0.1)
	#await tween.finished


func _on_speed_changed(new_speed : float):
	motor_sfx.pitch_scale = remap(new_speed, 0, 50, 0.5, 1.2)
