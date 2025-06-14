extends PowerUp
class_name ShieldData


func use_power_up(player: PlayerSpaceship):
	if uses <= 0:
		return
	uses -= 1
	player.start_shield(duration)
		
