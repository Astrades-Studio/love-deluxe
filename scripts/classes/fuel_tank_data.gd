extends PowerUp
class_name FuelTankData

@export var fuel_amount : float = 10

func use_power_up(player: PlayerSpaceship):
	if uses <= 0:
		return
	uses -= 1
	
	GameGlobals.add_fuel(fuel_amount)

func reset_uses():
	uses = 1
