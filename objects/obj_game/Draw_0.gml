// =========================================================
// CITY OF DESTRUCTION
// =========================================================

draw_set_alpha(1);


// ---------------------------------------------------------
// GROUND
// ---------------------------------------------------------

draw_set_color(make_color_rgb(31, 29, 27));

draw_rectangle(
    0, 0,
    game_width,
    game_height,
    false
);


// ---------------------------------------------------------
// COBBLESTONE GRID
// ---------------------------------------------------------

draw_set_color(make_color_rgb(45, 43, 40));

for (var grid_x = 0; grid_x < game_width; grid_x += 32)
{
    draw_line(
        grid_x,
        0,
        grid_x,
        game_height
    );
}

for (var grid_y = 0; grid_y < game_height; grid_y += 32)
{
    draw_line(
        0,
        grid_y,
        game_width,
        grid_y
    );
}


// ---------------------------------------------------------
// CITY WALLS
// ---------------------------------------------------------

draw_set_color(make_color_rgb(20, 19, 18));

draw_rectangle(
    0,
    0,
    game_width,
    45,
    false
);

draw_rectangle(
    0,
    game_height - 45,
    game_width,
    game_height,
    false
);

draw_rectangle(
    0,
    0,
    45,
    game_height,
    false
);

draw_rectangle(
    game_width - 45,
    0,
    game_width,
    game_height,
    false
);


// ---------------------------------------------------------
// BATTLEMENTS
// ---------------------------------------------------------

draw_set_color(make_color_rgb(30, 29, 27));

for (var battlement_x = 0;
     battlement_x < game_width;
     battlement_x += 40)
{
    draw_rectangle(
        battlement_x,
        0,
        battlement_x + 22,
        22,
        false
    );

    draw_rectangle(
        battlement_x,
        game_height - 22,
        battlement_x + 22,
        game_height,
        false
    );
}

for (var battlement_y = 0;
     battlement_y < game_height;
     battlement_y += 40)
{
    draw_rectangle(
        0,
        battlement_y,
        22,
        battlement_y + 22,
        false
    );

    draw_rectangle(
        game_width - 22,
        battlement_y,
        game_width,
        battlement_y + 22,
        false
    );
}


// ---------------------------------------------------------
// RUBBLE
// ---------------------------------------------------------

for (var rubble_index = 0;
     rubble_index < array_length(rubble);
     rubble_index++)
{
    var rubble_piece = rubble[rubble_index];

    draw_set_color(
        make_color_rgb(55, 52, 47)
    );

    draw_rectangle(
        rubble_piece.x,
        rubble_piece.y,
        rubble_piece.x + rubble_piece.size,
        rubble_piece.y + rubble_piece.size * 0.6,
        false
    );
}


// ---------------------------------------------------------
// FIRE
// ---------------------------------------------------------

for (var fire_index = 0;
     fire_index < array_length(fires);
     fire_index++)
{
    var fire = fires[fire_index];

    var flicker =
        sin(current_time * 0.01 + fire.phase) * 3;


    // Glow
    draw_set_alpha(0.10);

    draw_set_color(
        make_color_rgb(220, 80, 20)
    );

    draw_circle(
        fire.x,
        fire.y,
        fire.size * 2 + flicker,
        false
    );

    draw_set_alpha(1);


    // Flame
    draw_set_color(
        make_color_rgb(230, 90, 20)
    );

    draw_circle(
        fire.x,
        fire.y,
        fire.size + flicker,
        false
    );


    // Hot centre
    draw_set_color(
        make_color_rgb(255, 190, 50)
    );

    draw_circle(
        fire.x,
        fire.y + 2,
        fire.size * 0.45,
        false
    );
}


// =========================================================
// ENEMIES
// =========================================================

