import os,sys
import tkinter as tk
from tkinter import filedialog
import numpy as np
from copy import deepcopy
import pprint
import matplotlib
import matplotlib.dates as mdates
import matplotlib.pyplot as plt
import datetime,time
import dropbox
from dropbox.files import WriteMode
from dropbox.exceptions import ApiError, AuthError
from NewAutomate import upload,getFiles

def time_to_seconds(time_string):
        """Helper to convert strings 'hh:mm:ss' to integer seconds"""
        parts = time_string.split(':')
        s = int(parts[-1])
        m = int(parts[-2])
        if len(parts) == 2:
            h = 0
        else:
            h = int(parts[-3])
        time_obj = datetime.timedelta(hours=h, minutes=m, seconds=s)
        return int(time_obj.total_seconds())


format_file = 'format.txt'

filepath_object = open(format_file,'r')


root = tk.Tk()
root.withdraw()

filepath = filedialog.askdirectory()


filepath = str(filepath)
os.chdir(filepath)

files = os.listdir()
files = sorted(files,key=len)

k = 0


vpk_array = np.zeros((len(files),6,2))
burst_count_array1 = np.zeros((len(files),6,16))
burst_count_array2 = np.zeros((len(files),4,3))
max_array = np.zeros((len(files),18))
pos = np.zeros((len(files),18))
id_array = []
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
	i += 1
#pp.pprint(calculation_structures)

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
		vpk_array[k][vpk_index][i] = BURST_COUNT_final


	vpk_index += 1
	
def BURST_extract(calculation_structures,bytes_data,burst_count_index1):
	j = 0

	for a in range(3):
		mi = 0
		for i in range(16):
			
			BURST_COUNT = bytes_data[calculation_structures[j]['start_byte']:calculation_structures[j]['start_byte']+3]
			BURST_COUNT_int = int.from_bytes(BURST_COUNT,byteorder='big')
			BURST_COUNT_bin = '{:024b}'.format(BURST_COUNT_int)
			BURST_COUNT_final = int(BURST_COUNT_bin[calculation_structures[j]['start_bit']:calculation_structures[j]['start_bit']+calculation_structures[j]['nbit']],2)
			#print('{}'.format(calculation_structures[j]['var']),"Taken from {} bit and {} byte".format(calculation_structures[j]['start_bit'],calculation_structures[j]['start_byte']),int(BURST_COUNT_bin[calculation_structures[j]['start_bit']:calculation_structures[j]['start_bit']+calculation_structures[j]['nbit']],2))
			formatted_structure[calculation_structures[j]['var']] = BURST_COUNT_final
			j += 1
			burst_count_array1[k][burst_count_index1][i] = BURST_COUNT_final
			#if BURST_COUNT_final > mi:
				#mi = BURST_COUNT_final
				#burst_max_array[k][burst_count_index1] = mi
				#print(burst_max_array)

		max_array[k][burst_count_index1] = max(burst_count_array1[k][burst_count_index1])

		if max(burst_count_array1[k][burst_count_index1]) != 0:
			pos[k][burst_count_index1] = np.argmax(burst_count_array1[k][burst_count_index1])

		elif max(burst_count_array1[k][burst_count_index1]) == 0:

			if burst_count_index1 == 1 or burst_count_index1 == 4:
				pos[k][burst_count_index1] = 2

			elif burst_count_index1 == 2 or burst_count_index1 == 5:
				pos[k][burst_count_index1] = 3

		#print(burst_count_array1[k])
		burst_count_index1 += 1
		#print(burst_max_array[0])



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
		burst_count_array2[k][burst_count_index2][i] = BURST_COUNT_final

	
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
	DAT_file_object = open(files[k],'rb')


	Time = DAT_file_object.read(4)
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

	#print(int.from_bytes(time,byteorder='little',signed=True))
	formatted_structure['Time'] = int.from_bytes(Time,byteorder='little',signed=True)
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

	id_array.append(int.from_bytes(resp_id,byteorder='big',signed=True))


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
	if int.from_bytes(resp_id,byteorder='big') != 8:
		#print(files[k],int.from_bytes(resp_id,byteorder='big'))
		k += 1
		continue

	bytes_data = DAT_file_object.read()
	#print(bytes_data)

	
	
	copied_structures = deepcopy(calculation_structures)

	for i in range(2):

		PKG_extract(copied_structures,bytes_data,vpk_index)
		copied_structures = copied_structures[2:]

		#print("Calling index of counts is",burst_count_index1)
		BURST_extract(copied_structures,bytes_data,burst_count_index1)
		copied_structures = copied_structures[48:]

		vpk_index += 1
		burst_count_index1 += 3
	
	
	for i in range(4):

		#print("calling index is",burst_count_index2)
		PKG_extract(copied_structures,bytes_data,vpk_index)
		copied_structures = copied_structures[2:]
	
		BURST_LAST_extract(copied_structures,bytes_data,burst_count_index2)
		copied_structures = copied_structures[3:]

		vpk_index += 1
		burst_count_index2 += 1	
	
	#print("Closing file now")
	DAT_file_object.close()
	final_structure[files[k]] = deepcopy(formatted_structure)
