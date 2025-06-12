extends Node2D
class_name Level

@onready var hud: CanvasLayer = $HUD
@onready var win_overlay: CanvasLayer = $WinOverlay
@onready var continue_button: Button = %ContinueButton
@onready var main_menu_button: Button = %MainMenuButton
@onready var station_sprite: Sprite2D = %StationSprite
@onready var obstacle_spawner: ObstacleSpawner = %ObstacleSpawner

@export var target_distance := 120000

# -------------------------------------------------------------------------- #

## How far the ship is from the end of the level
var current_distance : int:
	set(new):
		current_distance = new
		_update_station_sprite(current_distance)
		hud.update_distance_travelled(int(target_distance - current_distance))

# -------------------------------------------------------------------------- #

## Controls how fast everything in the level moves.
var speed := 20.:
	set(new):
		speed = clamp(new, 0, 99)
		speed_changed.emit(int(speed))

# -------------------------------------------------------------------------- #

## Consumed by driving
var fuel := 100.0:
	set(new):
		fuel = new
		fuel_changed.emit(int(fuel))
## Fuel consumed per unit of distance
var fuel_consumption_rate := 0.8

# Signals ------------------------------------------------------------------ #

signal speed_changed(speed: float)
signal fuel_changed(fuel: int)

# Flags--------------------------------------------------------------------- #

## Flag that controls the process function
var driving := false

# Constants----------------------------------------------------------------- #

const MIN_SPEED := 20.0
const MAX_SPEED := 50.0
const FUEL_START := 100.0

# Built-in------------------------------------------------------------------ #

func _ready() -> void:
	hud.level = self
	GlobalGameEvents.destination_reached.connect(_on_destination_reached)
	GlobalGameEvents.game_started.connect(obstacle_spawner.start_spawning)
	continue_button.pressed.connect(_go_to_shop_scene)
	main_menu_button.pressed.connect(_back_to_main_menu)
	GameGlobals.level = self
	obstacle_spawner.level = self
	start_driving()


## Increases distance travelled, spends fuel and stops driving when distance is 0
func _process(delta: float) -> void:
	if !driving:
		return
	current_distance -= speed
	_spend_fuel(delta)
	
	if speed < MIN_SPEED:
		accelerate(0.1)
	
	if current_distance < 0:
		stop_driving()
		GlobalGameEvents.destination_reached.emit()

#region Public ------------------------------------------------------------ #

func start_driving():
	current_distance = target_distance
	driving = true
	GlobalGameEvents.game_started.emit()
	

func stop_driving():
	driving = false
	var tween := create_tween().set_ease(Tween.EASE_IN)
	tween.tween_property(self, "speed", 0.0, (speed / 20.))
	await tween.finished


func get_speed() -> float:
	return speed

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
	speed -= amount
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
		stop_driving()
		GlobalGameEvents.fuel_depleted.emit()


func _on_destination_reached() -> void:
	win_overlay.visible = true
	fuel = FUEL_START
	stop_driving()


## Makes the station in the distance bigger the closer we are
func _update_station_sprite(current_distance: int) -> void:
	var new_scale : float = remap(current_distance, target_distance, 0.0, 0.01, 0.4)
	station_sprite.scale = Vector2(new_scale, new_scale)


func _go_to_shop_scene():
	SceneTransitionManager.transition_to_scene(Preloader.ShopMenuScene)


func _back_to_main_menu():
	SceneTransitionManager.transition_to_scene(Preloader.MainMenuScene)


func restart_level():
	get_tree().reload_current_scene()

#endregion --------------------------------------------------------------
