# frozen_string_literal: true

lpb = get(:global_lines_per_beat)
live_loop :midi_clock_output do
  tick
  set :global_look, look

  reseed if look.zero?
  midi_reset if look.zero?

  midi_start if look.zero?

  midi_clock_beat

  sleep 1.0 / lpb
end
