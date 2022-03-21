extends TileMap

const SCENES := {
	"player": "res://Entities/player/player.tscn",
	"spikes": "res://Entities/spikes/spikes.tscn",
	"spikes_offset": "res://Entities/spikes/spikes_offest/spikes_offset.tscn",
	"chaser": "res://Entities/chaser/chaser.tscn",
	"brute_chaser": "res://Entities/chaser/brute_chaser/brute_chaser.tscn",
	"gold_chaser": "res://Entities/chaser/gold_chaser/gold_chaser.tscn",
	"crate": "res://Entities/crate/crate.tscn",
	"fire": "res://Entities/fire/fire.tscn",
	"timber_box": "res://Entities/fire/timber_pot/timber_pot.tscn",
	"unlite_timber_box": "res://Entities/fire/timber_pot/unlite_timber_pot/unlite_timber_pot.tscn",
	"specter": "res://Entities/specter/specter.tscn",
	"knight": "res://Entities/knight/knight.tscn",
	"archer": "res://Entities/archer/archer.tscn",
	"rogue": "res://Entities/knight/rogue/rogue.tscn",
	"king": "res://Entities/king/king.tscn",
	"ultra_chaser": "res://Entities/chaser/ultra_chaser/ultra_chaser.tscn",
	"red_spikes": "res://Entities/spikes/red_spikes/red_spikes.tscn",
	"diamond_spikes": "res://Entities/spikes/red_spikes/diamond_spikes/diamond_spikes.tscn",
	"arrow_turret": "res://Entities/arrow_turret/arrow_turret.tscn",
	"royal_spikes": "res://Entities/spikes/red_spikes/royal_spikes/royal_spikes.tscn",
	"pylon": "res://Entities/pylon/pylon.tscn",
	"mage": "res://Entities/archer/mage/mage.tscn",
	"warden": "res://Entities/knight/warden/warden.tscn",
	"medic": "res://Entities/medic/medic.tscn",
	"slime": "res://Entities/slime/slime.tscn",
	"queen": "res://Entities/queen/queen.tscn",
	"witch": "res://Entities/witch/witch.tscn",
	"lock": "res://Entities/lock/lock.tscn",
	"watcher_lock": "res://Entities/watcher_lock/watcher_lock.tscn",
	"green_heart": "res://Entities/Item_Pickups/green_heart/green_heart.tscn",
	"survivor": "res://Entities/survivor/survivor.tscn",
	"red_barrel": "res://Entities/red_barrel/red_barrel.tscn",
	"explosion": "res://Entities/explosion/explosion.tscn",
	"hunter": "res://Entities/hunter/hunter.tscn",
	"skeleton": "res://Entities/skeleton/skeleton.tscn",
	"stalker": "res://Entities/stalker/stalker.tscn",
	"soldier": "res://Entities/soldier/soldier.tscn",
	"metal_crate": "res://Entities/crate/metal_crate/metal_crate.tscn",
	"heart_mimic": "res://Entities/heart_mimic/heart_mimic.tscn",
	"landmine": "res://Entities/landmine/landmine.tscn",
	"zombie": "res://Entities/zombie/zombie.tscn",
	"berserker": "res://Entities/berserker/berserker.tscn",
	"gold_spikes": "res://Entities/spikes/gold_spikes/gold_spikes.tscn",
	"rocket_scorpian": "res://Entities/rocket_scorpian/rocket_scorpian.tscn",
	"pistol": "res://Entities/Item_Pickups/pistol/pistol.tscn",
	"white_armor": "res://Entities/Item_Pickups/white_armor/white_armor.tscn",
	"sword": "res://Entities/Item_Pickups/sword/sword.tscn",
	"gold_heart": "res://Entities/Item_Pickups/gold_heart/gold_heart.tscn",
	"heart": "res://Entities/Item_Pickups/heart/heart.tscn",
	"star": "res://Entities/Item_Pickups/star/star.tscn",
	"bow": "res://Entities/Item_Pickups/bow/bow.tscn",
	"staff": "res://Entities/Item_Pickups/staff/staff.tscn",
	"spear": "res://Entities/Item_Pickups/spear/spear.tscn",
	"dagger": "res://Entities/Item_Pickups/dagger/dagger.tscn",
	"xbow": "res://Entities/Item_Pickups/xbow/xbow.tscn",
	"health_potion": "res://Entities/Item_Pickups/health_potion/health_potion.tscn",
	"iron_potion": "res://Entities/Item_Pickups/iron_potion/iron_potion.tscn",
	"speed_feather": "res://Entities/Item_Pickups/speed_feather/speed_feather.tscn",
	"blow_gun": "res://Entities/Item_Pickups/blow_gun/blow_gun.tscn",
	"gold_apple": "res://Entities/Item_Pickups/gold_apple/gold_apple.tscn",
	"key": "res://Entities/Item_Pickups/key/key.tscn",
	"boots": "res://Entities/Item_Pickups/boots/boots.tscn",
	"medkit": "res://Entities/Item_Pickups/medkit/medkit.tscn",
	"awp": "res://Entities/Item_Pickups/awp/awp.tscn",
	"shotgun": "res://Entities/Item_Pickups/shotgun/shotgun.tscn",
	"assault_rifle": "res://Entities/Item_Pickups/assault_rifle/assault_rifle.tscn",
	"deagle": "res://Entities/Item_Pickups/deagle/deagle.tscn",
	"landmines": "res://Entities/Item_Pickups/landmines/landmines.tscn",
	"rocket_launcher": "res://Entities/Item_Pickups/rocket_launcher/rocket_launcher.tscn",
	"flamethrower": "res://Entities/Item_Pickups/flamethrower/flamethrower.tscn",
	"injection": "res://Entities/Item_Pickups/injection/injection.tscn",
	"maple_tree1": "res://Props/maple_tree1/maple_tree1.tscn",
	"maple_tree2": "res://Props/maple_tree2/maple_tree2.tscn",
	"maple_tree3": "res://Props/maple_tree3/maple_tree3.tscn",
	"tree_stump": "res://Props/tree_stump/tree_stump.tscn",
	"banner": "res://Props/banner/banner.tscn",
	"flag": "res://Props/flag/flag.tscn",
	"torch": "res://Props/torch/torch.tscn",
	"rock": "res://Props/rock/rock.tscn",
	"rock2": "res://Props/rock2/rock2.tscn",
	"stalagmite": "res://Props/stalagmite/stalagmite.tscn",
	"stalagmite2": "res://Props/stalagmite2/stalagmite2.tscn",
	"water_stalagmite": "res://Props/water_stalagmite/water_stalagmite.tscn",
	"ore": "res://Props/ore/ore.tscn",
	"cactus": "res://Props/cactus/cactus.tscn",
	"campfire": "res://Props/campfire/campfire.tscn",
	"dead_bush": "res://Props/dead_bush/dead_bush.tscn",
	"dead_tree": "res://Props/dead_tree/dead_tree.tscn",
	"old_barrel": "res://Props/old_barrel/old_barrel.tscn",
	"blaster": "res://Entities/Item_Pickups/blaster/blaster.tscn",
	"saber": "res://Entities/Item_Pickups/saber/saber.tscn",
	"trooper": "res://Entities/trooper/trooper.tscn",
	"speed_pad": "res://Entities/speed_pad/speed_pad.tscn",
	"teleporter": "res://Entities/Item_Pickups/teleporter/teleporter.tscn",
	"pulse_rifle": "res://Entities/Item_Pickups/pulse_rifle/pulse_rifle.tscn",
	"portal_gun": "res://Entities/Item_Pickups/portal_gun/portal_gun.tscn",
	"laser_pistol": "res://Entities/Item_Pickups/laser_pistol/laser_pistol.tscn",
	"drone": "res://Entities/drone/drone.tscn",
}

export var placement_offset: Vector2 = Vector2.ZERO

signal finished_batching

onready var ysort = get_parent()

onready var data = {}

func set_data():
	pass

func _ready(): # converts tiles to their respective scenes
	set_data()
	if data == {}:
		push_error("data was not set")
		return
	
	# replaces the number with the cells of that id
	for i in data.keys().size():
		if data[data.keys()[i]] is int:
			data[data.keys()[i]] = get_used_cells_by_id(data.values()[i])
	
	for i in data.keys().size():
		if data.values()[i].size() > 0:
			convert_tile(data.values()[i], data.keys()[i])
	
	clear() # remove all the tiles
	emit_signal("finished_batching")

func convert_tile(tiles, entity_name: String): # deletes the tile and places the entity
	var tile_pos: Vector2
	for i in range(0, tiles.size()):
		if SCENES[entity_name] is String:
			SCENES[entity_name] = load(SCENES.get(entity_name))
		var new_entity: Node = SCENES.get(entity_name).instance()
		tile_pos = map_to_world(tiles[i]) + placement_offset
		new_entity.set_position(Vector2(tile_pos.x + 8, tile_pos.y + 8))
		ysort.call_deferred("add_child", new_entity)
