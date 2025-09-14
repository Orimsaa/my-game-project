extends CharacterBody3D

# Emitted when the player jumped on the mob.
signal squashed

## Minimum speed of the mob in meters per second.
@export var min_speed = 10
## Maximum speed of the mob in meters per second.
@export var max_speed = 18


func _physics_process(_delta):
	move_and_slide()


func initialize(start_position, player_position):
	look_at_from_position(start_position, player_position, Vector3.UP)
	rotate_y(randf_range(-PI / 4, PI / 4))

	var random_speed = randf_range(min_speed, max_speed)
	# We calculate a forward velocity first, which represents the speed.
	velocity = Vector3.FORWARD * random_speed
	# We then rotate the vector based on the mob's Y rotation to move in the direction it's looking.
	velocity = velocity.rotated(Vector3.UP, rotation.y)

	$AnimationPlayer.speed_scale = random_speed / min_speed


func squash():
	# Debug: แสดงข้อความ
	print("Monster squashed! Playing death sound...")
	
	# ลองเล่นเสียงโดยตรงผ่าน AudioServer
	var audio_stream = preload("res://roblox-death-sound-effect.mp3")
	if audio_stream:
		print("Audio stream loaded successfully")
		# สร้าง AudioStreamPlayer ชั่วคราว
		var temp_player = AudioStreamPlayer.new()
		get_tree().current_scene.add_child(temp_player)
		temp_player.stream = audio_stream
		temp_player.volume_db = 10.0
		temp_player.play()
		print("Temporary audio player created and playing")
		
		# ลบ player หลังเสียงเล่นเสร็จ
		temp_player.finished.connect(func(): temp_player.queue_free())
	else:
		print("ERROR: Could not load audio stream")
	
	squashed.emit()
	
	# ซ่อน Monster ทันที
	visible = false
	# ปิดการชน
	$CollisionShape.disabled = true
	
	# รอเวลาสั้นๆ แทนการรอเสียงเสร็จ
	await get_tree().create_timer(1.0).timeout
	queue_free()


func _on_visible_on_screen_notifier_screen_exited():
	queue_free()
