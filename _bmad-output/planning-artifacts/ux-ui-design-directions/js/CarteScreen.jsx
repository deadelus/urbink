'use strict';
// ─── Carte Screen — Map + Bottom Sheet + Session ──────────────────────────────

const POI_CHIPS = ['🏛️ Monuments','🌿 Parcs','☕ Cafés','🛒 Marchés'];

const ITINERAIRES = [
  {emoji:'🗺️',name:'Tour de Montmartre',meta:'4,2 km · 55 min · 5 étapes'},
  {emoji:'📚',name:'Quartier Latin',meta:'3,1 km · 40 min · 4 étapes'},
  {emoji:'🌊',name:'Berges de la Seine',meta:'6,8 km · 1h20 · 6 étapes'},
  {emoji:'🏛️',name:'Marais & Archives',meta:'2,8 km · 35 min · 3 étapes'},
];

const NAV_APPS = [
  {icon:'📍',title:'GPS intégré',sub:'Recommandé'},
  {icon:'🍎',title:'Apple Plans',sub:'Application Maps'},
  {icon:'🗺️',title:'Google Maps',sub:'Application externe'},
  {icon:'🚗',title:'Waze',sub:'Voiture uniquement'},
];

const SNAP = {collapsed:72, peek:280, expanded:580};

