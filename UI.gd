extends Control

onready var scoreText = get_node("ScoreText")

func _ready():
	scoreText.text = ""

func set_score_text(score):
	scoreText.text = str("Letters Remaining: " + score)
