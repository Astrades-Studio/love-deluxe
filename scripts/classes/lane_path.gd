class_name LanePath extends Path2D

@export var start : Vector2
@export var end : Vector2
@export var reference_curve: Curve2D

func _ready() -> void:
	# Initialize the path with the start and end points
	var _curve := Curve2D.new()
	_curve.add_point(start)
	_curve.add_point(end)
	self.curve = curve


