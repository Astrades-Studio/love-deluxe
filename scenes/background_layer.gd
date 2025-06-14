extends CanvasLayer
class_name BackgroundLayer

@onready var station_sprite: Sprite2D = %StationSprite
@onready var planet: Sprite2D = $Planet
@onready var kuiper_belt: KuiperBelt = %KuiperBelt

#region Planet
const INITIAL_PLANET_SCALE: float = 10.0
const FINAL_PLANET_SCALE: float = 500.0

const INITIAL_PLANET_POSITION: Vector2 = Vector2(116, 108)
const FINAL_PLANET_POSITION: Vector2 = Vector2(57, 48)
#endregion

#region Station
const INITIAL_STATION_SCALE: float = 0.01
const FINAL_STATION_SCALE: float = 0.4


func initialize_background(level_data: LevelData) -> void:
	# Set the initial scale of the planet
	planet.scale = Vector2(INITIAL_PLANET_SCALE, INITIAL_PLANET_SCALE)
	planet.position = INITIAL_PLANET_POSITION

	# Set the initial scale of the station sprite
	station_sprite.scale = Vector2(INITIAL_STATION_SCALE, INITIAL_STATION_SCALE)

	# Set the shader for the planet
	if level_data.planet_shader:
		planet.material = level_data.planet_shader
	else:
		planet.hide()


func update_background(percentage_travelled: float) -> void:
	_update_station_sprite(percentage_travelled)
	_update_planet_sprite(percentage_travelled)
	
	if GameGlobals.current_level == GameGlobals.LevelNumber.URANUS_KUIPER:
		kuiper_belt.update_asteroids(percentage_travelled)


func _update_planet_sprite(percentage_travelled: float) -> void:
	# Calculate the new scale based on the percentage travelled
	# Make the scale slower at first but faster at the end
	var new_scale: float = lerp(INITIAL_PLANET_SCALE, FINAL_PLANET_SCALE, percentage_travelled * percentage_travelled)
	planet.scale = Vector2(new_scale, new_scale)

	# Calculate the new position based on the percentage travelled
	var new_position: Vector2 = lerp(INITIAL_PLANET_POSITION, FINAL_PLANET_POSITION, percentage_travelled)
	planet.position = new_position


func _update_station_sprite(percentage_travelled: float) -> void:
	# Calculate the new scale based on the percentage travelled
	var new_scale: float = lerp(INITIAL_STATION_SCALE, FINAL_STATION_SCALE, percentage_travelled)
	station_sprite.scale = Vector2(new_scale, new_scale)
