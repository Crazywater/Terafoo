use_bpm 90

define :t1 do
  use_synth :sine
  use_synth_defaults release: 0.5
  with_fx :panslicer, probability: 0.5, prob_pos: 0.5 do
    with_fx :ixi_techno do |ctrl|
      with_fx :tanh do
        32.times do
          control ctrl, phase: rrand(0.1, 0.5)
          play chord(:d, :diminished7).choose
          sleep 0.25
        end
      end
    end
  end
end

define :t2 do
  use_synth :chiplead
  use_synth_defaults release: 0.2
  pattern = (ring :cb3, :e3, :g3, :e3)
  (2 * 16).times do
    play pattern.tick + 1
    sleep 0.125
  end
  (2 * 16).times do
    play pattern.tick + 2
    sleep 0.125
  end
end

define :t3 do
  use_synth :saw
  use_synth_defaults release: 0.3, sustain: 0.9
  4.times do
    play chord(:D1, :diminished7).choose
    sleep 1
  end
  4.times do
    play chord(:Eb1, :diminished7).choose
    sleep 1
  end
end

define :t3_verse do
  use_synth :saw
  use_synth_defaults release: 0.3
  base = :A1
  play base + 7, sustain: 0.65
  sleep 0.75
  play base + 6, sustain: 1.15
  sleep 1.25
  play base + 3, sustain: 0.65
  sleep 0.75
  play base + 4, sustain: 1.15
  sleep 1.25
end
notes = [:d3, :f3, :ab3, :cb3]

define :t3_solo do
  use_synth :saw
  use_synth_defaults sustain: 0.1, release: 0.3
  note = notes.tick(:t3s)
  16.times do
    play note - 24
    sleep 0.25
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
  sample crispysn(1), amp: 0.7
  sample masu("snare", 3), amp: 5.0
end

define :halfsnare do
  sample crispysn((1..12).to_a.choose), amp: 0.5
  sample masu("snare", 1), amp: 3.0
end

define :bdru do
  sample :bd_haus
end

define :guitar_s do |note, amp|
  with_fx :krush, mix: 0.8, cutoff: 130, res: 0.2, amp: amp do
    with_fx :hpf, cutoff: 35 do
      with_fx :hpf, cutoff: 50, mix: 0.5 do
        with_fx :pan, pan: -0.2 do
          sample samples_base + "/guitar/" + note + "_1.flac", amp: 5
        end
        with_fx :pan, pan: 0.2 do
          sample samples_base + "/guitar/" + note + "_2.flac", amp: 5
        end
      end
    end
  end
end

define :guitar_louder do
  with_fx :level, amp: 0.25, amp_slide: 16 do |ctrl|
    control ctrl, amp: 0.7
    2.times do
      guitar_s("guitar_ds", 0.9)
      sleep 8
    end
  end
end

define :guitar_verse  do
  guitar_s("guitar_ds", 0.9)
  sleep 8
end

define :guitar_dim  do
  guitar_s("guitar_dim", 0.8)
  sleep 16
end

define :ixi_guitar_verse  do
  with_fx :ixi_techno, mix: 0.2 do
    guitar_s("guitar_ds", 0.9)
  end
  sleep 8
end


define :guitar_bridge do
  guitar_s("guitar_bridged", 1)
  sleep 4
  guitar_s("guitar_bridged_eb", 1)
  sleep 3.5
  guitar_s("guitar_bridged_eb2", 0.9)
  sleep 0.5
end

define :bd_only do
  sample :bd_haus
  sleep 0.5
end

define :screech do |duration, amp|
  use_synth :blade
  use_synth_defaults vibrato_depth: 0.25, vibrato_delay: 0, vibrato_onset: 0, note_slide: 0.25, sustain: duration, release: 0, amp: amp
  base = :A5
  firstsleep = true
  anticipate_slide = 0.125
  with_fx :tanh do
    ctrl = play base + 7
    (duration/4).times do
      control ctrl, note: base + 7
      sleep 0.75 - (firstsleep ? anticipate_slide : 0)
      firstsleep = false
      control ctrl, note: base + 6
      sleep 1.25
      control ctrl, note: base + 3
      sleep 0.75
      control ctrl, note: base + 4
      sleep 1.25
    end
    sleep anticipate_slide
  end
end

define :screech_16_v2 do
  with_transpose 7 do
    screech(16, 0.8)
  end
end


define :screech_16 do screech(16) end
define :screech_32 do screech(32, 0.8) end
define :screech_32_07 do screech(32, 0.7) end

define :crashintro do
  sleep 14
  4.times do |i|
    sample masu("crash", i + 1)
    sleep 0.5
  end
end

define :crsh do
  sample masu("ride", (6..8).to_a.choose), amp: 0.7
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
  halfsnare
  sleep 0.125
  bdru
  sleep 0.125
  halfsnare
  sleep 0.125
  bdru
  sleep 0.25
  snare
  sleep 0.25
  bdru
  sleep 0.25
end

define :amen_no_half do
  bdru
  sleep 0.25
  bdru
  sleep 0.25
  snare
  sleep 0.25
  bdru
  sleep 0.25
  bdru
  sleep 0.25
  bdru
  sleep 0.25
  snare
  sleep 0.5
end

define :boomclack do
  bdru
  sleep 0.5
  snare
  sleep 0.75
  bdru
  sleep 0.5
  snare
  sleep 0.25
end

