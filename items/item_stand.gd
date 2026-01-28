class_name ItemStand
extends Area3D

@onready var item: Node3D = $Item
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
 
@export var scene_database: SceneDatabase
@export var available_items: Array[ItemType.Item] = []

var current_item_type: ItemType.Item

signal item_picked


func _ready() -> void:
	if scene_database == null:
		push_error("[ItemStand] scene_database is not assigned.")
		return
	
	if available_items.is_empty():
		push_error("[ItemStand] available_items is empty.")
		return
		
	spawn_random_item()
	animation_player.play("animation")


func spawn_random_item() -> void:
	current_item_type = available_items.pick_random()
	
	clear_item()
	
	var item_instance: Node3D = scene_database.get_item(current_item_type).instantiate()
	item.add_child(item_instance)


func clear_item():
	for child in item.get_children():
		child.queue_free()


func _on_spearman_entered(body: Spearman) -> void:
	body.pick_item(current_item_type)
	clear_item()
	collision_shape.set_deferred("disabled", true)
	item_picked.emit()
