// ---------------------------------------------------------
// TIME
// ---------------------------------------------------------

if (game_time > 0)
{
    game_time = max(0, game_time - (1 / room_speed));
}


// ---------------------------------------------------------
// SPAWN ENEMIES
// ---------------------------------------------------------

if (game_time > 0)
{
    spawn_timer--;

    if (spawn_timer <= 0)
    {
        var amount = 1;

        if (level >= 3)
        {
            amount = 2;
        }

        if (level >= 6)
        {
            amount = 3;
        }

        for (var s = 0; s < amount; s++)
        {
            spawn_enemy();
        }

        spawn_timer = max(12, 50 - level * 3);
    }
}


// ---------------------------------------------------------
// MOVE ENEMIES
// ---------------------------------------------------------

for (var i = array_length(enemies) - 1; i >= 0; i--)
{
    var e = enemies[i];

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

        // If this enemy was our typing target,
        // clear the typing state.
        if (e.uid == target_uid)
        {
            target_uid = -1;
            typing_word = "";
            typing_index = 0;
        }

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
// TYPING
// ---------------------------------------------------------

var typed = keyboard_string;

// Clear input buffer.
keyboard_string = "";

if (typed != "")
{
    for (var k = 1; k <= string_length(typed); k++)
    {
        var character = string_lower(
            string_char_at(typed, k)
        );

        // Ignore spaces.
        if (character == " ")
        {
            continue;
        }

        // -----------------------------------------------------
        // SELECT TARGET
        //
        // Not yet typing a word: lock onto the nearest enemy
        // whose word STARTS with this character.
        // -----------------------------------------------------

        if (typing_word == "")
        {
            var best_index = -1;
            var best_distance = infinity;

            for (var n = 0; n < array_length(enemies); n++)
            {
                var candidate = enemies[n];

                var first_char =
                    string_lower(
                        string_char_at(candidate.word, 1)
                    );

                if (first_char != character)
                {
                    continue;
                }

                var d = point_distance(
                    player_x,
                    player_y,
                    candidate.x,
                    candidate.y
                );

                if (d < best_distance)
                {
                    best_distance = d;
                    best_index = n;
                }
            }

            // No enemy on screen starts with that letter.
            if (best_index == -1)
            {
                score = max(0, score - 1);
                continue;
            }

            target_uid = enemies[best_index].uid;

            typing_word =
                string_lower(enemies[best_index].word);

            typing_index = 0;
        }

        // -----------------------------------------------------
        // CHECK CHARACTER
        // -----------------------------------------------------

        var expected =
            string_char_at(
                typing_word,
                typing_index + 1
            );

        if (character == expected)
        {
            typing_index++;

            // -------------------------------------------------
            // WORD COMPLETE
            // -------------------------------------------------

            if (typing_index >= string_length(typing_word))
            {
                // Find the target by id — its index may have
                // shifted since we locked on. (Note: `var` in
                // GML is event-scoped, so this counter must not
                // reuse a name from an enclosing loop.)
                for (var t = 0; t < array_length(enemies); t++)
                {
                    if (enemies[t].uid != target_uid)
                    {
                        continue;
                    }

                    var killed = enemies[t];

                    score += killed.points;
                    xp += killed.xp;

                    array_delete(enemies, t, 1);

                    // Level up.
                    while (xp >= xp_next)
                    {
                        xp -= xp_next;

                        level++;

                        xp_next =
                            ceil(xp_next * 1.35);
                    }

                    break;
                }

                // Reset typing.
                typing_word = "";
                typing_index = 0;
                target_uid = -1;

                // New phrase.
                if (array_length(phrases) > 0)
                {
                    current_phrase =
                        phrases[
                            irandom(
                                array_length(phrases) - 1
                            )
                        ];
                }
            }
        }
        else
        {
            // Wrong character.
            score = max(0, score - 1);
        }
    }
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

        spawn_timer = 0;

        enemies = [];

        target_uid = -1;

        typing_word = "";

        typing_index = 0;

        for (var i = 0; i < 10; i++)
        {
            spawn_enemy();
        }
    }
}
