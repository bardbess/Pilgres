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

game_time = 1;
spawn_timer = 0;

// ---------------------------------------------------------
// TYPING
//
// The weapon is the passage, not a single word. The player
// types `current_phrase` straight through; every word finished
// hurts the enemies standing near the pilgrim, and finishing
// the whole passage blows them back.
// ---------------------------------------------------------

// Empty means "pick a new one" — the Step event does the
// picking and the parsing, so it only lives in one place.
current_phrase = "";

// How many characters of the passage are typed, correctly.
phrase_index = 0;

// One struct per word of current_phrase:
// { text, start, last_char }, the two numbers being 1-based
// character positions in the passage. (`end` is a GML keyword,
// hence last_char.) Filled in alongside current_phrase.
phrase_words = [];

// Words already paid out damage for. Words are credited in
// order, so this doubles as the index of the word being typed.
phrase_words_done = 0;

// Counts down after a wrong key, to flash the input box.
typo_flash = 0;

// Everything within this of the pilgrim feels a finished word,
// and the wider ring feels a finished passage.
word_blast_radius = 190;
phrase_blast_radius = 420;

phrases = [
    "evils oft as thick as murky night",
    "the city of destruction",
    "flee from the wrath to come",
    "the burden upon his back",
    "the path was narrow and difficult",
    "he pressed toward the celestial city",
    "the way was beset with danger",
    "watch and pray",
    "keep thy face toward the gate",

    "As I walked through the wilderness of this world, I lighted "
    + "on a certain place where was a den, and laid me down in "
    + "that place to sleep.",

    "I saw a man clothed with rags, standing with his face from "
    + "his own house, a book in his hand, and a great burden upon "
    + "his back.",

    "He broke out with a lamentable cry, saying, what shall I do? "
    + "So I saw that he wept and trembled, and cried out, life, "
    + "life, eternal life.",

    "Then said Evangelist, if this be thy condition, why standest "
    + "thou still? Because I know not whither to go, he answered. "
    + "Do you see yonder shining light? I think I do.",

    "The name of the slough was Despond. Here therefore they "
    + "wallowed for a time, being grievously bedaubed with the "
    + "dirt, and the burden upon his back made him sink.",

    "Now I saw in my dream, that the highway up which the pilgrim "
    + "was to go was fenced on either side with a wall, and that "
    + "wall was called Salvation."
];


// Longer words hit harder, and so do words built out of the
// letters the fingers do not live on.
word_damage = function(word_text)
{
    var common = "etaoinshrdlu";

    var strength = 0;

    for (var i = 1; i <= string_length(word_text); i++)
    {
        var c = string_lower(string_char_at(word_text, i));

        // Punctuation rides along inside the word token; it is
        // not part of what makes the word hard to type.
        if (string_pos(c, "abcdefghijklmnopqrstuvwxyz") == 0)
        {
            continue;
        }

        strength += 0.35;

        if (string_pos(c, common) == 0)
        {
            strength += 0.35;
        }
    }

    return max(1, round(strength));
};


// The passages carry capitals, commas and full stops for the
// sake of reading like prose. The player is never asked to type
// them — anything that is not a letter or a space is walked over.
char_is_typable = function(c)
{
    if (c == " ")
    {
        return true;
    }

    return (
        string_pos(
            string_lower(c),
            "abcdefghijklmnopqrstuvwxyz"
        ) > 0
    );
};


// Expanding rings, drawn in the world: one per finished word,
// a bigger one per finished passage.
shockwaves = [];

// ---------------------------------------------------------
// PLAYER
// ---------------------------------------------------------

player_x = game_width * 0.5;
player_y = game_height * 0.48;

player_radius = 18;

// Per-frame, the way enemy speed is — not divided by room_speed.
player_speed = 3;

// Arrow keys, never WASD: letter keys land in keyboard_string,
// which is the typing weapon.
player_moving = false;

// -1 faces left, 1 faces right. Only updated while actually
// moving sideways, so the pilgrim keeps facing where he stopped.
player_facing = 1;

// Swapped between spr_pilgrim_idle and spr_pilgrim_walk in the
// Step, and advanced by hand there the same way the enemy walk
// cycles are.
player_sprite = spr_pilgrim_idle;

player_frame = 0;

// ---------------------------------------------------------
// ENEMIES
// ---------------------------------------------------------

enemies = [];

enemy_spawn_count = 0;

// Every enemy gets its own id from this counter.
enemy_uid_next = 0;


// ---------------------------------------------------------
// WAVES
//
// Enemies arrive as encounters, not as an endless trickle: a
// wave is a fixed number of them, and the next wave does not
// begin until every enemy of this one is off the board — killed
// by the typing, or having reached the pilgrim.
//
// The 60s clock is still what ends the run. Clearing a wave
// buys time back, so the waves are what the run is actually
// about rather than a counter ticking along beside it.
// ---------------------------------------------------------

// 0 until start_wave() is called below; the first real wave is 1.
// Wave_limit is set to the max number of waves for this level
wave = 0;
wave_limit = 5

// How many enemies this wave sends in total, and how many of
// them have been spawned so far.
wave_quota = 0;
wave_spawned = 0;

// "spawning" — still feeding the wave in, a batch at a time.
// "clearing" — everything is out; waiting for the board to empty.
// "breather" — wave cleared, counting down to the next one.
wave_state = "breather";

// Frames of quiet between one wave and the next.
wave_break = 2 * room_speed;
wave_break_timer = 0;

// Frames left on the "WAVE N" banner announcing a new wave, and
// how long a fresh one lasts. Draw_64 fades the banner against
// wave_banner_max, so the two must come from one number.
wave_banner_max = 2 * room_speed;
wave_banner = 0;

// Seconds put back on the clock for clearing a wave.
//wave_time_bonus = 8;

// How many waves this run has finished — the score line on the
// game over screen. Counted separately from `wave`, which has
// already moved on during a breather.
waves_cleared = 0;

// Every wave is three enemies heavier than the one before.
start_wave = function(n)
{
    wave = n;

    wave_quota = 5 + (n - 1) * 3;
    wave_spawned = 0;

    wave_state = "spawning";

    // Zero, so the first batch walks in on the next step rather
    // than after a delay.
    spawn_timer = 0;

    wave_banner = wave_banner_max;

    // Reaching wave n means n - 1 are behind us. Stated here as
    // well as counted on the clear, so a restart cannot carry
    // the previous run's tally.
    waves_cleared = n - 1;
};

start_wave(1);


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