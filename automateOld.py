import os,sys
import tkinter as tk
from tkinter import filedialog
import numpy as np
from copy import deepcopy


'''
root = tk.Tk()
root.withdraw()

filepath = filedialog.askdirectory()


filepath = str(filepath)
os.chdir(filepath)

files = os.listdir()
'''
temp_data = bytearray(196)
data_bytes = bytearray(196)
extra_data = np.zeros((3,48))

burst_count_array1 = np.zeros((16,6))
burst_count_array2 = np.zeros((3,4))

format_file = 'format.txt'

calculation_structure = {'var':'','nbit': 0,'rbit': 0,'start_byte': 0,'start_bit': 0}

calculation_structures = []

for i in range(150):
	structure = deepcopy(calculation_structure)
	calculation_structures.append(structure)

#print(type(calculation_structures[0]['nbit']))


current_bit = 0

filepath_object = open(format_file,'r')

file = filepath_object.readline()
i = 0
while file != '':
	#print(f)
	file_separated = file.split()
	#print(file_separated)
	calculation_structures[i]['nbit'] = int(file_separated[0].strip())
	calculation_structures[i]['var'] = file_separated[1].strip()
	calculation_structures[i]['rbit'] = current_bit
	calculation_structures[i]['start_byte'] = int(current_bit/8)
	calculation_structures[i]['start_bit'] = current_bit- int(int(current_bit/8) * 8)
	current_bit += calculation_structures[i]['nbit']
	file = filepath_object.readline()
	#print(calculation_structures[i])
	i += 1


calculation_structures = calculation_structures[0:i-1]
#print(calculation_structures[0]['start_byte'],calculation_structures[2]['start_byte'])
filepath_object.close()
bb = bytearray(176)

#filepath.close()
i = 0
DAT_file_object = open('53.dat','rb')


#print(myarray)
#dummy = DAT_file_object.read(1)

'''

hello = DAT_file_object.read()
pitch = hello[2:5]
pitch_int = int.from_bytes(pitch,byteorder='big')
pitch_bin = '{:024b}'.format(pitch_int)
pitch_final_bin = pitch_bin[2:18]
print(int(pitch_final_bin,2),pitch_bin)
'''
time = DAT_file_object.read(4)
roll = DAT_file_object.read(2)
pitch = DAT_file_object.read(2)
yaw = DAT_file_object.read(2)
rolldot = DAT_file_object.read(2)
pitchdot = DAT_file_object.read(2)
yawdot = DAT_file_object.read(2)
x = DAT_file_object.read(2)
y = DAT_file_object.read(2)
z = DAT_file_object.read(2)
resp_id = DAT_file_object.read(1)
seq_cnt = DAT_file_object.read(1)
i_ion = DAT_file_object.read(2)



print("Time:",int.from_bytes(time,byteorder='little',signed=True))
print("roll:",int.from_bytes(roll,byteorder='big',signed=True))
print("pitch:",int.from_bytes(pitch,byteorder='big',signed=True))
print("yaw:",int.from_bytes(yaw,byteorder='big',signed=True))
print("rolldot:",int.from_bytes(rolldot,byteorder='big',signed=True))
print("pitchdot:",int.from_bytes(pitchdot,byteorder='big'))
print("yawdot:",int.from_bytes(yawdot,byteorder='big'))
print("x:",int.from_bytes(x,byteorder='big'))
print("y:",int.from_bytes(y,byteorder='big',signed=True))
print("z:",int.from_bytes(z,byteorder='big'))
print("resp_id:",int.from_bytes(resp_id,byteorder='big'))
print("seq_cnt:",int.from_bytes(seq_cnt,byteorder='big'))
print("i_ion:",int.from_bytes(i_ion,byteorder='big'))

bytes_data = DAT_file_object.read()
#print(bytes_data)


