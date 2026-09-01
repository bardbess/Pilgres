randomize();

// ---------------------------------------------------------
// GAME
// ---------------------------------------------------------

// Match the actual room, so spawn edges and the player
// stay correct if the room is resized.
game_width  = room_width;
game_height = room_height;



score = 0;
health = 3;
max_health = 3;

level = 1;
xp = 0;
xp_next = 10;

game_time = 60;
spawn_timer = 0;

typing_word = "";
typing_index = 0;

// The enemy currently being typed at, held by its unique id.
// An id survives array_delete shifting things around; an index does not.
target_uid = -1;


words = [
    "evil",
    "darkness",
    "destruction",
    "temptation",
    "vanity",
    "despair",
    "world",
    "sin",
    "sorrow",
    "fear",
    "pride",
    "anger",
    "doubt",
    "deceit",
    "wicked",
    "pilgrim",
    "journey",
    "burden",
    "faith",
    "hope",
    "mercy",
    "salvation",
    "cross",
    "grace",
    "endure"
];

phrases = [
    "evils oft as thick as murky night",
    "the city of destruction",
    "flee from the wrath to come",
    "the burden upon his back",
    "the path was narrow and difficult",
    "he pressed toward the celestial city",
    "the way was beset with danger",
    "watch and pray",
    "keep thy face toward the gate"
];

current_phrase = phrases[0];

// ---------------------------------------------------------
// PLAYER
// ---------------------------------------------------------

player_x = game_width * 0.5;
player_y = game_height * 0.48;

player_radius = 18;

// ---------------------------------------------------------
// ENEMIES
// ---------------------------------------------------------

enemies = [];

enemy_spawn_count = 0;

// Every enemy gets its own id from this counter.
enemy_uid_next = 0;

// Spawn some enemies immediately.
for (var i = 0; i < 10; i++)
{
    spawn_enemy();
}


// ---------------------------------------------------------
// CITY DECORATION
// ---------------------------------------------------------

fires = [];
rubble = [];

// Fires
for (var i = 0; i < 18; i++)
{
    fires[i] = {
        x: random_range(40, game_width - 40),
        y: random_range(40, game_height - 100),
        size: random_range(8, 20),
        phase: random(100)
    };
}

// Rubble
for (var i = 0; i < 80; i++)
{
    rubble[i] = {
        x: random_range(20, game_width - 20),
        y: random_range(20, game_height - 20),
        size: random_range(3, 12),
        rot: random(360)
    };
}