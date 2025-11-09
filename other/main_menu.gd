extends Control

@onready var texture_rect: TextureRect = $TextureRect
@onready var margin_container: CenterContainer = $MarginContainer

func _ready() -> void:
	if Global.show_hello_screen:
		texture_rect.texture = load("res://textures/hello_screen.png")
		margin_container.hide()
	else:
		texture_rect.texture = load("res://textures/main_menu_screen.png")
		margin_container.show()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and Global.show_hello_screen:
		Global.show_hello_screen = false
		texture_rect.texture = load("res://textures/main_menu_screen.png")
		margin_container.show()

func _on_new_game_button_pressed() -> void:
	get_tree().change_scene_to_file("res://level/level.tscn")

func _on_exit_button_pressed() -> void:
	get_tree().quit()
