extends OptionButton

var languages: Array[String] = ["es","en"]


func _ready() -> void:
	var index = languages.find(TranslationServer.get_locale()) 
	self.selected = index

func _on_item_selected(index: int) -> void:
	TranslationServer.set_locale(languages[index])