const CarteScreen = ({onNavigate, globalState, setGlobalState, lang='fr', cityData}) => {
  const {React} = window;
  const {T,IC,MapView,StatusBar,DynamicIsland,BottomNav,SearchBar,Chip,
    DragHandle,ZonesPill,SessionBar,PrimaryBtn,OutlineBtn,TextBtn,
    ModeCard,ParcoursCard,NavOptionCard,StatsRow} = window;
  const tFn = window.t || ((l,k)=>k);

  const [snap, setSnap] = React.useState('collapsed');
  const [chips, setChips] = React.useState([0]);
  const [zones, setZones] = React.useState(true);
  const [mode, setMode] = React.useState('libre'); // 'libre' | 'itineraire'
  const [subView, setSubView] = React.useState('start'); // 'start' | 'itineraires' | 'navChoice'
  const [navApp, setNavApp] = React.useState(0);
  const [selItin, setSelItin] = React.useState(null);

  // Session state from global
  const session = globalState.session;
  const setSession = (s) => setGlobalState(g=>({...g, session:s}));
  const explored = globalState.exploredStreets || [];

  // Session timer
  React.useEffect(()=>{
    if (!session.active) return;
    const iv = setInterval(()=>{
      setGlobalState(g=>{
        const cur = g.session;
        const allIds = window.STREET_SEGS.map(s=>s.id);
        const explored = g.exploredStreets || [];
        const unexplored = allIds.filter(id=>!window.HISTORICAL_STREETS.has(id)&&!explored.includes(id));
        const newStreets = unexplored.length>0
          ? [...explored, unexplored[Math.floor(Math.random()*unexplored.length)]]
          : explored;
        return {
          ...g,
          exploredStreets: newStreets,
          session:{
            ...cur,
            secs: cur.secs+1,
            km: cur.km + 0.008,
            streets: window.HISTORICAL_STREETS.size + newStreets.length,
          }
        };
      });
    }, 1000);
    return ()=>clearInterval(iv);
  },[session.active]);

  const startSession = () => {
    setSession({active:true,km:1.2,streets:12,secs:0});
    setSnap('collapsed');
    setSubView('start');
  };

  const stopSession = () => {
    setGlobalState(g=>({
      ...g,
      session:{active:false,km:g.session.km,streets:g.session.streets,secs:g.session.secs},
      showSummary:true,
    }));
  };

  const sheetH = SNAP[snap];
  const mapBottom = 74;
  const mapTop = session.active ? 94 : 50;

  // Content inside bottom sheet based on state
  const renderSheetContent = () => {
    if (subView==='itineraires') return <SheetItineraires
      itins={ITINERAIRES} selItin={selItin} setSelItin={setSelItin}
      onBack={()=>setSubView('start')} onSelect={(i)=>{setSelItin(i);setSubView('navChoice');}}
      onCreateItin={()=>onNavigate('createItin')} T={T} IC={IC}
      TextBtn={TextBtn} ParcoursCard={ParcoursCard}/>;

    if (subView==='navChoice') return <SheetNavChoice
      itin={selItin} navApp={navApp} setNavApp={setNavApp}
      onBack={()=>setSubView('itineraires')} onStart={startSession}
      T={T} IC={IC} TextBtn={TextBtn} NavOptionCard={NavOptionCard} PrimaryBtn={PrimaryBtn}/>;

    // Default: start screen
    return <SheetStart
      snap={snap} mode={mode} setMode={setMode} lang={lang}
      onSelectItin={()=>{setMode('itineraire');setSubView('itineraires');setSnap('expanded');}}
      onStart={startSession}
      T={T} IC={IC} ModeCard={ModeCard} PrimaryBtn={PrimaryBtn} StatsRow={StatsRow}/>;
  };

  return (
    <div style={{position:'relative',width:390,height:844,overflow:'hidden',background:T.bg,fontFamily:'Inter,sans-serif'}}>
      <DynamicIsland/>
      <StatusBar light={session.active}/>
      {session.active && <SessionBar km={session.km} streets={session.streets} secs={session.secs}/>}

      {/* Map */}
      <MapView exploredStreets={explored} sessionActive={session.active} top={mapTop} bottom={mapBottom}/>

      {/* Search + Chips + City button — hidden during session */}
      {!session.active && (
        <div style={{position:'absolute',top:58,left:16,right:16,zIndex:20}}>
          {/* City button row */}
          <div style={{display:'flex',alignItems:'center',gap:8,marginBottom:8}}>
            <div onClick={()=>onNavigate('city')} style={{display:'inline-flex',alignItems:'center',gap:6,background:T.surface,borderRadius:20,padding:'6px 12px 6px 8px',boxShadow:'0 2px 8px rgba(0,0,0,.10)',cursor:'pointer',border:`1px solid ${T.border}`}}>
              <span style={{fontSize:16}}>{cityData?.flag||'🇫🇷'}</span>
              <span style={{fontSize:13,fontWeight:600,color:T.text}}>{cityData?.name?.[lang]||'Paris'}</span>
              <svg width="12" height="12" fill="none" viewBox="0 0 24 24"><path d="M19 9l-7 7-7-7" stroke={T.muted} strokeWidth="2.5" strokeLinecap="round"/></svg>
            </div>
            <div style={{flex:1}}><SearchBar onClick={()=>onNavigate('filters')}/></div>
          </div>
          <div style={{display:'flex',gap:8,overflow:'hidden'}}>
            {POI_CHIPS.map((c,i)=><Chip key={i} label={c} active={chips.includes(i)}
              onClick={()=>setChips(p=>p.includes(i)?p.filter(x=>x!==i):[...p,i])}/>)}
            <Chip label="Voir plus ›" active={false} onClick={()=>onNavigate('filters')}/>
          </div>
        </div>
      )}

      {/* Zones pill */}
      <div style={{position:'absolute',left:16,bottom:session.active?94:sheetH+82,zIndex:20,transition:'bottom .35s ease'}}>
        <ZonesPill active={zones} onToggle={()=>setZones(v=>!v)}/>
      </div>

      {/* Stop session button */}
      {session.active && (
        <div onClick={stopSession} style={{
          position:'absolute',bottom:90,right:16,width:52,height:52,
          background:T.red,borderRadius:14,display:'flex',alignItems:'center',
          justifyContent:'center',boxShadow:'0 4px 12px rgba(220,38,38,.45)',
          cursor:'pointer',zIndex:60
        }}>
          <IC.stop/>
        </div>
      )}

      {/* Bottom Sheet */}
      {!session.active && (
        <div style={{
          position:'absolute',left:0,right:0,bottom:74,
          height:SNAP.expanded+4,
          transform:`translateY(${SNAP.expanded - sheetH}px)`,
          transition:'transform .4s cubic-bezier(.4,0,.2,1)',
          background:'rgba(255,255,255,.94)',
          backdropFilter:'blur(16px)',
          borderRadius:'24px 24px 0 0',
          boxShadow:'0 -6px 24px rgba(0,0,0,.08)',
          zIndex:30,
          display:'flex',flexDirection:'column',
        }}>
          <div onClick={()=>setSnap(s => s==='collapsed'?'peek':s==='peek'?'expanded':'peek')} style={{cursor:'pointer'}}>
            <DragHandle/>
            <div style={{display:'flex',alignItems:'center',justifyContent:'center',gap:4,padding:'4px 0',fontSize:12,color:T.muted,fontWeight:500}}>
              {snap==='collapsed' ? <><IC.chevUp c={T.muted} s={14}/> {tFn(lang,'sheet_hint_collapsed')}</> :
               snap==='peek'     ? <><IC.chevUp c={T.muted} s={14}/> {tFn(lang,'sheet_hint_peek')}</> :
                                   <><IC.chevDn c={T.muted} s={14}/> {tFn(lang,'sheet_hint_expanded')}</>}
            </div>
          </div>
          <div style={{flex:1,overflowY:snap==='expanded'?'auto':'hidden'}}>
            {renderSheetContent()}
          </div>
        </div>
      )}

      <BottomNav active="carte" onChange={onNavigate} lang={lang}/>
    </div>
  );
};

