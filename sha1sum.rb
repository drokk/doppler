# ruby version of power shell script of mine.
# encoding: utf-8
require 'openssl'
require 'optparse'
require 'pp'
options = {}
options[:pick] = 'sha1'

optparse = OptionParser.new do |opts|
    opts.banner = 'Usage: crypthashsum [options]'

    opts.on('--hash [TYPE]', 'Select hash type (md5, sha1, sha256') do |hash|
        options[:pick] = hash
    end
end

optparse.parse!

pick = options[:pick]

case pick
  when "md5"
    digest = OpenSSL::Digest::MD5.new
  when "sha1"
    digest = OpenSSL::Digest::SHA1.new
  when "sha256"
    digest = OpenSSL::Digest::SHA256.new
end

file = "#{ARGV[0]}"

data = File.read(file)

digest_2 = digest.digest(data)

pp pick
pp ARGV
# pp digest_2.each_byte.map { |b| b.to_s(16)}.join
pp digest_2.unpack('H*').first
