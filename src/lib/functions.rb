# frozen_string_literal: true

define :reseed do
  set :global_seed, rand(get(:global_seed_max))

  use_random_seed get(:global_seed)
end

define :midi_trigger do |note, channel, sustain = 0.1|
  midi note, channel: channel, sustain: sustain
end

