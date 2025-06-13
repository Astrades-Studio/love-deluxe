class_name PowerUp
extends Resource

@export var duration : float
@export var uses : int = 1


func use_power_up(player: PlayerSpaceship):
	if uses <= 0:
		return
	uses -= 1

func has_uses_left() -> bool:
	return uses

func execute(_delta: float):
	pass
