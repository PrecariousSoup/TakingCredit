extends Node

var letters_missing = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
var extra_chars = ":/().-1234567890©<>"

onready var ui: Node = get_node("/root/MainScene/CanvasLayer/UI")
onready var credits: Node = get_node("/root/MainScene/GodotCredits")

func update_letters_found(letters_found):
	#letters_found += letters
	#print(letters_found)
	for i in range(len(letters_missing)):
		for j in range(len(letters_found)):
			if letters_missing[i] == letters_found[j]:
				letters_missing[i] = "_"

	ui.set_score_text(letters_missing)

	#credits.set_letters_missing(get_letters_missing)

func get_letters_missing():
	var letters = letters_missing.replace("_", "")
	if len(letters) > 0:
		letters += extra_chars

	return letters
