// Local policy checks, not a replacement for the official Firebase Emulator Suite.
import fs from 'node:fs';
import assert from 'node:assert/strict';
const rules=JSON.parse(fs.readFileSync(new URL('../PSUTInternship/PSUTInternship/Firebase/database.rules.example.json',import.meta.url),'utf8')).rules;
const data={users:{student:{role:'student',isActive:true},company:{role:'Company Supervisor',isActive:true,companyId:'company'},otherCompany:{role:'Company Supervisor',isActive:true},academic:{role:'Academic Supervisor',isActive:true},admin:{role:'coordinator',isActive:true}},students:{student:{academicSupervisorId:'academic',companyId:'company',internshipId:'student',requiredHours:8}},opportunities:{opening:{companyId:'company',status:true}},tasks:{task:{studentId:'student',internshipId:'student',companyId:'company',academicSupervisorId:'academic',status:'Assigned',title:'Task',dueDate:'2026-11-01',maximumScore:20}},applications:{offer:{studentId:'student',opportunityId:'opening',companyId:'company',academicSupervisorId:'academic',status:'Approved',details:{}}},internships:{student:{studentId:'student',companyId:'company',academicSupervisorId:'academic',status:'active',approvedHours:0}},evaluations:{company_student:{studentId:'student',internshipId:'student',companyId:'company',academicSupervisorId:'academic',status:'submitted'}},trainingHours:{hours:{studentId:'student',internshipId:'student',companyId:'company',academicSupervisorId:'academic',hours:8,status:'Pending',description:'Training'}}};
class Snapshot{
 constructor(root,path=[]){this.root=root;this.path=path;}
 val(){let node=this.root;for(const key of this.path)node=node?.[key];return node??null;}
 child(path){return new Snapshot(this.root,[...this.path,...String(path).split('/')]);}
 parent(){return new Snapshot(this.root,this.path.slice(0,-1));}
 exists(){return this.val()!==null;}
 hasChildren(keys){return keys.every(key=>this.child(key).exists());}
 isString(){return typeof this.val()==='string';}
 isNumber(){return typeof this.val()==='number';}
 isBoolean(){return typeof this.val()==='boolean';}
}
let count=0;
function check(expression,path,uid,newRoot,query,vars){
 if(typeof expression==='boolean')return expression;
 if(expression===undefined)return false;
 const names=['auth','root','data','newData','query','now',...Object.keys(vars)];
 const values=[uid?{uid}:null,new Snapshot(data),new Snapshot(data,path),new Snapshot(newRoot,path),query,Date.now(),...Object.values(vars)];
 return Function(...names,'return ('+expression+');')(...values)===true;
}
function nodes(path){let node=rules;let vars={};const out=[{node,path:[],vars:{}}];for(let i=0;i<path.length;i++){const key=path[i];let match=Object.hasOwn(node,key)?key:Object.keys(node).find(k=>k.startsWith('$'));if(!match)break;if(match.startsWith('$'))vars={...vars,[match]:key};node=node[match];out.push({node,path:path.slice(0,i+1),vars});}return out;}
function allowed(mode,path,uid,{value,query={}}={}){
 path=path.split('/').filter(Boolean);let newRoot=structuredClone(data);
 if(mode==='write'){let node=newRoot;for(const key of path.slice(0,-1))node=node[key]??={};node[path.at(-1)]=value;}
 const ancestors=nodes(path);let grant=false;
 for(const entry of ancestors)if(check(entry.node['.'+mode],entry.path,uid,newRoot,query,entry.vars)){grant=true;break;}
 if(!grant||mode==='read')return grant;
 for(const entry of ancestors)if(entry.node['.validate']!==undefined&&!check(entry.node['.validate'],entry.path,uid,newRoot,query,entry.vars))return false;
 // Validate existing descendants too, including the public projection's unknown-field rule.
 function validate(nodeRule,at,vars){if(!new Snapshot(newRoot,at).exists())return true;if(nodeRule['.validate']!==undefined&&!check(nodeRule['.validate'],at,uid,newRoot,query,vars))return false;const value=new Snapshot(newRoot,at).val();if(value&&typeof value==='object')for(const key of Object.keys(value)){const match=Object.hasOwn(nodeRule,key)?key:Object.keys(nodeRule).find(k=>k.startsWith('$'));if(match&&!validate(nodeRule[match],[...at,key],match.startsWith('$')?{...vars,[match]:key}:vars))return false;}return true;}
 const leaf=ancestors.at(-1);return validate(leaf.node,leaf.path,leaf.vars);
}
function expect(actual,expected,label){assert.equal(actual,expected,label);count++;console.log('PASS '+label);}
const simplifiedApplication={studentId:'student',opportunityId:'opening',companyId:'company',status:'Pending',isOfferConfirmed:false,details:{studentName:'Student',studentEmail:'student@example.com'}};
expect(allowed('write','applications/student_opening','student',{value:simplifiedApplication}),true,'students can create applications without organization or training details');
expect(allowed('write','applications/offer','student',{value:simplifiedApplication}),false,'create-only application rules prevent overwriting an existing review');
expect(allowed('read','opportunities',null),true,'anonymous visitors can browse opportunity records');
expect(allowed('write','opportunities/opening',null,{value:{title:'Unauthorized',companyId:'company',status:true,deadline:'2026-12-01'}}),false,'anonymous visitors cannot edit opportunities');
expect(allowed('read','users',null),false,'anonymous visitors cannot read profiles');
expect(allowed('read','tasks','student'),false,'unfiltered student task reads are denied');
expect(allowed('read','tasks','student',{query:{orderByChild:'studentId',equalTo:'student'}}),true,'students can query their own tasks');
expect(allowed('read','tasks','student',{query:{orderByChild:'studentId',equalTo:'someoneElse'}}),false,'students cannot query another student');
expect(allowed('read','tasks/task','student'),true,'the assigned student can read a task');
expect(allowed('read','tasks/task','otherCompany'),false,'another company cannot read the task');
expect(allowed('read','tasks','academic',{query:{orderByChild:'academicSupervisorId',equalTo:'academic'}}),true,'academic task queries require the assigned supervisor');
expect(allowed('read','evaluations/company_student','student'),false,'students cannot read confidential final evaluations');
expect(allowed('read','evaluations','company',{query:{orderByChild:'companyId',equalTo:'company'}}),true,'companies can query evaluations in their scope');
expect(allowed('read','tasks','admin'),true,'the coordinator can monitor all tasks');
expect(allowed('read','internships/student','student'),true,'students can read their placement');
expect(allowed('read','internships/missingStudent','academic'),false,'academic access does not extend to arbitrary placements');
expect(allowed('read','completionReports/student','student'),true,'a missing completion report is an empty state');
expect(allowed('write','users/student/role','student',{value:'coordinator'}),false,'students cannot elevate their own role');
expect(allowed('write','users/student/mustChangePassword','student',{value:false}),true,'a user can complete the required password change');
expect(allowed('write','students/student/phone','student',{value:'0790000000'}),true,'students can edit permitted profile information');
expect(allowed('write','students/student/requiredHours','student',{value:0}),false,'students cannot lower their required hours');
expect(allowed('write','tasks/task/score','student',{value:20}),false,'students cannot assign their own grades');
expect(allowed('write','tasks/task/status','student',{value:'Submitted'}),true,'students can mark their submission state');
expect(allowed('write','tasks/task/status','student',{value:'Reviewed'}),false,'students cannot mark work reviewed');
expect(allowed('write','trainingHours/new','student',{value:{studentId:'student',internshipId:'student',companyId:'company',academicSupervisorId:'academic',hours:8,description:'Training',status:'Approved'}}),false,'students cannot approve their own hours');
expect(allowed('write','trainingHours/new','student',{value:{studentId:'student',internshipId:'student',companyId:'company',academicSupervisorId:'academic',hours:8,description:'Training',status:'Pending'}}),true,'students can submit hours for approval');
expect(allowed('write','trainingHours/hours/status','company',{value:'Approved'}),true,'the placement company can approve hours');
expect(allowed('write','trainingHours/hours/status','otherCompany',{value:'Approved'}),false,'another company cannot approve hours');
expect(allowed('write','internshipConfirmations/student','student',{value:{applicationId:'offer',confirmedAt:'2026-10-22'}}),true,'students can confirm their own approved offer');
data.internshipConfirmations={student:{applicationId:'offer',confirmedAt:'2026-10-22'}};
expect(allowed('write','internshipConfirmations/student','student',{value:{applicationId:'offer',confirmedAt:'2026-10-23'}}),false,'the database confirmation lock cannot be overwritten');
expect(allowed('write','completionReports/student','company',{value:{approvedByCoordinator:true,studentId:'student',internshipId:'student'}}),false,'company supervisors cannot issue completion reports');
expect(allowed('write','completionReports/student','admin',{value:{approvedByCoordinator:true,studentId:'student',internshipId:'student'}}),true,'only the coordinator can issue the final report');
expect(allowed('write','publicOpportunities/opening','company',{value:{title:'Opening',companyName:'Company',status:true,description:'Private description'}}),false,'private descriptions cannot be placed in public previews');

