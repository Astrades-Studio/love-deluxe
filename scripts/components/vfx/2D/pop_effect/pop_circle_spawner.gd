@icon("uid://qp0h88u7r1cm")
class_name PopCircleSpawner extends Node2D

signal spawn_finished

const PopCircleScene: PackedScene = preload("uid://7uexvgan7raf")

@export var amount_of_circles: int = 25
@export var autostart: bool = true


func _ready():
	if autostart:
		spawn()


func spawn():
	for i in range(amount_of_circles):
		add_child(PopCircleScene.instantiate() as PopCircleEffect)

	spawn_finished.emit()
