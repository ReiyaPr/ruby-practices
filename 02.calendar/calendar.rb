# clsss Dateのインポート

require "date"
require "optparse"

#option導入の準備
options = ARGV.getopts('m:','y:')

# 取得月のクラスをIntegerへ
if !options["m"]
  month = options["m"] = Date.today.month
else  
  month = options["m"].to_i
end

# 取得年のクラスをIntegerへ
if !options["y"]  
  year = options["y"] = Date.today.year
else 
  year = options["y"].to_i
end


# 初日を取得
day_first = Date.new(year,month,1) 

# 最終日を取得
day_last = Date.new(year,month,-1)

#初日の曜日を番号で取得
day_first_num = day_first.strftime('%w').to_i

# 初日から最終日をリスト化
dates_list = [*day_first..day_last]

puts "      #{month}月  #{year}"

week = ["日","月","火","水","木","金","土"].join(" ")
puts week

lines_num = 0
dates_list.each do |date|
  #1週目のスペース出力処理
  if lines_num.zero?
    print "   " * day_first_num 
    lines_num += 1
  end 
    #2週目以降の出力処理。日付が土曜日であれば改行
  if date.saturday? 
    print date.day.to_s.rjust(2)
    print "\n"
  else        
    print date.day.to_s.rjust(2)
    print " "
  end
end 

print "\n"


