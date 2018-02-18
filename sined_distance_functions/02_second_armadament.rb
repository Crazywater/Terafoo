notes = ring :D2, :E2, :F2, :G2, :F2, :E2, :F2, :E2
notes2 = ring :D2, :D2, :D2, :B2, :D2, :D2, :D2, :B2
notes3 = ring :D2, :E2, :F2, :G2, :G2, :F2, :E2, :A2, :D2, :E2, :F2, :G2, :G2, :F2, :E2, :D2

use_bpm 85

define :hardbass_base do |notes, slp, fullrange|
  len = fullrange ? slp : 0.5 * slp
  rls = fullrange ? 0.2 : 1.2
  with_fx :bitcrusher, bits: 3, amp: 1.5 do
    use_synth :sine
    note = notes.tick()
    play note, sustain: len, release: rls
    play note - 12, sustain: len, release: rls
    sleep slp
  end
end

define :hardbass_d do
  hardbass_base((ring :D2), 2, false)
end

define :hardbass do
  hardbass_base(notes, 2, false)
end

define :hardbass_filter do
  with_fx :lpf, cutoff: 60 do
    with_fx :level, amp: 0.8 do
      hardbass_base(notes, 2, true)
    end
  end
end

define :hardbass_filter2 do
  with_fx :lpf, cutoff: 60 do
    with_fx :level, amp: 0.8 do
      hardbass_base(notes2, 1, true)
    end
  end
end

define :hardbass_filter3 do
  with_fx :lpf, cutoff: 60 do
    with_fx :level, amp: 0.8 do
      hardbass_base(notes3, 2, true)
    end
  end
end

define :softbass do
  use_synth :sine
  8.times do
    note = notes.tick()
    play note, sustain: 2, release: 0.2
    sleep 2
  end
end

define :techno_base do |notes|
  note = notes.tick(:sine)
  use_synth :pulse
  with_fx :krush do
    with_fx :ixi_techno, phase: 2 do
      with_fx :slicer do |ctrl|
        with_fx :octaver do
          play note + 36, sustain: 2, release: 0, amp: 1.5
          play note + 48, sustain: 2, release: 0, amp: 1.5
          8.times do
            control ctrl, phase: [0.25, 0.125].choose
            sleep 0.25
          end
        end
      end
    end
  end
end

define :techno do
  techno_base(notes)
end

define :techno_n3 do
  techno_base(notes3)
end


define :valuefn do |cur_note, is_ascending, note|
  cur_as_float = hz_to_midi(midi_to_hz(cur_note))
  note_as_float = hz_to_midi(midi_to_hz(note))
  absdist = (note - cur_as_float).abs
  epsilon = 0.00001
  if (absdist < 0.01) or (is_ascending != (note_as_float > cur_as_float)) then
    return epsilon
  else
    return 1.0/absdist**2
  end
end
define :normalize do |map|
  sum = 0
  map.each do |key, val|
    sum +=val
  end
  map.each do |key, val|
    map[key] = val/sum
  end
  return map.sort_by{|key, val| val}
end

define :pick_note do |map|
  map.sort
  search_value = rand(1)
  sum = 0
  map.each do |key, val|
    sum += val
    if (sum > search_value) then return key end
  end
end

current_notes = [:D5, :D4]
is_ascending = [true, false]
define :gen_next_note do |index|
  cur_scale = scale(:D5, :diminished2)
  note_to_value = Hash.new
  cur_scale.each do |x|
    note_to_value[x] = valuefn(current_notes[index], is_ascending[index], x)
  end
  note_to_value = normalize(note_to_value)
  current_notes[index] = pick_note(note_to_value)
  if (rrand(0, 1) < 0.1) then
    is_ascending[index] = !is_ascending[index]
  end
  
  return current_notes[index]
end

scale_names.each do |scalename|
  sc = scale(:D2, scalename)
  test = notes.map{|sym| note(sym)} - sc
  if test.empty? then
    print scalename
  end
end
define :gen_duration do
  return [0.25, 0.5].choose
end

startbeat = 0
define :eudora do
  with_fx :bitcrusher, bits: 3, mix: 0.7 do
    use_synth :blade
    if rrand(0, 1) < 0.7 or (beat() - startbeat) > 13 then
      play gen_next_note(0), amp: 2, release: 0.5
      sleep gen_duration()
    else
      durations = [gen_duration(), gen_duration(), gen_duration()]
      ctrl = play gen_next_note(0), amp: 2, sustain: 1, release: 0.5, note_slide: 0.1
      durations.each do |dur|
        sleep dur
        control ctrl, note: gen_next_note(0)
      end
    end
    if (beat() - startbeat) > 16 then
      startbeat = beat()
    end
  end
