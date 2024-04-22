use_bpm 128

global_look = 0
global_lines_per_beat = 4.0
global_sequence_length = 16

global_root_note = :c0
global_scale = :mixolydian
global_chord = (chord global_root_note, :sus4, num_octaves: 2)

in_thread do
  live_loop :midi_clock_output do
    tick

    global_look = look

    # midi_stop if global_look == 0
    midi_reset if global_look == 0
    midi_start if global_look == 0

    midi_clock_beat

    sleep 1
  end
end
