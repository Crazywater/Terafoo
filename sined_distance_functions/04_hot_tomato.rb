use_bpm 84

samples_base = "C:/Program Files (x86)/Sonic Pi/etc/samples/"
define :crispysn do |i|
  return samples_base + "freesnd/" + (118283 + i).to_s + "__crispydinner__lr-sn-" + (sprintf '%04d', i) + ".flac"
end
define :masu do |name, i|
  return samples_base + "masu/mdk_" + name + (sprintf '%02d', i) + ".flac"
end

define :guitar_s do |note|
  with_fx :krush, mix: 0.9, cutoff: 125, res: 0.7, amp: 1 do
    with_fx :hpf, cutoff: 35 do
      with_fx :compressor do
        with_fx :pan, pan: -0.2 do
          sample samples_base + "/guitar/" + note + "_1.flac", amp: 7
        end
        with_fx :pan, pan: 0.2 do
          sample samples_base + "/guitar/" + note + "_2.flac", amp: 7
        end
      end
    end
  end
end

define :snare do
  sample crispysn(14), amp: 0.9
  sample masu("snare", 5), amp: 2
end

define :masusnare do
  sample masu("snare", 5), amp: 3
end

define :bdru do
  sample :bd_haus
end

define :hat do
  sample masu("ride", (1..4).to_a.choose), pan: 0.3
end

define :crash do
  sample masu("crash", [3, 4, 6, 7, 8].choose), amp: 0.6, start: 0.01
end

sc = ring scale(:F3, :minor_pentatonic),
  scale(:Gs3, :major_pentatonic),
  scale(:Ds3, :major_pentatonic),
  scale(:D3, :minor_pentatonic),
  scale(:F3, :minor_pentatonic),
  scale(:Gs3, :major_pentatonic),
  scale(:Ds3, :major_pentatonic),
  scale(:G3, :minor_pentatonic)

define :blipsy_base do |synth|
  use_synth synth
  use_synth_defaults release: 0.125, amp: 1.7
  s = sc.tick()
  16.times do
    play s.choose, pan: rrand(-0.1, 0.1)
    sleep 0.125
  end
end

define :blipsy do blipsy_base(:chiplead) end
define :blipsy_tanh do
  with_fx :tanh do
    blipsy_base(:sine)
  end
end


bnotes = ring 3, 6, 1, 5, 3, 6, 1, 5
define :bass do
  use_synth :pulse
  use_synth_defaults sustain: 0.5, attack: 0.01, amp: 0.7
  n = bnotes.tick()
  play :D1 + n
  sleep 0.75
  play :D1 + n, sustain: 0
  sleep 0.25
  play :D1 + n, sustain: 0.75, release: 0.3
  sleep 1
end

melnotes = ring 1, 3, 4, -1, 1, 3, 1,
  3, 1, 1, 3, 4, -1, -1, 1, 3, 1
melpauses = ring 3, 0.5, 4.5, 2, 0.5, 1, 4.5,
  0.5, 0.5, 2, 0.5, 4.5, 1, 1, 1, 0.5, 4.5

define :melody do
  use_synth :tb303
  pause = melpauses.tick(:p) * 0.5
  use_synth_defaults sustain: 0.5 * pause, release: 0.5 * pause, amp: 0.6, res: 0.5
  play :A4 + melnotes.tick(:n)
  play :A4 + melnotes.tick(:n2) + 7
  sleep pause
end

define :endmelody do
  use_synth :tb303
  use_synth_defaults sustain: 2, release: 2, amp: 0.6, res: 0.5
  play :A4 - 4
  play :A4 - 4 + 7
  play :A4 - 4 + 12
  sleep 16
end

othernotes = ring 12, 11, 9, 7, 9, 5, 2, 12, 11, 9, 7,
  9, 12, 11, 9, 7, 9, 5, 2, 5

otherpauses = ring 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 4,
  1, 1, 1, 1, 1, 1, 1.5, 0.5

