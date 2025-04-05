tool
extends SceneTree

func _init():
    var has_preset = false
    var settings = ConfigFile.new()
    if settings.load("export_presets.cfg") == OK:
        for section in settings.get_sections():
            if settings.get_value(section, "name") == "HTML5":
                has_preset = true
                break
    
    if not has_preset:
        print("Error: Export preset 'HTML5' not found")
        print("Please create an HTML5 export preset in Godot's Export menu")
        quit(1)
    
    quit(0)
