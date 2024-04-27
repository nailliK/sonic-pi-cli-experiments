use_bpm 82

# Timing
set :global_seed_max, 65_535
set :global_look, 0
set :global_lines_per_beat, 4.0
set :global_beats_per_sequence, get(:global_beats_per_beat) * 4.0

# Musicality
set :global_root_note, 0
set :global_root_scale, :phrygian
set :global_scale, (scale get(:global_root_note), get(:global_root_scale), num_octaves: 4)

live_loop :midi_clock_output do
  lpb = get(:global_lines_per_beat)
  tick

  reseed if look.zero?
  midi_reset if look.zero?
  set :global_look, look

  midi_start if look.zero?
  midi_clock_beat
  sleep 1.0 / lpb
end

##### ACID SEQUENCER #####

define :reseed do |seed_max|
  use_random_seed dice(seed_max)
end

define :quantize do |scale_root, scale_scale, note_value, num_octaves = 10|
  local_scale = scale(scale_root, scale_scale, num_octaves: num_octaves)
  closest_note = local_scale.min_by { |n| (n - note_value).abs }
  closest_note
end

define :proportion do |value, old_max, new_max|
  value * new_max.to_f / old_max
end

define :rand_bit do |prob|
  rand <= prob / 100.0 ? 1 : 0
end

define :step_condition do |condition_array, step_num|
  condition_array & (0x01 << step_num)
end

define :step_is_accent do |step_num|
  step_condition($accents, step_num) != 0
end

define :step_is_slid do |step_num|
  step_condition($slides, step_num) != 0
end

define :step_is_gated do |step_num|
  step_condition($gates, step_num) != 0
end

define :step_is_oct_up do |step_num|
  step_condition($oct_ups, step_num) != 0
end

define :step_is_oct_down do |step_num|
  step_condition($oct_downs, step_num) != 0
end

define :alter_note_on_octave_change do |note, scale_size, step_num|
  note += scale_size if step_is_oct_up step_num
  note -= scale_size if step_is_oct_down step_num
  note
end

define :get_pitch_change_density do |density|
  [8, [0, density].max].min
end

define :generate_gates do |step_min, step_max, density|
  seed = rand(get(:global_seed_max))
  gates = []

  step_max.times do |i|
    is_half = i < step_min
    on_off_density = step_min * density
  end

  # define :get_on_off_density do
  #   note_dens = $density - 7
  #   note_dens.abs
  # end

  #   puts "APPLY DENSITY"
  #
  #   latest_slide = 0
  #   latest_accent = 0
  #
  #   on_off_dens = get_on_off_density
  #   puts "OO_DENSITY: #{on_off_dens}"
  #   dens_prob = 10 + on_off_dens * 14
  #   puts "DEN_PROB: #{dens_prob}"
  #
  #   first_half = $regeneration_phase < 3
  #   if first_half
  #     $gates = 0
  #     $slides = 0
  #     $accents = 0
  #   end
  #
  #   $half_steps.times do |i|
  #     $gates = $gates << 1
  #     $gates |= rand_bit(dens_prob)
  #
  #     $slides = $slides << 1
  #     latest_slide = rand_bit(latest_slide ? 10 : 18)
  #     $slides |= latest_slide
  #
  #     $accents <<= 1
  #     latest_accent = rand_bit(latest_accent ? 7 : 16)
  #     $accents |= latest_accent
  #   end
  #
  #   $current_pattern_density = $density
end

define :generate_slides do

end

define :generate_notes do

end

define :generate_oct_ups do

end

define :generate_sequences do
  generate_gates
end

in_thread do
  set :seed, rand(get(:global_seed_max))
  set :step_min, 16
  set :step_max, 32

  set :density, rand(16)
  set :current_pattern_density, 0
  set :regen_phase, 0

  set :octave_offset, 0
  set :scale_size, get(:global_scale).size

  set :gates, generate_gates(get(:step_min, get(:step_max), get(:density)))
  set :slides, []
  set :notes, []
  set :oct_ups, []
  set :oct_downs, []

  set :step_current, 0
  set :step_previous, 0

  live_loop :acid_sequencer do
    generate_sequences
    tick
    sleep 1 / get(:global_lines_per_beat)
  end
end

