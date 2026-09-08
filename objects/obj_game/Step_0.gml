// ---------------------------------------------------------
// TIME
//
// Time increase as seconds pass
// ---------------------------------------------------------

if (game_time > 0)
{
    game_time = max(0, game_time + (1 / room_speed));
}


// ---------------------------------------------------------
// MOVE PLAYER
//
// Arrow keys only. The letter keys are the weapon — they get
// read out of keyboard_string further down, so WASD would type
// at enemies instead of walking.
// ---------------------------------------------------------

var move_x =
    keyboard_check(vk_right) - keyboard_check(vk_left);

var move_y =
    keyboard_check(vk_down) - keyboard_check(vk_up);

player_moving = (move_x != 0 || move_y != 0);

if (player_moving)
{
    // Normalise, or holding two arrows walks 1.41x as fast.
    var move_len = point_distance(0, 0, move_x, move_y);

    player_x += (move_x / move_len) * player_speed;
    player_y += (move_y / move_len) * player_speed;

    if (move_x != 0)
    {
        player_facing = sign(move_x);
    }
}

// Keep him inside the room, with room for the sprite.
player_x = clamp(
    player_x,
    player_radius + 10,
    game_width - player_radius - 10
);

player_y = clamp(
    player_y,
    player_radius + 40,
    game_height - player_radius - 20
);


// ---------------------------------------------------------
// PLAYER ANIMATION
//
// 8 fps matches the playback speed set on both sprites, in a
// 60 fps room; the walk runs a little quicker.
// ---------------------------------------------------------

var wanted_sprite = player_moving
    ? spr_pilgrim_walk
    : spr_pilgrim_idle;

// The two sprites have different frame counts, so a carried-over
// player_frame can land past the end of the one we switch to.
if (wanted_sprite != player_sprite)
{
    player_sprite = wanted_sprite;

    player_frame = 0;
}

player_frame += (player_moving ? 12 : 8) / 60;

var player_frame_count = sprite_get_number(player_sprite);

if (player_frame >= player_frame_count)
{
    player_frame -= player_frame_count;
}


// ---------------------------------------------------------
// WAVES
//
// One encounter at a time: the wave feeds its quota in a batch
// at a time, then nothing more arrives until the board is empty.
// The next bigger wave walks in after a short breather.
//
// A wave is cleared when the board is empty and the quota is
// spent — checked here and nowhere else. Enemies die in two
// other places (a finished word, a finished passage) and are
// removed in a third when they reach the pilgrim; a copy of
// this test in any of them is a copy that will drift.
// ---------------------------------------------------------

wave_banner = max(0, wave_banner - 1);

if (game_time > 0)
{
    switch (wave_state)
    {
        case "spawning":

            spawn_timer--;

            if (spawn_timer <= 0)
            {
                var amount = 2;

                if (level >= 3)
                {
                    amount = 3;
                }

                if (level >= 6)
                {
                    amount = 4;
                }

                // Never overshoot the quota — the wave is a
                // fixed group, not a rate.
                amount = min(amount, wave_quota - wave_spawned);

                for (var s = 0; s < amount; s++)
                {
                    spawn_enemy();

                    wave_spawned++;
                }

                spawn_timer = max(12, 50 - level * 3);
            }

            if (wave_spawned >= wave_quota)
            {
                wave_state = "clearing";
            }

            break;

        case "clearing":

            if (array_length(enemies) == 0)
            {
                // game_time += wave_time_bonus;

                score += wave * 25;

                waves_cleared++;

                wave_state = "breather";

                wave_break_timer = wave_break;
				
				if (wave >= wave_limit)
				{
					score += 2000
				}
            }

            break;

        case "breather":

            wave_break_timer--;

            if (wave_break_timer <= 0)
            {
                start_wave(wave + 1);
            }

            break;
    }
}


// ---------------------------------------------------------
// MOVE ENEMIES
// ---------------------------------------------------------

