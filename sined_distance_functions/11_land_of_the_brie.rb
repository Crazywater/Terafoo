use_bpm 120
set_sched_ahead_time! 1

samples_base = "C:/Program Files (x86)/Sonic Pi/etc/samples/"
define :mdk_sample do |type, index|
  idx = pad_number(index)
  return "#{samples_base}/masu/mdk_#{type}#{idx}.flac"
end

define :pad_number do |n|
  if (n < 10) then return "0#{n}" end
  return "#{n}"
end

define :mdk_crash do
  return mdk_sample("crash", Array(1..10).choose)
end

define :mdk_crash2 do
  return mdk_sample("crashtwo", Array(1..10).choose)
end

define :mdk_hatclosed do
  return mdk_sample("hatclosed", Array(1..25).choose)
end

define :mdk_hatopen do
  return mdk_sample("hatopen", Array(1..13).choose)
end

define :mdk_hatsmack do
  return mdk_sample("hatsmack", Array(1..6).choose)
end

define :mdk_kick do
  return mdk_sample("kick", Array(1..7).choose)
end

define :mdk_ride do
  return mdk_sample("ride", Array(1..4).choose)
end

define :mdk_ride_crash do
  return mdk_sample("ride", Array(5..7).choose)
end

define :mdk_snare do
  return mdk_sample("snare", Array(1..20).choose)
end

define :mdk_splash do
  return mdk_sample("splash", Array(1..3).choose)
end

# length 2
define :hihat do
  with_fx :panslicer, phase: 0.5, pan_min: -0.5, pan_max: 0.5, mix: 0.5 do
    8.times do
      if (rrand(0, 1) < 0.7) then
        if (rrand(0, 1) < 0.3) then
          with_fx :bpf, centre: 110, mix: 0.5 do
            with_fx :bitcrusher, bits: 4 do
              sample mdk_ride, pitch_stretch: 0.25, window_size: 0.01, pitch: rrand(10, 30)
            end
          end
        else
          with_fx :bitcrusher, bits: 4, mix: 0.3 do
            sample mdk_ride, finish: 0.01
          end
        end
      end
      sleep 0.25
    end
  end
end
define :hardbass do
  sample mdk_kick, pan: -0.5
  sample mdk_kick, pan: 0.5
end
# length 2
define :dbeat do
  with_fx :krush, mix: 0.5 do
    hardbass
    sleep 0.5
    sample mdk_snare
    sleep 0.25
    hardbass
    sleep 0.5
    hardbass
    sleep 0.25
    sample mdk_snare
    sleep 0.5
  end
end

define :otherbeat do
  with_fx :krush, mix: 0.5 do
    sample mdk_ride_crash
    sample mdk_snare
    hardbass
    sleep 0.5
    hardbass
    sleep 0.5
    sample mdk_ride_crash
    sample mdk_snare
    hardbass
    sleep 0.5
    hardbass
    sleep 0.5
  end
end

define :straightbeat do
  with_fx :krush, mix: 0.5 do
    hardbass
    sleep 0.5
    sample mdk_snare
    sleep 0.5
    hardbass
    sleep 0.5
    sample mdk_snare
    sleep 0.5
  end
end

define :doublebass do
  with_fx :krush, mix: 0.5 do
    2.times do
      sample mdk_ride_crash
      hardbass
      sleep 0.25
      hardbass
      sleep 0.25
      hardbass
      sample mdk_snare
      sleep 0.25
      hardbass
      sleep 0.25
    end
  end
end


define :halfbeat do
  with_fx :distortion do
    sample mdk_kick, pan: -0.3
    sample mdk_kick, pan: 0.3
    sleep 2
  end
end

# length 2
define :crash do
  with_fx :krush, mix: 0.5 do
    2.times do
      if (rrand(0, 1) < 0.1) then
        sample mdk_hatopen
      end
      if (rrand(0, 1) < 0.1) then
        sample mdk_ride_crash
      end
      sleep 1
    end
  end
end

tic = 0
p1chords = [
  chord_degree(1, :Eb4, :minor, 3),
  chord_degree(4, :Eb3, :minor, 3),
  chord_degree(6, :Eb3, :minor, 3),
  chord_degree(5, :Eb3, :minor, 4),
]
p2chords = [
  chord_degree(1, :Eb4, :minor, 3),
  chord_degree(4, :Eb3, :minor, 3),
  chord_degree(6, :Eb3, :minor, 3),
  chord_degree(5, :Eb3, :minor, 3),
  chord_degree(3, :Eb3, :hirajoshi, 3),
  chord_degree(4, :Eb3, :hirajoshi, 4),
  chord_degree(5, :Eb3, :minor, 4),
]
quiet_part_chords = [
  chord_degree(1, :Eb4, :minor, 3),
  chord_degree(5, :Eb3, :minor, 3),
  chord_degree(7, :Eb3, :minor, 3),
  chord_degree(4, :Eb3, :minor, 3),
  chord(:Gb3, :sus4),
  chord_degree(1, :Eb3, :minor, 3),
  chord_degree(1, :Eb4, :minor, 3),
  chord_degree(1, :Eb4, :minor, 3),
]
chords = p1chords + p2chords + quiet_part_chords + quiet_part_chords + quiet_part_chords

