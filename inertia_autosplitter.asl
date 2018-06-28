state("Inertia-Win64-Shipping") {
    // Counter that increases each time we load a level or we go to the main menu
    int count: "Inertia-Win64-Shipping.exe", 0x328065C;
    // 1 if we are inGame, 0 elsewhere
    int inGame: "Inertia-Win64-Shipping.exe", 0x3175558;
    // Time in seconds, same as shown in the game
    float timer: "Inertia-Win64-Shipping.exe", 0x0316E6D0, 0x7C0, 0x11C;
    // Value that changed when a menu is shown. Used for the end of the run.
    int showMenu: "Inertia-Win64-Shipping.exe", 0x2FBDB20;
    // 3 when game is in pause menu, 2 elsewhere
    int inPauseMenu: "Inertia-Win64-Shipping.exe", 0x31A56B4;
}

init {
    // Time offset for lvl 1 hack
    vars.realTimerOffset = 0f;
    // Current level ID
    current.levelID = 0;
    // True if the timer has reset once (to avoid first reset)
    vars.hasResetOnce = false;
    // Time where last split has be done
    vars.lastSplitTime = 0f;
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
        if (vars.hasResetOnce && old.count == current.count) {
            // We suppose we reset in-game (using R) at lvl 1, we don't reset timer
            vars.realTimerOffset += old.timer;
        } else {
            vars.hasResetOnce = true;
            vars.realTimerOffset = 0f;
        }
    }

    // RESET
    if (current.inGame == 0 && current.timer == 0f) {
        // Reset custom variables
        current.levelID = 0;
        vars.realTimerOffset = 0f;
        vars.lastSplitTime = 0f;
        vars.hasResetOnce = false;
    }
    // START
    if (current.levelID == 0 && old.inGame == 0 && current.inGame == 1) {
        current.levelID = 1;
    }
    // SPLIT:
    // * Not in pause menu
    // * For last level, avoid "double split" bug (Time "3f" is arbitrary)
    // * Ignore first split (we have a count increse at lvl 1 loading)
    //   Time "3f" is arbitrary (I don't think we'll finish lvl 1 in 3s xD)
    // * For end of run, check if the menu is shown (previous value + 1)
    if (current.inPauseMenu != 3 && (
        (current.timer > 3f && current.count != old.count) ||
        (current.levelID == 32 && current.timer > vars.lastSplitTime + 3f && current.showMenu != old.showMenu))
       ) {
        current.levelID++;
        vars.lastSplitTime = current.timer;
    }
}
