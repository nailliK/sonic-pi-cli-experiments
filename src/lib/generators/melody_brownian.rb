# frozen_string_literal: true

define :melody_generate_brownian do |mood, walk|
  reseed

  global_scale = get :global_scale
  sequence_length = get :global_sequence_length

  # choose subset of global_scale where length is original length * mood
  scale_limit = (global_scale.length * mood).to_i
  # create subset of scale
  mood_scale = global_scale.slice(0, scale_limit)

  sequence = {
    notes: [],
    gates: [],
    slides: [],
    oct_ups: [],
    oct_downs: []
  }

  new_note_index = dice(scale_limit)
  sequence_length.times do |i|
    reseed if (i % sequence_length / 2).zero?
    new_note_index += range(new_note_index - walk, new_note_index + walk).choose

    sequence[:gates][i] = rand + (mood / 10)
    sequence[:slides][i] = rand + (mood / 10)
    sequence[:notes][i] = mood_scale.ring[new_note_index]
  end

  sequence
end

live_loop :melody_brownian do
  sequence = get :global_brownian_melody_sequence
  lpb = get :global_lines_per_beat
  gs = get :global_start
  gl = get :global_look

  current_note = sequence[:notes].ring[gl]

  if gs == 1
    use_slide = rand <= sequence[:slides].ring[gl]
    trigger_note = rand <= sequence[:gates].ring[gl]

    midi_pitch_bend use_slide ? 1 : 0

    if trigger_note
      midi_trigger current_note, 5, sequence[:slides].ring[gl].positive? ? 1 / lpb : 0.1
    end
  end

  sleep 1 / lpb
end
