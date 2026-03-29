extends Node
func _ready() -> void:
    await get_tree().create_timer(1.5).timeout
    var m = get_node_or_null("/root/Main")
    if m:
        var u = m.get_node_or_null("UIManager")
        if u and u.has_method("get_state_machine"):
            u.get_state_machine().change_state(2)
            await get_tree().create_timer(0.5).timeout
            u.get_state_machine().push_state(5)
            await get_tree().create_timer(0.5).timeout
            get_viewport().get_texture().get_image().save_png("/tmp/pt_eq_names.png")
            print("[QT] Equipment screenshot taken")
            
            # Check catalogue
            if GameResources.config:
                var cat = GameResources.config.get("equipment_catalogue")
                print("[QT] Catalogue: %s" % str(cat))
                if cat:
                    var rods = cat.get("rods")
                    if rods:
                        for r in rods:
                            print("[QT] Rod: id=%s name=%s" % [r.id, r.display_name])
            set_process(false)
