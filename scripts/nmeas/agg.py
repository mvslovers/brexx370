import re,sys,json,statistics as st
def load(tag):
    txt=''
    for k in 'isvl':
        try: txt+=open(f'spool-{tag}-{k}.txt',errors='replace').read()+'\n'
        except: pass
    steps={}
    for m in re.finditer(r'IEF374I STEP /(\S+)\s*/ STOP\s+\S+ CPU\s+(\d+)MIN (\S+)SEC SRB\s+(\d+)MIN (\S+)SEC VIRT\s+(\d+)K',txt):
        steps[m[1]]=dict(cpu=int(m[2])*60+float(m[3]),virt=int(m[6]))
    res={}
    for blk in re.split(r'(?=NMCFG )',txt)[1:]:
        m=re.match(r'NMCFG kind=(\S+) n=(\d+) np=(-?\d+)',blk)
        key=(m[1],int(m[2]),int(m[3]))
        d={'bk':[]}
        for l in blk.split('\n'):
            r=re.match(r'NMRES (\S+) kind=\S+ n=\d+ rc=(\d+) calls=(\d+) tot16=(\d+) wall16=(\d+) max16=(\d+) last16=(\d+) nb=(\d+)',l)
            if r and r[1] not in d: d[r[1]]=dict(rc=int(r[2]),calls=int(r[3]),tot=int(r[4]),wall=int(r[5]),mx=int(r[6]),last=int(r[7]),nb=int(r[8]))
            b=re.match(r'NMBKT PASS1 (\d+) (\d+)',l)
            if b: d['bk'].append(int(b[2]))
            bb=re.match(r'NMBUILD .* seconds=(\S+)',l)
            if bb: d['build']=float(bb[1])
        res[key]=d
    return steps,res
tags=sys.argv[1:]
data={t:load(t) for t in tags}
out={}
for t,(steps,res) in data.items():
    for (k,n,np),d in res.items():
        if np!=3: continue
        o=out.setdefault((k,n),dict(calls=None,pass_ms=[],percall=[],med=[],first=[],last=[],base=[],mx=[],virt={},cpu={}))
        o['calls']=d['PASS2']['calls']; assert all(d[p]['rc']==0 for p in ('BASE','PASS1','PASS2','PASS3')),(t,k,n)
        for p in ('PASS1','PASS2','PASS3'):
            o['pass_ms'].append(d[p]['tot']/16/1000); o['percall'].append(d[p]['tot']/16/d[p]['calls'])
            o['mx'].append(d[p]['mx']/16)
        bk=d['bk'][:-1] if len(d['bk'])>2 else d['bk']
        o['med'].append(st.median(bk)/1600)
        th=max(1,len(bk)//3); o['first'].append(st.median(bk[:th])/1600); o['last'].append(st.median(bk[-th:])/1600)
        o['base'].append(d['BASE']['tot']/16/d['BASE']['calls'])
    for s,v in steps.items():
        m=re.match(r'([TCBO])([ISLV])?(\d+)([IS])?$',s)
        if not m: continue
        if m[1]=='O': k=m[4]; n=int(m[3]); pre='O'
        else: k=m[2]; n=int(m[3]); pre=m[1]
        out.setdefault((k,n),dict(calls=None,pass_ms=[],percall=[],med=[],first=[],last=[],base=[],mx=[],virt={},cpu={}))
        out[(k,n)]['virt'].setdefault(pre,[]).append(v['virt'])
for key in sorted(out,key=lambda x:(x[0],x[1])):
    o=out[key]
    if not o['pass_ms']: continue
    f=lambda xs:'%.1f'%st.median(xs)
    vv=o['virt']; vs=lambda p: '/'.join(map(str,vv.get(p,[]))) 
    print(key,'calls',o['calls'],'pass_ms',f(o['pass_ms']),'us/call mean',f(o['percall']),'median-bucket',f(o['med']),'first3rd',f(o['first']),'last3rd',f(o['last']),'BASE us',f(o['base']),'max call',f(o['mx']),'VIRT B',vs('B'),'C',vs('C'),'T',vs('T'),'O',vs('O'))

def md(tagset,title):
    print('\n###',title)
    print('| Art | Einträge | N-Aufrufe | Durchlauf ms | µs/Aufruf (Mittel) | µs/Aufruf Median 100er-Block, erstes/letztes Drittel | VIRT Basis → mit N (KB) | langsamster Aufruf µs |')
    print('|---|---|---|---|---|---|---|---|')
    # recompute for tagset
    o2={}
    for t in tagset:
        steps,res=data[t]
        for (k,n,np),d in res.items():
            if np!=3: continue
            o=o2.setdefault((k,n),dict(pm=[],pc=[],f=[],l=[],mx=[],virt={},calls=d['PASS2']['calls']))
            for p in ('PASS1','PASS2','PASS3'):
                o['pm'].append(d[p]['tot']/16000); o['pc'].append(d[p]['tot']/16/d[p]['calls']); o['mx'].append(d[p]['mx']/16)
            bk=d['bk'][:-1] if len(d['bk'])>2 else d['bk']
            th=max(1,len(bk)//3); o['f'].append(st.median(bk[:th])/1600); o['l'].append(st.median(bk[-th:])/1600)
        for s,v in steps.items():
            m=re.match(r'([TB])([ISLV])(\d+)$',s)
            if m: o2.setdefault((m[2],int(m[3])),dict(pm=[],pc=[],f=[],l=[],mx=[],virt={},calls=0))['virt'].setdefault(m[1],set()).add(v['virt'])
    names={'I':'Ganzzahl','S':'Zeichenkette','L':'200 Byte','V':'einfache Var.'}
    for key in sorted(o2,key=lambda x:('ISLV'.index(x[0]),x[1])):
        o=o2[key]
        if not o['pm']: continue
        vb=sorted(o['virt'].get('B',[])); vt=sorted(o['virt'].get('T',[]))
        fl='%.0f / %.0f'%(st.median(o['f']),st.median(o['l'])) if key[1]>=1000 else 'n. a. (unter 1 Block)'
        print('| %s | %d | %d | %.1f | %.1f | %s | %s → %s | %.0f |'%(names[key[0]],key[1],o['calls'],st.median(o['pm']),st.mean(o['pc']),fl,'/'.join(map(str,vb)),'/'.join(map(str,vt)),max(o['mx'])))
if True:
    md(['ce1','ce2'],'MVS/CE')
    md(['tk51','tk52'],'TK5')
