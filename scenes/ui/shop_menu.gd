extends CanvasLayer

@onready var dialog_box: DialogueManagerCustomBalloon = %DialogBox

var dialog := preload("res://resources/dialog/cutscenes.dialogue")

func _ready() -> void:
	DialogueManager.show_shop_dialogue_balloon(dialog_box, dialog, "shop")
