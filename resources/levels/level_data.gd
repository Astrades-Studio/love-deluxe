extends Resource
class_name LevelData

@export var level_no := 1
@export var level_name: StringName = "Earth-Mars"
@export var target_distance: int = 120000

var target_planet : ShaderMaterial

@export_enum("Earth", "Mars", "Jupiter", "Neptune", "Uranus", "Kuiper") var target_planet_name : String
@export var planet_shader : ShaderMaterial

@export_category("Obstacles")
@export var obstacle_list : Dictionary[ObstacleData, int] = {}
@export var distance_between_obstacles : int = 1500
var total_obstacle_weight: int = 0

@export_category("Pickups")
@export var pickup_list : Dictionary[ObstacleData, int] = {}
@export var distance_between_pickups: int = 4500
var total_pickup_weight: int = 0

@export_category("Signage")
@export var signage_list : Dictionary[ObstacleData, int] = {}
@export var distance_between_signage: int = 600
var total_signage_weight: int = 0


func _ready():
	assert(!obstacle_list.is_empty())
	total_obstacle_weight = _calculate_total_weight(obstacle_list)	
	
	assert(!pickup_list.is_empty())
	total_pickup_weight = _calculate_total_weight(pickup_list)
	
	assert(!signage_list.is_empty())
	total_signage_weight = _calculate_total_weight(signage_list)

	
func _calculate_total_weight(data_list: Dictionary[ObstacleData, int]) -> int:
	var total_weight := 0
	for data : ObstacleData in data_list:
		total_weight += data_list[data]
	return total_weight


func get_random_data_from_list(data_list: Dictionary[ObstacleData, int], total_weight: int) -> ObstacleData:
	for data : ObstacleData in data_list:
		total_weight += data_list[data]
	
	if total_weight == 0:
		return null
	
	var random_value := randi() % total_weight
	var cumulative_weight := 0
	
	for data : ObstacleData in data_list:
		cumulative_weight += data_list[data]
		if random_value < cumulative_weight:
			return data
	
	return null
