extends Node

@onready var health_label: Label = $Stats/HealthLabel
@onready var speed_label: Label = $Stats/SpeedLabel
@onready var damage_label: Label = $Stats/DamageLabel
@onready var spear_length_label: Label = $Stats/SpearLengthLabel
@onready var items_grid_container: GridContainer = $ItemsGridContainer

const DISPLAY_SCALE: float = 2.0

func update_health(health: int) -> void:
	health_label.text = str(health)

func update_speed(speed: int) -> void:
	speed_label.text = str(int(speed / DISPLAY_SCALE))

func update_damage(damage: int) -> void:
	damage_label.text = str(int(damage / DISPLAY_SCALE))

func update_spear_length(length: int) -> void:
	spear_length_label.text = str(int(length / DISPLAY_SCALE))

func add_item(texture_path: String) -> void:
	var texture: Texture2D = load(texture_path)
	if not texture:
		print("Failed to load texture:", texture_path)
		return
	var item_icon: TextureRect = TextureRect.new()
	item_icon.texture = texture
	items_grid_container.add_child(item_icon)
