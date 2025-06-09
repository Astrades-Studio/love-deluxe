class_name PauseLayer extends Control

@onready var back_button: Button = %ResumeButton
@onready var restart_button: Button = %RestartButton
@onready var settings_button: Button = %SettingsButton
@onready var quit_game_button: Button = %QuitGameButton

@export var open_input_action: StringName = InputControls.PauseGame

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed(open_input_action):
		visible = !visible


func _ready() -> void:
	back_button.grab_focus()
	restart_button.pressed.connect(on_restart_pressed)
	settings_button.pressed.connect(on_settings_pressed)
	quit_game_button.pressed.connect(on_quit_game_pressed)
	visibility_changed.connect(on_pause_menu_visibility_changed)

	process_mode = PROCESS_MODE_ALWAYS
	z_index = 1000

	hide()
#	settings_menu.hide()
#	settings_menu.z_index = z_index + 1

#	save_name_label.text = SaveManager.current_saved_game.display_name if SaveManager.current_saved_game else ""

	#SaveManager.created_savegame.connect(on_loaded_savegame)
	#SaveManager.loaded_savegame.connect(on_loaded_savegame)
	#
	#settings_menu.visibility_changed.connect(on_settings_menu_visibility_changed)
	#settings_button.pressed.connect(on_settings_button_pressed)
	#quit_game_button.pressed.connect(on_quit_game_button_pressed)


func on_pause_menu_visibility_changed() -> void:
	if visible:
		settings_button.grab_focus()

	get_tree().paused = visible

func on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func on_settings_pressed() -> void:
	pass


func on_quit_game_pressed() -> void:
	get_tree().quit()
