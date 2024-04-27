step_max = 32
step_min = 16
step_current = 0
step_previous = 0

half_steps = 16

seed = 0
seed_min = 0
seed_max = 65_535

global_root_note = 0
global_root_scale = :dorian
global_scale = (scale global_root_note, global_root_scale, num_octaves: 10)
scale_size = global_scale.size

# 0 - 14
density = 12
current_pattern_density = 0

# Sequence data
gates = 0
slides = 0
accents = 0
oct_ups = 0
oct_downs = 0
notes = []
octave_offset = 0

regeneration_phase = 0

define :rand_bit do |prob|
  rand <= prob / 100.0 ? 1 : 0
end

define :quantize do |note_value, num_octaves = 10|
  local_scale = scale(global_root_note, global_root_scale, num_octaves: num_octaves)
  closest_note = local_scale.min_by { |note| (note - note_value).abs }
  closest_note
end

define :reseed do
  seed = rand_i seed_min...seed_max
end

define :proportion do |value, old_max, new_max|
  (value.to_f / old_max) * new_max
end

define :get_pitch_change_density do
  [8, [0, density].max].min
end

define :step_condition do |condition_array, step_num|
  condition_array & (0x01 << step_num)
end

define :step_is_accent do |step_num|
  step_condition(accents, step_num)
end

define :step_is_slid do |step_num|
  step_condition(slides, step_num)
end

define :step_is_gated do |step_num|
  step_condition(gates, step_num)
end

define :step_is_oct_up do |step_num|
  step_condition(oct_ups, step_num)
end

define :step_is_oct_down do |step_num|
  step_condition(oct_downs, step_num)
end

define :alter_note_on_octave_change do |note, step_num|
  note += scale_size if step_is_oct_up step_num
  note -= scale_size if step_is_oct_down step_num
  note
end

define :get_pitch_for_step do |step_num|
  quant_note = alter_note_on_octave_change(notes[step_num] + 64, step_num)
  quant_note += quantize quant_note * scale_size / 12
  quant_note += octave_offset * scale_size
  quantize quant_note + global_root_note << 7
end

define :generate_pitches do
  first_half = true if regeneration_phase < 3

  pitch_change_density = get_pitch_change_density

  if pitch_change_density > 7
    available_pitches = scale_size - 1
  elsif pitch_change_density < 2
    available_pitches = pitch_change_density
  end

  range_from_scale = scale_size - 3
  range_from_scale = 3 if range_from_scale < 4

  available_pitches = 3 + proportion(pitch_change_density - 3, 4, range_from_scale)
  available_pitches = [available_pitches, 1].max
  available_pitches = [available_pitches, scale_size - 1].min

  if first_half
    oct_ups = 0
    oct_downs = 0
  end

  max_steps = first_half ? step_min : step_max

  start_step = first_half ? 0 : step_min
  (start_step...max_steps).each do |s|
    force_repeat_note_prob = 50 - (pitch_change_density * 6)

    if s.positive? && rand < force_repeat_note_prob / 100.0
      notes[s] = notes[s - 1]
    else
      notes[s] = rand_i 0...available_pitches + 1

      if oct_ups.zero?
        oct_ups = 0x1
      else
        oct_ups |= 0x1
      end

      if oct_downs.zero?
        oct_downs = 0x1
      else
        oct_downs |= 0x1
      end

    end
  end

  scale_size = 12 if scale_size.zero?
end

define :get_on_off_density do
  note_dens = density - 7
  note_dens.abs
end

define :update_step do |steps_state, step_num, state|
  if state
    steps_state |= (1 << step_num)
  else
    steps_state &= ~(1 << step_num)
  end
  steps_state
end

define :apply_density do
  latest_accent = false
  latest_slide = false

  on_off_density = get_on_off_density
  dense_prob = 10 + on_off_density * 14

  first_half = true if regeneration_phase < 3
  if first_half
    gates = 0
    slides = 0
    accents = 0
  end

  half_steps.times do |i|
    # Slide a bit to the left to make room for a new bit on the right.
    gates = update_step(gates, i, rand_bit(dense_prob))

    # Updating last step's state for slides
    latest_slide = rand_bit(latest_slide ? 10 : 18)
    slides = update_step(slides, i, latest_slide)

    # Updating last step's state for accents
    latest_accent = rand_bit(latest_accent ? 7 : 16)
    accents = update_step(accents, i, latest_accent)
  end

  current_pattern_density = density
end

define :regenerate_all do
  reseed

  case
  when regeneration_phase.odd?
    generate_pitches
  when regeneration_phase.even?
    apply_density
  else
    # type code here
  end

  regeneration_phase += 1
  regenerate_all if regeneration_phase < 5
end

define :init do
  regeneration_phase = 1
  regenerate_all
end

live_loop :testing do
  # init
  puts scale_size

  sleep 1
end

live_loop :controller do
  tick

  init if look.zero?

  step_previous = step_current
  step_current = look

  slide_start = get_pitch_for_step step_previous
  slide_end = get_pitch_for_step step_current
  gate_length = step_is_accent step_current ? 1.0 : 0.5
  use_pitch_bend = step_is_slid step_previous

  midi_pitch_bend 1, channel: 5
  midi slide_end, channel: 5, sustain: gate_length

  sleep 1
end
