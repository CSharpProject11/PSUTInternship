import json
from pathlib import Path
path=Path('PSUTInternship/PSUTInternship/Firebase/database.rules.example.json')
x=json.loads(path.read_text(encoding='utf-8-sig')); r=x['rules']
active="auth != null && root.child('users').child(auth.uid).child('isActive').val() === true"
def role(*names): return '('+active+' && ('+' || '.join("root.child('users').child(auth.uid).child('role').val() === '"+n+"'" for n in names)+'))'
a=role('coordinator','admin'); c=role('Company Supervisor','companySupervisor','company'); t=role('student','Student'); s=role('Academic Supervisor','academicSupervisor','academic')
ck="(root.child('users').child(auth.uid).child('companyId').exists() ? root.child('users').child(auth.uid).child('companyId').val() : (root.child('companySupervisors').child(auth.uid).child('companyId').exists() ? root.child('companySupervisors').child(auth.uid).child('companyId').val() : auth.uid))"
def company(p): return '('+p+".child('companyId').val() === "+ck+' || '+p+".child('companySupervisorId').val() === auth.uid)"
def assigned(uid):
 st="root.child('students').child("+uid+")"
 return '('+st+".child('academicSupervisorId').val() === auth.uid || (!"+st+".child('academicSupervisorId').exists() && root.child('studentGroups').child("+st+".child('groupId').val()).child('academicSupervisorId').val() === auth.uid))"
def placement(p): return "root.child('internships').child("+p+".child('internshipId').val())"
def owner(p,students=True):
 pl=placement(p)
 return a+' || ('+c+' && '+company(pl)+') || ('+s+' && '+pl+".child('academicSupervisorId').val() === auth.uid)"+(' || ('+t+' && '+p+".child('studentId').val() === auth.uid)" if students else '')
def collection_read(students=True):
 return a+(' || ('+t+" && query.orderByChild === 'studentId' && query.equalTo === auth.uid)" if students else '')+' || ('+c+" && query.orderByChild === 'internshipId' && "+company("root.child('internships').child(query.equalTo)")+') || ('+s+" && query.orderByChild === 'internshipId' && root.child('internships').child(query.equalTo).child('academicSupervisorId').val() === auth.uid)"
# Use the role-profile company ID consistently, including old records with no users.companyId.
def replace_ck(v):
 old="(root.child('users').child(auth.uid).child('companyId').exists() ? root.child('users').child(auth.uid).child('companyId').val() : auth.uid)"
 if isinstance(v,str): return v.replace(old,ck)
 if isinstance(v,dict): return {k:replace_ck(w) for k,w in v.items()}
 if isinstance(v,list): return [replace_ck(w) for w in v]
 return v
