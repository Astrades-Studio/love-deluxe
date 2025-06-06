# Duracion del nivel a velocidad maxima: 2 min
# Duracion del nivel a velocidad minima: 5 min
# Duracion del combustible: 4 min

# Velocidad minima: 1 ly / 10y 
# Velocidad maxima: 2.5 ly / 10y

# Distancia a recorrer: 300 AU

# Distancia entre Tierra y Luna en unidades astronómicas: 384400 km / 0.00256 AU
extends Node2D
class_name Level

@export var distance := 300.

static var speed: = 20.

const MIN_SPEED := 20.0
const MAX_SPEED := 50.0

static func accelerate(amount : float = 0.25) -> void:
	speed += amount
	if speed < MIN_SPEED:
		speed = MIN_SPEED
	if speed > MAX_SPEED:
		speed = MAX_SPEED
	print(speed)

static func decelerate(amount : float = 0.25) -> void:
	speed -= amount
	if speed < MIN_SPEED:
		speed = MIN_SPEED
	if speed > MAX_SPEED:
		speed = MAX_SPEED
	print(speed)
