use_bpm 70
samples_base = "C:/Program Files (x86)/Sonic Pi/etc/samples/"
define :crispysn do |i|
  return samples_base + "freesnd/" + (118283 + i).to_s + "__crispydinner__lr-sn-" + (sprintf '%04d', i) + ".flac"
end
define :masu do |name, i|
  return samples_base + "masu/mdk_" + name + (sprintf '%02d', i) + ".flac"
end
define :amigasay do |name|
  return samples_base + "amigasay/" + name + ".flac"
end
define :rands do |name|
  return samples_base + "random/" + name + ".flac"
end

define :snare do
  with_fx :reverb, mix: 0.5 do
    sample masu("snare", 4), amp: 5.0
  end
end
define :crash do
  sample masu("crash", [3, 4, 6, 7, 8].choose), rpitch: rrand(-0.2, 0.2), amp: 0.4
end

define :crash_2 do
  sample masu("crashtwo", (3..4).to_a.choose), rpitch: rrand(-0.2, 0.2), amp: 0.6
end

define :ride do
  sample masu("hatsmack", (4..6).to_a.choose), rpitch: rrand(-0.2, 0.2), amp: 0.9
end

define :hat do
  sample masu("hatclosed", (1..8).to_a.choose), rpitch: rrand(-0.1, 0.1)
end

define :bdru do
  sample :bd_haus, amp: 0.5
end

define :guitar_d do |note, start, finish|
  with_fx :krush, mix: 0.8, cutoff: 130, res: 0.3, amp: 0.9 do
    with_fx :hpf, cutoff: 45 do
      with_fx :hpf, cutoff: 50, mix: 0.5 do
        with_fx :lpf, cutoff: 80 do
          with_fx :pan, pan: -0.3 do
            sample samples_base + "/guitar/" + note + "_1.flac", amp: 5, start: start, finish: 1.0-finish
          end
          with_fx :pan, pan: 0.3 do
            sample samples_base + "/guitar/" + note + "_2.flac", amp: 5, start: start, finish: 1.0-finish
          end
        end
      end
    end
  end
end

define :bassynth do
  use_synth :subpulse
  use_synth_defaults release: 0.125, sustain: 0.25, amp: 0.35, sub_amp: 0.1
end

define :metro do
  bdru
  crash
  sleep 0.5
  snare
  crash
  sleep 0.5
end

define :dbeat do
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

define :crashes do
  crash
  sleep 0.5
end

define :rhythm2 do
  8.times do
    bdru
    ride
    sleep 0.25
    ride
    sleep 0.25
  end
  8.times do
    bdru
    ride
    sleep 0.25
  end
  8.times do
    bdru
    ride
    sleep 0.125
    bdru
    sleep 0.125
  end
  crash
  sleep 0.25
  crash
  sleep 0.25
  crash
  bdru
  sleep 0.25
  crash
  bdru
  sleep 0.25
end

define :bass do
  bassynth
  base = :D2
  4.times do
    play base
    sleep 0.25
    play base
    sleep 0.5
  end
  play base + 3
  sleep 0.25
  play base
  sleep 0.25
  play base + 7
  sleep 0.25
  play base + 6
  sleep 0.25
  4.times do
    play base
    sleep 0.25
    play base
    sleep 0.5
  end
  play base + 3
  sleep 0.25
  play base
  sleep 0.25
  play base + 2, release: 0.5
  sleep 0.5
  4.times do
    play base
    sleep 0.25
    play base
    sleep 0.5
  end
  play base + 3
  sleep 0.25
  play base
  sleep 0.25
  play base + 7
  sleep 0.25
  play base + 6
  sleep 0.25
  2.times do
    play base + 6
    sleep 0.25
    play base + 6
    sleep 0.5
  end
  2.times do
    play base + 5
    sleep 0.25
    play base + 5
    sleep 0.5
  end
  play base + 5
  sleep 0.5
  play base + 3, release: 0.5
  sleep 0.5
end