// ─── Sub-views ────────────────────────────────────────────────────────────────
const SheetStart = ({snap,mode,setMode,onSelectItin,onStart,T,IC,ModeCard,PrimaryBtn,StatsRow,lang='fr'}) => {
  const {React} = window;
  const tFn = window.t || ((l,k)=>k);
  const [layers, setLayers] = React.useState({monuments:true, quartiers:false, photos:false});
  const flip = k => setLayers(l=>({...l,[k]:!l[k]}));
  const LAYER_ITEMS = [
    {key:'monuments',label:tFn(lang,'layer_monuments'),sub:tFn(lang,'layer_monuments_sub')},
    {key:'quartiers',label:tFn(lang,'layer_quartiers'),sub:tFn(lang,'layer_quartiers_sub')},
    {key:'photos',   label:tFn(lang,'layer_photos'),   sub:tFn(lang,'layer_photos_sub')},
  ];

  return (
    <div style={{padding:'8px 0'}}>
      <div style={{fontSize:16,fontWeight:700,color:T.text,padding:'0 16px',marginBottom:12}}>{tFn(lang,'sheet_title')}</div>

      {/* Mode cards */}
      <div style={{display:'flex',gap:8,padding:'0 16px',marginBottom:12}}>
        <ModeCard icon="🚶" title={tFn(lang,'mode_libre')} sub={mode==='libre'?tFn(lang,'mode_libre_sel'):tFn(lang,'mode_libre_sub')} selected={mode==='libre'} onClick={()=>setMode('libre')}/>
        <ModeCard icon="🗺️" title={tFn(lang,'mode_itin')} sub={tFn(lang,'mode_itin_sub')} selected={mode==='itineraire'} onClick={onSelectItin}/>
      </div>

      {/* GPS chip */}
      <div style={{display:'inline-flex',alignItems:'center',gap:6,background:T.p06,border:`1px solid ${T.p18}`,borderRadius:10,padding:'6px 12px',margin:'0 16px',fontSize:12,fontWeight:500,color:T.primary}}>
        <IC.gps/> {tFn(lang,'gps_ready')}
      </div>

      {/* CTA */}
      <div style={{padding:'12px 16px 0'}}>
        <PrimaryBtn label={tFn(lang,'btn_start')} onClick={onStart}/>
      </div>

      {/* Expanded extras */}
      {snap==='expanded' && <>
        <div style={{height:14}}/>
        <StatsRow items={[{icon:'📏',val:'~2,4 km'},{icon:'⏱',val:'~30 min'},{icon:'🗺️',val:'~15 rues'}]}/>
        <div style={{padding:'16px 16px 0'}}>
          <div style={{fontSize:13,fontWeight:700,color:T.text,marginBottom:10}}>{tFn(lang,'layers_title')}</div>
          <div style={{background:T.surfVar,borderRadius:14,overflow:'hidden'}}>
            {LAYER_ITEMS.map((l,i)=>(
              <div key={l.key} onClick={()=>flip(l.key)} style={{display:'flex',alignItems:'center',gap:12,padding:'12px 14px',borderBottom:i<LAYER_ITEMS.length-1?`1px solid ${T.border}`:'none',cursor:'pointer'}}>
                <div style={{flex:1}}>
                  <div style={{fontSize:13,fontWeight:500,color:T.text}}>{l.label}</div>
                  <div style={{fontSize:11,color:T.muted}}>{l.sub}</div>
                </div>
                <div style={{width:40,height:24,borderRadius:12,background:layers[l.key]?T.primary:'#CBD5E1',position:'relative',transition:'background .2s',flexShrink:0}}>
                  <div style={{position:'absolute',top:3,left:layers[l.key]?19:3,width:18,height:18,borderRadius:'50%',background:'white',boxShadow:'0 1px 3px rgba(0,0,0,.2)',transition:'left .2s'}}/>
                </div>
              </div>
            ))}
          </div>
        </div>
        <div style={{padding:'14px 16px 8px',display:'flex',alignItems:'center',gap:8}}>
          <div style={{flex:1,height:1,background:T.border}}/>
          <span style={{fontSize:11,color:T.muted,whiteSpace:'nowrap'}}>{tFn(lang,'last_trip')}</span>
          <div style={{flex:1,height:1,background:T.border}}/>
        </div>
      </>}
    </div>
  );
};