define :othermel do
  use_synth :tb303
  pause = otherpauses.tick(:p)
  use_synth_defaults sustain: pause, release: 0.05, attack: 0.1, amp: 0.6, res: 0.5
  play :D5 + othernotes.tick(:n) - 5
  sleep pause
end

define :melody_double do
  use_synth :tb303
  pause = melpauses.tick(:p) * 0.5
  use_synth_defaults sustain: 0.5 * pause, release: 0.5 * pause, amp: 0.4, res: 0.5
  play :A4 + melnotes.tick(:n)
  play :A4 + melnotes.tick(:n2) + 7
  play :A4 + melnotes.tick(:n3) + 12
  sleep pause
end


define :guitar do
  guitar_s("ggriff")
  sleep 4
  guitar_s("ggriff2")
  sleep 4
end

crsls = ring 1.5, 0.25, 2.25,
  1.5, 0.5, 2,
  1.5, 0.25, 2.25,
  1, 1, 2
define :crashriff do
  crash
  sleep crsls.tick()
end

define :hihat do
  hat
  sleep 0.125
end

define :beator do
  bdru
  sleep 0.5
  snare
  sleep 0.25
  bdru
  sleep 0.5
  bdru
  sleep 0.25
  snare
  sleep 0.5
end

define :crashonce do
  crash
  sleep 32
end

define :krusheddrums do
  bdru
  sleep 0.5
  crash
  sleep 0.5
  with_fx :reverb do
    with_fx :level, amp: 0.5 do snare end
    masusnare
  end
  sleep 0.5
  crash
  sleep 0.5
end

define :krusheddrums_allcrash do
  bdru
  crash
  sleep 0.5
  crash
  sleep 0.5
  crash
  with_fx :reverb do
    with_fx :level, amp: 0.5 do snare end
    masusnare
  end
  sleep 0.5
  crash
  sleep 0.5
end

define :tridrums do
  bdru
  crash
  sleep 0.75
  bdru
  crash
  sleep 0.75
  snare
  crash
  sleep 0.5
end

define :pulsebass do
  use_synth :pulse
  use_synth_defaults sustain: 0.1, release: 0.4, amp: 0.7
  n = bnotes.tick()
  10.times do
    play :D1 + 3
    play :D2 + 3
    sleep 0.25
    play :D1 + 3
    play :D2 + 3
    sleep 0.5
  end
  play :D1 + 5
  play :D2 + 5
  sleep 0.25
  play :D1 + 6
  play :D2 + 6
  sleep 0.25
end

define :endbass do
  use_synth :pulse
  use_synth_defaults sustain: 2, release: 2, amp: 0.7
  play :D1 + 3
  play :D2 + 3
  sleep 16
end

define :testguitar do
  with_fx :level, amp: 1.1 do
    guitar_s("duka")
  end
  sleep 7.5
  guitar_s("dudahn")
  sleep 0.5
end

define :butter do
  guitar_s("butter1")
  sleep 4
  guitar_s("butter2")
  sleep 4
end

define :whatever do
  sleep 0.03
  guitar_s("whatever")
  sleep 16
end

define :endguitar do
  with_fx :level, amp: 1.1 do
    guitar_s("f_outro")
  end
  sleep 16
end

define :butterbass do
  use_synth :pulse
  use_synth_defaults amp: 0.7
  n = bnotes.tick()
  [7, 5].each do |i|
    2.times do
      play :D1 + i, release: 1
      play :D2 + i, release: 1
      sleep 0.75
      play :D1 + i, release: 0.5
      play :D2 + i, release: 0.5
      sleep 0.25
      play :D1 + i, release: 1
      play :D2 + i, release: 1
      sleep 1
    end
  end
end

define :weirdobass do
  use_synth :pulse
  use_synth_defaults amp: 0.7, release: 0.4
  n = bnotes.tick()
  [5, 7, 8, 7].each do |i|
    play :D1 + i
    play :D2 + i
    sleep 0.75
    play :D1 + i
    play :D2 + i
    sleep 0.75
    play :D1 + i
    play :D2 + i
    sleep 0.5
  end
end

