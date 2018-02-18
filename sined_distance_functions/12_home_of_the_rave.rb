use_bpm 80

define :amen_blip do
  use_synth :mod_beep
  duration = [0.125, 0.25].choose
  with_fx :tanh, krunch: 10 do
    play scale(:E4, :minor_pentatonic).choose + [0, 12].choose, release: duration, mod_range: 7, mod_phase: 0.1, mod_pulse_width: 0.5
  end
  sleep duration
end

define :amen_bass do
  amen_bass_base(:harmonic_minor)
end
define :amen_bass_base do |scale|
  note = scale(:E1, scale).choose
  duration = 0.5
  bar(note, 0.5)
  sleep 0.25
  bar2(note, 0.25)
  sleep 0.25
end

define :bar2 do |note, duration|
  use_synth :tb303
  play note + 12, sustain: duration, release: 0.1
end

define :bar do |note, duration|
  use_synth :dsaw
  with_fx :hpf, cutoff: 30 do
    with_fx :lpf, cutoff: 90 do
      with_fx :wobble, mix: 0.5 do
        play note, amp: 0.7, detune: 0.2, sustain: duration, release: 0.1
        play note, amp: 0.7, detune: 0.5, sustain: duration, release: 0.1
      end
    end
  end
end

define :amen_amen do
  sample :loop_amen_full, beat_stretch: 8
  sleep 8
end

chords = (knit :e3, 4, :d3, 2, :eb3, 2)
chords_2 = (knit :e3, 4, :a3, 2, :eb4, 2)
chords_3 = (knit :e4, 4, :a3, 2, :eb4, 2)
sleeps = (knit 4,4, 2,2, 2,2)
define :amen_chords do |chordarray|
  idx = beat().round() + 4
  note = chordarray[idx]
  duration = sleeps[idx]
  use_synth :dsaw
  with_fx :hpf, cutoff: 70 do
    with_fx :gverb, mix: 0.2, amp: 0.3, room: 10 do
      with_fx :panslicer, wave: 3, mix: 0.15, phase: 2 do
        with_synth_defaults detune: 0.05, sustain: duration, release: 0, cutoff: 110 do
          play note
          play note + 7
          play note + 12
        end
      end
    end
  end
  sleep duration
end

define :amen_chords_1 do
  amen_chords(chords)
end

define :amen_chords_2 do
  amen_chords(chords_2)
end

define :amen_chords_3 do
  amen_chords(chords_3)
end

define :chorus_bass do
  idx = beat().round()
  note = chords[idx] - 12
  duration = sleeps[idx]
  use_synth :dsaw
  play note, amp: 0.5, detune: 0.2, sustain: duration, release: 0.1
  play note, amp: 0.5, detune: 0.5, sustain: duration, release: 0.1
  sleep duration
end

define :chorus_bleepy_harmonic do
  chorus_bleepy_base(:minor_pentatonic)
end
define :chorus_bleepy do
  chorus_bleepy_base(:harmonic_minor)
end
define :chorus_bleepy_base do |scale|
  use_synth :mod_beep
  note = scale(:E4, scale).choose
  with_fx :krush do
    play note, release: rrand(0.5, 1)
    sleep 1
  end
end

define :chorus_counter_harmonic do
  chorus_counter_base(:minor_pentatonic)
end
define :chorus_counter do
  chorus_counter_base(:harmonic_minor)
end
define :chorus_counter_base do |scale|
  use_synth :mod_pulse
  note = scale(:E4, scale).choose + [-12, 12].choose
  sleep 0.5
  play note, release: 1
  sleep [0.25, 0.5].choose
end

define :test_rhythm do
  sample :drum_tom_lo_hard
  sample :bd_haus
  sleep 0.5
  sample :drum_cymbal_hard
  sleep 0.5
  sample :sn_dub
  sleep 0.5
  sample :drum_cymbal_hard
  sleep 0.5
  sample :drum_tom_lo_hard
  sample :bd_haus
  sleep 1
  sample :sn_dub
  sample :drum_cymbal_open
  sleep 1
end

define :tic_rhythm do
  sample :drum_cymbal_open
  sleep 1
  sample :drum_cymbal_closed
  sleep 1
  sample :drum_cymbal_closed
  sleep 1
  sample :drum_cymbal_closed
  sleep 1
end

define :punk_rhythm_1 do
  sample :drum_cymbal_open
  sleep 1
  sample :sn_dub
  sample :drum_cymbal_open
  sleep 1
end

define :punk_rhythm_2 do
  sample :drum_cymbal_open
  sleep 0.5
  sample :sn_dub
  sample :drum_cymbal_open
  sleep 0.5
