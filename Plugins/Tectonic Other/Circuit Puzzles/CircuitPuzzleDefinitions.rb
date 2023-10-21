CIRCUIT_PUZZLES = {
    :TUTORIAL_BASIC => {
        :base_graphic => "tutorial_basic",
        :interactables =>
        [
            [:tswitch_left,3,2,0]
        ],
        :solution_states =>
        [
            [1],
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
            [0],
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
            [0],
        ]
    },
    :WL_EXIT => {
        :base_graphic => "wl_exit",
        :interactables =>
        [
            [:tswitch_left,2,2,0],
        ],
        :solution_states =>
        [
            [1], # ???
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
            [1], # ???
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
            [0,1], # ???
        ]
    },
    :TC_ENTRANCE => {
        :base_graphic => "tc_entrance",
        :interactables =>
        [
            [:tswitch_right,2,2,0],
        ],
        :solution_states =>
        [
            [1], # ???
        ]
    },
    :TC_LIMIT2 => {
        :base_graphic => "tc_limit2",
        :interactables =>
        [
            [:tswitch_cross,2,2,0],
            [:tswitch_cross,3,3,3],
        ],
        :solution_states =>
        [
            [3,1], # ???
        ]
    },
    :TC_LIMIT1_LIMIT2 => {
        :base_graphic => "tc_limit1_limit2",
        :interactables =>
        [
            [:tswitch_cross,3,2,0],
            [:turntable,3,3,0],
        ],
        :solution_states =>
        [
            [2,0], # ???
        ]
    },
    :TC_SIDEPATH => {
        :base_graphic => "tc_sidepath",
        :interactables =>
        [
            [:turntable,2,2,0],
            [:cross_switch,3,2,0],
            [:tswitch_cross,4,3,2],
        ],
        :solution_states =>
        [
            [1,1,0], # ???
        ]
    },
    :TC_PRISON => {
        :base_graphic => "tc_prison",
        :interactables =>
        [
            [:tswitch_cross,3,2,1],
            [:tswitch_cross,3,3,2],
        ],
        :solution_states =>
        [
            [0,0], # ???
        ]
    },
    :TC_EXIT => {
        :base_graphic => "tc_exit",
        :interactables =>
        [
            [:tswitch_right,3,2,0],
        ],
        :solution_states =>
        [
            [1], # ???
        ]
    },
    :IC_WAVE => {
        :base_graphic => "ic_wave",
        :interactables =>
        [
            [:ground_spinner,2,2,2],
        ],
        :solution_states =>
        [
            [], # TODO
        ]
    },
    :IC_AVATAR_CAGE => {
        :base_graphic => "ic_avatar_cage",
        :interactables =>
        [
            [:turntable,1,1,3],
            [:cross_switch,1,2,0],
            [:turntable,2,2,1],
            [:tswitch_cross,3,0,2],
        ],
        :solution_states =>
        [
            [], # TODO
        ]
    },
    :IC_ELECTRIC_MAZE => {
        :base_graphic => "ic_electric_maze",
        :interactables =>
        [
            [:tswitch_cross,2,3,0],
            [:cross_switch,2,4,1],
            [:tswitch_cross,3,0,2],
        ],
        :solution_states =>
        [
            [], # TODO
        ]
    },
    :IC_EXIT => {
        :base_graphic => "ic_exit",
        :interactables =>
        [
            [:tswitch_cross,1,2,1],
            [:turntable,3,3,2],
        ],
        :solution_states =>
        [
            [], # TODO
        ]
    },
}