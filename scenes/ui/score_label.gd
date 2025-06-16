extends Label

@export var _text := "Score: "

func _ready() -> void:
	GlobalGameEvents.score_changed.connect(_on_score_changed)
	text = _text + str(GameGlobals.score)
	
func _on_score_changed(new_score : int):
	text = _text + str(new_score)