# ##########################################################################################################################

	max2 = burst_count_array2[k].ravel()
	ma = 0
	max_pos = 0
	temp = pos[k].tolist()
	for i in range(len(temp)):
		temp[i] = int(temp[i])

	for i in range(6):
		if burst_count_array1[k][i][temp[i]] > ma:
			max_pos = temp[i]
			ma = burst_count_array1[k][i][temp[i]]

	#print(max_pos)
	for i in range(6,18):
		max_array[k][i] = max2[i-6]

	#print(max_array[52])

	for i in range(6,18):
		if max_array[k][i] != 0:
			pos[k][i] = max_pos
		else:
			if (i-6) % 3 == 1:
				pos[k][i] = pos[k][1]
			else:
				pos[k][i] = pos[k][2]

	k += 1

#print(burst_count_array1[24],burst_count_array2[24])

os.chdir('..')
f_object = open('Timeinfo.txt')
f_data = f_object.read()
formatted_datetime = f_data.split('\n')[2]
final_datetime = formatted_datetime.split('=')[1].strip()
date1 = final_datetime.split()[0]
time1 = final_datetime.split()[1]
timestamp1 = time.mktime(datetime.datetime.strptime(date1,"%Y/%m/%d").timetuple())
timestamp2 = time_to_seconds(time1)
timestamp = (timestamp1 + timestamp2)*1000

#os.chdir('INMS_png')
count = 0
time_points = []
y_points = []
pitch_points = []
t_points = []


for i in files:
	try:
		pitch_points.append(final_structure[i]['pitch'])
		t_points.append(final_structure[i]['Time'])
	except(KeyError):
		continue

#print(len(pitch_points) == len(t_points))

for i in range(len(files)):
	xticks = np.arange(0,100,0.1)
	#print("going at",i)
	
	if id_array[i] != 8:
		#print("not included is",files[i])
		i += 1
		continue
	for j in range(18):
		
		if count >= 30:
			count = 0
			final_timestamp = (timestamp + ((20 * pos[i][j])) + (16*j*20))/1000 + (i*(0.2))	+ 16.2 + (i*16*18*20)/1000
			#print("Got that additonal 16.2 seconds at the file:",files[i],datetime.datetime.fromtimestamp(final_timestamp).strftime('%Y-%m-%d %H:%M:%S.%f'))
		else:
			final_timestamp = (timestamp + ((20 * pos[i][j])) + (16*j*20))/1000 + (i*(0.2)) + (i*16*18*20)/1000
		#print("non additonal is",datetime.datetime.fromtimestamp(final_timestamp).strftime('%Y-%m-%d %H:%M:%S.%f'))
		time_points.append(datetime.datetime.fromtimestamp(final_timestamp).strftime('%Y-%m-%d %H:%M:%S.%f') )
		y_points.append(final_timestamp)
		
	
	count += 1
datetimes = [datetime.datetime.strptime(t, '%Y-%m-%d %H:%M:%S.%f') for t in time_points]
#print(time_points)
x_points = []
for i in y_points:
	x_points.append(i/6000000)

final_max = []
for i in range(len(files)):
	if id_array[i] != 8:
		#print("not included is",files[i])
		i += 1
		continue
	final_max += max_array[i].tolist()
#final_max = list(filter((0.0).__ne__,final_max))

fig = plt.figure()

ax1 = fig.add_subplot(211)
ax1.plot(datetimes,final_max,marker='o')

ax1.grid(True)

ax2 = fig.add_subplot(212)
ax2.plot(t_points,pitch_points)
ax2.grid(True)

mng = plt.get_current_fig_manager()
mng.resize(*mng.window.maxsize())

current_path = os.getcwd()
os.chdir('..')
file_date_time = current_path.split('\\')[-1:][0].split()[1].split('_')[0]
file_date = file_date_time[0:6]
file_time = file_date_time[6:]

saving_day = ''
saving_month = ''
saving_year = ''

if file_date[4] == '0':
	saving_day = str(file_date[5])
else:
	saving_day = str(file_date[4:6])

if file_date[2] == '0':
	saving_month = str(file_date[3])
else:
	saving_month = str(file_date[2:4])

saving_year = '20' + str(file_date[0:2])


saving_format = "{}-{}-{}".format(saving_day,saving_month,saving_year)
plt.savefig(saving_format) 
#plt.show()
