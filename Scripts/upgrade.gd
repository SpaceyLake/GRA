extends Button

@export var image:Texture2D
@export var txt:String

func _ready():
	$TextureRect.texture = image
	$Label.text = txt
