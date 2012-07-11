import web
import json
import ssl
import socket
import struct
import binascii


certfile = 'ChrisElsmore.pem'
apns_address = ('gateway.sandbox.push.apple.com', 2195)


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
    #try:
      token = web.input().token
      #data = web.data() # you can get data use this method
      #print token
      #print token['token']
      payload = json.dumps("{\"aps\": {\"alert\" : \"Hello notification world!!\"}}")
      s = socket.socket()
      sock = ssl.wrap_socket(s, ssl_version=ssl.PROTOCOL_SSLv3, certfile=certfile)
      sock.connect(apns_address)
      
      fmt = "!cH32sH{0:d}s".format(len(payload))
      cmd = '\x00'
      msg = struct.pack(fmt, cmd, len(token), token, len(payload), payload)
      sock.write(msg)
      sock.close()
      return 'ok'
    #except Error(e):
    #  print e

if __name__ == '__main__':
  app = web.application(urls, globals())
  app.run()