for (var enemy_index = 0;
     enemy_index < array_length(enemies);
     enemy_index++)
{
    var enemy = enemies[enemy_index];

    var is_target =
        (enemy.uid == target_uid);


    // -----------------------------------------------------
    // TARGET RING
    // -----------------------------------------------------

    if (is_target)
    {
        draw_set_color(
            make_color_rgb(190, 150, 50)
        );

        draw_circle(
            enemy.x,
            enemy.y,
            enemy.radius + 7,
            true
        );
    }


    // -----------------------------------------------------
    // SHADOW
    // -----------------------------------------------------

    draw_set_alpha(0.4);

    draw_set_color(c_black);

    draw_ellipse(
        enemy.x - 14,
        enemy.y + 8,
        enemy.x + 14,
        enemy.y + 15,
        false
    );

    draw_set_alpha(1);


    // -----------------------------------------------------
    // BODY
    // -----------------------------------------------------

    // The two walk sprites are different sizes (16x34 and
    // 26x55), so scale both to one height instead of drawing
    // them raw — otherwise the enemy changes size every time
    // it turns around.
    var body_height = enemy.radius * 3.2;

    var body_scale =
        body_height / sprite_get_height(enemy.sprite);

    // Both sprites have their origin at the top-left corner,
    // so nothing centres itself. Place the feet just inside
    // the shadow ellipse and work back up from there.
    draw_sprite_ext(
        enemy.sprite,
        enemy.frame,
        enemy.x - (sprite_get_width(enemy.sprite) * body_scale) / 2,
        enemy.y + 12 - body_height,
        body_scale,
        body_scale,
        0,
        c_white,
        1
    );


    // -----------------------------------------------------
    // HEALTH BAR
    // -----------------------------------------------------

    draw_set_color(c_black);

    draw_rectangle(
        enemy.x - 18,
        enemy.y - 28,
        enemy.x + 18,
        enemy.y - 23,
        false
    );

    draw_set_color(
        make_color_rgb(170, 35, 30)
    );

    draw_rectangle(
        enemy.x - 17,
        enemy.y - 27,
        enemy.x + 17,
        enemy.y - 24,
        false
    );


    // -----------------------------------------------------
    // WORD
    //
    // Every enemy shows its word, so the player can pick
    // one. The target also shows how far along it is.
    // -----------------------------------------------------

    var word_width = string_width(enemy.word);

    var word_x = enemy.x - word_width * 0.5;
    var word_y = enemy.y - 48;

    if (is_target)
    {
        var done_part =
            string_copy(enemy.word, 1, typing_index);

        var left_part =
            string_copy(
                enemy.word,
                typing_index + 1,
                string_length(enemy.word)
            );

        draw_set_color(make_color_rgb(120, 210, 100));

        draw_text(word_x, word_y, done_part);

        draw_set_color(c_white);

        draw_text(
            word_x + string_width(done_part),
            word_y,
            left_part
        );
    }
    else
    {
        draw_set_color(make_color_rgb(200, 195, 180));

        draw_text(word_x, word_y, enemy.word);
    }
}


// =========================================================
// PLAYER
// =========================================================


// ---------------------------------------------------------
// SHADOW
// ---------------------------------------------------------

draw_set_alpha(0.45);

draw_set_color(c_black);

draw_ellipse(
    player_x - 20,
    player_y + 14,
    player_x + 20,
    player_y + 22,
    false
);

draw_set_alpha(1);


// ---------------------------------------------------------
// CLOAK
// ---------------------------------------------------------

draw_set_color(
    make_color_rgb(65, 70, 58)
);

draw_triangle(
    player_x,
    player_y - 18,

    player_x - 18,
    player_y + 18,

    player_x + 18,
    player_y + 18,

    false
);


// ---------------------------------------------------------
// HEAD
// ---------------------------------------------------------

draw_set_color(
    make_color_rgb(145, 105, 75)
);

draw_circle(
    player_x,
    player_y - 18,
    9,
    false
);


// ---------------------------------------------------------
// HOOD
// ---------------------------------------------------------

draw_set_color(
    make_color_rgb(42, 43, 38)
);

draw_circle(
    player_x,
    player_y - 20,
    12,
    false
);


// ---------------------------------------------------------
// STAFF
// ---------------------------------------------------------

draw_set_color(
    make_color_rgb(115, 79, 44)
);

draw_line_width(
    player_x + 14,
    player_y - 32,
    player_x + 20,
    player_y + 24,
    4
);


// ---------------------------------------------------------
// PLAYER GLOW
// ---------------------------------------------------------

draw_set_alpha(0.12);

draw_set_color(
    make_color_rgb(220, 190, 100)
);

draw_circle(
    player_x,
    player_y,
    35,
    false
);

draw_set_alpha(1);