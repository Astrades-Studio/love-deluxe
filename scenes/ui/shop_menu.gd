extends CanvasLayer

@onready var dialog_box: DialogueManagerCustomBalloon = %DialogBox

var dialog := preload("res://resources/dialog/shop.dialogue")

func _ready() -> void:
	DialogueManager.show_shop_dialogue_balloon(dialog_box, dialog)
