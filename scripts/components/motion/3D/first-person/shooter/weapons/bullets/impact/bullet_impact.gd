class_name BulletImpact extends Node3D

@export var texture: Texture2D = preload("uid://8b3lb0oesw0j")

@onready var impact: GPUParticles3D = $Impact
@onready var timer: Timer = $Timer
@onready var hit_material: StandardMaterial3D = (impact.draw_pass_1 as QuadMesh).surface_get_material(0)


func _ready() -> void:
	if is_instance_valid(timer):
		timer.autostart = false
		timer.one_shot = true
		timer.wait_time = impact.lifetime
		timer.timeout.connect(on_timeout)
	
	hit_material.albedo_texture = texture
	impact.emitting = true
	timer.start()


func on_timeout() -> void:
	queue_free()
