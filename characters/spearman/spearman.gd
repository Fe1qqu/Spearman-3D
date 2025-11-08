class_name Spearman
extends CharacterBody3D

var health: int = 3
var speed: int = 12

const ACCELERATION: float = 8.0

var input_rotation_x: float = 0.0
var input_rotation_y: float = 0.0
var current_rotation_x: float = 0.0
var current_rotation_y: float = 0.0

const MOUSE_SENSITIVITY: float = 0.1
const JOYSTICK_SENSITIVITY: float = 0.02
const SMOOTHING: float = 10.0
const MAX_VERTICAL_ANGLE: float = PI / 2.2

@onready var camera = $Camera3D
@onready var spear = $Spear
@onready var hud: Control = $Hud

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	hud.update_health(health)
	hud.update_speed(speed)
	hud.update_damage(spear.damage)
	hud.update_spear_length(spear.lenght)

func _process(delta: float):
	var stick_x = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
	var stick_y = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
	
	if abs(stick_x) > 0 or abs(stick_y) > 0:
		input_rotation_x = -stick_x * JOYSTICK_SENSITIVITY
		input_rotation_y = -stick_y * JOYSTICK_SENSITIVITY
	
	current_rotation_x = lerp(current_rotation_x, input_rotation_x, SMOOTHING * delta)
	current_rotation_y = lerp(current_rotation_y, input_rotation_y, SMOOTHING * delta)
	
	input_rotation_x = 0.0
	input_rotation_y = 0.0
	
	camera.rotation.x += current_rotation_y
	camera.rotation.x = clamp(camera.rotation.x, -MAX_VERTICAL_ANGLE, MAX_VERTICAL_ANGLE)
	rotation.y += current_rotation_x

func _physics_process(delta):
	var direction = Vector2(
		Input.get_action_strength("back") - Input.get_action_strength("forward"),
		Input.get_action_strength("left") - Input.get_action_strength("right")
	).normalized()
	
	direction = direction.rotated(-rotation.y)
	
	velocity.x = lerp(velocity.x, direction.x * speed, ACCELERATION * delta)
	velocity.z = lerp(velocity.z, direction.y * speed, ACCELERATION * delta)
	
	move_and_slide()

func _input(event):
	if event is InputEventMouseMotion:
		input_rotation_x = -deg_to_rad(event.relative.x) * MOUSE_SENSITIVITY
		input_rotation_y = -deg_to_rad(event.relative.y) * MOUSE_SENSITIVITY
	
	if event.is_action_pressed("attack"):
		spear.call("attack")

func take_damage(amount: int) -> void:
	health = max(0, health - amount)
	if health == 0:
		game_over()
	
	hud.update_health(health)

func game_over():
	get_tree().call_deferred("change_scene_to_file", "res://other/game_over.tscn")

func add_health(amount: int = 2):
	health += amount
	hud.update_health(health)

func add_speed(amount: int = 2):
	speed += amount
	hud.update_speed(speed)

func add_damage(amount: int = 4):
	spear.call("set_damage", spear.damage + amount)
	hud.update_damage(spear.damage)

func add_spear_lenght(amount: int = 8):
	spear.lenght += amount
	spear.scale.x += amount / 20.0
	hud.update_spear_length(spear.lenght)

func pick_item(item_type: String):
	match item_type:
		"hearth":
			add_health()
		"lightning":
			add_speed()
		"stick_tape":
			add_spear_lenght()
		"dumbbell":
			add_damage()
		_:
			print("Unknown item type:", item_type)
			return
	
	hud.add_item("res://textures/" + item_type + ".png")
