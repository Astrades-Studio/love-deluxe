extends Obstacle
class_name Cloud

var first_cloud := true
var spawning_clouds := false


func use_close_sprite():
	obstacle_large.show()
	obstacle_small.hide()
	
	if first_cloud:
		start_spawning_trailing_clouds()


func use_far_away_sprite():
	obstacle_large.z_index = 2
	obstacle_small.z_index = -1
	obstacle_large.hide()
	obstacle_small.show()

const DELAY_FRAMES := 5.0 

var delay_frame_count := DELAY_FRAMES


func start_spawning_trailing_clouds():
	if not first_cloud:
		return
	spawning_clouds = true


func _process(delta):
	super._process(delta)
	
	if spawning_clouds:
		delay_frame_count -= 1
		var spawn_count :=1
		if delay_frame_count <= 0:
			delay_frame_count = DELAY_FRAMES
			var cloud : Cloud = self.duplicate()
			get_parent().add_child(cloud)
			cloud.name = "TrailingCloud"
			cloud.first_cloud = false
			cloud.direction = direction
			cloud.position = position - direction * DELAY_FRAMES
			cloud.crash_type = 0
			cloud.use_close_sprite()
			spawn_count += 1
			cloud.rotate(randf_range(0.0, TAU))
	
	var areas := get_overlapping_areas()
	for area in areas:
		if area is PlayerSpaceship:
			GameGlobals.get_current_level().apply_slowdown(deceleration_on_hit)
		
