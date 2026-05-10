'use strict';
// ─── Overlays: Filters, Create Itinéraire, Session Summary, Celebration ────────

// ═══════ FILTERS SCREEN ═════════════════════════════════════════════════════
const FILTER_CATS = [
  {name:'Culture',items:['🏛️ Monuments','🎨 Musées','🎭 Théâtres','📚 Librairies','🎬 Cinémas']},
  {name:'Nature',items:['🌿 Parcs','🌳 Jardins','🌊 Berges','🏕️ Forêts']},
  {name:'Gastronomie',items:['☕ Cafés','🍽️ Restaurants','🥐 Boulangeries','🍷 Bars','🧀 Fromageries']},
  {name:'Transports',items:['🚇 Métro','🚲 Vélibs','🚌 Bus','🚉 RER']},
];

const FiltersScreen = ({onBack}) => {
  const {React} = window;
  const {T,IC,StatusBar,DynamicIsland,PrimaryBtn} = window;
  const [active, setActive] = React.useState(new Set(['🏛️ Monuments','🌿 Parcs']));

  const toggle = (item) => setActive(s => {
    const n = new Set(s);
    n.has(item) ? n.delete(item) : n.add(item);
    return n;
  });

  return (
    <div style={{position:'relative',width:390,height:844,overflow:'hidden',background:T.bg,fontFamily:'Inter,sans-serif'}}>
      <DynamicIsland/>
      <StatusBar/>
      {/* Header */}
      <div style={{position:'absolute',top:50,left:0,right:0,background:T.surface,borderBottom:`1px solid ${T.border}`,padding:'10px 8px 10px',display:'flex',alignItems:'center',gap:8,zIndex:20}}>
        <div onClick={onBack} style={{width:36,height:36,display:'flex',alignItems:'center',justifyContent:'center',cursor:'pointer'}}><IC.chevL/></div>
        <span style={{fontSize:16,fontWeight:700,color:T.text,flex:1}}>Filtres</span>
        {active.size>0 && <button onClick={()=>setActive(new Set())} style={{background:'none',border:'none',color:T.red,fontSize:13,fontWeight:500,cursor:'pointer',padding:'8px'}}>Réinitialiser</button>}
      </div>

      {/* Active banner */}
      {active.size>0 && (
        <div style={{position:'absolute',top:106,left:0,right:0,background:T.p06,padding:'10px 16px',display:'flex',alignItems:'center',gap:6,zIndex:10}}>
          <IC.check c={T.primary}/>
          <span style={{fontSize:13,fontWeight:500,color:T.primary}}>{active.size} filtre{active.size>1?'s':''} actif{active.size>1?'s':''}</span>
        </div>
      )}

      {/* Filter content */}
      <div style={{position:'absolute',top:active.size>0?142:106,left:0,right:0,bottom:80,overflowY:'auto'}}>
        {FILTER_CATS.map((cat,ci)=>{
          const catActive = cat.items.filter(i=>active.has(i)).length;
          return (
            <div key={ci} style={{padding:'20px 16px 0'}}>
              <div style={{display:'flex',alignItems:'center',gap:8,marginBottom:10}}>
                <span style={{fontSize:14,fontWeight:700,color:T.text}}>{cat.name}</span>
                {catActive>0 && <div style={{background:T.primary,borderRadius:8,padding:'1px 7px',fontSize:11,fontWeight:700,color:'white'}}>{catActive}</div>}
              </div>
              <div style={{display:'flex',flexWrap:'wrap',gap:8}}>
                {cat.items.map((item,ii)=>{
                  const on=active.has(item);
                  return (
                    <div key={ii} onClick={()=>toggle(item)} style={{display:'flex',alignItems:'center',gap:6,padding:'7px 12px',borderRadius:10,fontSize:13,fontWeight:500,border:`1px solid ${on?T.primary:T.border}`,background:on?T.primary:'white',color:on?'white':T.text,cursor:'pointer',transition:'all .15s'}}>{item}</div>
                  );
                })}
              </div>
            </div>
          );
        })}
        <div style={{height:20}}/>
      </div>

      {/* Apply button */}
      <div style={{position:'absolute',bottom:0,left:0,right:0,padding:'12px 16px 24px',background:T.surface,borderTop:`1px solid ${T.border}`}}>
        <PrimaryBtn label={active.size>0?`Appliquer (${active.size})`:'Appliquer'} onClick={onBack}/>
      </div>
    </div>
  );
};

