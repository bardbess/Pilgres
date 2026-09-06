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
// SHOCKWAVES
//
// The ring a finished word or a finished passage leaves on the
// ground. Under the enemies, so it reads as coming off the
// pilgrim rather than sitting on top of the crowd.
// =========================================================

for (var wave_index = 0;
     wave_index < array_length(shockwaves);
     wave_index++)
{
    var ring = shockwaves[wave_index];

    draw_set_alpha(ring.alpha);

    draw_set_color(ring.color);

    draw_circle(ring.x, ring.y, ring.radius, true);

    draw_circle(ring.x, ring.y, ring.radius - 3, true);

    draw_set_alpha(1);
}


// =========================================================
// ENEMIES
// =========================================================

for (var enemy_index = 0;
     enemy_index < array_length(enemies);
     enemy_index++)
{
    var enemy = enemies[enemy_index];

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

        // Washes out white for a few frames when a word lands,
        // so a hit that does not kill still reads as a hit.
        ((enemy.flash > 0)
            ? make_color_rgb(255, 210, 200)
            : c_white),

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

    // Fills back from the left as the enemy is worn down.
    var hp_fraction = clamp(enemy.hp / enemy.max_hp, 0, 1);

    draw_set_color(
        (hp_fraction > 0.5)
            ? make_color_rgb(170, 35, 30)
            : make_color_rgb(210, 140, 40)
    );

    draw_rectangle(
        enemy.x - 17,
        enemy.y - 27,
        enemy.x - 17 + 34 * hp_fraction,
        enemy.y - 24,
        false
    );


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
// BODY
//
// Scaled to a fixed height off player_radius, the same way
// the enemies are, so the sprite's own pixel size doesn't
// decide how big the pilgrim looks.
// ---------------------------------------------------------

var player_height = player_radius * 3.2;

var player_scale =
    player_height / sprite_get_height(player_sprite);

var player_width =
    sprite_get_width(player_sprite) * player_scale;

// The sprite's origin is its top-left corner, so nothing
// centres itself. Put the feet in the shadow ellipse and
// work back up from there. Facing left flips the x scale, and
// the sprite then grows leftward from the draw position — so
// the half-width offset has to flip with it, or he jumps a
// body width sideways every time he turns.
draw_sprite_ext(
    player_sprite,
    player_frame,
    player_x - (player_width / 2) * player_facing,
    player_y + 18 - player_height,
    player_scale * player_facing,
    player_scale,
    0,
    c_white,
    1
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