/// @DnDAction : YoYo Games.Common.Execute_Code
/// @DnDVersion : 1
/// @DnDHash : 20D9338A
/// @DnDArgument : "code" "/// @description Execute Code$(13_10)$(13_10)// =========================================================$(13_10)// ENEMIES$(13_10)// =========================================================$(13_10)$(13_10)for (var enemy_index = 0;$(13_10)     enemy_index < array_length(enemies);$(13_10)     enemy_index++)$(13_10){$(13_10)    var enemy = enemies[enemy_index];$(13_10)$(13_10)    var is_target =$(13_10)        (enemy.uid == target_uid);$(13_10)$(13_10)$(13_10)    // -----------------------------------------------------$(13_10)    // TARGET RING$(13_10)    // -----------------------------------------------------$(13_10)$(13_10)    if (is_target)$(13_10)    {$(13_10)        draw_set_color($(13_10)            make_color_rgb(190, 150, 50)$(13_10)        );$(13_10)$(13_10)        draw_circle($(13_10)            enemy.x,$(13_10)            enemy.y,$(13_10)            enemy.radius + 7,$(13_10)            true$(13_10)        );$(13_10)    }$(13_10)$(13_10)$(13_10)    // -----------------------------------------------------$(13_10)    // SHADOW$(13_10)    // -----------------------------------------------------$(13_10)$(13_10)    draw_set_alpha(0.4);$(13_10)$(13_10)    draw_set_color(c_black);$(13_10)$(13_10)    draw_ellipse($(13_10)        enemy.x - 14,$(13_10)        enemy.y + 8,$(13_10)        enemy.x + 14,$(13_10)        enemy.y + 15,$(13_10)        false$(13_10)    );$(13_10)$(13_10)    draw_set_alpha(1);$(13_10)$(13_10)$(13_10)    // -----------------------------------------------------$(13_10)    // BODY$(13_10)    // -----------------------------------------------------$(13_10)$(13_10)    draw_set_color($(13_10)        make_color_rgb(50, 45, 42)$(13_10)    );$(13_10)$(13_10)    draw_circle($(13_10)        enemy.x,$(13_10)        enemy.y + 5,$(13_10)        enemy.radius,$(13_10)        false$(13_10)    );$(13_10)$(13_10)$(13_10)    // -----------------------------------------------------$(13_10)    // HOOD$(13_10)    // -----------------------------------------------------$(13_10)$(13_10)    draw_set_color($(13_10)        make_color_rgb(75, 72, 68)$(13_10)    );$(13_10)$(13_10)    draw_circle($(13_10)        enemy.x,$(13_10)        enemy.y - 7,$(13_10)        enemy.radius * 0.65,$(13_10)        false$(13_10)    );$(13_10)$(13_10)$(13_10)    // -----------------------------------------------------$(13_10)    // FACE$(13_10)    // -----------------------------------------------------$(13_10)$(13_10)    draw_set_color($(13_10)        make_color_rgb(145, 105, 75)$(13_10)    );$(13_10)$(13_10)    draw_circle($(13_10)        enemy.x,$(13_10)        enemy.y - 5,$(13_10)        enemy.radius * 0.30,$(13_10)        false$(13_10)    );$(13_10)$(13_10)$(13_10)    // -----------------------------------------------------$(13_10)    // WEAPON$(13_10)    // -----------------------------------------------------$(13_10)$(13_10)    draw_set_color($(13_10)        make_color_rgb(110, 82, 52)$(13_10)    );$(13_10)$(13_10)    draw_line_width($(13_10)        enemy.x + 8,$(13_10)        enemy.y - 4,$(13_10)        enemy.x + 17,$(13_10)        enemy.y + 14,$(13_10)        3$(13_10)    );$(13_10)$(13_10)$(13_10)    // -----------------------------------------------------$(13_10)    // HEALTH BAR$(13_10)    // -----------------------------------------------------$(13_10)$(13_10)    draw_set_color(c_black);$(13_10)$(13_10)    draw_rectangle($(13_10)        enemy.x - 18,$(13_10)        enemy.y - 28,$(13_10)        enemy.x + 18,$(13_10)        enemy.y - 23,$(13_10)        false$(13_10)    );$(13_10)$(13_10)    draw_set_color($(13_10)        make_color_rgb(170, 35, 30)$(13_10)    );$(13_10)$(13_10)    draw_rectangle($(13_10)        enemy.x - 17,$(13_10)        enemy.y - 27,$(13_10)        enemy.x + 17,$(13_10)        enemy.y - 24,$(13_10)        false$(13_10)    );$(13_10)$(13_10)$(13_10)    // -----------------------------------------------------$(13_10)    // WORD$(13_10)    //$(13_10)    // Every enemy shows its word, so the player can pick$(13_10)    // one. The target also shows how far along it is.$(13_10)    // -----------------------------------------------------$(13_10)$(13_10)    var word_width = string_width(enemy.word);$(13_10)$(13_10)    var word_x = enemy.x - word_width * 0.5;$(13_10)    var word_y = enemy.y - 48;$(13_10)$(13_10)    if (is_target)$(13_10)    {$(13_10)        var done_part =$(13_10)            string_copy(enemy.word, 1, typing_index);$(13_10)$(13_10)        var left_part =$(13_10)            string_copy($(13_10)                enemy.word,$(13_10)                typing_index + 1,$(13_10)                string_length(enemy.word)$(13_10)            );$(13_10)$(13_10)        draw_set_color(make_color_rgb(120, 210, 100));$(13_10)$(13_10)        draw_text(word_x, word_y, done_part);$(13_10)$(13_10)        draw_set_color(c_white);$(13_10)$(13_10)        draw_text($(13_10)            word_x + string_width(done_part),$(13_10)            word_y,$(13_10)            left_part$(13_10)        );$(13_10)    }$(13_10)    else$(13_10)    {$(13_10)        draw_set_color(make_color_rgb(200, 195, 180));$(13_10)$(13_10)        draw_text(word_x, word_y, enemy.word);$(13_10)    }$(13_10)}"
/// @description Execute Code

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

    draw_set_color(
        make_color_rgb(50, 45, 42)
    );

    draw_circle(
        enemy.x,
        enemy.y + 5,
        enemy.radius,
        false
    );


    // -----------------------------------------------------
    // HOOD
    // -----------------------------------------------------

    draw_set_color(
        make_color_rgb(75, 72, 68)
    );

    draw_circle(
        enemy.x,
        enemy.y - 7,
        enemy.radius * 0.65,
        false
    );


    // -----------------------------------------------------
    // FACE
    // -----------------------------------------------------

    draw_set_color(
        make_color_rgb(145, 105, 75)
    );

    draw_circle(
        enemy.x,
        enemy.y - 5,
        enemy.radius * 0.30,
        false
    );


    // -----------------------------------------------------
    // WEAPON
    // -----------------------------------------------------

    draw_set_color(
        make_color_rgb(110, 82, 52)
    );

    draw_line_width(
        enemy.x + 8,
        enemy.y - 4,
        enemy.x + 17,
        enemy.y + 14,
        3
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