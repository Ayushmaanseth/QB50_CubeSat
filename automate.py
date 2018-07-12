import os,sys
import tkinter as tk
from tkinter import filedialog
import numpy as np
from copy import deepcopy
import pprint

pp = pprint.PrettyPrinter(indent=4)

format_file = 'format.txt'

filepath_object = open(format_file,'r')


root = tk.Tk()
root.withdraw()

filepath = filedialog.askdirectory()


filepath = str(filepath)
os.chdir(filepath)

files = os.listdir()
#files = files[3:]

k = 0


vpk_array = np.zeros((6,2,len(files)))
burst_count_array1 = np.zeros((6,16,len(files)))
burst_count_array2 = np.zeros((4,3,len(files)))

#dump_array = np.zeros((10,10,len(files)))

formatted_structure = {}

calculation_structure = {'var':'','nbit': 0,'rbit': 0,'start_byte': 0,'start_bit': 0}

calculation_structures = []
final_structure = {}


for i in range(150):
	structure = deepcopy(calculation_structure)
	calculation_structures.append(structure)

current_bit = 0

i = 0
file = filepath_object.readline()
while file != '':
	#print(f)
	file_separated = file.split()
	
	calculation_structures[i]['nbit'] = int(file_separated[0].strip())
	calculation_structures[i]['var'] = file_separated[1].strip()
	calculation_structures[i]['rbit'] = current_bit
	calculation_structures[i]['start_byte'] = int(current_bit/8)
	calculation_structures[i]['start_bit'] = current_bit- int(int(current_bit/8) * 8)
	current_bit += calculation_structures[i]['nbit']
	file = filepath_object.readline()
	#print(calculation_structures[i])
	i += 1

def PKG_extract(calculation_structures,bytes_data,vpk_index):
	j = 0

	for i in range(2):
		BURST_COUNT = bytes_data[calculation_structures[j]['start_byte']:calculation_structures[j]['start_byte']+3]
		BURST_COUNT_int = int.from_bytes(BURST_COUNT,byteorder='big')
		BURST_COUNT_bin = '{:024b}'.format(BURST_COUNT_int)
		BURST_COUNT_final = int(BURST_COUNT_bin[calculation_structures[j]['start_bit']:calculation_structures[j]['start_bit']+calculation_structures[j]['nbit']],2)
		#print('{}'.format(calculation_structures[j]['var']),"Taken from {}".format(calculation_structures[j]['start_bit']),int(BURST_COUNT_bin[calculation_structures[j]['start_bit']:calculation_structures[j]['start_bit']+calculation_structures[j]['nbit']],2))
		formatted_structure[calculation_structures[j]['var']] = BURST_COUNT_final
		j += 1
		vpk_array[vpk_index][i][k] = BURST_COUNT_final


	vpk_index += 1
	
def BURST_extract(calculation_structures,bytes_data,burst_count_index1):
	j = 0

	for k in range(3):

		for i in range(16):
			BURST_COUNT = bytes_data[calculation_structures[j]['start_byte']:calculation_structures[j]['start_byte']+3]
			BURST_COUNT_int = int.from_bytes(BURST_COUNT,byteorder='big')
			BURST_COUNT_bin = '{:024b}'.format(BURST_COUNT_int)
			BURST_COUNT_final = int(BURST_COUNT_bin[calculation_structures[j]['start_bit']:calculation_structures[j]['start_bit']+calculation_structures[j]['nbit']],2)
			#print('{}'.format(calculation_structures[j]['var']),"Taken from {} bit and {} byte".format(calculation_structures[j]['start_bit'],calculation_structures[j]['start_byte']),int(BURST_COUNT_bin[calculation_structures[j]['start_bit']:calculation_structures[j]['start_bit']+calculation_structures[j]['nbit']],2))
			formatted_structure[calculation_structures[j]['var']] = BURST_COUNT_final
			j += 1
			burst_count_array1[burst_count_index1][i][k] = BURST_COUNT_final

		burst_count_index1 += 1