for (const name of ['fullName','email','studentNumber','university','college','major']) expect(allowed('write','students/student/'+name,'student',{value:'tampered'}),false,'student profile protects '+name);
expect(allowed('write','students/student/gpa','student',{value:3.7}),true,'students can update a valid GPA');
expect(allowed('write','students/student/gpa','student',{value:5}),false,'profile rules reject GPA beyond 4');
expect(allowed('write','students/student/completedCreditHours','student',{value:1.5}),false,'credit hours must be whole numbers');
// Existing legacy evaluations remain supported; the percentage schema enforces a hard total cap.
const pct={studentId:'student',internshipId:'student',companyId:'company',academicSupervisorId:'academic',evaluatorId:'company',evaluatorRole:'companySupervisor',status:'draft',overallScore:100,totalMaximum:100,totalPercentage:100};
expect(allowed('write','evaluations/new_percentage','admin',{value:pct}),true,'a 100 percent evaluation is accepted');
expect(allowed('write','evaluations/new_percentage','admin',{value:{...pct,totalPercentage:100.01,overallScore:100.01}}),false,'percentage totals over 100 are rejected by database validation');
expect(allowed('write','evaluations/new_percentage','admin',{value:{...pct,totalPercentage:80,overallScore:90}}),false,'percentage totals cannot disagree with the saved result');
expect(allowed('write','evaluations/new_percentage','admin',{value:{...pct,percentage:101}}),false,'academic percentage cannot exceed 100');

