extends Node2D

@onready var ball := $Ball
@onready var player1 := $Player1
@onready var player2 := $Player2
@onready var score1 := $Score1
@onready var score2 := $Score2

func _ready():
	# Set up ball references
	if ball.has_method("set_player_score"):
		ball.player_score = score1
	if ball.has_method("set_ai_score"):
		ball.ai_score = score2