define :testguitar2 do
  with_fx :level, amp: 0, amp_slide: 8 do |ctl|
    control ctl, amp: 1.1
    2.times do
      guitar_s("shred")
      sleep 8
    end
  end
end

define :revcrash do
  sleep 11.5
  sample masu("crash_crescendo", 1)
  sleep 32
end

weirdosc = ring chord(:G4, :minor),
  chord(:A4, :diminished),
  chord(:As4, :major),
  chord(:A4, :diminished)

define :weirdo do
  s = weirdosc.tick()
  use_synth :tb303
  use_synth_defaults release: 0.125, amp: 0.6
  8.times do
    play s.choose
    sleep 0.125
  end
end

define :weirdo_chip do
  s = weirdosc.tick(:asd)
  use_synth :chiplead
  use_synth_defaults release: 0.125
  8.times do
    play s.choose + 12
    sleep 0.125
  end
end

define :weirdo_tanh do
  s = weirdosc.tick(:asdf)
  use_synth :sine
  use_synth_defaults release: 0.125
  with_fx :tanh do
    8.times do
      play s.choose - 12
      sleep 0.125
    end
  end
end

define :end_tanh do
  use_synth :sine
  use_synth_defaults release: 2
  with_fx :tanh do
    play :F3
  end
  sleep 16
end

define :downroll_base do |synth, amp, offset|
  with_fx :level do |ctl|
    use_synth synth
    [9, 8, 7, 6, 5, 4].each do |i|
      cur_chord = chord(:D4 + i, :minor)
      4.times do
        play cur_chord.choose + offset, amp: amp, release: 0.125
        sleep 0.125
      end
    end
    control ctl, amp: 0
  end
end

define :downroll_chip do
  downroll_base(:chiplead, 1.0, 12)
end

define :downroll_tanh do
  with_fx :tanh do
    downroll_base(:sine, 1.0, - 12)
  end
end

define :downroll do
  downroll_base(:tb303, 0.6, 0)
end

define :allcrashes do
  crash
  sleep 0.5
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
    playall(16, [:crashonce, :beator, :blipsy, :guitar, :bass])
    playall(16, [:crashriff, :beator, :hihat, :blipsy, :guitar, :bass, :melody])
    playall(16, [:crashriff, :beator, :hihat, :blipsy, :guitar, :bass, :melody_double, :revcrash])
    playall(16, [:krusheddrums, :testguitar, :pulsebass])
    playall(16, [:krusheddrums_allcrash, :testguitar, :testguitar2, :pulsebass])
    playall(16, [:crashonce, :crashriff, :beator, :hihat, :blipsy, :guitar, :bass, :melody])
    playall(16, [:crashriff, :beator, :hihat, :blipsy, :guitar, :bass, :melody_double, :revcrash])
    playall(24, [:beator, :hihat, :othermel, :butter, :butterbass])
    playall(8, [:tridrums, :whatever, :weirdobass, :weirdo])
    playall(8, [:tridrums, :weirdo, :weirdo_chip])
    playall(16, [:tridrums, :whatever, :weirdobass, :weirdo, :weirdo_chip, :weirdo_tanh])
    playall(3, [:downroll_chip, :downroll_tanh, :downroll])
    playall(16, [:crashriff, :beator, :hihat, :blipsy, :guitar, :bass, :melody])
    playall(16, [:crashriff, :beator, :hihat, :blipsy, :guitar, :bass, :melody_double])
    playall(32, [:allcrashes, :beator, :hihat, :blipsy, :blipsy_tanh, :guitar, :bass, :melody_double])
    with_fx :krush, amp: 0.9,  gain: 0.5, mix: 0, gain_slide: 2, amp_slide: 0.5 do |ctl|
      in_thread do playall(16, [:crashonce, :endmelody, :end_tanh, :endguitar, :endbass]) end
      sleep 2
      control ctl, mix: 1, gain: 100
      sleep 4
      control ctl, amp: 0
    end
  end
  
  define :metro do
    with_fx :pan, pan: -1 do
      sample :bd_haus, amp: 0.2
      sleep 0.5
    end
  end
  
  main