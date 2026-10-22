import {execFileSync} from 'node:child_process';
import {mkdirSync,writeFileSync} from 'node:fs';
const prefix='PSUTInternship/PSUTInternship/';
const read=p=>execFileSync('git',['show','HEAD:'+prefix+p],{encoding:'utf8'});
let master=read('Public.Master'),page=read('Default.aspx'),dialogs=read('Shared/Dialogs.ascx');
page=page.replace(/<%@[^%]*%>/g,'').replace(/<\/?asp:Content\b[^>]*>/g,'');
const html=master.replace(/<%@[^%]*%>/g,'').replace(/<asp:ContentPlaceHolder[^>]*\/>/,page).replace(/<psut:Dialogs[^>]*\/>/,dialogs.replace(/<%@[^%]*%>/g,'')).replace(/<%=\s*ResolveUrl\("~\/([^"\n]*)"\)\s*%>/g,'../../'+prefix+'$1').replace(/ runat="server"/g,'');
mkdirSync('.taste-skill/before',{recursive:true});writeFileSync('.taste-skill/before/index.html',html);
console.log('Recorded committed homepage baseline without changing the working project.');
