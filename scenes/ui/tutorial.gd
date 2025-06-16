extends Control
class_name Tutorial


@export var _next_scene : PackedScene = preload("uid://bfqb614bysg2o")
@export var __next_scene : float

@onready var speed: Control = %Speed
@onready var distance: Control = %Distance
@onready var fuel: Control = %Fuel
@onready var score: Control = %Score
@onready var controls: Control = %Controls
@onready var obstacles: Control = %Obstacles
@onready var good_luck: Control = %GoodLuck

@onready var messages: Array[Control] = [
	speed, distance, fuel, score, controls, obstacles, good_luck]

var current_message_index: int = 0

func _ready() -> void:
	await GameGlobals.wait(0.5)
	_hide_all_messages()
	show_next_message(current_message_index)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause"):
		GameGlobals.new_game()
		GameGlobals.load_first_level()
	elif event.is_action_pressed("ui_accept") or InputHelper.is_mouse_left_click(event):
		current_message_index += 1
		if current_message_index >= messages.size():
			GameGlobals.new_game()
			GameGlobals.load_first_level()
		else:
			show_next_message(current_message_index)

func _hide_all_messages() -> void:
	for message in messages:
		message.modulate.a = 0.0

func show_next_message(index: int) -> void:
	if index < 0 or index >= messages.size():
		return
	await _animate_transparency(messages[index -1 ], 0.0, 0.5)
	await _animate_transparency(messages[index], 1.0, 0.5)

func _animate_transparency(control: Control, target_alpha: float, duration: float = 0.5) -> void:
	control.show()
	var tween = create_tween()
	tween.tween_property(control, "modulate:a", target_alpha, duration)
	tween.set_ease(Tween.EASE_IN_OUT)
	await tween.finished
