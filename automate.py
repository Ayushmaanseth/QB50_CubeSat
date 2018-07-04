import os
import tkinter as tk
from tkinter import filedialog
import numpy as np
from scipy.io import FortranFile

def last(k,n):
	return ((k) & ((1<<(n)) - 1))

def mid(k,m,n):
	last((k)>>(m),((n) - (m)))

root = tk.Tk()
root.withdraw()

filepath = filedialog.askdirectory()


filepath = str(filepath)
os.chdir(filepath)

files = os.listdir()


myarray = bytearray()

i = 0
f = open(files[0],'rb')
#dummy = f.read(1)
byte = b'\x00'
temp_byte = b'\x00'
byte = f.read(4)
print(("Time is: ",int.from_bytes(byte,byteorder='big')))
while byte != b'':
	#print("".join(map(chr,byte)))
	byte = f.read(2)
	print(int.from_bytes(byte,byteorder='big'))
	

f.close()


#for file in files:
#myarray = np.append(myarray,np.fromfile(files[0],dtype=int))
	

#finalArray = myarray[1:].tolist()

#print(len(finalArray))
'''
for i in finalArray:
	print(i)
	print("\t")
 
'''
#print(myarray)
