extends Area2D
class_name PlayerSpaceship

@onready var pivot: Node2D = $Pivot
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var ship_sprite: Sprite2D = %ShipSprite
@onready var crash_sprite: Sprite2D = %CrashSprite
@onready var shaker_component_2d: ShakerComponent2D = $ShakerComponent2D
@onready var shield_timer: Timer = %ShieldTimer

# SFX
@onready var crash_sfx: AudioStreamPlayer2D = %CrashSFX
@onready var motor_sfx: AudioStreamPlayer2D = %MotorSFX
@onready var jump_sfx: AudioStreamPlayer2D = %JumpSFX
@onready var pickup_sfx: AudioStreamPlayer2D = %PickupSFX
@onready var shield_sfx: AudioStreamPlayer2D = %ShieldSFX

# VFX
@onready var shield_fx: Sprite2D = %ShieldFX


@onready var current_level : Level = get_tree().get_first_node_in_group("Level")
@export var horizontal_speed := 2.0

@export var roll_speed := 1.0

var last_movement := 0

var tilt := 0.0
var tilt_speed := 0.1
var accumulated_x_movement := 0.0
var dodging := false
 
const TOP_TILT := 30.0 # Maximum tilt angle in degrees


func _ready() -> void:
	crash_sprite.hide()
	GlobalGameEvents.speed_changed.connect(_on_speed_changed)
	GlobalGameEvents.game_started.connect(func(): motor_sfx.play())
	GlobalGameEvents.destination_reached.connect(func(): motor_sfx.stop())
	shield_timer.timeout.connect(stop_shield)


func _process(_delta: float) -> void:
	if !current_level.driving:
		return
	global_position.x = clamp(position.x, 40, 216)
	
	power_up_activation()

	if dodging:
		accumulated_x_movement = 0.0
		return
	
	var move_axis := Input.get_action_strength("move_left") - Input.get_action_strength("move_right")
	
	if !is_zero_approx(move_axis):
		_handle_horizontal_movement(move_axis)
	else:
		_handle_horizontal_movement(move_direction)

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


var move_direction : float = 0.0
func _unhandled_input(event: InputEvent) -> void:
	if !current_level.driving:
		return

	if event is InputEventKey or event is InputEventJoypadButton:
		move_direction = event.get_action_strength("move_left") - event.get_action_strength("move_right")
	
	elif event is InputEventScreenTouch or event is InputEventScreenDrag:
		move_direction = _handle_touch_input(event)

	if event is InputEventMouseButton or event is InputEventMouseMotion:
		move_direction = _handle_touch_input(event)

	if event.is_action_pressed("action_dodge"):
		_dodge()


func _handle_horizontal_movement(move_axis: float) -> float:
	if move_axis > 0:
		accumulated_x_movement -= horizontal_speed
		position.x -= horizontal_speed
		
		if last_movement != 1:
			accumulated_x_movement = 0.0 # Reset if changing direction
			last_movement = 1 # Right, tracked for rolling
	
	elif move_axis < 0:
		accumulated_x_movement += horizontal_speed
		position.x += horizontal_speed
		
		if last_movement != -1:
			accumulated_x_movement = 0.0 # Reset if changing direction
			last_movement = -1 # Left, tracked for rolling
	else:
		# If no horizontal movement, reset accumulated movement
		accumulated_x_movement = 0.0
	
	return accumulated_x_movement


func _handle_touch_input(event: InputEvent) -> float:
	var screen_width = GameGlobals.BOTTOM_RIGHT.x
	var touch_position = event.position.x
	
	var move_axis := 0.0
	
	if touch_position < screen_width / 2:
		move_axis = -1.0  # Left side of the screen
	elif touch_position > screen_width / 2:
		move_axis = 1.0   # Right side of the screen
	
	if event.is_released():
		move_axis = 0.0   # No movement when touch is released

	return _handle_horizontal_movement(move_axis)


func _dodge() -> void:
	if dodging:
		return
	collision_shape_2d.disabled = true
	dodging = true
	if last_movement < 0:
		animation_player.play("dodge")
	else:
		animation_player.play_backwards("dodge")
	
	jump_sfx.pitch_scale = randf_range(0.8,1.2)
	jump_sfx.play()
	
	await animation_player.animation_finished
	collision_shape_2d.disabled = false
	dodging = false


func power_up_activation():
	for item : PowerUp in inventory:
		item.use_power_up(self)
		if !item.has_uses_left():
			remove_powerup(item)


var shielded := false
func _on_area_entered(area: Area2D) -> void:
	var bump_direction : Vector2 = global_position.direction_to(area.global_position)
	if area.bumpable:
			area.bump_obstacle_towards(bump_direction, current_level.speed / 10.0)
	if area is PickUp:
		_on_player_hit(area, area.deceleration_on_hit)
		return
	if area is Obstacle:
		area.on_player_hit()
		_on_player_hit(area, area.deceleration_on_hit)


func _on_player_hit(obstacle: Obstacle, deceleration_on_hit: float = current_level.MAX_SPEED):
	crash_sfx.pitch_scale = randf_range(0.8,1.2)
	
	match obstacle.crash_type:
		0: # Dust
			pass
		1: # Mild
			shaker_component_2d.play_shake()
			crash_sfx.play()
			if shielded:
				return
		2: # Serious
			shaker_component_2d.play_shake()
			crash_sfx.play()
			if shielded:
				return
			animation_player.play("crash")
			get_tree().paused = true
			var duration := 5
			for frame in duration:
				await get_tree().process_frame
			get_tree().paused = false
			
			
		3: # Pickup
			add_powerup(obstacle.power_up)
			GameGlobals.add_score(obstacle.score)
			obstacle.on_hit()
			pickup_sfx.play()
	
	current_level.decelerate(deceleration_on_hit)


var inventory : Array[PowerUp]
func add_powerup(item: PowerUp):
	inventory.append(item.duplicate())


func remove_powerup(item: PowerUp):
	if item not in inventory:
		return
	
	inventory.erase(item)


func start_shield(duration: float) -> void:
	shielded = true
	shield_fx.show()
	shield_sfx.play()
	motor_sfx.stop()
	shield_timer.start(duration)


func stop_shield():
	shielded = false
	shield_fx.hide()
	shield_sfx.stop()
	motor_sfx.play()


func _on_speed_changed(new_speed : float):
	motor_sfx.pitch_scale = remap(new_speed, 0, 50, 0.5, 1.2)
