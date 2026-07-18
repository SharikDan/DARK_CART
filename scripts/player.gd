extends CharacterBody3D

const SPEED = 5.0
const MOUSE_SENSITIVITY = 0.003
const ACCELERATION = 0.1
const FRICTION = 0.15

var camera: Camera3D
var _yaw = 0.0
var _pitch = 0.0

func _ready():
	camera = $Camera3D
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	# Handle movement input
	var input_dir = Vector3.ZERO
	if Input.is_action_pressed("ui_up"):
		input_dir.z -= 1
	if Input.is_action_pressed("ui_down"):
		input_dir.z += 1
	if Input.is_action_pressed("ui_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("ui_right"):
		input_dir.x += 1
	
	if input_dir != Vector3.ZERO:
		input_dir = input_dir.normalized()
		velocity.x = lerp(velocity.x, input_dir.x * SPEED, ACCELERATION)
		velocity.z = lerp(velocity.z, input_dir.z * SPEED, ACCELERATION)
	else:
		velocity.x = lerp(velocity.x, 0.0, FRICTION)
		velocity.z = lerp(velocity.z, 0.0, FRICTION)
	
	# Apply gravity
	velocity.y -= 9.8 * delta
	
	move_and_slide()
	
	# Toggle mouse capture with ESC
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_yaw -= event.relative.x * MOUSE_SENSITIVITY
		_pitch -= event.relative.y * MOUSE_SENSITIVITY
		_pitch = clamp(_pitch, -PI/2, PI/2)
		
		var camera_basis = Basis()
		camera_basis = camera_basis.rotated(Vector3.UP, _yaw)
		camera_basis = camera_basis.rotated(camera_basis.x, _pitch)
		
		camera.set_global_basis(camera_basis)