def BURST_LAST_extract(calculation_structures,bytes_data,burst_count_index2):

	j = 0
	for i in range(3):
		
		BURST_COUNT = bytes_data[calculation_structures[j]['start_byte']:calculation_structures[j]['start_byte']+3]
		BURST_COUNT_int = int.from_bytes(BURST_COUNT,byteorder='big')
		BURST_COUNT_bin = '{:024b}'.format(BURST_COUNT_int)
		BURST_COUNT_final = int(BURST_COUNT_bin[calculation_structures[j]['start_bit']:calculation_structures[j]['start_bit']+calculation_structures[j]['nbit']],2)
		#print(BURST_COUNT_bin)
		#print('{}'.format(calculation_structures[j]['var']),"Taken from {}".format(calculation_structures[j]['start_bit']),int(BURST_COUNT_bin[calculation_structures[j]['start_bit']:calculation_structures[j]['start_bit']+calculation_structures[j]['nbit']],2))
		formatted_structure[calculation_structures[j]['var']] = BURST_COUNT_final
		j += 1
		burst_count_array2[burst_count_index2][i][k] = BURST_COUNT_final

	
	burst_count_index2 += 1





calculation_structures = calculation_structures[0:i]
#pp.pprint(calculation_structures)
filepath_object.close()

while k < len(files):

	vpk_index = 0
	burst_count_index1 = 0
	burst_count_index2 = 0
	#filepath.close()
	#print("opening new file now")
	DAT_file_object = open('53.dat','rb')


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

	formatted_structure['time'] = int.from_bytes(time,byteorder='little',signed=True)
	formatted_structure['roll'] = int.from_bytes(roll,byteorder='big',signed=True)
	formatted_structure['pitch'] = int.from_bytes(pitch,byteorder='big',signed=True)
	formatted_structure['yaw'] = int.from_bytes(yaw,byteorder='big',signed=True)
	formatted_structure['rolldot'] = int.from_bytes(rolldot,byteorder='big',signed=True)
	formatted_structure['pitchdot'] = int.from_bytes(pitchdot,byteorder='big',signed=True)
	formatted_structure['yawdot'] = int.from_bytes(yawdot,byteorder='big',signed=True)
	formatted_structure['x'] = int.from_bytes(x,byteorder='big',signed=True)
	formatted_structure['y'] = int.from_bytes(y,byteorder='big',signed=True)
	formatted_structure['z'] = int.from_bytes(z,byteorder='big',signed=True)
	formatted_structure['resp_id'] = int.from_bytes(resp_id,byteorder='big',signed=True)
	formatted_structure['seq_cnt'] = int.from_bytes(seq_cnt,byteorder='big',signed=True)
	formatted_structure['i_ion'] = int.from_bytes(i_ion,byteorder='big',signed=True)



	#print("Time:",int.from_bytes(time,byteorder='little',signed=True))
	#print("roll:",int.from_bytes(roll,byteorder='big',signed=True))
	#print("pitch:",int.from_bytes(pitch,byteorder='big',signed=True))
	#print("yaw:",int.from_bytes(yaw,byteorder='big',signed=True))
	#print("rolldot:",int.from_bytes(rolldot,byteorder='big',signed=True))
	#print("pitchdot:",int.from_bytes(pitchdot,byteorder='big'))
	#print("yawdot:",int.from_bytes(yawdot,byteorder='big'))
	#print("x:",int.from_bytes(x,byteorder='big'))
	#print("y:",int.from_bytes(y,byteorder='big',signed=True))
	#print("z:",int.from_bytes(z,byteorder='big'))
	#print("resp_id:",int.from_bytes(resp_id,byteorder='big'))
	#print("seq_cnt:",int.from_bytes(seq_cnt,byteorder='big'))
	#print("i_ion:",int.from_bytes(i_ion,byteorder='big'))

	bytes_data = DAT_file_object.read()
	#print(bytes_data)

	
	
	copied_structures = deepcopy(calculation_structures)

	for i in range(2):

		PKG_extract(copied_structures,bytes_data,vpk_index)
		copied_structures = copied_structures[2:]

		BURST_extract(copied_structures,bytes_data,burst_count_index1)
		copied_structures = copied_structures[48:]
	
	
	for i in range(4):

		PKG_extract(copied_structures,bytes_data,vpk_index)
		copied_structures = copied_structures[2:]
	
		BURST_LAST_extract(copied_structures,bytes_data,burst_count_index2)
		copied_structures = copied_structures[3:]
	
	#print("Closing file now")
	DAT_file_object.close()
	final_structure[files[k]] = formatted_structure
	k += 1
	
#pp.pprint(final_structure['4.dat']['time'])

