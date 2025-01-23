extends Control

var hello_screen_active: bool = true

func _ready() -> void:
	$TextureRect.texture = load("res://textures/hello_screen.png")
	$CenterContainer.hide()


func _input(event: InputEvent) -> void:
	if (event is InputEventKey or event is InputEventMouseButton) and event.pressed and hello_screen_active:
		$TextureRect.texture = load("res://textures/main_menu_screen.png")
		$CenterContainer.show()


func _on_new_game_button_pressed() -> void:
	get_tree().change_scene_to_file("res://level/level.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()
