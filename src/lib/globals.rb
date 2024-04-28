# frozen_string_literal: true

use_bpm 82

# Timing
set :global_seed_max, 65_535
set :global_seed, 0
set :global_look, 0
set :global_start, 0
set :global_lines_per_beat, 4.0
set :global_beats_per_sequence, get(:global_lines_per_beat) * 4.0

# Musicality
set :global_root_note, :Gb0
set :global_root_scale, :phrygian
set :global_scale, (scale get(:global_root_note), get(:global_root_scale), num_octaves: 4)
