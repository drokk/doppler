# ruby version of power shell script of mine.
# encoding: utf-8
require 'openssl'
require 'optparse'
require 'pp'
options = {}
# default hash is sha1
options[:pick] = 'sha1'

optparse = OptionParser.new do |opts|
    opts.banner = 'Usage: crypthashsum [options]'

    opts.on('--hash TYPE', 'Select hash type (md5, sha1, sha256') do |hash|
        options[:pick] = hash
    end

    opts.on('-d [TYPE]', 'directory of files we want to checksum') do |directory|
        options[:dir] = directory
    end


end

optparse.parse!

pick = options[:pick]

dir = options[:dir]

# populate files only if dir is not nil as in the user has defined a directory
unless dir.nil?
  files = Dir.entries(dir).reject { |content| content =~ /^\.*$/}
end


case pick
  when 'md5'
    digest = OpenSSL::Digest::MD5.new
  when 'sha1'
    digest = OpenSSL::Digest::SHA1.new
  when 'sha256'
    digest = OpenSSL::Digest::SHA256.new
  else
    abort (message='unknown hash!')

end

# create a digest for each file
ARGV.each do |file|

if File.exists?(file) then

  # if the files is bigger than LONG_MAX then read it in 512 byte chunks
  # according to http://ruby.about.com/od/advancedruby/ss/Cryptographic-Hashes-In-Ruby.htm
  if File.size(file) > 2147483647 then
    File.open(file) do|big_file|
      buffer = ''
      # read the file 512 bytes at a time
      while not big_file.eof
        big_file.read(512, buffer)
        digest.update(buffer)
      end
      digest_2 = digest.digest
    end
  # smaller files we can just read into memory.
  else
    digest_2 = digest.digest(File.read(file))
  end

  pp pick
  pp file
  pp File.size(file)
  pp digest_2.unpack('H*').first

else
  pp file
  pp 'file not found'
end
end