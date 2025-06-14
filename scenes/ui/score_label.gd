extends Label

var _text := "Score: "

func _ready() -> void:
	GlobalGameEvents.score_changed.connect(_on_score_changed)
	
func _on_score_changed(new_score : int):
	text = _text + str(new_score)
