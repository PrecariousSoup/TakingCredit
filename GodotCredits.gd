extends Node2D

const section_time := 1.0
const line_time := 0.2
const base_speed := 150
const speed_up_multiplier := 10.0
const title_color := Color.blueviolet

onready var global = get_node("/root/Global")

onready var line := $CreditsContainer/Line

var scroll_speed := base_speed
var speed_up := false

var started := false
var finished := false

var section
var section_next := true
var section_timer := 0.0
var line_timer := 0.0
var curr_line := 0
var lines := []

onready var credits_filename = "res://assets/text/credits.txt"

var base_credits = [
	[
		"A game by Awesome Game Company"
	],[
		"Programming",
		"Programmer Name",
		"Programmer Name 2"
	],[
		"Art",
		"Artist Name"
	],[
		"Music",
		"Musician Name"
	],[
		"Sound Effects",
		"SFX Name"
	],[
		"Testers",
		"Name 1",
		"Name 2",
		"Name 3"
	],[
		"Tools used",
		"Developed with Godot Engine",
		"https://godotengine.org/license",
		"",
		"Art created with My Favourite Art Program",
		"https://myfavouriteartprogram.com"
	],[
		"Special thanks",
		"My parents",
		"My friends",
		"My pet rabbit"
	]
]

var credits = []

var credit_lines_array = []
var credit_labels_array = []

func _ready():
	parse_credits(load_file(credits_filename))
	start()


	#credit_labels_array
	#for i in range(len(new_credits)):

func _process(delta):
	if finished:
		print("finished")

	scroll_speed = base_speed * delta

	if section_next:
		section_timer += delta * speed_up_multiplier if speed_up else delta
		if section_timer >= section_time:
			section_timer -= section_time

			if credits.size() > 0:
				started = true
				section = credits.pop_front()
				curr_line = 0
				add_line()

	else:
		line_timer += delta * speed_up_multiplier if speed_up else delta
		if line_timer >= line_time:
			line_timer -= line_time
			add_line()

	if speed_up:
		scroll_speed *= speed_up_multiplier

	if lines.size() > 0:
		for l in lines:
			l.rect_position.y -= scroll_speed
			if l.rect_position.y < -l.get_line_height():
				lines.erase(l)
				l.queue_free()
	elif started:
		finish()

func start():
	scroll_speed = base_speed
	speed_up = false
	started = false
	finished = false
	credits = copy_credits_array()
	section_next = true
	section_timer = 0.0
	line_timer = 0.0
	curr_line = 0
	lines = []
	credit_labels_array = []
	#finished = false

func copy_credits_array():
	var new_credits = [] + base_credits
	for i in range(len(new_credits)):
		new_credits[i] = [] + base_credits[i]
	return new_credits

func finish():
	if not finished:
		finished = true
		# NOTE: This is called when the credits finish
		# - Hook up your code to return to the relevant scene here, eg...
		#get_tree().change_scene("res://scenes/MainMenu.tscn")
		start()

func update_missing_letters(string):
	var missing = global.get_letters_missing()
	for i in range(len(missing)):
		string = string.replacen(missing[i], "_")
	return string

func add_line():
	var new_line = line.duplicate()
	new_line.text = update_missing_letters(section.pop_front())
	lines.append(new_line)
	if curr_line == 0:
		new_line.add_color_override("font_color", title_color)
	$CreditsContainer.add_child(new_line)
	credit_labels_array.push_back(new_line)

	if section.size() > 0:
		curr_line += 1
		section_next = false
	else:
		section_next = true


# https://godotengine.org/qa/57130/how-to-import-and-read-text
func load_file(file):
	var text_array := []

	var f = File.new()
	f.open(file, File.READ)
	var index = 1
	while not f.eof_reached(): # iterate through all lines until the end of file is reached
		var line = f.get_line()
		#file_text += "\n" + line
		text_array.push_back(line)

		index += 1
	f.close()

	return text_array


func parse_credits(line_array):
	base_credits = []

	var credits_section = []

	for i in range(len(line_array)):
		var line = line_array[i]
		if line == "":
			base_credits.push_back(credits_section)
			credits_section = []
		else:
			credits_section.push_back(line)
			credit_lines_array.push_back(line)

	base_credits.push_back(credits_section)
	print(base_credits)

func _unhandled_input(event):
	pass
	#if event.is_action_pressed("ui_cancel"):
		#finish()
	#if event.is_action_pressed("ui_down") and !event.is_echo():
	#	speed_up = true
	#if event.is_action_released("ui_down") and !event.is_echo():
	#	speed_up = false