r=replace_ck(r);x['rules']=r
# Profiles can be linked to a placement with an arbitrary record ID.
r['students']['$uid']['.read']=active+' && (auth.uid === $uid || '+a+' || ('+s+' && '+assigned('$uid')+') || ('+c+' && '+company("root.child('internships').child(data.child('internshipId').val())")+'))'
r['students']['$uid']['internshipId']={'.write':t+" && auth.uid === $uid && newData.val() === auth.uid && root.child('internshipConfirmations').child(auth.uid).exists()"}
r['studentGroups']['.indexOn']=['academicSupervisorId']
r['studentGroups']['.read']=a+' || ('+s+" && query.orderByChild === 'academicSupervisorId' && query.equalTo === auth.uid)"
# Root internships are still scoped; no assumption about a placement's key matching its student.
r['internships']['.indexOn']=['studentId','companyId','companySupervisorId','academicSupervisorId']
r['internships']['.read']+=' || ('+c+" && query.orderByChild === 'companySupervisorId' && query.equalTo === auth.uid)"
# Keep empty canonical slots readable for conditional creation.
r['internships']['$uid']['.read']=a+' || ('+c+' && '+company('data')+') || ('+s+" && data.child('academicSupervisorId').val() === auth.uid) || ("+t+" && (data.child('studentId').val() === auth.uid || (!data.exists() && $uid === auth.uid)))"
r['internships']['$uid']['approvedHours']['.write']=c+' && '+company('data.parent()')+" && data.parent().child('status').val() === 'active'"
# Tasks are related through internshipId in the supplied database.
r['tasks']['.indexOn']=['studentId','companyId','academicSupervisorId','internshipId','companySupervisorId']
r['tasks']['.read']=collection_read()+ ' || ('+s+" && query.orderByChild === 'academicSupervisorId' && query.equalTo === auth.uid)"
r['tasks']['$id']['.read']=owner('data')
pl=placement('newData')
r['tasks']['$id']['.write']=a+' || ('+c+' && '+company(pl)+" && "+pl+".child('status').val() === 'active' && newData.child('studentId').val() === "+pl+".child('studentId').val() && (!data.exists() || newData.child('studentId').val() === data.child('studentId').val()) && (!data.exists() || newData.child('internshipId').val() === data.child('internshipId').val()))"
r['tasks']['$id']['.validate']="newData.hasChildren(['studentId','internshipId','title','dueDate','status']) && (!newData.child('maximumScore').exists() || (newData.child('maximumScore').isNumber() && newData.child('maximumScore').val() > 0)) && (!newData.child('score').exists() || (newData.child('score').isNumber() && newData.child('score').val() >= 0 && newData.child('score').val() <= newData.child('maximumScore').val()))"
r['tasks']['$id']['status']['.write']=t+" && data.parent().child('studentId').val() === auth.uid && data.val() !== 'Reviewed' && data.val() !== 'reviewed' && (newData.val() === 'Submitted' || newData.val() === 'Deadline Passed')"
# Submissions use taskId as a relationship, not as the submission's database key.
sub=r['submissions'];sub['.indexOn']=['studentId','taskId','internshipId']
task="root.child('tasks').child(query.equalTo)"; taskpl=placement(task)
sub['.read']=a+' || ('+t+" && query.orderByChild === 'studentId' && query.equalTo === auth.uid) || (query.orderByChild === 'taskId' && (("+t+' && '+task+".child('studentId').val() === auth.uid) || ("+c+' && '+company(taskpl)+') || ('+s+' && '+taskpl+".child('academicSupervisorId').val() === auth.uid)))"
ptask="root.child('tasks').child(data.child('taskId').val())"; ptaskpl=placement(ptask)
sub['$id']['.read']=a+' || ('+t+" && data.child('studentId').val() === auth.uid) || ("+c+' && '+company(ptaskpl)+') || ('+s+' && '+ptaskpl+".child('academicSupervisorId').val() === auth.uid)"
ntask="root.child('tasks').child(newData.child('taskId').val())"; npl=placement(ntask)
sub['$id']['.write']=a+' || ('+c+' && '+company(ptaskpl)+" && newData.child('taskId').val() === data.child('taskId').val() && newData.child('studentId').val() === data.child('studentId').val()) || ("+t+' && '+ntask+".child('studentId').val() === auth.uid && "+ntask+".child('status').val() !== 'Reviewed' && "+ntask+".child('status').val() !== 'reviewed' && "+npl+".child('status').val() === 'active' && newData.child('studentId').val() === auth.uid && newData.child('status').val() === 'Submitted' && (!data.exists() || (newData.child('taskId').val() === data.child('taskId').val() && newData.child('studentId').val() === data.child('studentId').val())) && (!newData.child('feedback').exists() || newData.child('feedback').val() === '') && !newData.child('score').exists())"
# Hours and evaluations are scoped by the placement they belong to.
h=r['trainingHours'];h['.indexOn']=['studentId','internshipId'];h['.read']=collection_read();h['$id']['.read']=owner('data')
pl=placement('newData')
h['$id']['.write']=a+' || ('+t+" && !data.exists() && newData.child('studentId').val() === auth.uid && "+pl+".child('studentId').val() === auth.uid && "+pl+".child('status').val() === 'active' && newData.child('status').val() === 'Pending')"
for f in ['status','reviewedAt','reviewedBy']:
 h['$id'][f]['.write']=c+' && '+company(placement('data.parent()'))+' && '+placement('data.parent()')+".child('status').val() === 'active'"
