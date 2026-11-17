extends Control

var scenario = 0
var scenario_text = [
	"Advisor: greetings, m'lord. it has come to our attention that some new civilization has attacked our southern territories. We would need to go defend them, but in a nearby canyon, a lord-defector has made his last stand. He would be very easy to defeat, but he might want to kill civilians there. Your first job is to sweep in, protect the civilians, defeat the enemy lord, and get out. This would be a great learning opportunity, wouldn't it? \n Oh, and our paladin is there too. He will be of good help for you.",
	
]
var missionid = [
	preload("res://tutorial.tscn"),
	
]
func _ready():
	$Label.text = scenario_text[scenario]


func _on_button_pressed() -> void:
	var game = missionid[scenario].instantiate()
	get_parent().add_child(game)
	queue_free()
