class_name ObstacleData
extends Resource


@export_category("Obstacle Data")
@export var scene: PackedScene
@export var weight: int = 1
@export var name: String = "Obstacle"
@export var lane: int = -1  # -1 means any lane
@export var cooldown: int = 0  # Cooldown time in distance units
@export var score: int = 100  # Score awarded 