h['$id']['status']['.validate']="newData.val() === 'Approved' || newData.val() === 'Rejected' || newData.val() === 'Pending' || newData.val() === 'pending'"
h['$id']['reviewedBy']['.validate']="newData.val() === auth.uid"
e=r['evaluations'];e['.indexOn']=['studentId','internshipId','companyId','academicSupervisorId'];e['.read']=collection_read(False)+' || ('+c+" && query.orderByChild === 'companyId' && query.equalTo === "+ck+')'
e['$id']['.read']=owner('data',False)
pl=placement('newData'); common="newData.child('studentId').val() === "+pl+".child('studentId').val() && "+pl+".child('status').val() === 'active' && newData.child('evaluatorId').val() === auth.uid && (!data.exists() || (data.child('status').val() !== 'submitted' && data.child('studentId').val() === newData.child('studentId').val() && data.child('internshipId').val() === newData.child('internshipId').val() && data.child('evaluatorRole').val() === newData.child('evaluatorRole').val()))"
ce="root.child('evaluations').child(newData.child('companyEvaluationId').val())"
e['$id']['.write']=a+' || ('+common+' && (('+c+' && '+company(pl)+" && newData.child('evaluatorRole').val() === 'companySupervisor') || ("+s+' && '+pl+".child('academicSupervisorId').val() === auth.uid && newData.child('evaluatorRole').val() === 'academicSupervisor' && "+ce+".child('status').val() === 'submitted' && "+ce+".child('evaluatorRole').val() === 'companySupervisor' && "+ce+".child('internshipId').val() === newData.child('internshipId').val())))"
# Completion reports can already exist as pending records with arbitrary keys.
co=r['completionReports'];co['.indexOn']=['studentId','internshipId'];co['.read']=collection_read()
co['$uid']['.read']=owner('data')+' || ('+t+' && !data.exists() && $uid === auth.uid)'
co['$uid']['.write']=a+" && data.child('approvedByCoordinator').val() !== true && data.child('status').val() !== 'approved'"
co['$uid']['.validate']="newData.child('approvedByCoordinator').val() === true && newData.child('studentId').val() === "+placement('newData')+".child('studentId').val()"
# Feedback and optional reports also follow internship relationships.
for n in ['taskFeedback','reports']:
 if n not in r: continue
 r[n]['.indexOn']=list(set(r[n].get('.indexOn',[])+['studentId','internshipId']))
 r[n]['.read']=collection_read()
 key=next(k for k in r[n] if k.startswith('$'))
 r[n][key]['.read']=owner('data')
# Existing openings use text statuses and may not yet have a seat count.
r['opportunities']['$id']['.validate']="newData.hasChildren(['title','companyId','status','deadline']) && (newData.child('status').isBoolean() || newData.child('status').val() === 'active' || newData.child('status').val() === 'open' || newData.child('status').val() === 'closed' || newData.child('status').val() === 'inactive') && (!newData.child('availableSeats').exists() || (newData.child('availableSeats').isNumber() && newData.child('availableSeats').val() >= 0))"
op="root.child('opportunities').child(newData.child('opportunityId').val())"
app=r['applications']; app['.read']+=' || ('+s+" && query.orderByChild === 'studentId' && "+assigned('query.equalTo')+')'
app['$id']['.validate']="newData.hasChildren(['studentId','opportunityId','companyId','status']) && (newData.child('status').val() !== 'Rejected' || newData.child('rejectionReason').val().length > 0)"
app['$id']['.write']=a+' || ('+t+" && !data.exists() && newData.child('studentId').val() === auth.uid && newData.child('status').val() === 'Pending' && !newData.child('studentResponse').exists() && newData.child('isOfferConfirmed').val() !== true && !root.child('internshipConfirmations').child(auth.uid).exists() && ("+op+".child('status').val() === true || "+op+".child('status').val() === 'active' || "+op+".child('status').val() === 'open') && newData.child('companyId').val() === "+op+".child('companyId').val())"
for f in ['status','rejectionReason']:
 app['$id'][f]['.write']=c+' && data.parent().child(\'companyId\').val() === '+ck+" && (data.parent().child('status').val() === 'Pending' || data.parent().child('status').val() === 'pending')"
app['$id']['isOfferConfirmed']=app['$id']['studentConfirmed'].copy()
path.write_text(json.dumps(x,indent=2)+'\n',encoding='utf-8')
