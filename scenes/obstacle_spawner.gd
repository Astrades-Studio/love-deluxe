extends Marker2D
class_name ObstacleSpawner

@export_category("Lanes")
@export var horizon_mid_width := 50.0
@export var lane_count := 6
@export var obstacle_container: Node2D

@export_category("Obstacles")
@export var spawn_obstacles := true
var next_obstacle_spawn_on : float

@export_category("Bounds")
@export var bottom_right : Vector2 = Vector2(256, 240)
@export var bottom_left : Vector2 = Vector2(0, 240)
@export var debug_draw := true

@export_category("Signage")
@export var spawn_signage := true
var next_signage_spawn_on : float

#@export var signage_dict: Array[ObstacleData]

@export_category("Pickups")
@export var spawn_pickups := true
var pickups: Array[ObstacleData] = []
var next_pickup_spawn_on : float

#region Positions
@onready var top_left_marker: Marker2D = $TopLeft
@onready var top_right_marker: Marker2D = $TopRight
@onready var top_left : Vector2 = top_left_marker.global_position
@onready var top_right : Vector2 = top_right_marker.global_position
#endregion

var signage_lanes : Array[Lane] = []
var obstacle_lanes : Array[Lane] = []
var bottom_padding := 20.0
var lanes : Array[Lane]

var level_data : LevelData:
	set(new_level_data):
		level_data = new_level_data
		next_obstacle_spawn_on = level_data.target_distance
		next_signage_spawn_on = level_data.target_distance
		next_pickup_spawn_on = level_data.target_distance


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

	lanes = _calculate_lanes()
	_assign_lanes(lanes)


func _process(_delta: float) -> void:
	if !spawn_obstacles:
		return

	var distance : int = GameGlobals.get_distance_remaining()

	if spawn_signage:
		_spawn_signage(distance)
	if spawn_obstacles:
		_spawn_obstacles(distance)
	if spawn_pickups:
		_spawn_pickups(distance)


func _spawn_signage(_distance : float):
	if next_signage_spawn_on >= _distance:
		next_signage_spawn_on -= level_data.distance_between_signage

		for lane : Lane in signage_lanes:
			var _random_signage_scene : PackedScene = \
			level_data.get_random_data_from_list(level_data.signage_list,\
			level_data.total_signage_weight).scene
			_spawn_obstacle_on_lane(lane, _random_signage_scene)


func _spawn_obstacles(_distance : float):
	if next_obstacle_spawn_on >= _distance:
		next_obstacle_spawn_on -= level_data.distance_between_obstacles

		if obstacle_lanes.size() > 0:
			var lane := obstacle_lanes[randi() % obstacle_lanes.size()]
			var _random_obstacle_scene : PackedScene = \
			level_data.get_random_data_from_list(level_data.obstacle_list,\
			level_data.total_obstacle_weight).scene
			_spawn_obstacle_on_lane(lane, _random_obstacle_scene)


func _spawn_pickups(_distance : float):
	if next_pickup_spawn_on >= _distance:
		next_pickup_spawn_on -= level_data.distance_between_pickups

		if obstacle_lanes.size() > 0:
			var lane := obstacle_lanes[randi() % obstacle_lanes.size()]
			var _random_pickup_scene : PackedScene = \
			level_data.get_random_data_from_list(level_data.pickup_list,\
			level_data.total_pickup_weight).scene
			_spawn_obstacle_on_lane(lane, _random_pickup_scene)


func _spawn_obstacle_on_lane(lane: Lane, obstacle_scene: PackedScene) -> void:
	if !obstacle_scene:
		push_warning("No obstacle scene provided to spawn.")
		return

	var obstacle : Obstacle = obstacle_scene.instantiate() as Obstacle
	obstacle.global_position = (lane.start)
	obstacle.direction = (lane.end - lane.start).normalized()
	obstacle_container.add_child(obstacle)


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
