extends KinematicBody2D

var score: int = 0

const SPEED = 200
const JUMP_POWER = -400
const GRAVITY = 800
const ATTACKFRAME = 1

const MAGICMISSILE = preload("res://MagicMissile.tscn")

const ROOM_LETTERS = [
	"ABCDE",
	"FGHIJ",
	"KLMON",
	"OPQRS",
	"TUVW",
	"XYZ"
]

var velocity: Vector2 = Vector2()

const ROOM_OFFSET = -200 * 3

onready var global = get_node("/root/Global")

onready var rooms_node = get_node("/root/MainScene/ViewportContainer/Rooms")
onready var room_array = [
	get_node("/root/MainScene/ViewportContainer/Rooms/Room1"),
	get_node("/root/MainScene/ViewportContainer/Rooms/Room2"),
	get_node("/root/MainScene/ViewportContainer/Rooms/Room3"),
	get_node("/root/MainScene/ViewportContainer/Rooms/Room4"),
	get_node("/root/MainScene/ViewportContainer/Rooms/Room5"),
	get_node("/root/MainScene/ViewportContainer/Rooms/Room6")
]
onready var audioPlayer: Node = get_node("/root/MainScene/Camera2D/AudioPlayer")
onready var musicPlayer: Node = get_node("/root/MainScene/Camera2D/MusicPlayer")

var victory_music_track = "res://assets/audio/joshua-mclean_celebrate.ogg"

var on_ground = false
var is_firing = false

func _ready():
	get_node("/root/MainScene/WinnerLabel").hide()
	global.update_letters_found("")
	for i in range(len(room_array)):
		var cage = room_array[i].get_node("Cage")
		cage.letters = ROOM_LETTERS[i]
		cage.roomId = i + 1
	goto_room(0)

func _physics_process(delta):
	# movement inputs here
	if not is_firing:
		if Input.is_action_pressed("ui_left"):
			velocity.x = -SPEED
			$AnimatedSprite.play("run")
			if sign($Position2D.position.x) == 1:
				$Position2D.position.x *= -1
		elif Input.is_action_pressed("ui_right"):
			velocity.x = SPEED
			$AnimatedSprite.play("run")
			if sign($Position2D.position.x) == -1:
				$Position2D.position.x *= -1
		else:
			velocity.x = 0
			if on_ground == true:
				$AnimatedSprite.play("idle")

		# jump input
		if Input.is_action_just_pressed("jump") and on_ground:
			velocity.y = JUMP_POWER
			on_ground = false

		if Input.is_action_just_pressed("attack"):
			if on_ground:
				fireball_start()

		# GRAVITY
		velocity.y += GRAVITY * delta

		if is_on_floor():
			on_ground = true
		else:
			on_ground = false
			if velocity.y < 0:
				$AnimatedSprite.play("jump")
			else:
				$AnimatedSprite.play("fall")

		# sprite direction
		if velocity.x < 0:
			$AnimatedSprite.flip_h = true
		elif velocity.x > 0:
			$AnimatedSprite.flip_h = false

		# applying the velocity
		velocity = move_and_slide(velocity, Vector2.UP)


func die():
	get_tree().reload_current_scene()

func fireball_start():
	is_firing = true
	audioPlayer.play()
	$AnimatedSprite.play("attack")

func fireball_end():
	if is_firing:
		var magic_missile = MAGICMISSILE.instance()
		if sign($Position2D.position.x) == 1:
			magic_missile.set_fireball_direction(1)
		else:
			magic_missile.set_fireball_direction(-1)
		get_parent().add_child(magic_missile)
		magic_missile.global_position = $Position2D.global_position
		magic_missile.get_node("AnimatedSprite").play("shoot")


func collect_coin(value):
	score += value
	#global.update_letters_found(score)
	audioPlayer.play_coin_sfx()

func goto_next_room(current_room_index):
	var next_room_index
	if current_room_index < len(room_array) - 1:
		next_room_index = current_room_index + 1
		var offset = ROOM_OFFSET * next_room_index
		rooms_node.position.x = offset

		goto_room(next_room_index)
	else:
		end()



func goto_room(room_index):
	var room = room_array[room_index]

	var player = rooms_node.get_node("Player")
	var player_start = room.get_node("PlayerStart")
	var player_start_x = player_start.position.x + room.position.x
	var player_start_y = player_start.position.y + room.position.y
	player.position.x = player_start_x
	player.position.y = player_start_y

func _on_Cage_cage_destroyed(room_id, letters_found):
	#set_letters_as_found(letters_found)
	global.update_letters_found(letters_found)
	goto_next_room(room_id - 1)

func _on_AnimatedSprite_animation_finished():
	if is_firing:
		is_firing = false

func _on_AnimatedSprite_frame_changed():
	if is_firing and $AnimatedSprite.frame == ATTACKFRAME:
		fireball_end()

func end():
	get_node("/root/MainScene/WinnerLabel").show()
	var new_track = load(victory_music_track)
	musicPlayer.stream = new_track
	musicPlayer.play()
	pass
