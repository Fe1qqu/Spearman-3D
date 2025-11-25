extends Control

@onready var sensitivity_slider: HSlider = $BackgroundColorRect/SensitivitySlider
@onready var sensitivity_value_label: Label = $BackgroundColorRect/SensitivitySlider/SensitivityValueLabel

func _ready() -> void:
	sensitivity_slider.value = Settings.mouse_sensitivity
	sensitivity_value_label.text = str(Settings.mouse_sensitivity)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_action_pressed("quit"):
		Settings.save_settings()
		get_tree().change_scene_to_file("res://other/main_menu.tscn")

func _on_sensitivity_slider_value_changed(value: float) -> void:
	Settings.mouse_sensitivity = value
	sensitivity_value_label.text = str(value)
