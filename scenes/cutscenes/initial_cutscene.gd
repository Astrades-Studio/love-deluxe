extends Control

@export var next_scene : PackedScene
@export var dialog : DialogueResource

const CUTSCENE_DIALOG_BOX = preload("res://scenes/ui/cutscene_dialog_box.tscn")
func _ready() -> void:
	get_tree().create_timer(1.5).timeout.connect(start_dialog)


func start_dialog():
	DialogueManager.show_dialogue_balloon_scene(CUTSCENE_DIALOG_BOX, dialog)
	DialogueManager.dialogue_ended.connect(on_cutscene_ended)


func on_cutscene_ended(resource: DialogueResource):
	SceneTransitionManager.transition_to_scene(next_scene)










#
#@onready var text_1: Label = %Text1
#@onready var text_2: Label = %Text2
#@onready var text_3: Label = %Text3
#@onready var text_4: Label = %Text4
#
#@export var next_scene: PackedScene
#
#var playing : bool = true
#var delay_between_texts := 2.0
#var text_duration := 1.0
#
#var current_text_no := 0
#

#
#
#func show_text_animation(text_no: int = 1):
	#playing = true
	#var tween := create_tween()
	#match text_no:
		#1:
			#tween.tween_property(text_1, "modulate:a", 1.0, text_duration).set_ease(Tween.EASE_IN_OUT)
		#2:
			#tween.tween_property(text_1, "modulate:a", 1.0, text_duration).set_ease(Tween.EASE_IN_OUT)
		#3:
			#tween.tween_property(text_1, "modulate:a", 1.0, text_duration).set_ease(Tween.EASE_IN_OUT)
		#4:
			#tween.tween_property(text_1, "modulate:a", 1.0, text_duration).set_ease(Tween.EASE_IN_OUT)
#
	#await tween.finished
	#current_text_no += text_no
	#playing = false
#
#
#
#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("ui_accept"):
		#skip_text()
	#if event.is_action_pressed("ui_cancel"):
		#skip_cutscene()
#
#
#func play_cutscene():
	#pass
#
#
#func skip_text():
	#var tween := create_tween()
	#match current_text_no:
		#1:
			#tween.tween_property(text_1, "modulate:a", 0.0, text_duration).set_ease(Tween.EASE_IN_OUT)	
		#2:
			#tween.tween_property(text_1, "modulate:a", 0.0, text_duration).set_ease(Tween.EASE_IN_OUT)	
		#3:
			#tween.tween_property(text_1, "modulate:a", 0.0, text_duration).set_ease(Tween.EASE_IN_OUT)	
		#4:
			#cutscene_finished()
	#
	#playing = false
	#await tween.finished
	#show_text_animation(current_text_no + 1)
#
#
#func cutscene_finished():
	#playing = false
	#SceneTransitionManager.transition_to_scene(next_scene)
#
#
#func skip_cutscene():
	#cutscene_finished()
