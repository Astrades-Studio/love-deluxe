extends Marker2D
class_name RoadTest

@export_category("Lanes")
@export var horizon_mid_width := 50.0
@export var lane_count := 6

@export_category("Obstacles")
@export var obstacles : Array[PackedScene] = []
@export var obstacle_container: Node2D

@onready var top_left_marker: Marker2D = $TopLeft
@onready var top_right_marker: Marker2D = $TopRight

@onready var top_left : Vector2 = top_left_marker.global_position
@onready var top_right : Vector2 = top_right_marker.global_position

@export_category("Bounds")
@export var bottom_right : Vector2 = Vector2(256, 240)
@export var bottom_left : Vector2 = Vector2(0, 240)
@export var debug_draw := true

var buoy_lanes : Array[Lane] = []
var obstacle_lanes : Array[Lane] = []
var bottom_padding := 20.0
var lanes : Array[Lane]


class Lane:
	var start: Vector2
	var end: Vector2
	var path: Path2D
	var curve: Curve2D
	var obstacles: Array[Obstacle] = []
	var speed: float = 0.0


func _ready() -> void:
	queue_redraw()
	set_notify_transform(true)
	
	lanes = _calculate_lanes()
	create_paths(lanes)
	assign_lanes(lanes)


var delay_between_obstacles : float = 2.0
var MAX_DELAY_BETWEEN_OBSTACLES := 2.0

func _process(_delta: float) -> void:
	delay_between_obstacles -= _delta
	if delay_between_obstacles <= 0.0:
		delay_between_obstacles = MAX_DELAY_BETWEEN_OBSTACLES
		if obstacle_lanes.size() > 0:
			var lane := obstacle_lanes[randi() % obstacle_lanes.size()]
			spawn_random_obstacle(lane)


func spawn_random_obstacle(lane: Lane) -> void:
	var obstacle := obstacles[randi() % obstacles.size()].instantiate()
	obstacle.global_position = to_global(lane.start)
	obstacle.direction = (lane.end - lane.start).normalized()
	obstacle_container.add_child(obstacle)
	print("Spawned obstacle at: ", obstacle.global_position, " in lane with start: ", to_global(lane.start), " and end: ", to_global(lane.end))



func assign_lanes(_lanes: Array[Lane]) -> void:
	# Add the first and last lane to the buoy lanes
	buoy_lanes.append(lanes[0])
	buoy_lanes.append(lanes[lanes.size() - 1])
	
	# The rest are the obstacle lanes
	for i in range(1, lanes.size() - 1):
		obstacle_lanes.append(lanes[i])
		print("Obstacle Lane ", i, " Start: ", to_global(lanes[i].start), " End: ", to_global(lanes[i].end))


func create_paths(_lanes: Array[Lane]):
	var curve := Curve2D.new()

	for lane : Lane in _lanes:
		var path := Path2D.new()
		path.curve = Curve2D.new()
		path.curve.add_point(lane.start)
		path.curve.add_point(lane.end)
		add_child(path)
		lane.path = path
		lane.curve = path.curve
		print("Created path for lane with start: ", lane.start, " and end: ", lane.end)
	

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED and debug_draw:
		top_left = global_position - Vector2(horizon_mid_width, 0)
		top_right = global_position + Vector2(horizon_mid_width, 0)
		print("Top Left: ", top_left, " Top Right: ", top_right)
		queue_redraw()


func _calculate_lanes() -> Array[Lane]:
	var bottom_width := bottom_right.x - bottom_left.x
	var bottom_lane_width := bottom_width / lane_count
	var top_lane_width := horizon_mid_width * 2. / lane_count

	
	for i in range(lane_count + 1):
		var lane := Lane.new()
		lane.start = to_local(Vector2((global_position.x - horizon_mid_width) + i * top_lane_width, global_position.y))
		lane.end = to_local((bottom_left) + Vector2(i * bottom_lane_width, bottom_padding))
		print("Lane ", i, " Start: ", to_global(lane.start), " End: ", to_global(lane.end))
		lane.path = Path2D.new()
		lane.curve = Curve2D.new()
		
		lane.curve.add_point(lane.start)
		lane.curve.add_point(lane.end)
		lane.path.curve = lane.curve
		add_child(lane.path)
		
		lanes.append(lane)
	return lanes


#region Debug Drawing
func _draw() -> void:
	_draw_lanes(lanes)

# Called by the _draw() method to draw the lanes
func _draw_lanes(lanes: Array[Lane]) -> void:
	for lane in lanes:
		draw_line(lane.start, lane.end, Color(1, 1, 1, 0.3), 2)
#endregion

# Debug printing
	#print( "Bottom Left: ", bottom_left, " Bottom Right: ", bottom_right)
	#print("Bottom Width: ", bottom_width)
	#print("Bottom Lane Width: ", bottom_lane_width)
	#print("Top Lane Width: ", top_lane_width)
