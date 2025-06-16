extends Control

@export var _next_scene : PackedScene
@export var title : String = "initial_cutscene"
@export var dialog : DialogueResource
@export var scroll_speed : float = 30.

const CUTSCENE_DIALOG_BOX = preload("res://scenes/ui/cutscene_dialog_box.tscn")

@onready var end_card: Control = $EndCard
@onready var credits: Label = %Credits
@onready var credits_scroll: ScrollContainer = %CreditsScroll
@onready var glorpina: TextureRect = $ColorRect/Glorpina

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var audio_stream_player_2: AudioStreamPlayer = $AudioStreamPlayer2

var end_credits_scrolling := false

func _ready() -> void:
	credits_scroll.scroll_ended.connect(_on_scroll_ended)
	if is_instance_valid(dialog):
		get_tree().create_timer(1.5).timeout.connect(start_dialog)
	else:
		breakpoint


func _process(delta: float) -> void:
	if end_credits_scrolling:
		scroll_credits(delta)

var accumulated_scroll := 0.0
func scroll_credits(delta : float):
	# Scroll the credits text vertically
	accumulated_scroll += delta * scroll_speed  # Adjust speed as needed
	credits_scroll.scroll_vertical = accumulated_scroll
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause"):
		if end_credits_scrolling:
			_on_scroll_ended()
	
	

func start_dialog():
	DialogueManager.show_dialogue_balloon_scene(CUTSCENE_DIALOG_BOX, dialog, title)
	DialogueManager.dialogue_ended.connect(on_cutscene_ended)


func on_cutscene_ended(_resource: DialogueResource):
	# fade out glorpina with a tween
	var tween = create_tween()
	tween.tween_property(glorpina, "modulate:a", 0.0, 1.0)
	tween.set_ease(Tween.EASE_IN_OUT)
	await tween.finished

	# Fade in the end card
	end_card.modulate.a = 0.0
	end_card.show()
	tween.kill()
	tween = create_tween()
	tween.tween_property(end_card, "modulate:a", 1.0, 1.0)
	await tween.finished
	audio_stream_player.stop()
	audio_stream_player_2.play()
	end_credits_scrolling = true


func _on_scroll_ended():
	SceneTransitionManager.transition_to_scene("res://scenes/ui/main_menu.tscn")
