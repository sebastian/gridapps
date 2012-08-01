import web
import json
import ssl
import socket
import struct
import time
import binascii
from apns import APNs, PayloadAlert, Payload
from time import gmtime, strftime
from pymongo import Connection
#import redis


#r = redis.StrictRedis(host='localhost', port=6379, db=0)

#freqSet = "frequency:received"

#certfile = 'ChrisElsmore.pem'

connection = Connection('localhost', 27017)
db = connection["freqAppDB"]
tokenColl = db["deviceTokens:received"]

urls = (
  '/', 'indexRequest',
  '/requestnotify', 'notifyRequest'
  #'/setfreq', 'setjson'
)


class indexRequest:
  def GET(self):
    #print web.input(None)
    return 'Welcome to freqNotify!'


class notifyRequest:
  def POST(self):
    #time.sleep(3)
    rxToken = {'token':web.input().token, 'ts':int(time.time())}
    #tokenColl.insert(rxToken)
    print json.dumps(rxToken)
    #try:
    #   apns = APNs(use_sandbox=True, cert_file='ChrisElsmoreCert.pem', key_file='ChrisElsmoreKeyUn.pem')
#       token = web.input().token
#       print token
#       #payload = json.dumps("{\"aps\": {\"alert\" : \"Hello notification world!!\"}}")
#       payload = Payload(alert="Pop the kettle on, the grid is producing excess power!", sound="shortKettle.caf", badge=-1)    
#       #alert = PayloadAlert("Put the kettle on!", action_loc_key="Party!")
#       #payload = Payload(alert=alert, sound="default", badge=-1)
#       apns.gateway_server.send_notification(token, payload)
# 
#       for (token_hex, fail_time) in apns.feedback_server.items():
#         print token_hex+" : "+fail_time
#       apns = None
#       return 'ok'
#     except Error(e):
#       print e

if __name__ == '__main__':
  app = web.application(urls, globals())
  app.run()
  
  

