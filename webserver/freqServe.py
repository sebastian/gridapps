import web
import json


urls = (
  '/', 'indexRequest',
  '/json', 'jsonRequest',
  '/setfreq', 'setjson'
)

freq = 50;

class indexRequest:
  def GET(self):
    return 'Welcome to freqServe!'


class jsonRequest:
  def GET(self):
    out = {'freq':freq}
    if freq >= 50:
      out['instruction'] = 'yes'
    else:
      out['instruction'] = 'no'
      
    web.header('Content-Type', 'application/json')
    return json.dumps(out)
    
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
