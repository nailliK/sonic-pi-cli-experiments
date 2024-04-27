define :midi_trigger do |channel, note|
  midi note, port: port, channel: channel, sustain: 0.1
end
