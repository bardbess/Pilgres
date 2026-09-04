function spawn_enemy()
{
    var side = irandom(3);

    var ex;
    var ey;

    switch (side)
    {
        case 0:
            // Top
            ex = random_range(60, game_width - 60);
            ey = -30;
            break;

        case 1:
            // Right
            ex = game_width + 30;
            ey = random_range(60, game_height - 60);
            break;

        case 2:
            // Bottom
            ex = random_range(60, game_width - 60);
            ey = game_height + 30;
            break;

        case 3:
            // Left
            ex = -30;
            ey = random_range(60, game_height - 60);
            break;
    }


    var enemy_word =
        words[irandom(array_length(words) - 1)];


    var enemy_speed =
        random_range(0.25, 0.45)
        + level * 0.025;


    var enemy = {
        uid: enemy_uid_next++,

        x: ex,
        y: ey,

        radius: random_range(12, 17),

        speed: enemy_speed,

        word: enemy_word,

        hp: 1,

        points: 10 + level * 2,

        xp: 1
    };


    array_push(enemies, enemy);
}