define :otherbeat do
  2.times do |i|
    bdru
    crsh
    sleep 0.25
    bdru
    crsh
    sleep 0.25
    snare
    sleep 0.25
    bdru
    crsh
    sleep 0.125
    if rrand(0, 1) < 0.5 then
      halfsnare
    end
    sleep 0.125
    bdru
    crsh
    sleep 0.125
    if rrand(0, 1) < 0.5 then
      halfsnare
    end
    sleep 0.125
    bdru
    crsh
    sleep 0.25
    snare
    sleep 0.25
    if i == 1 then
      snare
    end
    sleep 0.25
  end
end

define :hihat do
  sample masu("hatsmack", (2..6).to_a.choose)
  sleep 0.25
end

define :crashhat do
  sample masu("crash", (2..6).to_a.choose), amp: 0.5
  sleep 0.25
end
define :play_supersaw do |note, length|
  use_synth :dsaw
  args = [cutoff: 130, detune: 0.4, attack: 0.01,  release: 0.05, sustain: length]
  with_fx :level, amp: 0.25 do
    play note, *args
    play note + 12, *args
    play note + 24, *args
    play note + 36, *args
  end
end

scaleidx = 0
define :advancescale do
  scaleidx = scaleidx + 1
  sleep 4
end


define :testeuda do
  32.times do
    use_synth :chiplead
    use_synth_defaults release: 0.2, amp: 0.5
    sc = cur_scale(3)
    play (sc + sc.reverse).tick()
    sleep 0.125
  end
end

define :testeuda2 do
  with_fx :flanger, phase: 2 do
    use_synth :tri
    use_synth_defaults attack: 0.1, attack: 0.2, sustain: 1.8, release: 2, amp: 0.35
    4.times do
      sc = cur_scale(1)
      play_chord [sc[1], sc[4]], release: 4
      sleep 4.05
    end
  end
end

define :testeuda3 do
  note = notes.tick() - 24
  with_fx :slicer do |ctrl|
    play_supersaw note, 4
    16.times do
      control ctrl, phase: [0.125, 0.25].choose
      sleep 0.25
    end
  end
end

define :cur_scale do |octaves|
  scl = (ring :kumoi, :hirajoshi, :iwato, :kumoi)
  return scale(:d, scl[scaleidx], num_octaves: octaves)
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
  
  define :crashonce do
    sample masu("crash", [1, 2, 3, 4].choose)
    sleep 16
  end
  
  define :main do
    playall(8, [:t2])
    playall(8, [:t1, :t2, :t3])
    playall(8, [:t1, :t2, :t3, :bd_only])
    playall(16, [:bd_only, :guitar_louder, :t1, :t2, :t3, :crashintro])
    playall(2, [])
    playall(16, [:t3_verse, :guitar_verse, :screech_32_07, :amen_no_half, :crashhat, :crashonce])
    playall(16, [:t3_verse, :guitar_verse, :amen, :crashhat])
    playall(16, [:guitar_bridge, :t1, :t2, :t3, :otherbeat, :crashintro])
    playall(16, [:t3_verse, :guitar_verse, :screech_32, :amen, :crashhat])
    playall(16, [:t3_verse, :ixi_guitar_verse, :amen, :crashhat])
    playall(16, [:testeuda, :testeuda2, :advancescale])
    playall(16, [:testeuda, :testeuda2, :testeuda3, :advancescale])
    playall(16, [:t3_solo, :testeuda, :testeuda2, :testeuda3, :boomclack, :crashintro, :advancescale])
    playall(16, [:t3_solo, :testeuda3, :amen, :crashhat, :guitar_dim, :crashonce])
    playall(16, [:t3_solo, :testeuda3, :amen, :crashhat, :guitar_dim, :play_solo])
    playall(16, [:t3_solo, :testeuda3, :amen, :crashhat, :guitar_dim, :play_solo])
    playall(16, [:t3_verse, :guitar_verse, :screech_32, :amen, :crashhat])
    playall(16, [:t3_verse, :ixi_guitar_verse, :screech_16_v2, :amen, :crashhat, :crashintro])
    playall(1, [:crashonce])
  end
  solo1 = ring :a5, :b5, :c6, :b5, :a5, :g5, :a5, :f5, :c5,
    :a5, :a5, :a5, :ab5, :a5, :a5,
    :a5, :a5, :a5, :c6, :a5, :a5,
    :a5, :a5, :a5
  solo2 = ring :cb6, :a5, :cb6, :a5, :cb6, :a5, :cb6, :a5,
    :d6, :f6, :d5, :f6, :d6, :f6, :d5, :f6
  
  times1 = ring 1.5, 0.5, 0.5, 0.5, 0.5, 0.5, 1, 1, 1.25,
    0.25, 0.25, 0.25, 0.25, 0.5, 0.5,
    0.25, 0.25, 0.25, 0.25, 0.5, 0.5,
    0.25, 0.25, 0.25
  times2 = ring 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25,
    0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25
  
  times2sum = 16 * 0.25
  define :play_solo do
    use_synth :tb303
    use_synth_defaults res: 0.7, release: 0.1, amp: 0.8
    solo1.length.times do
      ticker = tick()
      duration = times1[ticker]
      note = solo1[ticker]
      play note, sustain: 0.5*duration, release: 0.5*duration
      sleep duration
    end
    ctrl = nil
    solo2.length.times do
      ticker = tick(:solo2)
      duration = times2[ticker]
      note = solo2[ticker]
      if ticker == 0 then
        ctrl = play note, sustain: times2sum, release: 0.01
      else
        control ctrl, note: note
      end
      sleep duration
    end
  end
  
  define :metro do
    sample :bd_haus
    sleep 0.5
  end
  
  main