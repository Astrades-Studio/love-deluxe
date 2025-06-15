extends Node2D
class_name Level

@onready var hud: CanvasLayer = $HUD
@onready var win_overlay: CanvasLayer = $WinOverlay
@onready var game_over_layer: CanvasLayer = $GameOverLayer


@onready var background_layer: BackgroundLayer = $BackgroundLayer
@onready var obstacle_spawner: ObstacleSpawner = %ObstacleSpawner

# Settings ----------------------------------------------------------------- #

@export var level_data : LevelData

# -------------------------------------------------------------------------- #

## How far the ship is from the end of the level
var distance_remaining : int:
	set(new_distance):
		distance_remaining = new_distance
		var _percentage_travelled := get_percentage_travelled()
		background_layer.update_background(_percentage_travelled)
		hud.update_distance_travelled(_percentage_travelled)

# -------------------------------------------------------------------------- #


## Controls how fast everything in the level moves.
var speed := 20.:
	set(new):
		if !using_nitro:
			speed = clamp(new, 1, MAX_SPEED)
		else:
			speed = clamp(new, 1, MAX_NITRO_SPEED)
		GlobalGameEvents.speed_changed.emit(int(speed))

# -------------------------------------------------------------------------- #

## Consumed by driving
var fuel := 100.0:
	set(new):
		fuel = new
		GlobalGameEvents.fuel_changed.emit(int(fuel))
## Fuel consumed per unit of distance
var fuel_consumption_rate := 1.5


# Flags--------------------------------------------------------------------- #

## Flag that controls the process function
var driving := false
var using_nitro := false
# Constants----------------------------------------------------------------- #

const MIN_SPEED := 20.0
const MAX_SPEED := 50.0
const MAX_NITRO_SPEED := 75.0
const FUEL_START := 100.0

# Built-in------------------------------------------------------------------ #

func _ready() -> void:
	GlobalGameEvents.fuel_depleted.connect(_on_fuel_depleted)
	GlobalGameEvents.destination_reached.connect(_on_destination_reached)
	GlobalGameEvents.game_started.connect(obstacle_spawner.start_spawning)
	
	GameGlobals.level = self
	set_up_level()
	start_driving()


func set_up_level() -> void:
	level_data = GameGlobals.get_current_level_data()
	obstacle_spawner.level_data = level_data
	background_layer.initialize_background(level_data)
	

## Increases distance travelled, spends fuel and stops driving when distance is 0
func _process(delta: float) -> void:
	if !driving:
		return

# substract speed from distance remaining

	distance_remaining -= int(speed * delta * 100.0)

	_spend_fuel(delta)
	
	if speed < MIN_SPEED:
		accelerate(0.1)
	
	if distance_remaining < 0:
		obstacle_spawner.stop_spawning()
		await stop_driving()
		GlobalGameEvents.destination_reached.emit()

#region Public ------------------------------------------------------------ #

func start_driving():
	distance_remaining = level_data.target_distance
	driving = true
	GlobalGameEvents.game_started.emit()
	

func stop_driving():
	driving = false
	var tween := create_tween().set_ease(Tween.EASE_IN)
	tween.tween_property(self, "speed", 0.0, (speed / 20.))
	await tween.finished


func get_speed() -> float:
	return speed


func get_percentage_travelled() -> float:
	return (level_data.target_distance - distance_remaining) / float(level_data.target_distance)


func get_distance_remaining() -> int:
	return distance_remaining


func get_distance_travelled() -> int:
	return level_data.target_distance - distance_remaining

#region Speed controls -------------------------------------------------------

func accelerate(amount : float = 0.1) -> void:
	speed += amount
	if speed > MAX_SPEED:
		speed = lerp(speed, MAX_SPEED, 0.1)


func decelerate(amount : float = 0.25) -> void:
	speed -= amount
	if speed < MIN_SPEED:
		speed = lerp(speed, MIN_SPEED, 0.1)
	if speed > MAX_SPEED:
		speed = lerp(speed, MAX_SPEED, 0.1)


## Slowdown is for deceleration effects that trigger continously every frame
var already_applied_slowdown_this_frame := false
func apply_slowdown(amount : float):
	if already_applied_slowdown_this_frame:
		return
	speed = clamp(speed - amount, 5.0, MAX_SPEED)
	already_applied_slowdown_this_frame = true
	_reset_frame_applied_slowdown.call_deferred()

func _reset_frame_applied_slowdown():
	already_applied_slowdown_this_frame = false
	
#endregion --------------------------------------------------------------

#endregion --------------------------------------------------------------

#region Private ---------------------------------------------------------

## Called every second to consume fuel
var time_accumulator = 0.0
func _spend_fuel(delta) -> void:
	time_accumulator += delta
	if time_accumulator >= 1.0:
		time_accumulator -= 1.0  # Keeps the remainder
		_spend_fuel_per_second()


func _spend_fuel_per_second():
	fuel -= fuel_consumption_rate
	if fuel < 0:
		fuel = 0
		await stop_driving()
		GlobalGameEvents.fuel_depleted.emit()


func add_fuel(amount : float):
	fuel += amount
	print(fuel)
	GlobalGameEvents.fuel_changed.emit(fuel)

#endregion --------------------------------------------------------------


func _on_destination_reached() -> void:
	win_overlay.show()
	fuel = FUEL_START


func _on_fuel_depleted():
	game_over_layer.show()
	fuel = FUEL_START
