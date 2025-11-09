extends Area3D

@onready var item: Node3D = $Item
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
 
var current_item_name: String

var item_scenes: Dictionary[String, PackedScene] = {
	"dumbbell": preload("res://items/dumbbell.glb"),
	"hearth": preload("res://items/hearth.glb"),
	"lightning": preload("res://items/lightning.glb"),
	"stick_tape": preload("res://items/stick_tape.glb")
}

signal item_picked

func _ready() -> void:
	spawn_random_item()
	animation_player.play("animation")

func spawn_random_item() -> void:
	var item_names: Array[String] = item_scenes.keys()
	current_item_name = item_names[randi() % item_names.size()]
	
	clear_item()
	
	var item_scene: PackedScene = item_scenes[current_item_name]
	var item_instance: Node3D = item_scene.instantiate()
	item.add_child(item_instance)

func clear_item():
	for child in item.get_children():
		child.queue_free()

func _on_spearman_entered(body: Spearman) -> void:
	body.pick_item(current_item_name)
	clear_item()
	collision_shape.set_deferred("disabled", true)
	item_picked.emit()
