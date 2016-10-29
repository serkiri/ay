import sys
import os

if __name__ == '__main__':
    print ('starting to Hex')
    print (sys.version)
    pt3FileName = sys.argv[1]
    print (pt3FileName)
    pt3File = open(pt3FileName, 'rb')
    hexFileName = pt3FileName + '.hex'
    hexFile = open(hexFileName, "w")
    
    pt3File.seek(0,2)
    pt3FileSize = pt3File.tell()
    print (pt3FileSize)


    i = 0;
    while(True):
        if (i != 0) and (i % 512 == 0):
            hexFile.write('\n')    
        pt3File.seek(i,0)
        hexValue = hex(ord(pt3File.read(1)))[2:].zfill(2)
        hexFile.write('0x' + hexValue)
        if i == pt3FileSize - 1:
            break
        hexFile.write(', ')
        i += 1