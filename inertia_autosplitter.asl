state("Inertia-Win64-Shipping") {
    // Counter that increases each time we load a level or we go to the main menu
    int count: "Inertia-Win64-Shipping.exe", 0x02FB49C0, 0x60, 0x50, 0x68, 0x2F8, 0x90, 0x230;
    // 1 if we are inGame, 0 elsewhere
    int inGame: "Inertia-Win64-Shipping.exe", 0x3176558;
    // Time in seconds, same as shown in the game
    float timer: "Inertia-Win64-Shipping.exe", 0x0316F6D0, 0x7C0, 0x11C;
    // Value that changed when a menu is shown. Used for the end of the run.
    int showMenu: "Inertia-Win64-Shipping.exe", 0x2FBEB20;
}

init {
    // Time offset for lvl 1 hack
    vars.realTimerOffset = 0f;
    // Current level ID
    current.levelID = 0;
}

start {
    return current.levelID == 1;
}

reset {
    return current.levelID == 0;
}

split {
    return current.levelID == old.levelID + 1;
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

    // RESET
    if (current.inGame == 0 && current.timer == 0f) {
        current.levelID = 0;
        // Also reset offset on livesplit reset
        vars.realTimerOffset = 0f;
    }
    // START
    if (current.levelID == 0 && old.inGame == 0 && current.inGame == 1) {
        current.levelID = 1;
    }
    // SPLIT:
    // * Ignore first split (we have a count increse at lvl 1 loading)
    //   Time "3f" is arbitrary (I don't think we'll finish lvl 1 in 3s xD)
    // * For end of run, check if the menu is shown
    if ((current.timer > 3f && current.count != old.count) ||
        (current.levelID == 32 && old.showMenu != current.showMenu)) {
        current.levelID++;
    }
}
