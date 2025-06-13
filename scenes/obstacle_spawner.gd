extends Marker2D
class_name ObstacleSpawner

@export_category("Lanes")
@export var horizon_mid_width := 50.0
@export var lane_count := 6

@export_category("Obstacles")
@export var spawn_obstacles := true
#@export var obstacles : Array[PackedScene] = []
@export var obstacles: Array[ObstacleData]
@export var obstacle_container: Node2D
@export var delay_between_obstacles : int = 1500  # Cada 100 km
var next_obstacle_spawn_on : float
var total_obstacle_weight: int = 0

@onready var top_left_marker: Marker2D = $TopLeft
@onready var top_right_marker: Marker2D = $TopRight

@onready var top_left : Vector2 = top_left_marker.global_position
@onready var top_right : Vector2 = top_right_marker.global_position

@export_category("Bounds")
@export var bottom_right : Vector2 = Vector2(256, 240)
@export var bottom_left : Vector2 = Vector2(0, 240)
@export var debug_draw := true

@export_category("Edges")
@export var spawn_signage := true
@export var delay_between_signage : float = 500
var next_signage_spawn_on : float

@export var signage_dict: Array[ObstacleData]
var total_signage_weight: int = 0

var signage_lanes : Array[Lane] = []
var obstacle_lanes : Array[Lane] = []
var bottom_padding := 20.0
var lanes : Array[Lane]

var level : Level:
	set(new_level):
		level = new_level
		next_obstacle_spawn_on = level.target_distance
		next_signage_spawn_on = level.target_distance


class Lane:
	var start: Vector2
	var end: Vector2
	var path: Path2D
	var curve: Curve2D
	var obstacles: Array[Obstacle] = []
	var speed: float = 0.0


func _ready() -> void:
	if debug_draw:
		queue_redraw()
	set_notify_transform(true)
	
	# Calculate the total weight from our obstacle list
	for obstacle_data : ObstacleData in obstacles:
		total_obstacle_weight += obstacle_data.weight
	
	for signage_data : ObstacleData in signage_dict:
		total_signage_weight += signage_data.weight

	lanes = _calculate_lanes()
	#_create_paths(lanes)
	_assign_lanes(lanes)


func _process(_delta: float) -> void:
	if !spawn_obstacles:
		return
	var distance := GameGlobals.level.current_distance
	if spawn_signage:
		_spawn_signage(distance)
	if spawn_obstacles:
		_spawn_obstacles(distance)


func _spawn_signage(_distance : float):
	if next_signage_spawn_on >= _distance:
		next_signage_spawn_on -= delay_between_signage
	
		for lane in signage_lanes:
			var signage_scene : PackedScene = _choose_random_obstacle_based_on_weight(signage_dict, total_signage_weight)
			#: PackedScene = signage_dict[randi() % signage_dict.size()]["scene"]
			var signage := signage_scene.instantiate() as Obstacle
			signage.global_position = (lane.start)
			signage.direction = (lane.end - lane.start).normalized()
			obstacle_container.add_child(signage)


func _spawn_obstacles(_distance : float):
	if next_obstacle_spawn_on >= _distance:
		next_obstacle_spawn_on -= delay_between_obstacles
		
		if obstacle_lanes.size() > 0:
			var lane := obstacle_lanes[randi() % obstacle_lanes.size()]
			_spawn_random_obstacle(lane)


func _spawn_random_obstacle(lane: Lane) -> void:
	var chosen_obstacle_scene : PackedScene = _choose_random_obstacle_based_on_weight(obstacles, total_obstacle_weight)
	# var obstacle_scene : PackedScene = obstacles[randi() % obstacles.size()]["scene"]
	var obstacle : Obstacle = chosen_obstacle_scene.instantiate() as Obstacle
	obstacle.global_position = (lane.start)
	obstacle.direction = (lane.end - lane.start).normalized()
	obstacle_container.add_child(obstacle)
	# print("Spawned obstacle at: ", obstacle.global_position, " in lane with start: ", to_global(lane.start), " and end: ", to_global(lane.end))


func _choose_random_obstacle_based_on_weight(data: Array[ObstacleData], total_weight: int) -> PackedScene:
	if total_weight == 0:
		push_warning("Total obstacle weight is zero. Cannot choose an obstacle.")
		return null

	var random_pick = randi_range(1, total_weight)
	for obstacle_data in data:
		random_pick -= obstacle_data.weight
		if random_pick <= 0:
			return obstacle_data.scene
	
	push_warning("No obstacle found for the random pick: " + str(random_pick))
	return null


## Sets which lanes are for obstacles and which for SIGNAGE
func _assign_lanes(_lanes: Array[Lane]) -> void:
	# Add the first and last lane to the signage lanes
	signage_lanes.append(lanes[0])
	signage_lanes.append(lanes[lanes.size() - 1])
	
	# The rest are the obstacle lanes
	for i in range(1, lanes.size() - 1):
		obstacle_lanes.append(lanes[i])


func _create_paths(_lanes: Array[Lane]):
	var curve := Curve2D.new()

	for lane : Lane in _lanes:
		var path := Path2D.new()
		path.curve = Curve2D.new()
		path.curve.add_point(lane.start)
		path.curve.add_point(lane.end)
		add_child(path)
		lane.path = path
		lane.curve = path.curve


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED and debug_draw:
		top_left = global_position - Vector2(horizon_mid_width, 0)
		top_right = global_position + Vector2(horizon_mid_width, 0)
		queue_redraw()


## Checks the road vertices and amount of lanes and creates lines going from the horizon
## to the bottom of the screen with regular spacing between them.
func _calculate_lanes() -> Array[Lane]:
	var bottom_width := bottom_right.x - bottom_left.x
	var bottom_lane_width := bottom_width / lane_count
	var top_lane_width := horizon_mid_width * 2. / lane_count

	for i in range(lane_count + 1):
		var lane := Lane.new()
		lane.start = to_local(Vector2((global_position.x - horizon_mid_width) + i * top_lane_width, global_position.y))
		lane.end = to_local((bottom_left) + Vector2(i * bottom_lane_width, bottom_padding))
		# print("Lane ", i, " Start: ", to_global(lane.start), " End: ", to_global(lane.end))
		lane.path = Path2D.new()
		lane.curve = Curve2D.new()
		
		lane.curve.add_point(lane.start)
		lane.curve.add_point(lane.end)
		lane.path.curve = lane.curve
		add_child(lane.path)
		
		lanes.append(lane)
	return lanes


func reset_all_variables() -> void:
	lanes.clear()
	obstacle_lanes.clear()
	signage_lanes.clear()
	total_obstacle_weight = 0
	total_signage_weight = 0
	spawn_obstacles = false
	spawn_signage = false


	if debug_draw:
		queue_redraw()


#region Debug Drawing
func _draw() -> void:
	if debug_draw:
		_draw_lanes(lanes)

# Called by the _draw() method to draw the lanes
func _draw_lanes(_lanes: Array[Lane]) -> void:
	for lane in _lanes:
		draw_line(lane.start, lane.end, Color(1, 1, 1, 0.3), 2)
#endregion


func start_spawning() -> void:
	spawn_obstacles = true
	spawn_signage = true


func stop_spawning() -> void:
	spawn_obstacles = false
	spawn_signage = false
