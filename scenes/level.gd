extends Node2D
class_name Level

@onready var hud: CanvasLayer = $HUD
@onready var win_overlay: CanvasLayer = $WinOverlay
@onready var continue_button: Button = %ContinueButton
@onready var main_menu_button: Button = %MainMenuButton
@onready var station_sprite: Sprite2D = %StationSprite
@onready var moving_stars: GPUParticles2D = %MovingStars

@export var target_distance := 120000.

var current_distance : float:
	set(new):
		current_distance = new
		update_station_sprite(current_distance)
		hud.update_distance_travelled(int(target_distance - current_distance))
		#hud.update_distance_remaining(int(current_distance))

## Controls how fast everything in the level moves.
var speed := 20.:
	set(new):
		speed = clamp(new, 0, 99)
		speed_changed.emit(int(speed))

## Consumed by driving
var fuel := 100.0:
	set(new):
		fuel = new
		fuel_changed.emit(int(fuel))

signal speed_changed(speed: float)
signal fuel_changed(fuel: int)
# ------------------------------

var driving := false

const MIN_SPEED := 20.0
const MAX_SPEED := 50.0
const FUEL_START := 100.0


var fuel_consumption_rate := 0.8  # Fuel consumed per unit of distance


func _ready() -> void:
	current_distance = target_distance
	hud.level = self
	GlobalGameEvents.destination_reached.connect(on_destination_reached)
	continue_button.pressed.connect(go_to_shop_scene)
	main_menu_button.pressed.connect(back_to_main_menu)
	GameGlobals.level = self
	moving_stars.level = self
	start_driving()


func on_destination_reached() -> void:
	win_overlay.visible = true
	fuel = FUEL_START
	stop_driving()
	
	
func start_driving():
	driving = true

func stop_driving():
	driving = false
	#speed = lerp(speed, 0.0, 0.1)
	var tween := create_tween().set_ease(Tween.EASE_IN)
	tween.tween_property(self, "speed", 0.0, (speed / 10.))
	await tween.finished

## Increases distance travelled, spends fuel and stops driving when distance is 0
func _process(delta: float) -> void:
	if !driving:
		return
	current_distance -= speed
	spend_fuel(delta)
	
	if speed < MIN_SPEED:
		accelerate(0.1)
	
	if current_distance < 0:
		stop_driving()
		GlobalGameEvents.destination_reached.emit()

## Called every frame to consume fuel
var time_accumulator = 0.0
func spend_fuel(delta) -> void:
	time_accumulator += delta
	if time_accumulator >= 1.0:
		time_accumulator -= 1.0  # Keep the remainder
		spend_fuel_per_second()  # Call your function


func spend_fuel_per_second():
	fuel -= fuel_consumption_rate
	if fuel < 0:
		fuel = 0
		stop_driving()
		GlobalGameEvents.fuel_depleted.emit()


func get_speed() -> float:
	return speed	


#region Speed controls
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

var already_applied_slowdown_this_frame := false
func apply_slowdown(amount : float):
	if already_applied_slowdown_this_frame:
		return
	speed -= amount
	already_applied_slowdown_this_frame = true
	reset_frame_applied_slowdown.call_deferred()

func reset_frame_applied_slowdown():
	already_applied_slowdown_this_frame = false

#endregion

func update_station_sprite(current_distance):
	var new_scale : float = remap(current_distance, target_distance, 0.0, 0.01, 0.4)
	station_sprite.scale = Vector2(new_scale, new_scale)


const SHOP_MENU = preload("res://scenes/ui/shop_menu.tscn")
func go_to_shop_scene():
	SceneTransitionManager.transition_to_scene(SHOP_MENU)


const MAIN_MENU = preload("res://scenes/ui/main_menu.tscn")
func back_to_main_menu():
	SceneTransitionManager.transition_to_scene(MAIN_MENU)


func restart_level():
	get_tree().reload_current_scene()
