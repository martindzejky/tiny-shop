extends StaticBody2D
class_name Door


func toggle() -> void:
    if $shape.disabled:
        $shape.disabled = false
        $sprite.frame = 0
    else:
        $shape.disabled = true
        $sprite.frame = 1