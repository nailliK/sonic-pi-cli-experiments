# frozen_string_literal: true

# -- IGNORE_START
require '../sonic-pi'
require './lib/globals'
require './lib/functions'
require './lib/clock'
require './lib/drum_sequences/standard_breaks'
# -- IGNORE_END

# House global variables
eval_file '~/Sites/Sonic Pi CLI Experiments/src/lib/globals.rb'

# Miscellaneous utility functions
eval_file '~/Sites/Sonic Pi CLI Experiments/src/lib/functions.rb'

# Basic MIDI clock signal that also increments a global tick
eval_file '~/Sites/Sonic Pi CLI Experiments/src/lib/clock.rb'

##### THE MAGIC HAPPENS BELOW #####
eval_file '~/Sites/Sonic Pi CLI Experiments/src/lib/drum_sequences/standard_breaks.rb'
eval_file '~/Sites/Sonic Pi CLI Experiments/src/lib/generators/drum.rb'

breaks = get :drum_sequence_standard_breaks
patterns = [breaks[0], breaks[1], breaks[2]]

drum_sequence = calculate_pattern_stats patterns

live_loop :drum_sequencer do
  lpb = get :global_lines_per_beat
  # gl = get :global_look
  gs = get :global_start

  if gs == 1
    drum_sequence.each do |instrument|
      puts instrument
    end
  end

  sleep 1 / lpb

end

set :output, {
  bd: { frequency: [3, 3, 1], total_positions: [3, 6, 3], avg_position: [1.0, 2.0, 3.0] },
  sn: { frequency: [3, 3], total_positions: [3, 6], avg_position: [1.0, 2.0] },
  ch: { frequency: [3, 3, 3, 3, 3, 3, 3, 3, 1], total_positions: [3, 6, 9, 12, 15, 18, 21, 24, 9], avg_position: [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0] }
}
