@icon("uid://bcjjojntjp0fh")
class_name FireArmWeaponMotion extends Node3D


func enable() -> void:
	set_physics_process(true)
	
	
func disable() -> void:
	set_physics_process(false)


func is_enabled() -> bool:
	return is_physics_processing()


func is_disabled() -> bool:
	return not is_physics_processing()
