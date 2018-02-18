use_bpm 50

samples_base = "C:/Program Files (x86)/Sonic Pi/etc/samples/"
define :crispysn do |i|
  return samples_base + "freesnd/" + (118283 + i).to_s + "__crispydinner__lr-sn-" + (sprintf '%04d', i) + ".flac"
end
define :masu do |name, i|
  return samples_base + "masu/mdk_" + name + (sprintf '%02d', i) + ".flac"
end

define :guitar_s do |note|
  with_fx :krush, mix: 0.8, cutoff: 125, res: 0.7 do
    with_fx :hpf, cutoff: 35 do
      with_fx :compressor do
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

define :snare do
  sample crispysn(14), amp: 0.9
  sample masu("snare", 5), amp: 2
end

define :bdru do
  sample :bd_haus
end

define :hat do
  sample masu("ride", (1..4).to_a.choose)
end

define :euclid_beat do
  tick
  snare if (spread 3, 7).look
  bdru if (spread 5, 11).look
  hat if (spread 8, 9).look
  sleep 0.125
end

define :euclid_beat_2 do
  tick
  snare if (spread 4, 7).look
  bdru if (spread 5, 11).look
  hat if (spread 8, 9).look
  sleep 0.125
end

define :euclid_beat_3 do
  tick
  snare if (spread 5, 7).look
  bdru if (spread 5, 11).look
  hat if (spread 8, 9).look
  sleep 0.125
end

sc = scale(:C2, :hirajoshi)
define :wobblybass do
  use_synth :tb303
  use_synth_defaults res: 0.8, release: [0.125, 0.25].choose
  play sc.choose
  sleep 0.125
end

define :melo do
  use_synth :blade
  play sc.choose() + 48
  sleep 0.25
end

define :guitar_c do
  guitar_s("3c")
  sleep 4
end

define :guitar_ds do
  guitar_s("3ds")
  sleep 4
end

define :guitar_gg do
  guitar_s("gg")
  sleep 4
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
  
  define :ambient do
    use_synth :prophet
    with_fx :wobble do |wobctl|
      use_synth_defaults res: 0, attack: 0, sustain: 4, release: 0, amp: 0.5
      play :C2
      play :C3
      16.times do
        control wobctl, phase: [0.125, 0.125/2, 0.25].choose
        sleep 0.25
      end
    end
  end
  
  define :main do
    playall(8, [:euclid_beat, :wobblybass, :guitar_c, :ambient])
    playall(8, [:melo, :euclid_beat, :wobblybass, :guitar_c, :ambient])
    with_transpose 3 do
      playall(8, [:melo, :euclid_beat_2, :wobblybass, :guitar_ds, :ambient])
    end
    playall(4, [:melo, :euclid_beat, :wobblybass, :guitar_c, :ambient])
    with_fx :krush, mix: 0.9, amp: 1.3 do
      playall(4, [:melo, :euclid_beat, :wobblybass, :guitar_c, :ambient])
    end
    with_transpose 3 do
      playall(8, [:melo, :euclid_beat_2, :wobblybass, :guitar_ds, :ambient])
    end
    with_transpose 7 do
      playall(4, [:melo, :euclid_beat_3, :wobblybass, :guitar_gg, :ambient])
    end
    playall(2, [:guitar_c])
  end
  
  live_loop :ll do main end
  
  