end

define :punk_rhythm_3 do
  sample :drum_cymbal_open
  sleep 0.25
  sample :sn_dub
  sample :drum_cymbal_open
  sleep 0.25
end

define :punk_3_supplement do
  sample :drum_cymbal_open, amp: 0.7
  sleep 0.25
end

define :crush_1 do |duration|
  with_fx :bitcrusher, bits: 3 do
    sample :drum_heavy_kick, beat_stretch: duration, pitch: 30 + rrand(-50, 150)
  end
end

define :crush_2 do |duration|
  with_fx :bitcrusher, bits: 4 do
    sample :ambi_piano, beat_stretch: duration, pitch: 50 + rrand(-50, 50)
  end
end

define :crush_3 do |duration|
  with_fx :bitcrusher, bits: 2, amp: 0.5 do
    sample :elec_triangle, beat_stretch: duration, pitch: 50 + rrand(-50, 50)
  end
end

define :crush_4 do |duration|
  with_fx :bitcrusher, bits: 7 do
    sample :elec_triangle, beat_stretch: duration, pitch: 50 + rrand(-50, 50)
  end
end

define :random_crushes do
  use_arg_checks false
  crush = [:crush_1, :crush_2, :crush_3, :crush_4].choose
  duration = 0.25
  send(crush, 2*duration)
  sleep duration
end

define :playall do |duration, functions|
  start_beat = beat()
  end_beat = start_beat + duration
  functions.each do |item|
    in_thread do
      while beat() < end_beat do send(item) end
      end
    end
    sleep duration
  end
  
  define :main do
    playall(16, [:chorus_bleepy, :chorus_counter])
    playall(16, [:chorus_bass, :chorus_bleepy, :chorus_counter, :test_rhythm])
    with_fx :krush do
      in_thread do
        playall(16, [:chorus_bass, :chorus_bleepy, :chorus_counter, :test_rhythm])
      end
    end
    playall(16, [:chorus_bass, :chorus_bleepy, :chorus_counter, :test_rhythm])
    with_fx :krush, mix: 0.1 do
      playall(4, [:tic_rhythm, :chorus_bleepy, :chorus_counter])
    end
    sample :drum_cymbal_hard
    playall(16, [:amen_amen, :amen_bass, :amen_blip])
    playall(16, [:amen_amen, :amen_bass, :amen_chords_1, :amen_blip])
    playall(8, [:amen_amen, :amen_bass, :amen_chords_2, :amen_blip])
    playall(4, [:amen_bass, :punk_rhythm_1, :amen_chords_3])
    playall(4, [:amen_bass, :punk_rhythm_2])
    playall(4, [:amen_bass, :punk_rhythm_3])
    playall(12, [:punk_3_supplement, :amen_amen, :chorus_bleepy_harmonic, :chorus_counter_harmonic])
    playall(8, [:punk_3_supplement, :amen_amen, :amen_chords_1, :chorus_bleepy_harmonic, :chorus_counter_harmonic])
    playall(12, [:random_crushes, :chorus_bleepy_harmonic, :chorus_counter_harmonic])
    playall(4, [:random_crushes])
    playall(16, [:amen_amen, :amen_bass, :amen_blip])
    playall(2, [:random_crushes])
    playall(2, [:amen_amen, :amen_bass, :amen_blip])
    playall(2, [:random_crushes])
    playall(2, [:amen_bass, :amen_blip])
    playall(4, [:random_crushes])
    playall(4, [:amen_amen, :amen_bass, :amen_blip])
    playall(16, [:random_crushes, :amen_amen, :amen_chords_1, :amen_bass, :amen_blip])
    with_fx :ixi_techno, mix: 0.5, phase: 8 do
      playall(4, [:random_crushes, :amen_amen, :amen_chords_1, :amen_bass, :amen_blip])
    end
    playall(4, [:random_crushes, :amen_chords_1, :amen_bass, :amen_blip])
    with_fx :ixi_techno, mix: 0.5, phase: 8, phase_offset: 0.5 do
      playall(4, [:random_crushes, :amen_amen, :amen_chords_1, :amen_bass, :amen_blip])
    end
    playall(4, [:random_crushes, :amen_chords_1, :amen_bass, :amen_blip])
    playall(8, [:random_crushes, :punk_3_supplement, :amen_amen, :amen_chords_1, :amen_bass, :amen_blip])
    playall(4, [:random_crushes, :amen_chords_1])
    playall(4, [:random_crushes])
  end
  
  main()