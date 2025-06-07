# Duracion del nivel a velocidad maxima: 2 min
# Duracion del nivel a velocidad minima: 5 min
# Duracion del combustible: 4 min

# Velocidad minima: 1 ly / 10y 
# Velocidad maxima: 2.5 ly / 10y

# Distancia a recorrer: 300 AU

# Distancia entre Tierra y Luna en unidades astronómicas: 384400 km / 0.00256 AU
extends Node2D
class_name Level

@onready var hud: CanvasLayer = $HUD
@onready var win_overlay: CanvasLayer = $WinOverlay

@export var target_distance := 120000.

var current_distance : float:
	set(new):
		current_distance = new
		hud.update_distance_travelled(int(target_distance - current_distance))
		hud.update_distance_remaining(int(current_distance))

# Speed and fuel management
var speed := 20.:
	set(new):
		speed = clamp(new, 0, 99)
		speed_changed.emit(int(speed))

var fuel := 400.0:
	set(new):
		fuel = new
		fuel_changed.emit(int(fuel))

signal speed_changed(speed: float)
signal fuel_changed(fuel: int)
# ------------------------------

var driving := false

const MIN_SPEED := 20.0
const MAX_SPEED := 50.0
const FUEL_START := 1000.0


var fuel_consumption_rate := 0.1  # Fuel consumed per unit of distance


func _ready() -> void:
	current_distance = target_distance
	hud.level = self
	GlobalGameEvents.destination_reached.connect(on_destination_reached)
	GameGlobals.level = self
	start_driving()


func on_destination_reached() -> void:
	win_overlay.visible = true
	fuel = FUEL_START
	
	# Stop driving and reset speed
	stop_driving()
	
func start_driving():
	driving = true

func stop_driving():
	driving = false
	speed = 0.0


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


func spend_fuel(delta) -> void:
	fuel -= fuel_consumption_rate * speed * delta

	if fuel < 0:
		fuel = 0
		stop_driving()
		GlobalGameEvents.fuel_depleted.emit()

func get_speed() -> float:
	return speed	

func accelerate(amount : float = 0.1) -> void:
	speed += amount
	
	if speed > MAX_SPEED:
		speed = lerp(speed, MAX_SPEED, 0.1)
	print(speed)

func decelerate(amount : float = 0.25) -> void:
	speed -= amount
	if speed < MIN_SPEED:
		speed = lerp(speed, MIN_SPEED, 0.1)
	if speed > MAX_SPEED:
		speed = lerp(speed, MAX_SPEED, 0.1)
	print(speed)
