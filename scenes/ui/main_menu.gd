extends Control

@onready var new_game_button: Button = %NewGameButton
@onready var continue_button: Button = %ContinueButton
@onready var settings_button: Button = %SettingsButton
@onready var quit_button: Button = %QuitButton
@onready var game_settings_ui: Control = $GameSettingsUI

@export var initial_game_scene : PackedScene

func _ready() -> void:
	new_game_button.pressed.connect(on_new_game_pressed)
	continue_button.pressed.connect(on_continue_pressed)
	settings_button.pressed.connect(on_settings_pressed)
	quit_button.pressed.connect(on_quit_pressed)


func on_new_game_pressed() -> void:
	SceneTransitionManager.transition_to_scene(
		initial_game_scene, 
		true,
	)


func on_continue_pressed() -> void:
	print("Continue button pressed. Implement continue game logic here.")
	#SaveManager.load_savegame(SaveManager.list_of_saved_games[0])


func on_settings_pressed() -> void:
	print("Settings button pressed. Implement settings menu here.")
	game_settings_ui.show()


func on_quit_pressed() -> void:	
	get_tree().quit()
