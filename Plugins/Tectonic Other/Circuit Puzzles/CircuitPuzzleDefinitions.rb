CIRCUIT_PUZZLES = {
    :TUTORIAL_BASIC => {
        :base_graphic => "tutorial_basic",
        :interactables =>
        [
            [:tswitch_left,3,2,0]
        ],
        :solution_states =>
        [
            [1], # Ideal (and only) solution. Disables nearby barrier (EV043).
        ]
    },
    :TUTORIAL_RESISTORS => {
        :base_graphic => "tutorial_resistors",
        :interactables =>
        [
            [:cross_switch,2,3,1]
        ],
        :solution_states =>
        [
            [0], # Ideal (and only) solution. Disables nearby barrier (EV057).
        ]
    },
    :WL_PRISON => {
        :base_graphic => "wl_prison",
        :interactables =>
        [
            [:tswitch_left,2,2,0],
            [:tswitch_left,4,2,3],
        ],
        :solution_states =>
        [
            [0,0], # Disables Integration Chamber barrier (map 382, EV041) and enables Integration Chamber ground signal (map 382, EV074), but not nearby barrier.
            [0,1], # Changes nothing: nearby barrier enabled, Integration Chamber barrier enabled.
            [0,2], # Changes nothing: nearby barrier enabled, Integration Chamber barrier enabled.
            [0,3], # (Initial state.) Nearby barrier enabled, Integration Chamber barrier enabled.
            [1,3], # Changes nothing: nearby barrier enabled, Integration Chamber barrier enabled.
            [1,1], # Changes nothing: nearby barrier enabled, Integration Chamber barrier enabled.
            [1,2], # Changes nothing: nearby barrier enabled, Integration Chamber barrier enabled.
            [1,0], # Ideal solution. Disables nearby barrier (EV026), Integration Chamber barrier (map 382, EV041), and Integration Chamber ground signal (map 382, EV074).
        ]
    },
    :WL_EXIT => {
        :base_graphic => "wl_exit",
        :interactables =>
        [
            [:cross_switch,2,2,0],
        ],
        :solution_states =>
        [
            [1], # Sole solution state. Disables nearby barrier (EV025), two barriers in Sandstone Switchbox (map 406, EV054 and EV015), and a ground signal in Sandstone Switchbox (map 406, EV015), and enables one ground signal in Sandstone Switchbox (map 406, EV052).
        ]
    },
    :RO_PRISON => {
        :base_graphic => "ro_prison",
        :interactables =>
        [
            [:tswitch_up,3,3,0],
        ],
        :solution_states =>
        [
            [1], # Sole solution state. Enables nearby ground signal (EV006), disables nearby barrier (EV045), disables Integration Chamber barrier (map 382, EV042), disables Integration Chamber ground signal (map 382, EV075).
        ]
    },
    :RO_EXIT => {
        :base_graphic => "ro_exit",
        :interactables =>
        [
            [:turntable,3,3,1],
            [:tswitch_up,4,2,0],
        ],
        :solution_states =>
        [
            [2,0], # Legal, but changes nothing.
            [3,0], # Legal, but changes nothing.
            [0,0], # Legal, but changes nothing.
            [1,1], # Legal, but changes nothing.
            [1,0], # (Initial state.) Legal, but changes nothing.
            [2,1], # Ideal solution. Disables nearby barrier (EV043), disables two barriers in Sandstone Switchbox (map 406, EV062 and 084), disables ground signal in Sandstone Switchbox (map 406, EV016).
        ]
    },
    :TC_PRISON => {
        :base_graphic => "tc_prison",
        :interactables =>
        [
            [:tswitch_right,3,2,0],
            [:tswitch_right,2,3,0],
            [:tswitch_up,3,3,0]
        ],
        :solution_states =>
        [
            [0,0,0], # (Initial state.) Legal, but changes nothing.
            [0,0,1], # Legal, but changes nothing.
            [0,1,0], # Legal, but changes nothing.
            [0,1,1], # Legal, but changes nothing.
            [1,0,0], # Legal, but changes nothing.
            [1,0,1], # Legal, but changes nothing.
            [1,1,1], # Legal, but changes nothing.
            [1,1,0], # Ideal solution. Enables nearby ground signal (EV039), disables nearby barrier (EV005), disables Integration Chamber barrier (map 382, EV043), disables Integration Chamber ground signal (map 382, EV076).
        ]
    },
    :TC_EXIT => {
        :base_graphic => "tc_exit",
        :interactables =>
        [
            [:tswitch_up,4,1,1],
            [:tswitch_up,3,2,1],
            [:tswitch_cross,2,3,3],
            [:turntable,4,3,1],
        ],
        :solution_states =>
        [
            [0,0,0,1], # Changes nothing: ground signal disabled, barrier enabled.
            [0,0,1,0], # Changes nothing: ground signal disabled, barrier enabled.
            [0,1,0,1], # Changes nothing: ground signal disabled, barrier enabled.
            [0,1,1,0], # Changes nothing: ground signal disabled, barrier enabled.
            [0,1,3,0], # Changes nothing: ground signal disabled, barrier enabled.
            [0,1,3,1], # Changes nothing: ground signal disabled, barrier enabled.
            [1,0,0,1], # Changes nothing: ground signal disabled, barrier enabled.
            [1,0,1,0], # Changes nothing: ground signal disabled, barrier enabled.
            [1,1,0,1], # Changes nothing: ground signal disabled, barrier enabled.
            [1,1,0,2], # Changes nothing: ground signal disabled, barrier enabled.
            [1,1,1,0], # Changes nothing: ground signal disabled, barrier enabled.
            [1,1,3,0], # Changes nothing: ground signal disabled, barrier enabled.
            [1,1,3,1], # (Initial state.) Ground signal disabled, barrier enabled.
            [0,1,0,2], # Enables nearby ground signal (EV043), but does not affect Sandstone Switchbox.
            [0,1,1,3], # Enables nearby ground signal (EV043), but does not affect Sandstone Switchbox.
            [0,1,3,2], # Enables nearby ground signal (EV043), but does not affect Sandstone Switchbox.
            [0,1,3,3], # Enables nearby ground signal (EV043), but does not affect Sandstone Switchbox.
            [1,0,0,2], # Enables nearby ground signal (EV043), but does not affect Sandstone Switchbox.
            [1,0,1,3], # Enables nearby ground signal (EV043), but does not affect Sandstone Switchbox.
            [1,1,1,3], # Enables nearby ground signal (EV043), but does not affect Sandstone Switchbox.
            [1,1,3,2], # Enables nearby ground signal (EV043), but does not affect Sandstone Switchbox.
            [1,1,3,3], # Enables nearby ground signal (EV043), but does not affect Sandstone Switchbox.
            [0,0,0,2], # Ideal solution. Enables nearby ground signal (EV043), disables Regieleki barrier (map 406, EV080), disables Regieleki ground signal (map 406, EV046).
            [0,0,1,3], # Ideal solution. Enables nearby ground signal (EV043), disables Regieleki barrier (map 406, EV080), disables Regieleki ground signal (map 406, EV046).
        ]
    },
    :IC_WAVE => {
        :base_graphic => "ic_wave",
        :interactables =>
        [
            [:ground_spinner,2,2,0],
        ],
        :solution_states =>
        [
            [0], # (Initial state.) In this state, interacting with EV002 toggles EV003 and EV004.
            [1], # In this state, interacting with EV002 toggles EV004.
            [2], # In this state, interacting with EV002 does nothing.
            [3], # In this state, interacting with EV002 toggles EV003.
        ]
    },
    :IC_AVATAR_CAGE => {
        :base_graphic => "ic_avatar_cage",
        :interactables =>
        [
            [:cross_switch,3,1,1],
            [:turntable,2,2,2],
            [:tswitch_cross,3,2,3],
            [:tswitch_up,4,2,1]
        ],
        :solution_states =>
        [
            [0,1,0,1], # Changes nothing: barrier is active, puzzle is inactive.
            [1,2,0,1], # Changes nothing: barrier is active, puzzle is inactive.
            [1,2,3,1], # (Initial state.) Barrier is active, puzzle is inactive.
            [0,1,1,0], # Disables barrier (EV049), triggering avatar attack. Puzzle still inactive.
            [1,2,1,0], # Disables barrier (EV049), triggering avatar attack. Puzzle still inactive.
            [1,2,3,0], # Disables barrier (EV049), triggering avatar attack. Puzzle still inactive.
            [0,0,0,1], # Enables puzzle (EV050) without disabling barrier.
            [0,0,2,1], # Enables puzzle (EV050) without disabling barrier.
            [1,0,0,1], # Ideal solution. Activates puzzle (EV050), but disables barrier (EV049), triggering avatar attack.
            [1,0,1,1], # Ideal solution. Activates puzzle (EV050), but disables barrier (EV049), triggering avatar attack.
            [1,0,2,1], # Ideal solution. Activates puzzle (EV050), but disables barrier (EV049), triggering avatar attack.
            [1,0,3,1], # Ideal solution. Activates puzzle (EV050), but disables barrier (EV049), triggering avatar attack.
            [1,0,1,0], # Ideal solution. Activates puzzle (EV050), but disables barrier (EV049), triggering avatar attack.
            [0,1,1,0], # Ideal solution. Activates puzzle (EV050), but disables barrier (EV049), triggering avatar attack.
            [1,0,2,0], # Ideal solution. Activates puzzle (EV050), but disables barrier (EV049), triggering avatar attack.
            [0,0,2,0], # Ideal solution. Activates puzzle (EV050), but disables barrier (EV049), triggering avatar attack.
            [1,0,3,0], # Ideal solution. Activates puzzle (EV050), but disables barrier (EV049), triggering avatar attack.
        ]
    },
    :IC_ELECTRIC_MAZE => {
        :base_graphic => "ic_electric_maze",
        :interactables =>
        [
            [:tswitch_up,2,1,0],
            [:tswitch_down,3,1,1],
            [:tswitch_cross,4,1,2],
        ],
        :solution_states =>
        [
            [0,0,0], # Barriers 1, 2 enabled. Barriers 3, 4 disabled. (i.e.: EV079 unchanged, EV104 unchanged, EV082 unchanged, EV084 unchanged)
            [0,0,2], # Barriers 1, 2 enabled. Barriers 3, 4 disabled. (i.e.: EV079 unchanged, EV104 unchanged, EV082 unchanged, EV084 unchanged)
            [0,1,0], # Barriers 1, 2 enabled. Barriers 3, 4 disabled. (i.e.: EV079 unchanged, EV104 unchanged, EV082 unchanged, EV084 unchanged)
            [0,1,1], # Barriers 1, 2 enabled. Barriers 3, 4 disabled. (i.e.: EV079 unchanged, EV104 unchanged, EV082 unchanged, EV084 unchanged)
            [0,1,2], # (Initial state.) Barriers 1 (EV079), 2 (EV104) enabled. Barriers 3 (EV082), 4 (EV084) disabled.
            [1,0,0], # Barrier 2 enabled. Barriers 1, 3, 4 disabled. (i.e.: EV079 switched, EV104 unchanged, EV082 unchanged, EV084 unchanged)
            [1,0,2], # Barrier 2 enabled. Barriers 1, 3, 4 disabled. (i.e.: EV079 switched, EV104 unchanged, EV082 unchanged, EV084 unchanged)
            [0,0,1], # Barriers 1, 3, 4 enabled. Barrier 2 disabled. (i.e.: EV079 unchanged, EV104 switched, EV082 switched, EV084 switched)
            [1,0,1], # Barriers 2, 3, 4 enabled. Barrier 1 disabled. (i.e.: EV079 switched, EV104 unchanged, EV082 switched, EV084 switched)
        ]
    },
    :IC_EXIT => {
        :base_graphic => "ic_exit",
        :interactables =>
        [
            [:tswitch_cross,1,2,1],
            [:turntable,3,3,1],
        ],
        :solution_states =>
        [
            [0,2], # Enables puzzle (EV068). Does not disable barrier or change ground signals.
            [1,1], # (Initial state.) Changes nothing: puzzle is disabled, barrier is enabled.
            [1,0], # Disables barrier (EV048). Enables nearby ground signal (EV045) and disables Integration Chamber ground signal (map 382, EV014).
            [0,3], # Ideal solution. Enables puzzle (EV068), disables barrier (EV048), enables nearby ground signal (EV045), disables Integration Chamber ground signal (map 382, EV014).
        ]
    },
}