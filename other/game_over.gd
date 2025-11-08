extends Control

func _ready() -> void:
	$AnimationPlayer.play("animation")

func _input(event: InputEvent) -> void:
	if event is InputEventKey and not $AnimationPlayer.is_playing() and event.is_action_pressed("quit"):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			get_tree().change_scene_to_file("res://other/main_menu.tscn")