end

samples_base = "C:/Program Files (x86)/Sonic Pi/etc/samples/"
define :masu do |name, i|
  return samples_base + "masu/mdk_" + name + (sprintf '%02d', i) + ".flac"
end

define :crispysn do |i|
  return samples_base + "freesnd/" + (118283 + i).to_s + "__crispydinner__lr-sn-" + (sprintf '%04d', i) + ".flac"
end

define :snare do
  sample crispysn(1), amp: 1.2
  sample masu("snare", 3), amp: 3.0, rpitch: rrand(-0.7, 0.7)
end

define :halfsnare do
  sample crispysn((1..12).to_a.choose), amp: 0.5
  sample masu("snare", 1), amp: 3.0, rpitch: rrand(-0.7, 0.7)
end

define :bdru do
  sample :bd_haus, amp: 1.2
end

define :crash do
  sample masu("crash", [3, 4, 6, 7, 8].choose), rpitch: rrand(-0.5, 0.7)
end

define :bass do
  bdru
  sleep 0.5
end

define :crashes do
  crash
  sleep 0.5
end

define :amen do
  bdru
  sleep 0.25
  bdru
  sleep 0.25
  snare
  sleep 0.25
  bdru
  sleep 0.125
  if rrand(0, 1) < 0.7 then
    halfsnare
  end
  sleep 0.125
  bdru
  sleep 0.125
  if rrand(0, 1) < 0.7 then
    halfsnare
  end
  sleep 0.125
  bdru
  sleep 0.25
  snare
  sleep 0.25
  bdru
  sleep 0.25
end

define :boomchak do
  4.times do
    bdru
    sleep 0.25
    bdru
    sleep 0.25
    snare
    crash
    sleep 0.25
  end
  bdru
  sleep 0.5
  bdru
  crash
  sleep 0.5
end


define :guitar_d do |note|
  with_fx :krush, mix: 0.9, cutoff: 130, res: 0.3, amp: 1.3 do
    with_fx :hpf, cutoff: 60 do
      with_fx :pan, pan: -0.3 do
        sample samples_base + "/guitar/" + note + "_1.flac", amp: 15
      end
      with_fx :pan, pan: 0.3 do
        sample samples_base + "/guitar/" + note + "_2.flac", amp: 15
      end
    end
  end
end

define :guitar_verse do
  guitar_d("d_e_f")
  sleep 6
  guitar_d("g")
  sleep 2
  guitar_d("f_e_f_e")
  sleep 8
end

define :guitar_verse2 do
  guitar_d("d_e_f")
  sleep 6
  guitar_d("g")
  sleep 2
  guitar_d("feda")
  sleep 8
  guitar_d("d_e_f")
  sleep 6
  guitar_d("g")
  sleep 2
  guitar_d("gf")
  sleep 4
  guitar_d("e")
  sleep 2
  guitar_d("d")
  sleep 2
end


define :reverse_crash do
  sleep 8
  reverse_crash_half
end

define :reverse_crash_half do
  sleep 3.5
  sample masu("crash_crescendo", 1), amp: 2
  sleep 8
end

define :random_rhythm do
  if (rrand(0, 1) < 0.1) then
    sample :bd_haus, amp: 0.5
  end
  if (rrand(0, 1) < 0.05) then
    snare
  end
  if (rrand(0, 1) < 0.02) then
    crash
  end
  if (rrand(0, 1) < 0.1) then
    halfsnare
  end
  sleep 1.0/6.0
end

define :ticks do
  sample masu("hatclosed", (1..25).to_a.choose)
  sleep 1.0/6.0
end

define :halfdbass do
  with_fx :level, amp: 0, amp_slide: 4 do |ctrl|
    control ctrl, amp: 2
    64.times do
      sample :bd_haus, amp: 0.6
      sleep 0.125
    end
  end
end

define :randblips_sustain do
  (8 * 8).times do
    use_arg_checks false
    with_fx :bitcrusher, bits: 4 do
      sample :ambi_piano, beat_stretch: rrand(0.3, 0.5), pitch: 50 + rrand(-50, 50), amp: rrand(0, 1), pan: rrand(-0.5, 0.5)
    end
    sleep 0.125
  end
end

