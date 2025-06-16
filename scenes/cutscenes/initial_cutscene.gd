extends Control

@export var _next_scene : PackedScene
@export var title : String = "initial_cutscene"
@export var dialog : DialogueResource

const CUTSCENE_DIALOG_BOX = preload("res://scenes/ui/cutscene_dialog_box.tscn")

func _ready() -> void:
	MusicManager.play_music_from_bank("Summer")
	if is_instance_valid(dialog):
		get_tree().create_timer(1.5).timeout.connect(start_dialog)
	else:
		breakpoint


func start_dialog():
	DialogueManager.show_dialogue_balloon_scene(CUTSCENE_DIALOG_BOX, dialog, title)
	DialogueManager.dialogue_ended.connect(on_cutscene_ended)


func on_cutscene_ended(_resource: DialogueResource):
	SceneTransitionManager.transition_to_scene(_next_scene)
