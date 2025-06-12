extends CanvasLayer
class_name HUD

#@onready var score_label: Label = %ScoreLabel
@onready var fuel_bar: TextureProgressBar = %FuelBar
@onready var speedometer: TextureProgressBar = %Speedometer

#@onready var cash_label: Label = %CashLabel
#@onready var bullet_label: Label = %BulletLabel
#@onready var label_5: Label = %Label5
#@onready var distance_travelled_label: Label = %DistanceTravelledLabel
#@onready var distance_remaining_label: Label = %DistanceRemainingLabel

@onready var progress_marker: HScrollBar = %ProgressMarker

var level : Level

func _ready() -> void:
	# Connect to the GameGlobals signals to update the HUD when values change
	
	if !GameGlobals.is_node_ready():
		await GameGlobals.ready

	level = GameGlobals.level
	
	GlobalGameEvents.cash_changed.connect(update_cash)
	GlobalGameEvents.bullet_changed.connect(update_bullet)
	# GlobalGameEvents.score_changed.connect(update_score)
	# GameGlobals.connect("distance_travelled_changed", self, "update_distance_travelled")
	# GameGlobals.connect("distance_remaining_changed", self, "update_distance_remaining")
	level = get_tree().get_first_node_in_group("Level")
	level.fuel_changed.connect(update_fuel)
	level.speed_changed.connect(update_speed)
	progress_marker.size.y = 8
	
	# Initialize the HUD with the current game state
	update_labels()
	

func update_labels():
	@warning_ignore_start("narrowing_conversion")
	#update_score(GameGlobals.score)
	update_cash(GameGlobals.cash)
	update_bullet(GameGlobals.bullet)
	update_fuel(level.fuel)
	update_speed(level.speed)
	@warning_ignore_restore("narrowing_conversion")

#func update_score(score: int):
	#score_label.text = "Score: %s" % score


func update_fuel(fuel: int):
	fuel_bar.value = fuel


func update_speed(speed: int):
	speedometer.value = speed


func update_cash(cash: int):
	pass
	#cash_label.text = "Cash: %s" % cash


func update_bullet(bullet: int):
	pass
	#bullet_label.text = "Bullets: %s" % bullet

#
func update_distance_travelled(distance: int):
	_update_progress_bar(distance)
	#distance_travelled_label.text = "Distance Travelled: %s" % distance
	
	#
#
#func update_distance_remaining(distance: int):
	#distance_remaining_label.text = "Distance Remaining: %s" % distance


func _update_progress_bar(distance: int) -> void:
	var initial_value := 0
	var final_value := 100
	var target_distance := level.target_distance
	
	progress_marker.value = remap(distance, 0, target_distance, initial_value, final_value)
