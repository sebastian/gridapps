import serial
try: import simplejson as json
except ImportError: import json
import redis
import time


r = redis.StrictRedis(host='localhost', port=6379, db=0)

freqSet = "frequency:received"

ser = serial.Serial("/dev/tty.usbserial-A8004Iy6", 57600, timeout=2)
ser.close()
ser.open()
ser.flushInput()

while 1:
	rxJson = json.loads(ser.readline())
	if 'type' in rxJson and 'data' in rxJson:
		print "Valid JSON rx'd"
		if rxJson['type'] == 'log':
			print "LOG: " + str(rxJson['data'])
		elif rxJson['type'] == 'report':
			print "REP: " + str(rxJson['data'])
			# rxData = json.loads(rxJson['data'])
			now = int(time.time())
			
			r.zadd(freqSet, now, str(rxJson['data']))
