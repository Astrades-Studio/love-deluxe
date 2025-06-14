extends Control

@export var next_scene : PackedScene = Preloader.LevelScene
@export var title : String = "initial_cutscene"
@export var dialog : DialogueResource

const CUTSCENE_DIALOG_BOX = preload("res://scenes/ui/cutscene_dialog_box.tscn")

func _ready() -> void:
	if is_instance_valid(dialog):
		get_tree().create_timer(1.5).timeout.connect(start_dialog)
	else:
		breakpoint


func start_dialog():
	DialogueManager.show_dialogue_balloon_scene(CUTSCENE_DIALOG_BOX, dialog, title)
	DialogueManager.dialogue_ended.connect(on_cutscene_ended)


func on_cutscene_ended(resource: DialogueResource):
	SceneTransitionManager.transition_to_scene(next_scene)