# $step_max = 32
# $step_min = 16
# $step_current = 0
# $step_previous = 0
# $half_steps = 16
#
# $seed = 0
# $seed_min = 0
# $seed_max = 65_535
#
# $scale_size = $global_scale.size
#
# # 0 - 14
# $density = rand_i 0..14
# $current_pattern_density = 0
#
# # Sequence data
# $gates = 0
# $slides = 0
# $accents = 0
# $oct_ups = 0
# $oct_downs = 0
# $notes = []
# $octave_offset = 0
# $regeneration_phase = 0
#
# define :get_pitch_for_step do |step_num|
#   quant_note = 64 + $notes[step_num]
#   # Adding octave offset.
#   quant_note += $octave_offset * $scale_size
#
#   # Making adjustments based on step_num.
#   if step_is_oct_up(step_num)
#     quant_note += $scale_size
#   elsif step_is_oct_down(step_num)
#     quant_note -= $scale_size
#   end
#
#   quant_note = [0, [quant_note, 127].min].max
#
#   return quantize(quant_note) + ($global_root_note << 7) # SPi doesn't have this bit shift operation.
# end
#
# define :generate_pitches do
#   first_half = true if $regeneration_phase < 3
#
#   pitch_change_density = get_pitch_change_density
#
#   if pitch_change_density > 7
#     available_pitches = $scale_size - 1
#   elsif pitch_change_density < 2
#     available_pitches = pitch_change_density
#   end
#
#   range_from_scale = $scale_size - 3
#   range_from_scale = 3 if range_from_scale < 4
#
#   available_pitches = 3 + proportion(pitch_change_density - 3, 4, range_from_scale)
#   available_pitches = [available_pitches, 1].max
#   available_pitches = [available_pitches, $scale_size - 1].min
#
#   if first_half
#     $oct_ups = 0
#     $oct_downs = 0
#   end
#
#   max_steps = first_half ? $step_min : $step_max
#
#   start_step = first_half ? 0 : $step_min
#   (start_step...max_steps).each do |s|
#     force_repeat_note_prob = 50 - (pitch_change_density * 6)
#
#     if s.positive? && rand < force_repeat_note_prob / 100.0
#       $notes[s] = $notes[s - 1]
#     else
#       $notes[s] = rand_i 0...available_pitches + 1
#
#       if $oct_ups.zero?
#         $oct_ups = 0x1
#       else
#         $oct_ups |= 0x1
#       end
#
#       if $oct_downs.zero?
#         $oct_downs = 0x1
#       else
#         $oct_downs |= 0x1
#       end
#
#     end
#   end
# end
#
# define :get_on_off_density do
#   note_dens = $density - 7
#   note_dens.abs
# end
#
# define :update_step do |steps_state, step_num, state|
#   if state
#     steps_state |= (1 << step_num)
#   else
#     steps_state &= ~(1 << step_num)
#   end
#   steps_state
# end
#
# define :apply_density do
#   puts "APPLY DENSITY"
#
#   latest_slide = 0
#   latest_accent = 0
#
#   on_off_dens = get_on_off_density
#   puts "OO_DENSITY: #{on_off_dens}"
#   dens_prob = 10 + on_off_dens * 14
#   puts "DEN_PROB: #{dens_prob}"
#
#   first_half = $regeneration_phase < 3
#   if first_half
#     $gates = 0
#     $slides = 0
#     $accents = 0
#   end
#
#   $half_steps.times do |i|
#     $gates = $gates << 1
#     $gates |= rand_bit(dens_prob)
#
#     $slides = $slides << 1
#     latest_slide = rand_bit(latest_slide ? 10 : 18)
#     $slides |= latest_slide
#
#     $accents <<= 1
#     latest_accent = rand_bit(latest_accent ? 7 : 16)
#     $accents |= latest_accent
#   end
#
#   $current_pattern_density = $density
# end
#
# define :regenerate_all do
#   reseed
#
#   puts "PHASE: #{$regeneration_phase}"
#
#   generate_pitches if $regeneration_phase == 1 || $regeneration_phase == 3
#   apply_density if $regeneration_phase == 2 || $regeneration_phase == 4
#
#   $regeneration_phase += 1
#   regenerate_all if $regeneration_phase < 5
# end
#
# define :init do
#   $regeneration_phase = 1
#   regenerate_all
#
#   puts "generated"
# end
#
# live_loop :controller do
#   tick
#
#   init if look.zero?
#
#   $step_previous = $step_current
#   puts "S_P: #{$step_previous}"
#
#   $step_current += 1
#   $step_current = 0 if $step_current >= $step_max
#   puts "S_C: #{$step_current}"
#
#   use_pitch_bend = step_is_slid $step_previous
#   puts "PB: #{use_pitch_bend}"
#
#   sustain = 1.0 / $global_lines_per_beat
#   sustain /= 2 if step_is_accent $step_current
#   puts "SUSTAIN: #{sustain}"
#
#   puts "GATE: #{step_is_gated $step_current}"
#
#   midi_pitch_bend 1, channel: 5 if use_pitch_bend
#   midi get_pitch_for_step($step_current), channel: 5, sustain: sustain if step_is_gated $step_current
#
#   sleep 1.0 / $global_lines_per_beat
#
#   puts $regeneration_phase
# end