// ═══════ CREATE ITINÉRAIRE ════════════════════════════════════════════════════
const CREATE_POI = [
  {icon:'🏛️',name:'Tour Eiffel',sub:'Monument · 7ème arr.'},
  {icon:'🏛️',name:'Musée du Louvre',sub:'Musée · 1er arr.'},
  {icon:'🌿',name:'Jardin des Tuileries',sub:'Parc · 1er arr.'},
];

const CreateItineraireScreen = ({onBack, onCreate, lang='fr', cityData}) => {
  const {React} = window;
  const {T,IC,StatusBar,DynamicIsland,SearchBar,Chip,PrimaryBtn,OutlineBtn,PoiTile,DragHandle,StatsRow,CityHeaderBar} = window;
  const cityName = cityData?.name?.[lang] || cityData?.name?.fr || 'Paris';
  const [tabMode, setTabMode] = React.useState('manuel');
  const [pois, setPois] = React.useState(CREATE_POI);
  const [duration, setDuration] = React.useState(30);
  const [generated, setGenerated] = React.useState(false);
  const [chips, setChips] = React.useState([0]);

  const autoResult = [
    {icon:'💧',name:'Canal Saint-Martin',sub:'Parc · 10ème arr.'},
    {icon:'🛒',name:'Marché d\'Aligre',sub:'Marché · 12ème arr.'},
    {icon:'🌿',name:'Coulée Verte',sub:'Promenade · 12ème arr.'},
  ];

  return (
    <div style={{position:'relative',width:390,height:844,overflow:'hidden',background:T.bg,fontFamily:'Inter,sans-serif'}}>
      <DynamicIsland/>
      <StatusBar/>

      {/* Header — back + title row */}
      <div style={{position:'absolute',top:50,left:0,right:0,zIndex:20,background:T.surface,borderBottom:`1px solid ${T.border}`,padding:'10px 12px'}}>
        <div style={{display:'flex',alignItems:'center',gap:10,marginBottom:10}}>
          <div onClick={onBack} style={{width:36,height:36,borderRadius:10,background:T.surfVar,display:'flex',alignItems:'center',justifyContent:'center',cursor:'pointer',flexShrink:0}}>
            <IC.chevL/>
          </div>
          <div style={{flex:1}}>
            <div style={{fontSize:16,fontWeight:700,color:T.text}}>
              {lang==='en'?'Create itinerary':lang==='es'?'Crear itinerario':lang==='pt'?'Criar itinerário':lang==='ja'?'ルートを作成':'Créer un itinéraire'}
            </div>
          </div>
          <CityHeaderBar cityData={cityData} lang={lang}/>
        </div>
        {/* Full-width search bar */}
        <SearchBar onClick={()=>{}}/>
        {/* Chips */}
        <div style={{display:'flex',gap:8,marginTop:8,overflow:'hidden'}}>
          {['🏛️ Monuments','🌿 Parcs','☕ Cafés','Voir plus ›'].map((c,i)=>(
            <Chip key={i} label={c} active={chips.includes(i)} onClick={()=>setChips(p=>p.includes(i)?p.filter(x=>x!==i):[...p,i])}/>
          ))}
        </div>
      </div>

      {/* Map background */}
      <div style={{position:'absolute',top:170,left:0,right:0,bottom:74,background:'#E8E4D8'}}>
        <svg viewBox="0 0 390 760" style={{width:'100%',height:'100%'}} preserveAspectRatio="xMidYMid slice">
          <defs><pattern id="cgrid" width="46" height="46" patternUnits="userSpaceOnUse"><path d="M46 0H0V46" fill="none" stroke="#D6D0C2" strokeWidth="0.5" opacity="0.5"/></pattern></defs>
          <rect width="390" height="760" fill="#E8E4D8"/>
          <rect width="390" height="760" fill="url(#cgrid)"/>
          <rect x="22" y="60" width="68" height="42" rx="5" fill="#C5D5A8" opacity=".65"/>
          <rect x="235" y="88" width="80" height="52" rx="5" fill="#C5D5A8" opacity=".65"/>
          <line x1="0" y1="240" x2="390" y2="240" stroke="#256F4C" strokeWidth="5" opacity=".7"/>
          <line x1="0" y1="360" x2="390" y2="360" stroke="#BFB9AF" strokeWidth="4" opacity=".5"/>
          <line x1="120" y1="0" x2="120" y2="760" stroke="#256F4C" strokeWidth="5" opacity=".7"/>
          <line x1="240" y1="0" x2="240" y2="760" stroke="#BFB9AF" strokeWidth="4" opacity=".5"/>
          {/* POI pins */}
          {pois.map((_,i)=>{
            const positions=[{x:120,y:240},{x:240,y:300},{x:170,y:180}];
            const p=positions[i]||{x:200,y:300};
            return <g key={i} transform={`translate(${p.x-12},${p.y-28})`}>
              <ellipse cx="12" cy="30" rx="4" ry="2" fill="rgba(0,0,0,.15)"/>
              <path d="M12 0C7 0 3 4 3 9C3 16 12 24 12 24C12 24 21 16 21 9C21 4 17 0 12 0z" fill="#256F4C"/>
              <text x="12" y="13" textAnchor="middle" fontSize="10" fill="white" fontWeight="700">{i+1}</text>
            </g>;
          })}
          {/* Route line */}
          {pois.length>1 && <polyline points="120,240 240,300 170,180" fill="none" stroke="#256F4C" strokeWidth="2.5" strokeDasharray="6,4" opacity=".7"/>}
        </svg>
      </div>

      {/* Bottom sheet */}
      <div style={{position:'absolute',left:0,right:0,bottom:74,background:T.surface,backdropFilter:'blur(16px)',borderRadius:'24px 24px 0 0',borderTop:`1px solid ${T.border}`,boxShadow:'0 -6px 24px rgba(0,0,0,.25)',zIndex:30}}>
        <DragHandle/>
        <div style={{height:12}}/>
        {/* Mode tabs */}
        <div style={{display:'flex',gap:8,padding:'0 16px 12px'}}>
          {[['manuel','✏️ Manuel'],['auto','✨ Auto']].map(([k,l])=>(
            <div key={k} onClick={()=>{setTabMode(k);setGenerated(false);}} style={{flex:1,display:'flex',alignItems:'center',justifyContent:'center',gap:5,padding:'9px 8px',borderRadius:10,fontSize:13,fontWeight:600,cursor:'pointer',border:`1.5px solid ${tabMode===k?T.primary:'transparent'}`,background:tabMode===k?T.p10:T.surfVar,color:tabMode===k?T.primary:T.muted}}>{l}</div>
          ))}
        </div>

        {tabMode==='manuel' ? (
          <div style={{maxHeight:320,overflowY:'auto'}}>
            <div style={{display:'flex',alignItems:'center',justifyContent:'space-between',padding:'0 16px',marginBottom:8}}>
              <span style={{fontSize:16,fontWeight:700,color:T.text}}>Étapes du parcours</span>
              <div style={{background:T.p10,borderRadius:10,padding:'3px 8px',fontSize:11,fontWeight:600,color:T.primary}}>{pois.length} / min. 3</div>
            </div>
            <div style={{margin:'0 16px 8px',background:T.surfVar,borderRadius:10,display:'flex',alignItems:'center',gap:8,padding:'10px 12px'}}>
              <IC.edit c={T.muted}/>
              <span style={{fontSize:14,color:T.muted,flex:1}}>Nommer cet itinéraire… (optionnel)</span>
            </div>
            <div style={{padding:'0 16px'}}>
              {pois.map((p,i)=><PoiTile key={i} num={i+1} icon={p.icon} name={p.name} sub={p.sub} onDelete={()=>setPois(ps=>ps.filter((_,j)=>j!==i))}/>)}
            </div>
            <div style={{padding:'8px 16px 16px'}}>
              <PrimaryBtn label="🗺️  Créer l'itinéraire" disabled={pois.length<3} onClick={()=>{onCreate&&onCreate();onBack();}}/>
            </div>
          </div>
        ) : (
          <div style={{maxHeight:320,overflowY:'auto',padding:'0 0 16px'}}>
            {!generated ? (
              <>
                <div style={{padding:'0 16px 8px'}}>
                  <div style={{fontSize:16,fontWeight:700,color:T.text,marginBottom:4}}>Génération automatique</div>
                  <div style={{fontSize:12,color:T.muted}}>Maximise les rues non explorées autour de toi</div>
                </div>
                <div style={{display:'flex',gap:6,padding:'0 16px',marginBottom:12}}>
                  {[15,30,45,60].map(d=>(
                    <div key={d} onClick={()=>setDuration(d)} style={{flex:1,display:'flex',flexDirection:'column',alignItems:'center',justifyContent:'center',padding:'10px 4px',borderRadius:10,cursor:'pointer',background:duration===d?T.primary:T.surfVar}}>
                      <span style={{fontSize:18,fontWeight:700,lineHeight:1,color:duration===d?'white':T.text}}>{d}</span>
                      <span style={{fontSize:10,marginTop:2,color:duration===d?'rgba(255,255,255,.8)':T.muted}}>min</span>
                    </div>
                  ))}
                </div>
                <div style={{margin:'0 16px 12px'}}>
                  <StatsRow items={[{icon:'📏',val:`~${(duration*0.09).toFixed(1)} km`},{icon:'⏱',val:`${duration} min`},{icon:'🗺️',val:`~${Math.round(duration*0.6)} rues`}]}/>
                </div>
                <div style={{padding:'0 16px'}}>
                  <PrimaryBtn label="✨  Générer l'itinéraire" color="amber" onClick={()=>setGenerated(true)}/>
                </div>
              </>
            ) : (
              <>
                <div style={{margin:'0 16px 8px'}}>
                  <StatsRow items={[{icon:'📏',val:'2,8 km'},{icon:'⏱',val:'35 min'},{icon:'🗺️',val:'18 rues'}]} color="amber"/>
                </div>
                <div style={{padding:'0 16px'}}>
                  {autoResult.map((p,i)=><PoiTile key={i} num={i+1} icon={p.icon} name={p.name} sub={p.sub} color="amber"/>)}
                </div>
                <div style={{display:'flex',gap:8,padding:'8px 16px'}}>
                  <OutlineBtn label="🔄 Regénérer" onClick={()=>setGenerated(false)} flex="0 0 auto"/>
                  <PrimaryBtn label="✓ Utiliser" color="amber" onClick={()=>{onCreate&&onCreate();onBack();}}/>
                </div>
              </>
            )}
          </div>
        )}
      </div>
      <BottomNav active="carte" onChange={()=>{}}/>
    </div>
  );
};

