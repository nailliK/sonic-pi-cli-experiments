# frozen_string_literal: true

# -- IGNORE_START
require '../sonic-pi'
require './lib/globals'
require './lib/functions'
require './lib/clock'
require './lib/drum_sequences/hip_hop'
require './lib/generators/drum'
require './lib/generators/melody_brownian'
# -- IGNORE_END

# House global variables
eval_file '~/Sites/Sonic Pi CLI Experiments/src/lib/globals.rb'

# Miscellaneous utility functions
eval_file '~/Sites/Sonic Pi CLI Experiments/src/lib/functions.rb'

# Basic MIDI clock signal that also increments a global tick
eval_file '~/Sites/Sonic Pi CLI Experiments/src/lib/clock.rb'

##### THE MAGIC HAPPENS BELOW #####

# Grouping of drum patterns
eval_file '~/Sites/Sonic Pi CLI Experiments/src/lib/drum_sequences/hip_hop.rb'
# Drum sequence generation and live loop
eval_file '~/Sites/Sonic Pi CLI Experiments/src/lib/generators/drum.rb'

# Brownian motion melody generation and live loop
eval_file '~/Sites/Sonic Pi CLI Experiments/src/lib/generators/melody_brownian.rb'

# Declare patterns and store analyzed patterns in global_drum_sequence in sequencer live loop
patterns = get :drum_sequence_hip_hop
set :global_drum_sequence, drum_calculate_pattern_stats(patterns)

# Declare the melody sequence
set :global_brownian_melody_sequence, melody_generate_brownian(8, 2)

# start the clock
set :global_start, 1
