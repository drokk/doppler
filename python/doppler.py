#!/usr/local/bin/python3
from Crypto.Hash import SHA256,MD5,SHA1
import argparse 

# hash_object = SHA256.new(data=b'first')
# print(hash_object.hexdigest())
# hash_object = MD5.new(data=b'first')
# print(hash_object.hexdigest())
# hash_object = SHA1.new(data=b'first')
# print(hash_object.hexdigest())

parser = argparse.ArgumentParser(description='lets create some hashes')
parser.add_argument(metavar='String', type=str, dest='string', help='give me word')
parser.add_argument('--hash', dest='hash2',  help='valid options are SHA256, MD5, SHA1' )

args = parser.parse_args()

print(args.string,' ',args.hash2)

if args.hash2 == 'SHA256':
    hash_object = SHA256.new(data=args.string.encode())
elif args.hash2 == 'MD5':
        hash_object = MD5.new(data=args.string.encode())
elif args.hash2 == 'SHA1':
        hash_object = SHA1.new(data=args.string.encode())
else:
    print('unknown hash')     

if 'hash_object' in locals():     # if the hash_object is defined print out the string,hash type and the hash
    print(args.string,' ',args.hash2,' ',hash_object.hexdigest())