const SheetItineraires = ({itins,selItin,onBack,onSelect,onCreateItin,T,IC,TextBtn,ParcoursCard}) => (
  <div>
    <div style={{display:'flex',alignItems:'center',justifyContent:'space-between',padding:'0 4px'}}>
      <TextBtn label={<><IC.chevL s={16}/> Retour</>} onClick={onBack}/>
      <TextBtn label={<><IC.plus s={16} c={T.primary}/> Créer</>} color={T.primary} onClick={onCreateItin}/>
    </div>
    <div style={{fontSize:16,fontWeight:700,color:T.text,padding:'0 16px',marginBottom:12}}>Mes itinéraires</div>
    <div style={{padding:'0 16px'}}>
      {itins.map((it,i)=><ParcoursCard key={i} emoji={it.emoji} name={it.name} meta={it.meta} onClick={()=>onSelect(it)}/>)}
    </div>
  </div>
);

const SheetNavChoice = ({itin,navApp,setNavApp,onBack,onStart,T,IC,TextBtn,NavOptionCard,PrimaryBtn}) => (
  <div>
    <div style={{display:'flex',alignItems:'center',justifyContent:'space-between',padding:'0 4px'}}>
      <TextBtn label={<><IC.chevL s={16}/> Retour</>} onClick={onBack}/>
    </div>
    {itin && (
      <div style={{margin:'0 16px 12px',background:T.a10,border:`1px solid ${T.a22}`,borderRadius:10,padding:'10px 16px',display:'flex',alignItems:'center',gap:8}}>
        <span style={{fontSize:16}}>{itin.emoji}</span>
        <span style={{fontSize:13,fontWeight:600,color:T.text,flex:1}}>{itin.name}</span>
        <span style={{fontSize:11,color:T.muted}}>{itin.meta.split('·').slice(0,2).join('·')}</span>
      </div>
    )}
    <div style={{fontSize:16,fontWeight:700,color:T.text,padding:'0 16px',marginBottom:8}}>Naviguer avec…</div>
    <div style={{padding:'0 16px'}}>
      {NAV_APPS.map((a,i)=><NavOptionCard key={i} icon={a.icon} title={a.title} sub={a.sub} selected={navApp===i} onClick={()=>setNavApp(i)}/>)}
    </div>
    <div style={{padding:'8px 16px 16px'}}><PrimaryBtn label="🧭  C'est parti !" color="amber" onClick={onStart}/></div>
  </div>
);

Object.assign(window, {CarteScreen});
