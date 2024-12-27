extends CharacterBody3D
class_name Spearman

const SPEED = 5.0
const ACCELERATION = 8
const MOUSE_SENSITIVITY = 0.1

@onready var camera = $Camera3D
 
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
 

func _physics_process(delta):
	var direction = Input.get_vector("forward", "back", "right", "left")

	direction = direction.normalized().rotated(-rotation.y)

	velocity.x = lerp(velocity.x, direction.x * SPEED, ACCELERATION * delta)
	velocity.z = lerp(velocity.z, direction.y * SPEED, ACCELERATION * delta)
	
	move_and_slide()
 

func _input(event):
	if event is InputEventMouseMotion:
		camera.rotation.x += -deg_to_rad(event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x , -PI / 2.2, PI / 2.2)
		rotation.y += -deg_to_rad(event.relative.x * MOUSE_SENSITIVITY)
