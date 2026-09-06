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
// WAVE
//
// Under the clock, because the two belong together: clearing a
// wave is what puts seconds back on it.
// =========================================================

draw_set_color(c_white);

draw_text(
    timer_x,
    180,
    "WAVE"
);

draw_set_color(make_color_rgb(200, 120, 100));

draw_text(
    timer_x,
    210,
    string(wave)
);

// Everything this wave still has to send, plus everything of it
// still standing.
var wave_left =
    (wave_quota - wave_spawned)
    + array_length(enemies);

draw_set_color(make_color_rgb(150, 140, 130));

draw_text(
    timer_x,
    240,
    (wave_state == "breather")
        ? "cleared"
        : string(wave_left) + " left"
);


// =========================================================
// WAVE BANNER
//
// Announces a new encounter, then fades out of the way. Skipped
// once the run is over, so it cannot sit on top of GAME OVER.
// =========================================================

if (wave_banner > 0 && health > 0 && game_time > 0)
{
    var banner_text = "WAVE " + string(wave);

    // Full strength for the first half, fading over the second.
    draw_set_alpha(min(1, (wave_banner / wave_banner_max) * 2));

    draw_set_color(make_color_rgb(220, 190, 120));

    draw_text(
        (gui_w - string_width(banner_text)) * 0.5,
        gui_h * 0.30,
        banner_text
    );

    draw_set_alpha(1);
}


// =========================================================
// TYPING PANEL
//
// The passage is the weapon, so it gets the room it needs.
// The words are laid out and wrapped by hand — draw_text_ext
// would wrap them for us, but then there is no way to colour
// one word differently from the next — and the panel grows to
// fit however many lines that takes.
// =========================================================

var panel_w = 900;

var panel_x1 = (gui_w - panel_w) * 0.5;
var panel_x2 = panel_x1 + panel_w;

var text_x = panel_x1 + 30;
var text_w = panel_w - 60;

var space_w = string_width(" ");
var line_h = string_height("Mg") + 4;


// ---------------------------------------------------------
// LAY THE PASSAGE OUT
//
// One pass to place every word, so the height is known before
// the panel behind it is drawn.
// ---------------------------------------------------------

var word_count = array_length(phrase_words);

var word_offset_x = [];
var word_line = [];

var line_index = 0;
var cursor_x = 0;

for (var i = 0; i < word_count; i++)
{
    var this_w = string_width(phrase_words[i].text);

    if (cursor_x > 0 && cursor_x + this_w > text_w)
    {
        line_index++;

        cursor_x = 0;
    }

    word_offset_x[i] = cursor_x;
    word_line[i] = line_index;

    cursor_x += this_w + space_w;
}

var line_count = line_index + 1;

var status_h = string_height("Mg") + 4 + 8;

var panel_h =
    20                      // top padding
    + line_count * line_h   // the passage
    + 16                    // gap
    + 46                    // the input box
    + 10                    // gap
    + status_h              // label and progress bar
    + 18;                   // bottom padding

var panel_y2 = gui_h - 30;
var panel_y1 = panel_y2 - panel_h;

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


// ---------------------------------------------------------
// THE PASSAGE
//
// Words already spent are dimmed green, the word under the
// fingers is lit, and the rest of the passage waits in grey.
// ---------------------------------------------------------

var text_y = panel_y1 + 20;

for (var i = 0; i < word_count; i++)
{
    var word_entry = phrase_words[i];

    var wx = text_x + word_offset_x[i];
    var wy = text_y + word_line[i] * line_h;

    if (i < phrase_words_done)
    {
        draw_set_color(make_color_rgb(105, 150, 95));

        draw_text(wx, wy, word_entry.text);

        continue;
    }

    if (i > phrase_words_done)
    {
        draw_set_color(make_color_rgb(125, 120, 110));

        draw_text(wx, wy, word_entry.text);

        continue;
    }

    var lit_count = clamp(
        phrase_index - word_entry.start + 1,
        0,
        string_length(word_entry.text)
    );

    var lit_part = string_copy(word_entry.text, 1, lit_count);

    var unlit_part = string_copy(
        word_entry.text,
        lit_count + 1,
        string_length(word_entry.text)
    );

    draw_set_color(make_color_rgb(150, 225, 120));

    draw_text(wx, wy, lit_part);

    draw_set_color(make_color_rgb(245, 235, 210));

    draw_text(wx + string_width(lit_part), wy, unlit_part);
}


// ---------------------------------------------------------
// THE WORD UNDER THE FINGERS
// ---------------------------------------------------------

var box_x2 = panel_x2 - 30;

var box_y1 = text_y + line_count * line_h + 16;
var box_y2 = box_y1 + 46;

draw_set_color(make_color_rgb(50, 45, 40));

draw_rectangle(text_x, box_y1, box_x2, box_y2, false);

// The border goes red for a beat on a wrong key. Without it a
// mistyped character just silently refuses to advance, which
// reads as the game having frozen.
draw_set_color(
    (typo_flash > 0)
        ? make_color_rgb(200, 65, 50)
        : make_color_rgb(120, 95, 50)
);

draw_rectangle(text_x, box_y1, box_x2, box_y2, true);

var box_text_x = text_x + 20;
var box_text_y = box_y1 + 13;

if (phrase_words_done < word_count)
{
    var active_word = phrase_words[phrase_words_done];

    var active_count = clamp(
        phrase_index - active_word.start + 1,
        0,
        string_length(active_word.text)
    );

    var active_typed = string_copy(
        active_word.text,
        1,
        active_count
    );

    var active_rest = string_copy(
        active_word.text,
        active_count + 1,
        string_length(active_word.text)
    );

    draw_set_color(make_color_rgb(150, 225, 120));

    draw_text(box_text_x, box_text_y, active_typed);

    var typed_w = string_width(active_typed);

    draw_set_color(make_color_rgb(115, 110, 100));

    draw_text(
        box_text_x + typed_w,
        box_text_y,
        active_rest
    );

    if ((current_time div 500) mod 2 == 0)
    {
        draw_set_color(make_color_rgb(230, 225, 205));

        draw_text(box_text_x + typed_w, box_text_y, "|");
    }
}


// ---------------------------------------------------------
// PASSAGE PROGRESS
// ---------------------------------------------------------

var status_y = box_y2 + 10;

var status_text = "Typing...";

draw_set_color(make_color_rgb(185, 178, 160));

draw_text(
    panel_x1 + (panel_w - string_width(status_text)) * 0.5,
    status_y,
    status_text
);

var bar_y1 = status_y + string_height("Mg") + 4;
var bar_y2 = bar_y1 + 8;

draw_set_color(make_color_rgb(38, 34, 30));

draw_rectangle(text_x, bar_y1, box_x2, bar_y2, false);

var phrase_length = string_length(current_phrase);

var progress = (phrase_length > 0)
    ? clamp(phrase_index / phrase_length, 0, 1)
    : 0;

draw_set_color(make_color_rgb(120, 200, 95));

draw_rectangle(
    text_x,
    bar_y1,
    text_x + (box_x2 - text_x) * progress,
    bar_y2,
    false
);


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

    var score_line =
        "Score: " + string(score)
        + "     Waves cleared: " + string(waves_cleared);

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
