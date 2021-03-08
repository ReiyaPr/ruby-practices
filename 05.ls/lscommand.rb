# frozen_string_literal: true

require 'etc'
require 'optparse'
options = ARGV.getopts('a', 'l', 'r')

class File
  attr_reader :file_info, :permission, :file_type, :permission_8base, :sylink, :user_id, :group_id, :bytesize, :month, :day, :time, :name, :size,
              :permission_data, :block

  def initialize(file)
    @file_info = File.lstat(file)
    @file_type = file_info.ftype
    @block = file_info.blocks
    @permission_8base = file_info.mode.to_s(8).slice(-3..-1)
    @sylink = file_info.nlink
    @user_id = Etc.getpwuid(file_info.uid).name
    @group_id = Etc.getgrgid(file_info.gid).name
    @bytesize = file_info.size
    @month = file_info.mtime.strftime('%m').to_i
    @day = file_info.mtime.strftime('%d').to_i
    @time = file_info.mtime.strftime('%H:%M')
    @name = file
  end

  def file_type_convert(file_type)
    {
      "file": '-',
      "directory": 'd',
      "characterSpecial": 'c',
      "blockSpecial": 'b',
      "fifo": 'f',
      "link": 'l',
      "socket": 's'
    }[file_type.to_sym]
  end

  def make_permission_code
    array = []
    array << permission_8base[0].to_i << permission_8base[1].to_i << permission_8base[2].to_i
    permission_data = [] << file_type_convert(file_type)
    array.each do |s|
      case s
      when 7 then permission_data.push('rwx')
      when 6 then permission_data.push('rw-')
      when 5 then permission_data.push('r-x')
      when 4 then permission_data.push('r--')
      when 3 then permission_data.push('-wx')
      when 2 then permission_data.push('-w-')
      when 1 then permission_data.push('--x')
      when 0 then permission_data.push('---')
      end
    end
    permission_data.join('')
  end

  def make_info_array
    file_info_array = []
    file_info_array << make_permission_code
    file_info_array << sylink
    file_info_array << user_id
    file_info_array << group_id
    file_info_array << bytesize
    file_info_array << month
    file_info_array << day
    file_info_array << time
    file_info_array << name
    file_info_array.join(' ')
  end
end
# ここまでクラス情報でlコマンドのオプションが可能になる

dir_file = if options['a'] && options['r']
             Dir.glob('*', File::FNM_DOTMATCH).reverse
           elsif options['r']
             Dir.glob('*').reverse
           elsif options['a']
             Dir.glob('*', File::FNM_DOTMATCH)
           else
             Dir.glob('*')
           end

def file_size_total(files)
  total = 0
  files.each do |f|
    file = File.new(f)
    total += file.block
  end
  puts "total #{total}"
end

if options['l']
  file_size_total(dir_file)
  dir_file.each do |f|
    file = File.new(f)
    puts file.make_info_array
  end
else
  # 出力のためファイル数を3の倍数になるよう調整
  mod = dir_file.length % 3
  case mod
  when 1
    2.times { dir_file << ' ' }
  when 2
    dir_file << ' '
  end
  # 最も長いファイル名の長さを取得
  file_name_length = []
  dir_file.each do |f|
    file_name_length << f.length
  end
  max_files_length = file_name_length.max
  # lsコマンドの出力処理
  row_num = (dir_file.length / 3)
  i = 0
  row_num.times do
    puts("#{dir_file[i].ljust(max_files_length)}    #{dir_file[i + row_num].ljust(max_files_length)}  #{dir_file[i + row_num * 2].ljust(max_files_length)}")
    i += 1
  end
end