// ═══════ SESSION SUMMARY ═════════════════════════════════════════════════════
const SessionSummary = ({session, onClose, onCelebrate}) => {
  const {React} = window;
  const {T,IC,PrimaryBtn,OutlineBtn} = window;

  React.useEffect(()=>{
    const t = setTimeout(()=>onCelebrate&&onCelebrate(), 800);
    return ()=>clearTimeout(t);
  },[]);

  const mins = Math.floor((session.secs||0)/60);
  const secs = String((session.secs||0)%60).padStart(2,'0');

  return (
    <div style={{position:'absolute',inset:0,background:'rgba(15,23,42,.6)',backdropFilter:'blur(8px)',zIndex:1000,display:'flex',alignItems:'flex-end'}}>
      <div style={{width:'100%',background:T.surface,borderRadius:'28px 28px 0 0',padding:'0 0 40px',maxHeight:'85%',overflowY:'auto'}}>
        <div style={{width:40,height:4,background:T.pill,borderRadius:2,margin:'12px auto'}}/>
        <div style={{padding:'8px 24px 0'}}>
          <div style={{textAlign:'center',marginBottom:20}}>
            <div style={{fontSize:40,marginBottom:8}}>🎉</div>
            <div style={{fontFamily:'Crimson Pro,serif',fontSize:26,fontWeight:700,color:T.text,letterSpacing:'-.5px'}}>Sortie terminée !</div>
            <div style={{fontSize:13,color:T.muted,marginTop:4}}>Belle exploration, continuez comme ça</div>
          </div>

          <div style={{display:'grid',gridTemplateColumns:'1fr 1fr',gap:10,marginBottom:20}}>
            {[
              {icon:'🗺️',val:session.streets||0,unit:'rues explorées'},
              {icon:'📏',val:`${(session.km||0).toFixed(1)}`,unit:'kilomètres'},
              {icon:'⏱',val:`${mins}:${secs}`,unit:'durée'},
              {icon:'🏆',val:'2',unit:'nouveaux badges'},
            ].map((s,i)=>(
              <div key={i} style={{background:T.surfVar,borderRadius:16,padding:'14px',textAlign:'center'}}>
                <div style={{fontSize:22,marginBottom:4}}>{s.icon}</div>
                <div style={{fontFamily:'Crimson Pro,serif',fontSize:22,fontWeight:700,color:T.primary}}>{s.val}</div>
                <div style={{fontSize:11,color:T.muted}}>{s.unit}</div>
              </div>
            ))}
          </div>

          <div style={{background:T.a10,border:`1px solid ${T.a22}`,borderRadius:16,padding:'12px 16px',marginBottom:20,display:'flex',alignItems:'center',gap:10}}>
            <span style={{fontSize:24}}>🏆</span>
            <div>
              <div style={{fontSize:13,fontWeight:600,color:T.text}}>2 badges débloqués !</div>
              <div style={{fontSize:11,color:T.muted}}>Pont de la Tournelle · Berge Sud</div>
            </div>
            <IC.chevL c={T.accent} s={18}/>
          </div>

          <div style={{display:'flex',gap:10}}>
            <OutlineBtn label={<><IC.share c={T.muted} s={16}/> Partager</>} onClick={onClose} flex={1}/>
            <PrimaryBtn label="Super !" onClick={onClose}/>
          </div>
        </div>
      </div>
    </div>
  );
};

