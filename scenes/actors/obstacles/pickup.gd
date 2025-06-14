class_name PickUp
extends Obstacle


func _ready() -> void:
	will_give_score = false


func on_hit():
	queue_free()
