# frozen_string_literal: true

define :reseed do
  set :global_seed, rand(get(:global_seed_max))

  use_random_seed get(:global_seed)
end

define :midi_trigger do |channel, note|
  midi note, port: port, channel: channel, sustain: 0.1
end