define :cur_chord do
  return chords[tic % chords.length]
end
# length 8
define :chordidx do
  if (rrand(0, 1) < 0.5) then
    with_fx :krush, mix: 0.5 do
      sample mdk_crash2
    end
  end
  sleep 8
  tic = inc(tic)
  print "next chord"
end

#length: 56
define :mainline do
  use_synth :dpulse
  use_synth_defaults amp: 0.6, detune: 0.2, dpulse_width: 0.4
  play :Eb4
  sleep 6.5
  notes = [:Eb4, :F4, :Gb4,
           :Gb4, :Ab4, :B4,
           :B4, :Db5, :Ab4,
           :Ab4, :Gb4, :Ab4,
           :Ab4, :B4, :Eb5]
  times = [0.5, 0.5, 7]
  play_pattern_timed(notes, times)
  sync :chordidx
end

define :pianocommon do |note|
  use_synth_defaults attack: 0, decay: 0.01, sustain_level: 0.5
  use_synth :saw
  play note, vel: rrand(0.15, 0.25), release: 0.3
  use_synth :square
  play note, release: 0.25
  sleep 0.25
end

define :piano do
  note = cur_chord.choose - [12, 24].choose
  pianocommon(note)
end

define :pianohigh do
  note = cur_chord.choose - 12
  pianocommon(note)
end

#length: 8
define :slicerloop do
  use_synth :tb303
  with_fx :slicer do |slicer|
    with_fx :flanger do
      play_chord [cur_chord[0] - 12, cur_chord[2] - 12,
      cur_chord[0], cur_chord[2], cur_chord[0] + 12, cur_chord[2] + 12],
        sustain: 8, release: 0, res: 0, vel: 0.5
      16.times do
        control slicer, phase: [0.5, 0.25, 0.125].choose
        sleep 0.5
      end
    end
  end
end

# length 2
define :drumloop do
  in_thread do hihat end
  in_thread do dbeat end
  crash
end

define :otherdrumloop do
  in_thread do otherbeat end
  crash
end

define :doublebassloop do
  in_thread do hihat end
  in_thread do doublebass end
  crash
end

# length 56
define :fullloop do
  in_thread do 28.times do drumloop end end
  in_thread do 7.times do slicerloop end end
  in_thread do (56*4).times do piano end end
  in_thread do mainline end
  7.times do chordidx end
end

define :strippedloop do
  in_thread do 16.times do drumloop end end
  in_thread do (32*4).times do piano end end
  4.times do chordidx end
end

define :quietpart do
  in_thread do sample mdk_crash end
  in_thread do broemm end
  32.times do halfbeat end
  
  in_thread do sample mdk_crash end
  in_thread do broemm end
  in_thread do (64*4).times do pianohigh end end
  in_thread do 32.times do drumloop end end
  8.times do chordidx end
  
  in_thread do sample mdk_crash end
  in_thread do broemm end
  in_thread do 8.times do with_transpose -12 do slicerloop end end end
  in_thread do with_fx :level, amp: 0.5 do with_transpose 19 do broemm end end end
  in_thread do (64*4).times do pianohigh end end
  in_thread do
    16.times do drumloop end
    4.times do otherdrumloop end
    12.times do drumloop end
  end
  8.times do chordidx end
end

define :broemm do
  use_synth :prophet
  use_synth_defaults release: 0
  play :eb3, sustain: 4
  sleep 4
  play :db3, sustain: 2
  sleep 2
  play :cb3, sustain: 2
  sleep 2
  play :bb2, sustain: 6
  sleep 6
  play :bb2, sustain: 1
  sleep 1
  play :cb3, sustain: 1
  sleep 1
  play :db3, sustain: 4
  sleep 4
  play :cb3, sustain: 2
  sleep 2
  play :bb2, sustain: 2
  sleep 2
  play :ab2, sustain: 6
  sleep 6
  play :ab2, sustain: 1
  sleep 1
  play :bb2, sustain: 1
  sleep 1
  play :cb3, sustain: 3
  sleep 3
  play :cb3, sustain: 1
  sleep 1
  play :bb2, sustain: 1
  sleep 1
  play :bb2, sustain: 1
  sleep 1
  play :ab2, sustain: 1
  sleep 1
  play :ab2, sustain: 1
  sleep 1
  play :gb2, sustain: 6
  sleep 6
  play :eb2, sustain: 2
  sleep 2
  play :gb2, sustain: 6
  sleep 6
  play :eb2, sustain: 2
  sleep 2
  play :gb2, sustain: 8
  sleep 8
end

define :endpart do
  i = 0
  8.times do
    with_bpm_mul 0.9**i do
      in_thread do 4.times do drumloop end end
      in_thread do 32.times do piano end end
      chordidx
      i = i + 1
    end
  end
end

define :main do
  2.times do drumloop end
  strippedloop
  fullloop
  quietpart
  endpart
end

main