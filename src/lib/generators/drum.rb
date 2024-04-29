# frozen_string_literal: true

define :drum_calculate_density do |patterns|
  total_density = Hash.new(0)

  patterns.each do |pattern|
    pattern.each do |key, beats|
      if key == :name || key == :inst_keys
        next
      end

      instrument = key
      beats.each do |beat|
        total_density[instrument] += beat
      end
    end
  end

  total_density.each do |instrument, total|
    total_density[instrument] = total / (patterns.size.to_f * 16)
  end

  total_density
end

define :drum_calculate_totals do |patterns|
  total_beats = Hash.new { |h, k| h[k] = Array.new(16, 0) }

  patterns.each do |pattern|
    pattern.each do |key, beats|
      if key == :name || key == :inst_keys
        next
      end
      instrument = key
      beats.each_with_index do |beat, idx|
        total_beats[instrument][idx] += beat
      end
    end
  end

  total_beats.each do |instrument, beats|
    total_beats[instrument] = beats.map { |beat| beat / patterns.size.to_f }
  end

  total_beats
end

define :drum_calculate_weight do |totals, density, index|
  total_at_index = totals[index]
  weight = total_at_index * density
  weight
end

define :drum_calculate_pattern_stats do |patterns|
  reseed
  
  totals = drum_calculate_totals(patterns)
  densities = drum_calculate_density(patterns)
  output = {}

  totals.each do |instrument, beats|
    output[instrument] = {
      totals: beats,
      density: densities[instrument]
    }
  end

  output
end

live_loop :drum_sequence_controller do
  sequence = get :global_drum_sequence
  drum_keys = get :global_drum_keys
  lpb = get :global_lines_per_beat
  gs = get :global_start
  gl = get :global_look

  if gs == 1
    i = 0
    sequence.each do |instrument, stats|
      totals = stats[:totals].ring
      density = stats[:density]

      step_total = totals[gl]
      midi_trigger drum_keys[instrument], 10 if rand <= step_total

      i += 1
    end
  end

  sleep 1 / lpb
end
