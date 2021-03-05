# frozen_string_literal: true

score = ARGV[0]
scores = score.split(',')
shots = []
scores.each do |s|
  if s == 'X'
    shots << 10
    shots << 0
  else
    shots << s.to_i
  end
end

frames = []
shots.each_slice(2) do |s|
  s.delete 0 if s[0] == 10
  frames << s
end

# 10フレーム目の処理
case frames.length
when 11
  frames[9].concat frames[10]
  frames.delete_at 10
when 12
  frames[9].concat frames[10]
  frames[9].concat frames[11]
  2.times { frames.delete_at 10 }
end

point = 0
frames.each_with_index do |f, i|
  point +=  if i <= 7 && f[0] == 10 && frames[i + 1][0] == 10 # ストライクが1~8フレームで連続で発生
              20 +  frames[i + 2][0]
            elsif i == 8 && f[0] == 10 # 9フレーム目でストライク
              10 + frames[9][0..1].sum
            elsif i <= 7 && f[0] == 10 # ストライクが発生した時
              10 + frames[i + 1].sum
            elsif i != 9 && f.sum == 10 # スペアが発生した時
              10 + frames[i + 1][0]
            else
              f.sum
            end
end
puts point
