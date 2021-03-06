import web
import json
import redis


r = redis.StrictRedis(host='localhost', port=6379, db=0)

freqSet = "frequency:received"

urls = (
  '/', 'indexRequest',
  '/json', 'jsonRequest'
  #'/setfreq', 'setjson'
)

freq = 50;

class indexRequest:
  def GET(self):
    return 'Welcome to freqServe!'


class jsonRequest:
  def GET(self):
    out = r.zrevrange(freqSet, 0, 0)[0].replace("\'", "\"")
    #out.replace("\'", "\"")
    outJson = json.loads(out)
    if outJson['freq'] < 50:
      outJson['instruction'] = 'no'
    else:
      outJson['instruction'] = 'yes'
    
    #print out
    #print str(out) 
    web.header('Content-Type', 'application/json')
    return json.dumps(outJson)
    
class setjson:
  def GET(self):
    global freq
    freq = float(web.input(freq=50).freq)
    out = {'freq':freq}
    if freq >= 50:
      out['instruction'] = 'yes'
    else:
      out['instruction'] = 'no'
      
    web.header('Content-Type', 'application/json')
    return json.dumps(out)

if __name__ == '__main__':
  app = web.application(urls, globals())
  app.run()
