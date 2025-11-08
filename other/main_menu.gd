extends Control

func _ready() -> void:
	if Global.show_hello_screen:
		$TextureRect.texture = load("res://textures/hello_screen.png")
		$MarginContainer.hide()
	else:
		$TextureRect.texture = load("res://textures/main_menu_screen.png")
		$MarginContainer.show()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and Global.show_hello_screen:
		Global.show_hello_screen = false
		$TextureRect.texture = load("res://textures/main_menu_screen.png")
		$MarginContainer.show()

func _on_new_game_button_pressed() -> void:
	get_tree().change_scene_to_file("res://level/level.tscn")

func _on_exit_button_pressed() -> void:
	get_tree().quit()
