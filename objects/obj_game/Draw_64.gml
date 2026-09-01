// Everything here is positioned against the real GUI size,
// so the HUD stays put if the room or window changes size.

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();


// =========================================================
// TOP TITLE
// =========================================================

draw_set_alpha(0.92);

draw_set_color(make_color_rgb(18, 16, 14));

draw_rectangle(
    25, 20,
    gui_w - 25, 82,
    false
);

draw_set_alpha(1);

draw_set_color(make_color_rgb(180, 140, 65));

draw_rectangle(
    25, 20,
    gui_w - 25, 82,
    true
);

draw_set_color(make_color_rgb(220, 190, 120));

draw_text(
    52,
    33,
    "THE PILGRIM'S PROGRESS"
);

draw_set_color(make_color_rgb(180, 170, 145));

draw_text(
    52,
    57,
    "CITY OF DESTRUCTION"
);


// =========================================================
// LEFT HUD
// =========================================================

draw_set_color(c_white);

draw_text(
    45,
    105,
    "HEALTH"
);

draw_set_color(make_color_rgb(180, 35, 30));

for (var h = 0; h < max_health; h++)
{
    var hx = 45 + h * 28;

    draw_circle(
        hx + 8,
        145,
        8,
        false
    );
}

draw_set_color(c_white);

draw_text(
    45,
    165,
    string(health) + " / " + string(max_health)
);

draw_text(
    45,
    195,
    "SCORE  " + string(score)
);

draw_text(
    45,
    225,
    "ENEMIES  " + string(array_length(enemies))
);


// =========================================================
// LEVEL
// =========================================================

draw_set_color(c_white);

draw_text(
    45,
    255,
    "LEVEL " + string(level)
);

draw_set_color(make_color_rgb(30, 27, 24));

draw_rectangle(
    45,
    280,
    245,
    295,
    false
);

draw_set_color(make_color_rgb(180, 140, 55));

var xp_width = 200 * (xp / xp_next);

draw_rectangle(
    45,
    280,
    45 + xp_width,
    295,
    false
);


// =========================================================
// TIMER
// =========================================================

var timer_x = gui_w - 160;

draw_set_color(c_white);

draw_text(
    timer_x,
    105,
    "TIME"
);

draw_set_color(make_color_rgb(220, 190, 100));

draw_text(
    timer_x,
    135,
    string(ceil(game_time))
);


// =========================================================
// TYPING PANEL
// =========================================================

var panel_w = 720;

var panel_x1 = (gui_w - panel_w) * 0.5;
var panel_x2 = panel_x1 + panel_w;

var panel_y2 = gui_h - 30;
var panel_y1 = panel_y2 - 130;

draw_set_alpha(0.96);

draw_set_color(make_color_rgb(19, 17, 15));

draw_rectangle(
    panel_x1,
    panel_y1,
    panel_x2,
    panel_y2,
    false
);

draw_set_alpha(1);

draw_set_color(make_color_rgb(185, 145, 65));

draw_rectangle(
    panel_x1,
    panel_y1,
    panel_x2,
    panel_y2,
    true
);


// Prompt
draw_set_color(make_color_rgb(220, 205, 170));

draw_text(
    panel_x1 + 30,
    panel_y1 + 20,
    current_phrase
);


// ---------------------------------------------------------
// WORD BEING TYPED
// ---------------------------------------------------------

draw_set_color(make_color_rgb(50, 45, 40));

draw_rectangle(
    panel_x1 + 30,
    panel_y1 + 60,
    panel_x2 - 30,
    panel_y1 + 110,
    false
);


var word_x = panel_x1 + 50;
var word_y = panel_y1 + 73;

if (typing_word != "")
{
    var typed_part =
        string_copy(
            typing_word,
            1,
            typing_index
        );

    var remaining_part =
        string_copy(
            typing_word,
            typing_index + 1,
            string_length(typing_word)
        );

    draw_set_color(make_color_rgb(120, 210, 100));

    draw_text(
        word_x,
        word_y,
        typed_part
    );

    var typed_width = string_width(typed_part);

    draw_set_color(make_color_rgb(210, 210, 195));

    draw_text(
        word_x + typed_width,
        word_y,
        remaining_part
    );
}
else
{
    draw_set_color(make_color_rgb(140, 135, 125));

    draw_text(
        word_x,
        word_y,
        "Type a word to attack..."
    );
}


// =========================================================
// GAME OVER
// =========================================================

if (health <= 0 || game_time <= 0)
{
    draw_set_alpha(0.85);

    draw_set_color(c_black);

    draw_rectangle(
        0,
        0,
        gui_w,
        gui_h,
        false
    );

    draw_set_alpha(1);

    var over_title = "THE NIGHT HAS COME";

    if (health <= 0)
    {
        over_title = "THE PILGRIM HAS FALLEN";
    }

    var score_line = "Score: " + string(score);

    var again_line = "Press ENTER to begin again";

    draw_set_color(make_color_rgb(220, 190, 120));

    draw_text(
        (gui_w - string_width(over_title)) * 0.5,
        gui_h * 0.42,
        over_title
    );

    draw_set_color(c_white);

    draw_text(
        (gui_w - string_width(score_line)) * 0.5,
        gui_h * 0.47,
        score_line
    );

    draw_text(
        (gui_w - string_width(again_line)) * 0.5,
        gui_h * 0.53,
        again_line
    );
}