const solution={taskId:'task',studentId:'student',internshipId:'student',status:'Submitted',feedback:'',answer:'Solution'};
data.tasks.task.dueAt=Date.now()-1000;
expect(allowed('write','submissions/new_work','student',{value:solution}),false,'expired task deadlines prevent direct student submissions');
expect(allowed('write','tasks/task/status','student',{value:'Submitted'}),false,'expired tasks cannot be marked submitted directly');
data.tasks.task.dueAt=Date.now()+60000;
expect(allowed('write','submissions/new_work','student',{value:solution}),true,'an active task accepts work before its deadline');
data.tasks.task.active=false;
expect(allowed('write','submissions/new_work','student',{value:solution}),false,'archived tasks reject direct student submissions');
delete data.tasks.task.active;delete data.tasks.task.dueAt;
data.tasks.task.status='Complete';
expect(allowed('write','submissions/new_work','student',{value:solution}),false,'legacy Complete status blocks direct resubmission');
expect(allowed('write','tasks/task/status','student',{value:'Submitted'}),false,'legacy Complete status cannot be undone by a student');
data.tasks.task.status='Assigned';

// Match the actual collection names and foreign keys from the supplied export.
for (const key of Object.keys(data)) delete data[key];
Object.assign(data, JSON.parse(fs.readFileSync(new URL('./fixtures/database-shape.json',import.meta.url),'utf8')));
data.users={student1:{role:'student',isActive:true},superC1:{role:'Company Supervisor',isActive:true,companyId:'company1'},superA1:{role:'Academic Supervisor',isActive:true},foreign:{role:'Company Supervisor',isActive:true,companyId:'foreign-company'},admin:{role:'coordinator',isActive:true}};
expect(allowed('read','tasks','superC1',{query:{orderByChild:'internshipId',equalTo:'internship1'}}),true,'legacy company tasks are readable through their internship');
expect(allowed('read','tasks','foreign',{query:{orderByChild:'internshipId',equalTo:'internship1'}}),false,'a foreign company cannot query another internship');
expect(allowed('read','tasks/task1','superC1'),true,'a legacy task needs no duplicated companyId to enforce ownership');
expect(allowed('read','submissions','superC1',{query:{orderByChild:'taskId',equalTo:'task1'}}),true,'companies query submission1 by taskId');
expect(allowed('read','submissions','superA1',{query:{orderByChild:'taskId',equalTo:'task1'}}),true,'academic supervisors can follow the task to its submission');
expect(allowed('read','submissions','foreign',{query:{orderByChild:'taskId',equalTo:'task1'}}),false,'task relationships cannot expose foreign submissions');
expect(allowed('read','submissions/submission1','student1'),true,'students can read their existing arbitrarily keyed submission');
expect(allowed('read','trainingHours','superC1',{query:{orderByChild:'internshipId',equalTo:'internship1'}}),true,'legacy hour logs are scoped by internshipId');
expect(allowed('write','trainingHours/hour1/status','superC1',{value:'Approved'}),true,'companies can approve legacy hour entries without companyId');
expect(allowed('write','trainingHours/hour1/hours','superC1',{value:24}),false,'companies cannot rewrite the quantity of submitted hours');
expect(allowed('write','trainingHours/hour1/status','foreign',{value:'Approved'}),false,'other companies cannot approve legacy hour entries');
expect(allowed('write','applications/app1/status','superC1',{value:'Approved'}),true,'lowercase pending applications can be approved');
expect(allowed('write','tasks/task1/maximumScore','superC1',{value:10}),true,'a company can configure a missing maximum score for its legacy task');
expect(allowed('write','tasks/task1/maximumScore','foreign',{value:10}),false,'a company cannot configure another company task');
expect(allowed('read','evaluations/evaluation1','superA1'),true,'the assigned academic supervisor can read the existing company draft');
expect(allowed('read','evaluations/evaluation1','student1'),false,'existing final evaluations remain confidential');
expect(allowed('read','completionReports','student1',{query:{orderByChild:'internshipId',equalTo:'internship1'}}),true,'students can locate a report using their actual internship key');
expect(allowed('read','completionReports','foreign',{query:{orderByChild:'internshipId',equalTo:'internship1'}}),false,'foreign companies cannot query a completion report');
expect(allowed('write','completionReports/report1','admin',{value:{studentId:'student1',internshipId:'internship1',approvedByCoordinator:true,status:'approved'}}),true,'the coordinator can approve an existing pending report');
expect(allowed('write','submissions/submission1','student1',{value:{studentId:'student1',taskId:'task1',status:'Submitted',answer:'Updated work',feedback:'',fileUrl:'https://example.test/work.pdf'}}),true,'resubmission may retain an arbitrary existing submission key');
expect(allowed('write','submissions/submission1','student1',{value:{studentId:'student1',taskId:'unknown-task',status:'Submitted',answer:'Updated work'}}),false,'resubmission cannot change to an unrelated task');
expect(allowed('read','students/student1','superA1'),true,'studentGroups can supply a missing explicit academic assignment');
data.students.student1.internshipId='internship1';
expect(allowed('read','students/student1','superC1'),true,'reverse placement links authorize individual trainee profiles');
expect(allowed('read','students/student1','foreign'),false,'reverse placement links do not expose profiles to other companies');

