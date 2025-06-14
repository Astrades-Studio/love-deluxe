extends CanvasLayer
class_name WinOverlay


@onready var continue_button: Button = %ContinueButton
@onready var main_menu_button: Button = %MainMenuButton


func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
	continue_button.pressed.connect(_go_to_shop_scene)
	main_menu_button.pressed.connect(_back_to_main_menu)


func _on_visibility_changed(visible: bool) -> void:
	if visible:
		continue_button.grab_focus()


func _go_to_shop_scene():
	SceneTransitionManager.transition_to_scene(Preloader.ShopMenuScene)


func _back_to_main_menu():
	SceneTransitionManager.transition_to_scene(Preloader.MainMenuScene)
