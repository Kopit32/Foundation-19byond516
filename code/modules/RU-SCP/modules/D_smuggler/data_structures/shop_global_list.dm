GLOBAL_LIST_INIT(global_shop_items, list(
    // --- LIGHT TIER ---
    list(
        "name" = "Cigarettes",
        "tier" = "light",
        "cost" = 30,
        "items" = list(
            "/obj/item/storage/fancy/cigarettes/professionals" = 1,
            "/obj/item/flame/lighter" = 1
        )
    ),
    list(
        "name" = "MRE",
        "tier" = "light",
        "cost" = 20,
        "items" = list(
            "/obj/item/storage/mre" = 1
        )
    ),
    list(
        "name" = "Knife",
        "tier" = "light",
        "cost" = 50,
        "items" = list(
            "/obj/item/material/knife/kitchen" = 1
        )
    ),
    list(
        "name" = "Tape",
        "tier" = "light",
        "cost" = 60,
        "items" = list(
            "/obj/item/tape_roll" = 1
        )
    ),
    list(
        "name" = "Construction book",
        "tier" = "light",
        "cost" = 70,
        "items" = list(
            "/obj/item/skill_book/construction" = 1
        )
    ),
    list(
        "name" = "Alcohol",
        "tier" = "light",
        "cost" = 30,
        "items" = list(
            "/obj/item/reagent_containers/food/drinks/bottle/vodka" = 1
        )
    ),
    list(
        "name" = "First Aid kit",
        "tier" = "light",
        "cost" = 50,
        "items" = list(
            "/obj/item/storage/firstaid/regular" = 1
        )
    ),
    list(
        "name" = "Steel",
        "tier" = "light",
        "cost" = 50,
        "items" = list(
            "/obj/item/stack/material/steel/ten" = 1
        )
    ),
    list(
        "name" = "Wood",
        "tier" = "light",
        "cost" = 40,
        "items" = list(
            "/obj/item/stack/material/wood/ten" = 1
        )
    ),
	list(
        "name" = "Paper",
        "tier" = "light",
        "cost" = 15,
        "items" = list(
            "/obj/item/paper" = 10
        )
    ),

    // --- MEDIUM TIER ---
    list(
        "name" = "Random tool",
        "tier" = "medium",
        "cost" = 50,
        "items" = list(
            "/obj/effect/random_tool" = 1
        ),
		"goal_type" = "/datum/goal/item/tools"
    ),
    list(
        "name" = "Battle knife",
        "tier" = "medium",
        "cost" = 80,
        "items" = list(
            "/obj/item/material/knife/combat" = 1
        )
    ),
    list(
        "name" = "Melee book",
        "tier" = "medium",
        "cost" = 80,
        "items" = list(
            "/obj/item/skill_book/melee" = 1
        )
    ),
    list(
        "name" = "Electrian book",
        "tier" = "medium",
        "cost" = 120,
        "items" = list(
            "/obj/item/skill_book/electicity" = 1
        )
    ),
    list(
        "name" = "Insulated gloves",
        "tier" = "medium",
        "cost" = 200,
        "items" = list(
            "/obj/item/clothing/gloves/insulated" = 1
        )
    ),
    list(
        "name" = "Stimulator",
        "tier" = "medium",
        "cost" = 200,
        "items" = list(
            "/obj/item/reagent_containers/hypospray/autoinjector/stimpack" = 1
        )
    ),
    list(
        "name" = "Advanced first aid kit",
        "tier" = "medium",
        "cost" = 150,
        "items" = list(
            "/obj/item/storage/firstaid/combat" = 1
        )
    ),
    list(
        "name" = "Telescopic baton",
        "tier" = "medium",
        "cost" = 120,
        "items" = list(
            "/obj/item/melee/telebaton" = 1
        )
    ),
    list(
        "name" = "radio",
        "tier" = "medium",
        "cost" = 150,
        "items" = list(
            "/obj/item/device/radio" = 1
        )
    ),
	list(
        "name" = "Metal pipe",
        "tier" = "medium",
        "cost" = 100,
        "items" = list(
            "/obj/item/zipgun_tube" = 1
        )
    ),
	list(
        "name" = "Seven 9mm bullets",
        "tier" = "medium",
        "cost" = 70,
        "items" = list(
            "/obj/item/ammo_casing/pistol/c9mm" = 7
        )
    ),
	list(
        "name" = "Surgical kit",
        "tier" = "medium",
        "cost" = 200,
        "items" = list(
            "/obj/item/storage/firstaid/surgery" = 1
        )
    ),

    // --- HIGH TIER ---
    list(
        "name" = "Fake security kit",
        "tier" = "high",
        "cost" = 400,
        "items" = list(
            "/obj/item/storage/box/large/fake_security" = 1,
            "/obj/item/card/id/junseclvl1lcz" = 1
        ),
		"goal_type" = "/datum/goal/id_card/security"
    ),
    list(
        "name" = "Push-button phone",
        "tier" = "high",
        "cost" = 700,
        "items" = list(
            "/obj/item/chaos_phone" = 1
        ),
		"goal_type" = "/datum/goal/item/scp"
    ),
    list(
        "name" = "Makarov",
        "tier" = "high",
        "cost" = 300,
        "items" = list(
            "/obj/item/gun/projectile/pistol/makarov" = 1,
            "/obj/item/ammo_magazine/scp/a9mm" = 1
        ),
		"goal_type" = "/datum/goal/item/gun"
    ),
    list(
        "name" = "Hacking tool",
        "tier" = "high",
        "cost" = 500,
        "items" = list(
            "/obj/item/device/multitool/hacktool" = 1
        )
    ),
    list(
        "name" = "Random security channel key",
        "tier" = "high",
        "cost" = 400,
        "items" = list(
            "TODO" = 1
        )
    ),
	list(
        "name" = "Makarov ammo",
        "tier" = "high",
        "cost" = 200,
        "items" = list(
            "/obj/item/ammo_magazine/scp/a9mm" = 3
        )
    )
))
