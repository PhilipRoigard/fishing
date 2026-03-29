class_name Enums
extends RefCounted


enum ItemQuality {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
	LEGENDARY,
}

enum Rarity {
	COMMON,
	UNCOMMON,
	RARE,
	LEGENDARY,
}

enum GameMode {
	LOADING,
	MAIN_MENU,
	WHARF_HUB,
	FISHING_SESSION,
	TRANSITION,
}

enum FishingState {
	IDLE,
	CASTING,
	WAITING,
	BITE_ALERT,
	FIGHTING,
	SUCCESS,
	FAIL,
}

enum FightPhase {
	NORMAL,
	DESPERATE,
	FINAL_STAND,
}

enum EquipmentSlot {
	ROD,
	HOOK,
	LURE,
	BAIT,
}

enum DepthZone {
	SHALLOWS,
	OPEN_OCEAN,
	DEEP_OCEAN,
	ABYSS,
}

enum ConsumableEffect {
	STUN,
	REDUCE_DECAY,
	INCREASE_TENSION_CAP,
	INCREASE_PROGRESS_GAIN,
	REDUCE_TENSION,
	ALL_BUFFS,
}

enum BiomeFlag {
	REEF = 1,
	OCEAN = 2,
	DEEP_OCEAN = 4,
	ABYSS = 8,
}


const QUALITY_COLORS: Dictionary = {
	ItemQuality.COMMON: Color(0.6, 0.6, 0.6),
	ItemQuality.UNCOMMON: Color(0.2, 0.8, 0.2),
	ItemQuality.RARE: Color(0.2, 0.6, 1.0),
	ItemQuality.EPIC: Color(0.7, 0.3, 1.0),
	ItemQuality.LEGENDARY: Color(1.0, 0.84, 0.0),
}

const QUALITY_MULTIPLIERS: Dictionary = {
	ItemQuality.COMMON: 1.0,
	ItemQuality.UNCOMMON: 1.5,
	ItemQuality.RARE: 2.0,
	ItemQuality.EPIC: 3.0,
	ItemQuality.LEGENDARY: 4.5,
}

const QUALITY_NAMES: Dictionary = {
	ItemQuality.COMMON: "Common",
	ItemQuality.UNCOMMON: "Uncommon",
	ItemQuality.RARE: "Rare",
	ItemQuality.EPIC: "Epic",
	ItemQuality.LEGENDARY: "Legendary",
}

const RARITY_NAMES: Dictionary = {
	Rarity.COMMON: "Common",
	Rarity.UNCOMMON: "Uncommon",
	Rarity.RARE: "Rare",
	Rarity.LEGENDARY: "Legendary",
}
