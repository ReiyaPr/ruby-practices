# frozen_string_literal: true

require 'etc'
require 'optparse'

class FileData
  attr_reader :file_info, :name

  def initialize(file)
    @file_info = File.lstat(file)
    @name = file
  end

  PERMISSION_CODES =
    {
      '7' => 'rwx',
      '6' => 'rw-',
      '5' => 'r-x',
      '4' => 'r--',
      '3' => '-wx',
      '2' => '-w-',
      '1' => '--x',
      '0' => '---'
    }.freeze

  # -lオプション実行時に出力されるデータの作成
  def build_info_array
    file_info_array = []
    file_info_array << convert_permission_code
    file_info_array << file_info.nlink
    file_info_array << Etc.getpwuid(file_info.uid).name
    file_info_array << Etc.getgrgid(file_info.gid).name
    file_info_array << file_info.size.to_s.rjust(6)
    file_info_array << file_info.mtime.strftime('%-m %e %H:%M')
    file_info_array << name
    file_info_array << "-> #{File.readlink(name)}" if convert_file_type(file_info.ftype) == 'l'
    file_info_array.join(' ')
  end

  private

  FILE_TYPES =
    {
      file: '-',
      directory: 'd',
      characterSpecial: 'c',
      blockSpecial: 'b',
      fifo: 'f',
      link: 'l',
      socket: 's'
    }.freeze

  def convert_file_type(file_type)
    FILE_TYPES[file_type.to_sym]
  end

  def convert_permission_code
    octal_permission_codes = file_info.mode.to_s(8).slice(-3..-1).chars
    permission_data = [convert_file_type(file_info.ftype)]
    octal_permission_codes.each do |code|
      permission_data << PERMISSION_CODES[code]
    end
    permission_data.join
  end
end

COLUMN_COUNT = 3
def main
  options = ARGV.getopts('a', 'l', 'r')
  directory_files = options['a'] ? Dir.glob('*', File::FNM_DOTMATCH) : Dir.glob('*')
  directory_files.reverse! if options['r']
  if options['l']
    call_l_options(directory_files)
  else
    call_dafault_ls(directory_files)
  end
end

private

def call_l_options(files)
  file_blocksize_total(files)
  files.each do |f|
    file = FileData.new(f)
    puts file.build_info_array
  end
end

def call_dafault_ls(files)
  slice_number = (files.size / COLUMN_COUNT.to_f).ceil
  sliced_files_array = files.each_slice(slice_number).to_a
  unless sliced_files_array.first.length == sliced_files_array.last.length
    (sliced_files_array.first.length - sliced_files_array.last.length).times { sliced_files_array.last.push(' ') }
  end
  sliced_files_array.transpose.each do |array|
    array.each do |element|
      print element.ljust(files.max_by(&:length).size + 7)
    end
    print "\n"
  end
end

def file_blocksize_total(files)
  file_blocks = files.map do |f|
    FileData.new(f).file_info.blocks
  end
  puts "total #{file_blocks.sum}"
end
main
