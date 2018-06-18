state("Inertia-Win64-Shipping") {
    // Counter that increases each time we load a level or we go to the main menu
    int count: "Inertia-Win64-Shipping.exe", 0x02FB49C0, 0x60, 0x50, 0x68, 0x2F8, 0x90, 0x230;
    // 1 if we are inGame, 0 elsewhere
    int inGame: "Inertia-Win64-Shipping.exe", 0x3176558;
    // Time in seconds, same as shown in the game
    float timer: "Inertia-Win64-Shipping.exe", 0x031B1700, 0x50, 0x70, 0x5E8, 0x59C;
}

init {
    // Time offset for lvl 1 hack
    vars.realTimerOffset = 0f;
}

start {
    return old.inGame == 0 && current.inGame == 1;
}

reset {
    return current.inGame == 0 && current.timer == 0f;
}

split {
    // Ignore first split (we have a count increse at lvl 1 loading)
    // Time "3f" is arbitrary (I don't think we'll finish lvl 1 in 3s xD)
    return current.timer > 3f && current.count != old.count;
}

gameTime {
    return TimeSpan.FromSeconds(vars.realTimerOffset + current.timer);
}

update {
    // Current hack for lvl 1 to not reset IGT timer
    if (current.timer < old.timer) {
        if (old.count == current.count) {
            // We suppose we reset in-game (using R) at lvl 1, we don't reset timer
            vars.realTimerOffset += old.timer;
        } else {
            vars.realTimerOffset = 0f;
        }
    }
}
