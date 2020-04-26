#!/usr/local/bin/python3
#TODO flesh out file digestion
#TODO identify file system objects
import hashlib 
import argparse 

# let's get all available hashes 
#available_hashes = Crypto.Hash.__all__

parser = argparse.ArgumentParser(description='lets create some hashes')
parser.add_argument('--strings', type=str, nargs='+',dest='input', help='give me word')
parser.add_argument('--hash', dest='hash2', help='valid options are SHA256, MD5, SHA1' )
parser.add_argument('--file', dest='file', help='file name')
args = parser.parse_args()

#print(args.input,' ',args.hash2)


# offloading argument inputs into local variables 
args_input = args.input  
args_hashes = args.hash2.lower()  
args_file = args.file 
BLOCK_SIZE = 65536
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

# if args_file : #read the file and produce the hash. 
#     with open(args_file, 'rb') as file: 
#         file_block = file.read(BLOCK_SIZE)
#         while len(file_block) > 0: 
#             if hash2 == 'SHA256':
#                 hash_object = SHA256.(data=string.encode())
#             elif hash2 == 'MD5':
#                     hash_object = MD5.new(data=string.encode())
#             elif hash2 == 'SHA1':
#                     hash_object = SHA1.new(data=string.encode())
#             else:
#                 print('unknown hash')     
