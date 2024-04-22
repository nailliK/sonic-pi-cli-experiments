step = 0
step_max = 32
step_min = 16
half_steps = 16

seed = 0
seed_min = 0
seed_max = 65535


# root note and scale are provided as global vars
octave_offset = 0
scale_size = scale(global_root_note, global_scale).size

# 0 - 14
density = 12


gate_off_clock = 0
cycle_time = 0

# We can leverage Sonic Pi's slide functionality
slide_start_cv = 0
slide_end_cv = 0

# Sequence data
gates = Array.new(step_max, 0)
slides = Array.new(step_max, 0)
accents = Array.new(step_max, 0)
oct_ups = Array.new(step_max, 0)
oct_downs = Array.new(step_max, 0)
notes = Array.new(step_max, 0)

current_gate = 0
current_pitch = 0

current_gate_cv = 0
current_pitch_cv = 0

current_slide_start = 0
current_slide_end = 0

curr_step_semitone = 0

regeneration_phase = 0

define :reseed do
  seed = rand_i(seed_min, seed_max)
end

define :proportion do |value, old_max, new_max|
  return (value.to_f / old_max) * new_max
end

define :get_pitch_change_density do
  return [8, [0, density].max].min
end

define :get_pitch_for_step do |step_num|
end

define :get_next_step do |step|
end

define :generate_pitches do
  first_half = true if regeneration_phase < 3

  pitch_change_density = get_pitch_change_density

  if pitch_change_density > 7
    available_pitches = scale_size - 1
  elsif pitch_change_density < 2
    available_pitches = pitch_change_density
  else
    # 3-7
  end

  range_from_scale = scale_size - 3
  range_from_scale = 3 if range_from_scale < 4

  available_pitches = 3 + proportion(pitch_change_dens - 3, 4, range_from_scale)
  available_pitches = [available_pitches, 1].max
  available_pitches = [available_pitches, scale_size - 1].min

  if first_half
    oct_ups = Array.new(step_max, 0)
    oct_downs = Array.new(step_max, 0)
  end

  max_steps = first_half ? step_min : step_max

  start_step = first_half ? 0 : step_min
  (start_step...max_steps).each do |s|
    force_repeat_note_prob = 50 - (pitch_change_density * 6)

    if s > 0 && rand < force_repeat_note_prob / 100.0
      notes[s] = notes[s - 1]
    else
      notes[s] = rand_i(0, available_pitches + 1)

      oct_ups << 1
      oct_downs << 1

      if rand < 0.4
        if rand < 0.5
          oct_ups[-1] = oct_ups[-1] | 0x1
        else
          oct_downs[-1] = oct_downs[-1] | 0x1
        end
      end
    end
  end

  scale_size = 12 if scale_size == 0
end

define :apply_density do
end

define :regenerate_all do
  reseed

  case regeneration_phase
  # First half of the sequence
  when 1
    generate_pitches
    inc regeneration_phase
  when 2
    apply_density
    inc regeneration_phase

  # Second half of the sequence
  when 3
    generate_pitches
    inc regeneration_phase
  when 4
    apply_density
    inc regeneration_phase
  else
    # done
  end

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