extends CanvasLayer
class_name HUD


@onready var fuel_bar: TextureProgressBar = %FuelBar
@onready var speedometer: TextureProgressBar = %Speedometer
@onready var cash_label: Label = %CashLabel

@onready var planet_texture: TextureRect = %PlanetTexture
@onready var planet_label: Label = %PlanetLabel

@onready var progress_marker: HScrollBar = %ProgressMarker

func _ready() -> void:
	# Connect to the GameGlobals signals to update the HUD when values change
	
	if !GameGlobals.is_node_ready():
		await GameGlobals.ready

	GlobalGameEvents.cash_changed.connect(update_cash)
	GlobalGameEvents.fuel_changed.connect(update_fuel)
	GlobalGameEvents.speed_changed.connect(update_speed)
	GlobalGameEvents.bullets_changed.connect(update_bullet)
	progress_marker.size.y = 8
	
	# Initialize the HUD with the current game state
	update_labels()
	

func update_labels():
	@warning_ignore_start("narrowing_conversion")
	update_planet(GameGlobals.get_current_level_data())
	update_cash(GameGlobals.cash)
	update_bullet(GameGlobals.bullets)
	update_fuel(GameGlobals.get_current_fuel())
	update_speed(GameGlobals.get_current_speed())
	@warning_ignore_restore("narrowing_conversion")

func update_planet(_level_data: LevelData):
	if _level_data.planet_shader:
		planet_texture.texture = PlaceholderTexture2D.new()
		planet_texture.material = _level_data.planet_shader
	else:
		planet_texture.texture = preload("res://scenes/actors/obstacles/t_obstacle_asteroid_large.png")
		planet_texture.material = null
	planet_label.text = _level_data.target_planet_name



func update_fuel(fuel: int):
	fuel_bar.value = fuel


func update_speed(speed: int):
	speedometer.value = speed


func update_cash(cash: int):
	pass
	#cash_label.text = "Cash: %s" % cash


func update_bullet(bullet: int):
	pass


func update_distance_travelled(percentage: float):
	_update_progress_bar(percentage)


func _update_progress_bar(percentage: float) -> void:
	progress_marker.value = percentage * 100
