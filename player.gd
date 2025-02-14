extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		$CameraPivot.rotate_y(-deg_to_rad(event.relative.x))
		$CameraPivot/Camera.rotate_x(deg_to_rad(event.relative.y))
		$CameraPivot/Camera.rotation.x = clamp($CameraPivot/Camera.rotation.x, deg_to_rad(-90), deg_to_rad(45))

func _physics_process(delta):
	if $ShapeCast3D.is_colliding():
		var point = $ShapeCast3D.get_collision_point(0)
		var normal = $ShapeCast3D.get_collision_normal(0)
		
		global_position = point + normal
		
		var newBasis = global_basis
		newBasis.y = normal
		newBasis.x = -newBasis.z.cross(normal)
		newBasis = newBasis.orthonormalized()
		
		if newBasis.determinant() != 0:
			global_basis = newBasis
		
		var input_dir = Input.get_vector("Left", "Right", "Up", "Down")
		
		var forward = $CameraPivot.global_basis.z
		var right = $CameraPivot.global_basis.x
		
		var direction = (forward * input_dir.y + right * input_dir.x).normalized()
		if direction:
			velocity = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.y = move_toward(velocity.y, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
	
	if !$ShapeCast3D.is_colliding():
		velocity += get_gravity() * delta
	elif Input.is_action_pressed("ui_accept"):
		velocity += JUMP_VELOCITY * global_basis.y
	
	move_and_slide()