define :eudor do
  sample rands("178187__snapper4298__lens-zooming-in-and-out"), rpitch: rrand(-1, 1)
  sleep 1
  sample rands("321215__hybrid-v__sci-fi-weapons-deploy"), rpitch: rrand(-1, 1)
  sleep 1
  sample rands("123253__skullsmasha__mechanicalclamp"), amp: 2, rpitch: rrand(-1, 1)
  sleep 15
end

define :guitar do
  guitar_d("test", 0, 0)
  sleep 3.005
  guitar_d("test2_2", 0, 0)
  sleep 0.995
  guitar_d("test", 0, 0)
  sleep 3
  guitar_d("test3", 0, 0)
  sleep 1
  guitar_d("test", 0, 0)
  sleep 3.005
  guitar_d("test2_2", 0, 0)
  sleep 0.99
  guitar_d("test4", 0, 0)
  sleep 1.505
  guitar_d("test5", 0, 0)
  sleep 1.5
  guitar_d("test8", 0, 0)
  sleep 0.5
  guitar_d("test6", 0, 0)
  sleep 0.50001
end

bridgenotes = ring 7, 3, 5,
  0, 3, 5, 7, 5, 3,
  0, 3, 5, 7, 5, 3,
  0, 0
bridgepauses = ring 6, 1, 6,
  1, 1, 1, 1, 2, 2,
  1, 1, 1, 1, 2, 3,
  1, 4
define :bridge do
  use_synth :chiplead
  use_synth_defaults release: 1, amp: 0.7
  bridgenotes.length.times do
    base = :D5
    play base + bridgenotes.tick(:bfn)
    sleep bridgepauses.tick(:bfp) * 0.25
  end
end

define :bridge_pre do
  use_synth :chiplead
  use_synth_defaults release: 1, amp: 0.7
  i = 0
  6.times do
    base = :D5
    play base + bridgenotes[i]
    sleep bridgepauses[i] * 0.25
    i = i + 1
  end
end

refnotes = ring 7, 8, 7, 7, 7, 7, 7, 3, 5,
  0, 3, 5, 7, 7, 7, 7, 7, 8, 7,
  8, 7, 7, 7, 7, 7, 3, 5,
  0, 3, 5, 7, 7, 8, 5, 5, 7, 3
refpauses = ring 1, 1, 2, 1, 2, 3, 2, 2, 5,
  1, 1, 1, 1, 1, 1, 1, 1, 1, 4,
  1, 2, 2, 2, 3, 2, 2, 5,
  1, 1, 1, 1, 1, 1, 2, 1, 1, 4
slides = [0, 17]
define :refrain do
  use_synth :blade
  use_synth_defaults amp: 1.3, vibrato_delay: 0, vibrato_onset: 0.2
  base = :D5
  idx = tick(:rfp)
  hasslide = (slides.include? idx)
  length = refpauses[idx] * 0.25
  ctrl = play base + refnotes[idx], sustain: length * 0.9, release: length * 0.25, note_slide: length, note_slide_shape: 7
  if hasslide then
    control ctrl, note: base + refnotes[idx+1]
    sleep refpauses[idx] * 0.25
    idx = tick(:rfp)
    length = refpauses[idx] * 0.25
    play base + refnotes[idx], sustain: length * 0.9, release: length * 0.25
  end
  sleep refpauses[idx] * 0.25
end

define :refrainchords do
  sleep 0.5
  play_chord chord(:A4, '5')
  sleep 3
  play_chord chord(:G4, '5')
  sleep 2
  play_chord chord(:A4, '5')
  sleep 3
  play_chord chord(:A4, '5')
  sleep 3
  play_chord chord(:G4, '5')
  sleep 2
  play_chord chord(:A4, '5')
  sleep 1
  play_chord chord(:G4, '5')
  sleep 1
  play_chord chord(:F4, '5')
  sleep 2
end

