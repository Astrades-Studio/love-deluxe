@tool
extends Path2D

const STAR_SPRITE = preload("res://assets/UI/shapes/triangle/pixel/flecha.png")

var path_follows : Array
@export var speed := 0.05
@export var corner : Vector2
@export var corner_2 : Vector2
@export var active = true

const MIN_SPEED := 0.01
const MAX_SPEED := 0.05


func _ready() -> void:
	path_follows = get_children()
	#active = GameGlobals.level.driving
	#set_paths_offset()

func _process(_delta: float) -> void:
	keep_starts_at_screen_border()
	if !active:
		return
	
	var _speed := 20.
	if !Engine.is_editor_hint():
		_speed = GameGlobals.get_current_speed()
	speed = remap(_speed, 0.0, Level.MAX_SPEED, 0.0, MAX_SPEED)
	
	move_all_paths(speed)

func set_paths_offset():
	var amount_of_paths := get_child_count()
	var offset := 1. / amount_of_paths
	var last_offset := 1.0
	for path : PathFollow2D in path_follows:
		last_offset += offset
		path.progress_ratio += last_offset


func move_all_paths(_speed := 0.05):
	for path : PathFollow2D in path_follows:
		path.progress_ratio -= _speed

func keep_starts_at_screen_border():
	if corner != Vector2.ZERO:
		curve.set_point_position(0, to_local(corner))
		curve.set_point_position(1, to_local(corner_2))
