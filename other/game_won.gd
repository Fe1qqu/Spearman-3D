extends Control

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_action_pressed("quit"):
		get_tree().quit()