define :dbass_common do |first, crash|
  sleep 0.25
  if first then
    bdru
    send(crash)
  end
  sleep 0.25
  2.times do
    4.times do
      bdru
      send(crash)
      sleep 0.25
    end
    snare
    send(crash)
    bdru
    sleep 0.25
    3.times do
      bdru
      send(crash)
      sleep 0.25
    end
  end
  6.times do
    2.times do
      bdru
      send(crash)
      sleep 0.25
    end
    snare
    send(crash)
    bdru
    sleep 0.25
    5.times do
      bdru
      send(crash)
      sleep 0.25
    end
  end
end

define :halfcrash do
  if [true, false].choose then
    ride
  else
    crash
  end
end

define :dbass do
  dbass_common(true, :crash)
end
define :dbass_continue do
  dbass_common(false, :crash)
end
define :dbass_continue_2 do
  dbass_common(false, :halfcrash)
end


bgschords = ring chord(:G2, :minor, num_octaves: 4),
  chord(:F2, :major, num_octaves: 4),
  chord(:D2, :minor, num_octaves: 4),
  chord(:F2, :major, num_octaves: 4),
  chord(:E2, :major, num_octaves: 4),
  chord(:D3, :minor, num_octaves: 6)

define :bridgesupplement_notes do
  3.times do
    ch1 = bgschords.tick(:bgsc)
    index = 0
    8.times do
      play ch1[index]
      index = index + 1
      sleep 0.125
    end
    8.times do
      play ch1[index]
      index = index - 1
      sleep 0.125
    end
  end
  2.times do
    ch1 = bgschords.tick(:bgsc)
    index = 0
    8.times do
      play ch1[index]
      index = index + 1
      sleep 0.125
    end
  end
  ch1 = bgschords.tick(:bgsc)
  index = 0
  16.times do
    play ch1[index]
    index = index + 1
    sleep 0.125
  end
end

define :bridgesupplement do
  use_synth :prophet
  use_synth_defaults amp: 0.5
  bridgesupplement_notes
end

refchords = ring chord(:D4, :minor),
  chord(:D4, :minor),
  chord(:C4, :major),
  chord(:C4, :major),
  chord(:F4, :major),
  chord(:G4, :minor),
  chord(:A4, :major),
  chord(:A4, :major),
  chord(:A4, :major),
  chord(:A4, :major),
  chord(:G4, :minor),
  chord(:G4, :minor),
  chord(:A4, :major),
  chord(:G4, :diminished),
  chord(:F4, :major)
define :refsupplement_notes do
  with_fx :pan do |ctrl|
    sleep 1.5
    15.times do
      cur_chord = refchords.tick(:refsc)
      8.times do
        control ctrl, pan: rrand(-0.1, 0.1)
        play cur_chord.tick(:refspl) + 12
        sleep 0.125
      end
    end
  end
end

define :refsupplement do
  use_synth :prophet
  use_synth_defaults amp: 0.5
  refsupplement_notes
end

define :refsupplement_crushed do
  with_fx :bitcrusher, bits: 3, amp: 0.7 do
    use_synth :sine
    use_synth_defaults amp: 0.25, release: 0.225
    with_transpose 12 do
      refsupplement_notes
    end
  end
end
define :refsupplement_crushed_early do
  with_fx :bitcrusher, bits: 3, amp: 0.7 do
    use_synth :sine
    use_synth_defaults amp: 0.25, release: 0.225
    with_transpose 12 do
      in_thread do
        cur_chord = refchords[0]
        sleep 0.5
        8.times do
          play cur_chord.tick(:refscearly) + 12
          sleep 0.125
        end
      end
      refsupplement_notes
    end
  end
end

define :bridgesupplement_crushed do
  with_fx :bitcrusher, bits: 3, amp: 0.7 do
    use_synth :sine
    use_synth_defaults amp: 0.3, release: 0.225
    with_transpose 12 do
      bridgesupplement_notes
    end
  end
end

define :bridgebass_pre do
  bassynth
  base = :D2
  2.times do
    curnote = bgschords.tick(:bgbpl)[0]
    4.times do
      play curnote
      sleep 0.5
    end
  end
end

