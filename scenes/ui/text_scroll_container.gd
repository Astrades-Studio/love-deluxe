@tool
extends ScrollContainer

var scroll_progress := 0
@export var skip_every := 2


func _process(_delta: float) -> void:
	if !self.ready:
		return
	_scroll_text()

func _scroll_text():
	scroll_progress += 1
	var last_scroll_value = scroll_horizontal
	if scroll_progress % skip_every:
		scroll_horizontal += 1
		if scroll_horizontal == last_scroll_value and last_scroll_value != 0:
			scroll_horizontal = 0
			
	