for (var i = array_length(enemies) - 1; i >= 0; i--)
{
    var e = enemies[i];


    // Knockback rides on top of the walk, and dies away over
    // roughly half a second.
    if (e.kx != 0 || e.ky != 0)
    {
        e.x += e.kx;
        e.y += e.ky;

        e.kx *= 0.86;
        e.ky *= 0.86;

        if (abs(e.kx) < 0.05)
        {
            e.kx = 0;
        }

        if (abs(e.ky) < 0.05)
        {
            e.ky = 0;
        }

        // Enemies spawn off-room and walk in, so being outside
        // is legal — but a hard knockback can throw one so far
        // that it spends most of the round walking back at
        // 0.3px a frame. Keep it just off the edge.
        e.x = clamp(e.x, -50, game_width + 50);
        e.y = clamp(e.y, -50, game_height + 50);
    }

    e.flash = max(0, e.flash - 1);


    var dx = player_x - e.x;
    var dy = player_y - e.y;

    var dist = point_distance(
        e.x,
        e.y,
        player_x,
        player_y
    );

    if (dist > 0)
    {
        e.x += (dx / dist) * e.speed;
        e.y += (dy / dist) * e.speed;
    }

    // Face the way we are moving. The deadzone matters: an enemy
    // walking almost straight up or down has dx hovering around 0,
    // and without it the sprite flips every single frame.
	 
          e.sprite = (dy > 0)
              ? spr_enemy_walkdown
              : spr_enemy_walkdown;
      
    if (abs(dx) > 1.1)
    {
        e.sprite = (dx > 0)
            ? spr_enemy_walkright
            : spr_enemy_walkleft;
    } 

    // Advance the walk cycle by hand — 8 fps, matching the
    // playback speed set on both sprites, in a 60 fps room.
    e.frame += 8 / 60;

    var frame_count = sprite_get_number(e.sprite);

    if (e.frame >= frame_count)
    {
        e.frame -= frame_count;
    }

    // Enemy reaches player.
    var new_dist = point_distance(
        e.x,
        e.y,
        player_x,
        player_y
    );

    if (new_dist <= player_radius + e.radius)
    {
        health--;

        array_delete(enemies, i, 1);

        if (health <= 0)
        {
            health = 0;
            game_time = 0;
        }

        continue;
    }

    enemies[i] = e;
}


// ---------------------------------------------------------
// SHOCKWAVES
//
// Purely decorative rings left behind by finished words and
// finished passages. The damage is dealt the instant the word
// lands, not by these.
// ---------------------------------------------------------

for (var w = array_length(shockwaves) - 1; w >= 0; w--)
{
    // Named `ring`, not `wave` — `wave` is the encounter
    // counter on the instance, and a local of that name would
    // shadow it for the whole event.
    var ring = shockwaves[w];

    ring.radius += (ring.max_radius - ring.radius) * 0.18;

    ring.alpha -= ring.fade;

    if (ring.alpha <= 0)
    {
        array_delete(shockwaves, w, 1);
    }
}


// ---------------------------------------------------------
// PICK A PASSAGE
//
// current_phrase is emptied when it is finished, and the new
// one is chosen and parsed here — the only place that does it,
// so the Create event and the restart just clear it.
// ---------------------------------------------------------

if (current_phrase == "")
{
    current_phrase =
        phrases[irandom(array_length(phrases) - 1)];

    phrase_index = 0;
    phrase_words = [];
    phrase_words_done = 0;

    // Split on spaces, remembering where each word sits in the
    // passage so a character count is enough to tell which words
    // are finished.
    var word_start = 1;

    var pick_length = string_length(current_phrase);

    for (var c = 1; c <= pick_length + 1; c++)
    {
        var at_end = (c > pick_length);

        if (!at_end && string_char_at(current_phrase, c) != " ")
        {
            continue;
        }

        if (c > word_start)
        {
            array_push(phrase_words, {
                text: string_copy(
                    current_phrase,
                    word_start,
                    c - word_start
                ),

                start: word_start,

                last_char: c - 1
            });
        }

        word_start = c + 1;
    }
}


// ---------------------------------------------------------
// TYPING
//
// Straight through the passage, one character at a time. There
// is no target to choose — the damage goes to whoever is stood
// near the pilgrim when a word lands.
// ---------------------------------------------------------

typo_flash = max(0, typo_flash - 1);

var typed = keyboard_string;

// Clear input buffer.
keyboard_string = "";

var phrase_length = string_length(current_phrase);

if (typed != "" && health > 0 && game_time > 0)
{
    for (var k = 1; k <= string_length(typed); k++)
    {
        var character = string_lower(
            string_char_at(typed, k)
        );

        // Anything that is not a letter or a space is not worth
        // asking a player to hit under pressure — walk past the
        // punctuation and capitals before comparing.
        while (
            phrase_index < phrase_length
            && !char_is_typable(
                string_char_at(current_phrase, phrase_index + 1)
            )
        )
        {
            phrase_index++;
        }

        if (phrase_index >= phrase_length)
        {
            break;
        }

        var expected = string_lower(
            string_char_at(current_phrase, phrase_index + 1)
        );

        if (character == expected)
        {
            phrase_index++;
        }
        else
        {
            // Wrong key. The passage does not move on.
            score = max(0, score - 1);

            typo_flash = 18;
        }
    }
}