define :bridgebass do
  bassynth
  base = :D2
  3.times do
    curnote = bgschords.tick(:bgbpl)[0]
    4.times do
      play curnote
      sleep 0.5
    end
  end
  2.times do
    curnote = bgschords.tick(:bgbpl)[0]
    2.times do
      play curnote
      sleep 0.5
    end
  end
  curnote = bgschords.tick(:bgbpl)[0] - 12
  play curnote, release: 0.75
  sleep 0.5
  play curnote, release: 0.75
  sleep 0.5
end

define :refbass do
  bassynth
  base = :D2
  play base
  sleep 0.5
  5.times do
    play base + 7
    sleep 0.5
  end
  play base + 3
  sleep 0.5
  4.times do
    play base + 5
    sleep 0.5
  end
  2.times do
    play base + 7
    sleep 0.5
  end
  play base + 8
  sleep 0.5
  play base + 10
  sleep 0.5
  7.times do
    play base + 7
    sleep 0.5
  end
  play base + 3
  sleep 0.5
  4.times do
    play base + 5
    sleep 0.5
  end
  2.times do
    play base + 7
    sleep 0.5
  end
  2.times do
    play base + 5
    sleep 0.5
  end
  2.times do
    play base + 3
    sleep 0.5
  end
end

define :refguitar do
  sleep 8
  refguitar_nosleep(0, 0)
end
define :refguitar_fade do
  sleep 8
  with_fx :level, amp: 0.7, amp_slide: 0.25 do |ctrl|
    refguitar_nosleep(0, 0)
    control ctrl, amp: 1
  end
end
define :refguitar_nolast do
  sleep 8
  refguitar_nolasth(0, 0)
end

define :refguitar_sleeplong do
  sleep 15.875
  refguitar_nosleep(0.375, 0)
end

define :refguitar_now do
  sleep 0.25
  refguitar_nosleep(0.75, 0)
end

define :refguitar_nosleep do |headstart, prefinish|
  with_fx :level, amp: 0.6 do
    guitar_d("g7th", 0.25*headstart, 0)
    sleep 4 - headstart
    guitar_d("g5", 0, 0)
    sleep 2
    guitar_d("g7_8", 0, 0)
    sleep 2
    guitar_d("g7th", 0, 0)
    sleep 4
    guitar_d("g5", 0, 0)
    sleep 2
    guitar_d("g_7_3_5", 0, 0.5 * prefinish)
    sleep 2 - prefinish
  end
  sleep 8
end

define :refguitar_nolasth do |headstart, prefinish|
  with_fx :level, amp: 0.6 do
    guitar_d("g7th", 0.25*headstart, 0)
    sleep 4 - headstart
    guitar_d("g5", 0, 0)
    sleep 2
    guitar_d("g7_8", 0, 0)
    sleep 2
    guitar_d("g7th", 0, 0)
    sleep 4
    guitar_d("g5", 0, 0)
    sleep 2
    guitar_d("g_7_3_7", 0, 0.5 * prefinish)
    sleep 2 - prefinish
  end
  sleep 8
end


define :testor_default do |base|
  2.times do
    play base
    sleep 0.25
  end
  2.times do
    play base + 3
    sleep 0.25
  end
  2.times do
    play base + 5
    sleep 0.25
  end
  play base + 6
  sleep 0.25
  play base + 7
  sleep 0.25
end

define :testor do
  with_fx :ixi_techno, cutoff_min: 90, cutoff_max: 120, res: 0.5 do
    base = :D3
    use_synth :tb303
    use_synth_defaults release: 0.125, amp: 0.5
    3.times do
      testor_default(base)
    end
    3.times do
      play base + 6
      sleep 0.25
    end
    play base + 5, release: 0.45
    sleep 0.5
    play base + 5
    sleep 0.25
    play base + 5, release: 0.45
    sleep 0.5
    3.times do
      testor_default(base)
    end
    3.times do
      play base + 6
      sleep 0.25
    end
    play base + 7, release: 0.45
    sleep 0.5
    play base + 7
    sleep 0.25
    play base + 8, release: 0.45
    sleep 0.5
  end