scs = ring scale(:C4, :diminished2, num_octaves: 3), scale(:D4, :diminished2, num_octaves: 4)
define :chordia do |offset, isrand|
  use_synth :dsaw
  with_fx :tanh do
    use_synth_defaults release: 0.45
    sc = scs.tick()
    (8 * 4).times do
      if offset then
        if isrand then
          play sc.choose(), amp: 0.4, pan: rrand(-0.3, 0.3)
        end
        sc.tick(:blah)
        play sc.tick(:blah), amp: 0.4, pan: rrand(-0.3, 0.3)
      else
        if isrand then
          play sc.choose(), amp: 0.8, pan: rrand(-0.3, 0.3)
        else
          play sc.tick(), amp: 0.8, pan: rrand(-0.3, 0.3)
        end
      end
      sleep 1.0/8.0 + 0.0001
    end
  end
end

define :chordia_reg do
  chordia(false, false)
end
define :chordia_offset_1 do
  chordia(false, false)
end
define :chordia_offset do
  chordia(true, false)
end

define :crashonce do
  crash
  sleep 32
end

define :guitar_other do
  guitar_d("dd")
  guitar_d("eeee")
  sleep 3.06
  guitar_d("bbb")
  sleep 0.94
end

melody = ring 3, 0, 5, 7, 0, 7, 8, 7, 5, 7, 0,
  7, 5, 5, 5, 3, 5,
  3, 3, 3, 2, 3,
  2, 2, 2, 0, 2, 7,
  3, 0, 5, 7, 0, 7, 8, 7, 5, 7, 0,
  7, 5, 5, 5, 3, 5,
  3, 3, 3, 2, 3,
  2, 2, 2, 0, 2, 0
sleeps = ring 0.75, 0.75, 0.5, 0.75, 0.75, 0.5, 0.75, 0.75, 0.5, 0.75, 0.75,
  0.5, 0.25, 0.5, 0.5, 0.25, 0.5,
  0.25, 0.5, 0.5, 0.25, 0.5,
  0.25, 0.5, 0.5, 0.25, 0.5, 2
legato =
  ring false, false, true, false, false, true, true, true, true, false, false,
  true, false, false, false, true, true,
  false, false, false, true, true,
  false, false, false, true, true, true,
  true, true, true, true, true, true, true, true, true, true, true,
  true, false, false, true, true, true,
  false, false, true, true, true,
  false, false, true, true, true, true

define :testmelody do
  use_synth :dsaw
  duration = sleeps.tick(:sl)
  note = melody.tick(:mel)
  leg = legato.tick(:lg)
  if leg then
    stn = duration
    rls = 0.1 * duration
  else
    stn = 0.5 * duration
    rls = 0.5 * duration
  end
  use_synth_defaults cutoff: 130, detune: 0.15, attack: 0.01, sustain: stn, release: rls
  play :D3 + note, amp: 0.6, detune: 0.1
  play :D4 + note, amp: 0.4
  play :D5 + note, amp: 0.3
  play :D6 + note, amp: 0.15
  sleep duration
end

define :playall do |duration, functions|
  start_beat = beat()
  end_beat = start_beat + duration
  functions.each do |fn|
    in_thread do
      send(fn)
      while beat() < end_beat do
          send(fn)
        end
      end
    end
    sleep duration
  end
  
  define :main do
    playall(16, [:hardbass])
    playall(16, [:hardbass, :amen, :reverse_crash])
    playall(32, [:hardbass_filter, :amen, :crashes, :eudora, :guitar_verse, :techno])
    playall(12, [:hardbass_filter2, :guitar_other, :boomchak])
    playall(4, [:hardbass_d])
    playall(32, [:hardbass_filter, :amen, :crashes, :eudora, :guitar_verse, :techno])
    playall(8, [:chordia_offset_1, :chordia_offset, :random_rhythm, :ticks, :randblips_sustain, :reverse_crash_half, :halfdbass])
    playall(32, [:hardbass_filter3, :amen, :crashes, :guitar_verse2, :techno_n3, :testmelody])
    playall(16, [:hardbass_filter, :amen, :crashes, :eudora, :guitar_verse, :techno])
    playall(4, [:hardbass_filter2, :guitar_other, :boomchak])
    playall(32, [:hardbass_filter3, :amen, :crashes, :guitar_verse2, :techno_n3, :testmelody])
    playall(4, [:hardbass_d])
  end
  
  define :metro do
    sample :bd_haus, amp: 0.1
    sleep 0.5
  end
  
  
  main
  