// Trailing punctuation, so the last word of the passage can
// actually finish.
while (
    phrase_index < phrase_length
    && !char_is_typable(
        string_char_at(current_phrase, phrase_index + 1)
    )
)
{
    phrase_index++;
}


// ---------------------------------------------------------
// WORD COMPLETE
//
// Every word whose last letter is now behind us, and that has
// not been paid out yet, hurts the enemies near the pilgrim.
// Crediting in order keeps it idempotent — a word can never be
// counted twice, and none can be skipped.
// ---------------------------------------------------------

while (
    phrase_words_done < array_length(phrase_words)
    && phrase_index >= phrase_words[phrase_words_done].last_char
)
{
    var finished_word = phrase_words[phrase_words_done];

    phrase_words_done++;

    var hit = word_damage(finished_word.text);

    array_push(shockwaves, {
        x: player_x,
        y: player_y,
        radius: 20,
        max_radius: word_blast_radius,
        alpha: 0.45,
        fade: 0.035,
        color: make_color_rgb(150, 210, 120)
    });

    // Backwards: array_delete shifts everything after the
    // removed enemy down one.
    for (var i = array_length(enemies) - 1; i >= 0; i--)
    {
        var foe = enemies[i];

        var d = point_distance(player_x, player_y, foe.x, foe.y);

        if (d > word_blast_radius)
        {
            continue;
        }

        foe.hp -= hit;

        foe.flash = 8;

        if (foe.hp > 0)
        {
            continue;
        }

        score += foe.points;
        xp += foe.xp;

        array_delete(enemies, i, 1);

        while (xp >= xp_next)
        {
            xp -= xp_next;

            level++;

            xp_next = ceil(xp_next * 1.35);
        }
    }
}


// ---------------------------------------------------------
// PASSAGE COMPLETE
//
// Heavier damage, and everything still standing in the wider
// ring is thrown back off the pilgrim.
// ---------------------------------------------------------

if (phrase_length > 0 && phrase_index >= phrase_length)
{
    var blast = 5 + level;

    array_push(shockwaves, {
        x: player_x,
        y: player_y,
        radius: 30,
        max_radius: phrase_blast_radius,
        alpha: 0.7,
        fade: 0.018,
        color: make_color_rgb(235, 195, 110)
    });

    for (var i = array_length(enemies) - 1; i >= 0; i--)
    {
        var foe = enemies[i];

        var d = point_distance(player_x, player_y, foe.x, foe.y);

        if (d > phrase_blast_radius)
        {
            continue;
        }

        foe.hp -= blast;

        foe.flash = 14;

        if (foe.hp <= 0)
        {
            score += foe.points;
            xp += foe.xp;

            array_delete(enemies, i, 1);

            while (xp >= xp_next)
            {
                xp -= xp_next;

                level++;

                xp_next = ceil(xp_next * 1.35);
            }

            continue;
        }

        // Push straight out from the pilgrim, hardest up close.
        var push = 14 * (1 - d / phrase_blast_radius) + 4;

        var away = point_direction(player_x, player_y, foe.x, foe.y);

        foe.kx = lengthdir_x(push, away);
        foe.ky = lengthdir_y(push, away);
    }

    // Emptied, so the block at the top of the Step picks and
    // parses the next passage.
    current_phrase = "";
}


// ---------------------------------------------------------
// RESTART
// ---------------------------------------------------------

if (keyboard_check_pressed(vk_enter))
{
    if (health <= 0 || game_time <= 0)
    {
        health = max_health;

        score = 0;

        level = 1;

        xp = 0;

        xp_next = 10;

        game_time = 60;

        enemies = [];

        player_x = game_width * 0.5;

        player_y = game_height * 0.48;

        // Emptied so the top of the Step picks a fresh passage.
        current_phrase = "";

        phrase_index = 0;

        phrase_words = [];

        phrase_words_done = 0;

        shockwaves = [];

        // The one path that begins a wave — it resets every
        // wave field, so none can be forgotten here.
        start_wave(1);
    }
}