j = 0
for i in range(2):
	BURST_COUNT = bytes_data[calculation_structures[j]['start_byte']:calculation_structures[j]['start_byte']+3]
	BURST_COUNT_int = int.from_bytes(BURST_COUNT,byteorder='big')
	BURST_COUNT_bin = '{:024b}'.format(BURST_COUNT_int)
	BURST_COUNT_final = int(BURST_COUNT_bin[calculation_structures[j]['start_bit']:calculation_structures[j]['start_bit']+calculation_structures[j]['nbit']],2)
	print('{}'.format(calculation_structures[j]['var']),"Taken from {}".format(calculation_structures[j]['start_bit']),int(BURST_COUNT_bin[calculation_structures[j]['start_bit']:calculation_structures[j]['start_bit']+calculation_structures[j]['nbit']],2))
	j += 1

calculation_structures = calculation_structures[2:]



for i in range(48):
	BURST_COUNT = bytes_data[calculation_structures[j]['start_byte']:calculation_structures[j]['start_byte']+3]
	BURST_COUNT_int = int.from_bytes(BURST_COUNT,byteorder='big')
	BURST_COUNT_bin = '{:024b}'.format(BURST_COUNT_int)
	#print(BURST_COUNT_bin)
	print('{}'.format(calculation_structures[j]['var']),"Taken from {} bit and {} byte".format(calculation_structures[j]['start_bit'],calculation_structures[j]['start_byte']),int(BURST_COUNT_bin[calculation_structures[j]['start_bit']:calculation_structures[j]['start_bit']+calculation_structures[j]['nbit']],2))
	j += 1

count = 0

calculation_structures = calculation_structures[48:]
#print(calculation_structures)






j = 0
for i in range(2):
	BURST_COUNT = bytes_data[calculation_structures[j]['start_byte']:calculation_structures[j]['start_byte']+3]
	BURST_COUNT_int = int.from_bytes(BURST_COUNT,byteorder='big')
	BURST_COUNT_bin = '{:024b}'.format(BURST_COUNT_int)
	#print(BURST_COUNT_bin)
	print('{}'.format(calculation_structures[j]['var']),"Taken from {} bit and {} byte".format(calculation_structures[j]['start_bit'],calculation_structures[j]['start_byte']),int(BURST_COUNT_bin[calculation_structures[j]['start_bit']:calculation_structures[j]['start_bit']+calculation_structures[j]['nbit']],2))
	

	j += 1
calculation_structures = calculation_structures[2:]
#print(byte)
j = 0
for i in range(48):
	BURST_COUNT = bytes_data[calculation_structures[j]['start_byte']:calculation_structures[j]['start_byte']+3]
	BURST_COUNT_int = int.from_bytes(BURST_COUNT,byteorder='big')
	BURST_COUNT_bin = '{:024b}'.format(BURST_COUNT_int)
	#print(BURST_COUNT_bin)
	print('{}'.format(calculation_structures[j]['var']),"Taken from {}".format(calculation_structures[j]['start_bit']),int(BURST_COUNT_bin[calculation_structures[j]['start_bit']:calculation_structures[j]['start_bit']+calculation_structures[j]['nbit']],2))
	

	j += 1

calculation_structures = calculation_structures[48:]

j = 0
for i in range(19):
	BURST_COUNT = bytes_data[calculation_structures[j]['start_byte']:calculation_structures[j]['start_byte']+3]
	BURST_COUNT_int = int.from_bytes(BURST_COUNT,byteorder='big')
	BURST_COUNT_bin = '{:024b}'.format(BURST_COUNT_int)
	#print(BURST_COUNT_bin)
	print('{}'.format(calculation_structures[j]['var']),"Taken from {}".format(calculation_structures[j]['start_bit']),int(BURST_COUNT_bin[calculation_structures[j]['start_bit']:calculation_structures[j]['start_bit']+calculation_structures[j]['nbit']],2))
	

	j += 1



#print(np.frombuffer(z,dtype=np.int16))
'''
while byte != b'':
	#print("".join(map(chr,byte)))
	count += 1
	byte = DAT_file_object.read(2)
	#print(byte)
	temp = np.frombuffer(byte,dtype=np.int16)
	val = mid(temp,0,12)
	print(val)	
'''

DAT_file_object.close()
#print("Count: ",count)

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

'''
Time is:  579657827
roll :  0
pitch:  6
yaw:  0
rolldot:  65426
pitchdot:  63306
yawdot:  10
x:  345
y:  64234
z:  0

'''
