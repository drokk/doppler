#!/usr/local/bin/python3
#TODO identify file system objects
import hashlib 
import argparse 

# let's get all available hashes 
#available_hashes = Crypto.Hash.__all__

parser = argparse.ArgumentParser(description='lets create some hashes')
parser.add_argument('--strings', type=str, nargs='+',dest='input', help='give me word')
parser.add_argument('--hash', dest='hash2', help='valid options are SHA256, MD5, SHA1' )
parser.add_argument('--file', type=str, dest='files', nargs='+', help='file name(s)')
args = parser.parse_args()

#print(args.input,' ',args.hash2)


# offloading argument inputs into local variables 
args_input = args.input  
args_hashes = args.hash2.lower()  
args_files = args.files 
BLOCK_SIZE = 65536 #increase this value if want to back file hashing with more memory for speed reasons 
# catch the all in the hashes option 
if args_hashes == 'all':
    args_hashes = 'sha256,md5,sha1'


if args_hashes.find(','): # if receiving a string of comma separated options split them into list 
    hashes = args_hashes.split(',') 
else:
    hashes = args_hashes

if args_input : # only what to do checksum on cli input if there not files 
    for string in args_input:
        for hashtype in hashes: 
            hashobject = hashlib.new(hashtype)
            hashobject.update(string.encode())
               

            if 'hashobject' in locals():     # if the hash_object is defined print out the string,hash type and the hash
                print(string,' ',hashtype,' ',hashobject.hexdigest())

if args_files : #read a file and produce the hash, see https://nitratine.net/blog/post/how-to-hash-files-in-python/
    for file in args_files: 
        for hashtype in hashes:
            hashobject = hashlib.new(hashtype) 
            with open(file, 'rb') as file_handle: 
                file_block = file_handle.read(BLOCK_SIZE)
                while len(file_block) > 0:
                    hashobject.update(file_block)
                    file_block = file_handle.read(BLOCK_SIZE)
            print(file,' | ',hashtype,' | ',hashobject.hexdigest())        