// ═══════ CELEBRATION OVERLAY ════════════════════════════════════════════════
const CelebrationOverlay = ({onDone}) => {
  const {React} = window;
  const {T,PrimaryBtn} = window;
  const [particles] = React.useState(()=>Array.from({length:24},(_,i)=>({
    id:i,x:Math.random()*390,delay:Math.random()*0.5,
    emoji:['🎉','⭐','✨','🏆','🎊'][Math.floor(Math.random()*5)],
    size:12+Math.random()*16,
  })));

  return (
    <div style={{position:'absolute',inset:0,background:'rgba(15,23,42,.85)',backdropFilter:'blur(4px)',zIndex:2000,display:'flex',flexDirection:'column',alignItems:'center',justifyContent:'center',overflow:'hidden'}}>
      {/* Particles */}
      {particles.map(p=>(
        <div key={p.id} style={{position:'absolute',left:p.x,top:-20,fontSize:p.size,animation:`fall 2s ${p.delay}s ease-in both`}}>{p.emoji}</div>
      ))}
      {/* Badge */}
      <div style={{animation:'badgePop .6s cubic-bezier(.34,1.56,.64,1) both',textAlign:'center',padding:'0 32px'}}>
        <div style={{width:120,height:120,borderRadius:'50%',background:'linear-gradient(135deg,#F59E0B,#B8832E)',margin:'0 auto 20px',display:'flex',alignItems:'center',justifyContent:'center',fontSize:52,boxShadow:'0 0 0 8px rgba(245,158,11,.2),0 0 0 16px rgba(245,158,11,.1)'}}>🏆</div>
        <div style={{fontFamily:'Crimson Pro,serif',fontSize:30,fontWeight:700,color:'white',marginBottom:8}}>Badge débloqué !</div>
        <div style={{fontSize:18,fontWeight:600,color:T.accent,marginBottom:6}}>Pont de la Tournelle</div>
        <div style={{fontSize:13,color:'rgba(255,255,255,.7)',marginBottom:32,lineHeight:1.5}}>Vous avez traversé ce pont historique<br/>datant du XVIIIe siècle</div>
        <PrimaryBtn label="Continuer l'exploration" onClick={onDone}/>
        <div onClick={onDone} style={{marginTop:14,fontSize:13,color:'rgba(255,255,255,.5)',cursor:'pointer'}}>Ignorer</div>
      </div>
    </div>
  );
};

Object.assign(window, {FiltersScreen, CreateItineraireScreen, SessionSummary, CelebrationOverlay});
