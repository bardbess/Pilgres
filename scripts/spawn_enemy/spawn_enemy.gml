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


    // Tougher as the levels climb, so one finished word stops
    // being an instant kill.
    var enemy_hp = 2 + floor(level / 3);


    var enemy_speed =
        random_range(0.25, 0.45)
        + level * 0.025;

    var enemy = {
        uid: enemy_uid_next++,

        x: ex,
        y: ey,

        radius: random_range(12, 17),

        // Which way the enemy is walking. Picked from its
        // movement every step; this is just a starting value.
        sprite: spr_enemy_walkright,

        // Structs are not instances, so there is no automatic
        // image_index. The step event advances this by hand.
        frame: irandom(sprite_get_number(spr_enemy_walkright) - 1),

        speed: enemy_speed,

        hp: enemy_hp,
        max_hp: enemy_hp,

        // Knockback velocity, in pixels per step. Added on top
        // of the walk and decayed towards zero every step.
        kx: 0,
        ky: 0,

        // Frames of white hit-flash left.
        flash: 0,

        points: 10 + level * 2,

        xp: 1
    };


    array_push(enemies, enemy);
}