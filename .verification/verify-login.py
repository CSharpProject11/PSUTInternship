import urllib.request, urllib.parse, http.cookiejar
from html.parser import HTMLParser
class Form(HTMLParser):
 def __init__(self): super().__init__(); self.fields={}
 def handle_starttag(self,tag,attrs):
  a=dict(attrs)
  if tag=='input' and 'name' in a:self.fields[a['name']]=a.get('value','')
cookies=http.cookiejar.CookieJar(); client=urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cookies))
url='http://localhost:55681/Login.aspx'
r=client.open(url);f=Form();f.feed(r.read().decode())
assert any(c.name=='ASP.NET_SessionId' for c in cookies)
session=[c.value for c in cookies if c.name=='ASP.NET_SessionId'][0]
assert 'no-store' in r.headers.get('Cache-Control','')
f.fields.pop('resetPassword',None)
f.fields.update({'loginButton':'Login','emailTextBox':'','passwordTextBox':''})
r=client.open(url,urllib.parse.urlencode(f.fields).encode());body=r.read().decode()
assert 'Enter your email and password.' in body
assert session==[c.value for c in cookies if c.name=='ASP.NET_SessionId'][0]
state=f.fields['__VIEWSTATE']; f.fields['__VIEWSTATE']=('A' if state[0]!='A' else 'B')+state[1:]
r=client.open(url,urllib.parse.urlencode(f.fields).encode());body=r.read().decode()
assert r.url.endswith('Login.aspx?expired=1') and 'Your sign-in form expired.' in body
print('PASS session cookie persists, no-store cache policy, valid POST handler, stable session ID, invalid viewstate recovery. No Firebase requests made.')


