# ruby replacement for an old powershell script.
# encoding: utf-8
require 'openssl'
require 'optparse'
require 'pp'
options = {}
# default hash is sha1
options[:pick] = 'sha1'

optparse = OptionParser.new do |opts|
    opts.banner = 'Usage: sha1sum.rb [options]'

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

# populate files by directory listing only if dir is not nil (as in the user has defined a directory)
if dir.nil?
  files = ARGV
  else
  files = Dir.entries(dir).reject { |content| File::ftype(dir+"/"+content) != "file"} #we want only files in our array
  files = files.map { |file| "#{dir}/#{file}"} # and we need to add the path to the directory to each file
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
result = {}

# create a digest for each file
def hash_file (files)
  files.each do |file|


    if (File.exists?(file) and  File.readable_real?(file))
    # if the files is larger than LONG_MAX then read it in 512 byte chunks
    # according to http://ruby.about.com/od/advancedruby/ss/Cryptographic-Hashes-In-Ruby.htm

    File.open(file) do |big_file|
      buffer = ''
      while not big_file.eof
        big_file.read(512, buffer)
        digest.update(buffer)
      end
    end

    result[file] = [pick,File.size(file),digest]
    #pp pick
    #pp file
    #pp File.size(file)
    #puts digest
    #puts result

    else
    pp file
    pp 'file not found'
    end
  end
end