end

define :singlecrush do
  with_fx :pan do |ctrl|
    sc = scale(:A4, :minor_pentatonic, num_octaves: 3)
    with_fx :bitcrusher, bits: 3, amp: 0.6 do
      use_synth :sine
      use_synth_defaults release: 0.125, amp: 0.3
      control ctrl, pan: rrand(-0.4, 0.4)
      play sc.choose
    end
  end
end

define :crushors do
  2.times do
    7.times do
      singlecrush
      sleep 0.125
    end
    sleep 0.125
  end
  4.times do
    singlecrush
    sleep 0.125
  end
  sleep 0.25
  2.times do
    singlecrush
    sleep 0.125
  end
  sleep 1
end

define :bridgepredrum do
  sleep 4
  8.times do
    bdru
    sleep 0.5
  end
end

define :breakdown do
  sleep 0.4
  with_fx :level, amp: 2 do
    with_fx :krush, mix: 0, mix_slide: 0.5, amp_slide: 1 do |crushctrl|
      with_fx :bitcrusher, bits: 3, amp: 0.7 do
        use_synth :sine
        use_synth_defaults amp: 0.35, release: 4
        ctrl = play :F5, note_slide: 1
        control ctrl, note: :D5
        control crushctrl, mix: 0.8
        sleep 0.125
        ctrl2 = play :D5, note_slide: 1, amp_slide: 1
        control ctrl2, note: :F5
        sleep 2
        control crushctrl, mix: 0
        sleep 0.5
        control crushctrl, amp: 0.5, mix: 0
        sleep 0.5
        play :D1, release: 1
        sleep 6
      end
    end
  end
end

define :onecrash do
  sleep 0.5
  crash
  sleep 32
end

define :tikatika do
  sleep 31
  4.times do
    sample masu("ride", [3, 4].choose), amp: 1.5
    sleep 0.25
  end
end

lyrics = ring "I", "have", "a", "system", "in", "my", "mind",
  #"and", "though", "you'll", "never", "agree",
  "some", "times", "youve", "got", "to", "pay", "the", "price"
#"for", "yet", "another", "invention", "of", "man"
rbsleeps = ring 2, 2, 0.5, 5.5, 2, 2, 5 + 12.5,
  #1, 1, 0.5, 2, 8,
  2, 2.5, 1, 1.5, 3, 2, 2, 5.5 + 15
#1, 1, 3, 3, 2, 5
define :robovoice do
  with_fx :bitcrusher do
    with_fx :hpf, cutoff: 60, pre_amp: 1.5 do
      duration = rbsleeps.tick(:rbvs) * 0.25
      sample amigasay(lyrics.tick(:rbvl)), amp: 3
      sleep duration
    end
  end
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
    playall(4.6, [:eudor])
    playall(32, [:metro, :bass, :guitar, :tikatika])
    playall(8.5, [:rhythm2, :bridge, :bridgesupplement, :bridgebass, :refguitar_fade, :onecrash])
    playall(16, [:dbass, :refrain, :refsupplement, :refbass])
    playall(0.5, [])
    playall(32, [:dbeat, :crashes, :bass, :guitar, :testor, :crushors])
    playall(8, [:bridgepredrum, :bridge_pre, :bridgebass_pre])
    playall(8.5, [:rhythm2, :bridge, :bridgesupplement_crushed, :bridgebass, :refguitar_nolast])
    playall(16, [:dbass, :refsupplement_crushed, :refbass, :refguitar_sleeplong])
    playall(16, [:dbass_continue, :robovoice, :refsupplement_crushed_early, :refbass])
    playall(16, [:dbass_continue, :refrain, :robovoice, :refsupplement_crushed_early, :refbass, :refguitar_now])
    playall(16, [:dbass_continue_2, :refrain, :robovoice, :refsupplement_crushed_early, :refbass, :refguitar_now])
    playall(8, [:breakdown, :onecrash])
  end
  
  define :metronome do
    sample :bd_haus, amp: 0.2
    sleep 0.5
  end
  
  main
  