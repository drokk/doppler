#!/usr/local/bin/python3
from Crypto.Hash import *
import argparse 

# let's get all available hashes 
#available_hashes = Crypto.Hash.__all__

parser = argparse.ArgumentParser(description='lets create some hashes')
parser.add_argument(metavar='String', type=str, nargs='+',dest='input', help='give me word')
parser.add_argument('--hash', dest='hash2', help='valid options are SHA256, MD5, SHA1' )

args = parser.parse_args()

print(args.input,' ',args.hash2)


# offloading argument inputs into local variables 
args_input = args.input  
args_hashes = args.hash2.upper()  

# catch the all in the hashes option 
if args_hashes == 'ALL':
    args_hashes = 'SHA256,MD5,SHA1'


if args_hashes.find(','): # if receiving a string of comma separated options split them into list 
    hashes = args_hashes.split(',') 
else:
    hashes = args_hashes


for string in args_input:
    for hash2 in hashes: 
        if hash2 == 'SHA256':
            hash_object = SHA256.new(data=string.encode())
        elif hash2 == 'MD5':
                hash_object = MD5.new(data=string.encode())
        elif hash2 == 'SHA1':
                hash_object = SHA1.new(data=string.encode())
        else:
            print('unknown hash')     

        if 'hash_object' in locals():     # if the hash_object is defined print out the string,hash type and the hash
            print(string,' ',hash2,' ',hash_object.hexdigest())