console.log(count+' local rule assertions passed. Verify deployment with the Firebase Emulator Suite before production use.');

data.students.student1.academicSupervisorId="superA1";
data.meetings={invite:{studentId:'student1',supervisorId:'superA1',status:'Pending',roomName:'UIMS-test-room'}};
const accepted={...data.meetings.invite,status:'Accepted',respondedAt:'2026-10-23T12:00:00Z'};
expect(allowed('read','meetings/invite','student1'),true,'assigned student can read a meeting before accepting');
expect(allowed('write','meetings/invite','student1',{value:accepted}),true,'student can accept their pending invitation');
expect(allowed('write','meetings/invite','superC1',{value:accepted}),false,'company cannot accept a student invitation');
expect(allowed('write','meetings/invite',null,{value:accepted}),false,'anonymous users cannot accept invitations');
expect(allowed('write','meetings/invite','student1',{value:{...accepted,studentId:'another'}}),false,'students cannot transfer invitation ownership');
data.meetings.invite.status='Accepted';
expect(allowed('write','meetings/invite','student1',{value:accepted}),false,'database blocks a duplicate acceptance write');
expect(allowed('write','meetings/invite','superA1',{value:{...accepted,status:'Cancelled'}}),true,'assigned supervisor can cancel an accepted invitation');
console.log(count+' local rule assertions passed, including meeting acceptance.');
