import {createServer} from 'node:http';
import {readFileSync, statSync, createReadStream} from 'node:fs';
import {resolve, extname, join} from 'node:path';
const root=resolve('PSUTInternship/PSUTInternship');
export function renderHome(){
 let master=readFileSync(join(root,'Public.Master'),'utf8');
 let page=readFileSync(join(root,'Default.aspx'),'utf8').replace(/<%@[^%]*%>/g,'').replace(/<\/?asp:Content\b[^>]*>/g,'');
 let dialogs=readFileSync(join(root,'Shared/Dialogs.ascx'),'utf8').replace(/<%@[^%]*%>/g,'');
 return master.replace(/<%@[^%]*%>/g,'').replace(/<asp:ContentPlaceHolder[^>]*\/>/,page).replace(/<psut:Dialogs[^>]*\/>/,dialogs).replace(/<%=\s*ResolveUrl\("~\/([^"\n]*)"\)\s*%>/g,'/$1').replace(/ runat="server"/g,'');
}
if(process.argv.includes('--export')){
 const {writeFileSync}=await import('node:fs');
 writeFileSync(join(root,'index.html'),renderHome().replaceAll('href="/','href="').replaceAll('src="/','src="').replace("root:'/'","root:'./'"));
 console.log('Exported index.html from the Web Forms homepage.');
}else{
 const types={'.css':'text/css','.js':'text/javascript','.jpg':'image/jpeg','.jpeg':'image/jpeg','.gif':'image/gif','.woff2':'font/woff2','.ttf':'font/ttf','.mp4':'video/mp4','.svg':'image/svg+xml'};
 createServer((req,res)=>{
  const url=new URL(req.url,'http://localhost');
  if(url.pathname==='/'||url.pathname==='/Default.aspx'||url.pathname==='/index.html'){res.writeHead(200,{'Content-Type':'text/html; charset=utf-8','Cache-Control':'no-store'});res.end(renderHome());return;}
  if(!/^\/(Assets|Content|Scripts)\//.test(url.pathname)){res.writeHead(404,{'Content-Type':'text/plain'});res.end('This preview serves the homepage only. Run the ASP.NET project in Visual Studio / IIS Express for sign-in and authenticated pages.');return;}
  const file=resolve(root,'.'+decodeURIComponent(url.pathname));
  if(!file.startsWith(root+'\\')&&!file.startsWith(root+'/')){res.writeHead(403);res.end();return;}
  try{const size=statSync(file).size;const headers={'Content-Type':types[extname(file)]||'application/octet-stream','Accept-Ranges':'bytes'};const range=req.headers.range?.match(/bytes=(\d+)-(\d*)/);if(range){let start=+range[1],end=Math.min(range[2]?+range[2]:size-1,size-1);res.writeHead(206,{...headers,'Content-Range':`bytes ${start}-${end}/${size}`,'Content-Length':end-start+1});createReadStream(file,{start,end}).pipe(res);}else{res.writeHead(200,{...headers,'Content-Length':size});createReadStream(file).pipe(res);}}catch{res.writeHead(404);res.end();}
 }).listen(4173,'127.0.0.1',()=>console.log('PSUT homepage preview: http://127.0.0.1:4173/'));
}
