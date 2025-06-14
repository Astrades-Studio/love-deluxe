extends CanvasLayer
class_name GameOverLayer

@onready var retry_button: Button = %RetryButton
@onready var main_menu_button_2: Button = %MainMenuButton2


func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
	retry_button.pressed.connect(restart_level)
	main_menu_button_2.pressed.connect(_back_to_main_menu)


func restart_level():
	GameGlobals.reset_score()
	get_tree().reload_current_scene()


func _back_to_main_menu():
	SceneTransitionManager.transition_to_scene(Preloader.MainMenuScene)


func _on_visibility_changed() -> void:
	if visible:
		retry_button.grab_focus()
