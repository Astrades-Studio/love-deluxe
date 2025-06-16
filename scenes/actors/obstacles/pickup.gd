class_name PickUp
extends Obstacle


func _ready() -> void:
	super._ready()
	will_give_score = false


func on_hit():
	queue_free()
