extends Control

func _ready() -> void:
	$AnimationPlayer.play("animation")

func _input(event: InputEvent) -> void:
	if event is InputEventKey and not $AnimationPlayer.is_playing() and event.is_action_pressed("quit"):
		get_tree().quit()
