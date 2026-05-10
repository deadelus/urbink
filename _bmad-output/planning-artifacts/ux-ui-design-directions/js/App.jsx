'use strict';
// ─── Root App — Phone Frame + Navigation + Global State ──────────────────────

const App = ({tweaks={}}) => {
  const {React} = window;
  const {T, StatusBar, DynamicIsland, BottomNav,
    CarteScreen, ParcoursScreen, SocialScreen, BadgesScreen, ProfilScreen,
    FiltersScreen, CreateItineraireScreen, SessionSummary, CelebrationOverlay,
    SettingsScreen, CityScreen, MyCitiesScreen, RanksScreen, t, CITIES, RankCelebrationOverlay} = window;

  // Global state
  const [tab, setTab] = React.useState(()=> {
    const m = location.hash.match(/tab=(\w+)/);
    return m ? m[1] : 'carte';
  });
  const [overlay, setOverlay] = React.useState(()=> {
    const m = location.hash.match(/overlay=(\w+)/);
    return m ? m[1] : null;
  }); // 'filters'|'createItin'|'summary'|'celebration'
  const [celebrationCfg, setCelebrationCfg] = React.useState({fromIdx:4, toIdx:5});

  // Listen for tweaks-triggered celebration
  React.useEffect(()=>{
    const onTrigger = (e) => {
      const {fromIdx, toIdx} = e.detail || {};
      setCelebrationCfg({fromIdx: fromIdx ?? 4, toIdx: toIdx ?? 5});
      setOverlay('celebration');
    };
    window.addEventListener('urbink:trigger-celebration', onTrigger);
    return ()=>window.removeEventListener('urbink:trigger-celebration', onTrigger);
  },[]);
  const [globalState, setGlobalState] = React.useReducer(
    (s, fn) => typeof fn === 'function' ? fn(s) : {...s, ...fn},
    {
      session: {active:false, km:0, streets:0, secs:0},
      exploredStreets: [],
      showSummary: false,
      lang: 'fr',
      city: 'paris',
    }
  );

  // Deep-link via hash for screenshots: #tab=profil or #overlay=myCities
  React.useEffect(()=>{
    window.__setTab = setTab;
    window.__setOverlay = setOverlay;
    const apply = () => {
      const t = (location.hash.match(/tab=(\w+)/)||[])[1];
      const o = (location.hash.match(/overlay=(\w+)/)||[])[1];
      if (t) setTab(t);
      if (o) setOverlay(o);
    };
    apply();
    window.addEventListener('hashchange', apply);
    return () => window.removeEventListener('hashchange', apply);
  },[]);

  // Watch for showSummary flag from session stop
  React.useEffect(()=>{
    if (globalState.showSummary) {
      setGlobalState(s=>({...s, showSummary:false}));
      setOverlay('summary');
    }
  },[globalState.showSummary]);

  const handleNavigate = (dest) => {
    if (['carte','parcours','social','badges','profil'].includes(dest)) {
      setTab(dest);
      setOverlay(null);
    } else if (dest === 'filters')    { setOverlay('filters'); }
    else if (dest === 'createItin')   { setOverlay('createItin'); }
    else if (dest === 'city')         { setOverlay('myCities'); }
    else if (dest === 'myCities')     { setOverlay('myCities'); }
    else if (dest === 'ranks')        { setOverlay('ranks'); }
  };

  const lang = globalState.lang || 'fr';
  const city = globalState.city || 'paris';
  const cityData = CITIES && CITIES.find(c=>c.id===city);

  const renderScreen = () => {
    switch(tab) {
      case 'carte':     return <CarteScreen onNavigate={handleNavigate} globalState={globalState} setGlobalState={setGlobalState} lang={lang} cityData={cityData}/>;
      case 'parcours':  return <ParcoursScreen onNavigate={handleNavigate} onCreateItin={()=>setOverlay('createItin')} lang={lang} cityData={cityData}/>;
      case 'social':    return <SocialScreen onNavigate={handleNavigate} lang={lang}/>;
      case 'badges':    return <BadgesScreen onNavigate={handleNavigate} lang={lang} cityData={cityData} rankPlacement={tweaks.badgesRankPlacement || 'A'}/>;
      case 'profil':    return <ProfilScreen onNavigate={handleNavigate} onSettings={()=>setOverlay('settings')} lang={lang} cityData={cityData} onChangeCity={()=>setOverlay('city')}/>;
      default:          return null;
    }
  };

  return (
    <div style={{position:'relative', width:390, height:844, overflow:'hidden', borderRadius:50, boxShadow:'0 0 0 1px #21262D, 0 30px 80px rgba(0,0,0,.7)', fontFamily:'Inter,sans-serif'}}>
      {/* Main screen */}
      {renderScreen()}

      {/* Overlays */}
      {overlay === 'settings' && (
        <div style={{position:'absolute',inset:0,zIndex:500,animation:'fadeIn .2s ease'}}>
          <SettingsScreen onBack={()=>setOverlay(null)} lang={lang}
            onLangChange={l=>setGlobalState(g=>({...g,lang:l}))}/>
        </div>
      )}
      {overlay === 'myCities' && (
        <div style={{position:'absolute',inset:0,zIndex:500,animation:'fadeIn .2s ease'}}>
          <MyCitiesScreen
            onBack={()=>setOverlay(null)}
            currentCity={city}
            lang={lang}
            onSelectCity={c=>setGlobalState(g=>({...g,city:c,exploredStreets:[]}))}/>
        </div>
      )}
      {overlay === 'ranks' && (
        <div style={{position:'absolute',inset:0,zIndex:500,animation:'fadeIn .2s ease'}}>
          <RanksScreen onBack={()=>setOverlay(null)} rankIdx={4} xpInRank={32}/>
        </div>
      )}
      {overlay === 'filters' && (
        <div style={{position:'absolute',inset:0,zIndex:500,animation:'fadeIn .2s ease'}}>
          <FiltersScreen onBack={()=>setOverlay(null)}/>
        </div>
      )}
      {overlay === 'createItin' && (
        <div style={{position:'absolute',inset:0,zIndex:500,animation:'fadeIn .2s ease'}}>
          <CreateItineraireScreen onBack={()=>setOverlay(null)} onCreate={()=>{}} lang={lang} cityData={cityData}/>
        </div>
      )}
      {overlay === 'summary' && (
        <SessionSummary
          session={globalState.session}
          onClose={()=>{setOverlay('celebration');}}
          onCelebrate={()=>{}}
        />
      )}
      {overlay === 'celebration' && (
        <RankCelebrationOverlay fromIdx={celebrationCfg.fromIdx} toIdx={celebrationCfg.toIdx} onDone={()=>setOverlay(null)}/>
      )}
    </div>
  );
};

// ─── Tweaks Panel ─────────────────────────────────────────────────────────────
const TweaksPanel = ({show, tweaks, onChange}) => {
  const {React} = window;
  const GEM_DATA = window.GEM_DATA || [];
  const triggerCelebration = () => {
    window.dispatchEvent(new CustomEvent('urbink:trigger-celebration', {
      detail: {fromIdx: tweaks.celebFromIdx ?? 4, toIdx: tweaks.celebToIdx ?? 5},
    }));
  };
  if (!show) return null;
  return (
    <div style={{position:'fixed',bottom:24,right:24,width:260,background:'white',borderRadius:20,boxShadow:'0 8px 32px rgba(0,0,0,.18), 0 2px 8px rgba(0,0,0,.08)',padding:'16px',zIndex:9999,fontFamily:'Inter,sans-serif',maxHeight:'90vh',overflowY:'auto'}}>
      <div style={{fontSize:13,fontWeight:700,color:'#0F172A',marginBottom:14,letterSpacing:.5}}>TWEAKS</div>

      {/* Theme toggle */}
      <div style={{marginBottom:14}}>
        <div style={{fontSize:11,fontWeight:600,color:'#64748B',marginBottom:6,textTransform:'uppercase',letterSpacing:.5}}>Thème</div>
        <div style={{display:'flex',gap:6}}>
          {[['light','☀️ Clair'],['dark','🌙 Sombre']].map(([k,l])=>(
            <div key={k} onClick={()=>onChange('theme',k)} style={{flex:1,padding:'8px 0',borderRadius:10,fontSize:12,fontWeight:600,textAlign:'center',cursor:'pointer',background:tweaks.theme===k?'#0F172A':'#F1F5F9',color:tweaks.theme===k?'white':'#64748B',transition:'all .15s'}}>{l}</div>
          ))}
        </div>
      </div>

      {/* Badges — Rank placement */}
      <div style={{marginBottom:14}}>
        <div style={{fontSize:11,fontWeight:600,color:'#64748B',marginBottom:6,textTransform:'uppercase',letterSpacing:.5}}>Rang dans Badges</div>
        <div style={{display:'flex',gap:4}}>
          {[
            ['A','A','Sous-titre'],
            ['B','B','Card dédiée'],
            ['C','C','4ᵉ stat'],
          ].map(([k,short,full])=>{
            const sel = (tweaks.badgesRankPlacement||'A')===k;
            return (
              <div key={k} onClick={()=>onChange('badgesRankPlacement',k)} title={full} style={{flex:1,padding:'8px 0 6px',borderRadius:10,textAlign:'center',cursor:'pointer',background:sel?'#0F172A':'#F1F5F9',color:sel?'white':'#64748B',transition:'all .15s'}}>
                <div style={{fontSize:13,fontWeight:700,lineHeight:1}}>{short}</div>
                <div style={{fontSize:9,marginTop:2,opacity:.8,letterSpacing:.2}}>{full}</div>
              </div>
            );
          })}
        </div>
      </div>

      {/* Celebration trigger */}
      <div style={{marginBottom:14,padding:'12px',background:'#0F172A',borderRadius:14}}>
        <div style={{fontSize:11,fontWeight:700,color:'#E8C547',marginBottom:8,textTransform:'uppercase',letterSpacing:1}}>Célébration de rang</div>
        <div style={{display:'flex',gap:6,marginBottom:8}}>
          <select value={tweaks.celebFromIdx ?? 4} onChange={e=>onChange('celebFromIdx', parseInt(e.target.value))} style={{flex:1,padding:'6px 8px',borderRadius:8,border:'1px solid #334155',background:'#1E293B',color:'white',fontSize:11,fontFamily:'inherit'}}>
            {GEM_DATA.map((g,i)=> <option key={g.id} value={i}>{i+1}. {g.name}</option>)}
          </select>
          <span style={{color:'#94A3B8',fontSize:14,alignSelf:'center'}}>→</span>
          <select value={tweaks.celebToIdx ?? 5} onChange={e=>onChange('celebToIdx', parseInt(e.target.value))} style={{flex:1,padding:'6px 8px',borderRadius:8,border:'1px solid #334155',background:'#1E293B',color:'white',fontSize:11,fontFamily:'inherit'}}>
            {GEM_DATA.map((g,i)=> <option key={g.id} value={i}>{i+1}. {g.name}</option>)}
          </select>
        </div>
        <button onClick={triggerCelebration} style={{
          width:'100%',padding:'9px 12px',borderRadius:10,border:'none',cursor:'pointer',
          background:'linear-gradient(90deg, #D4A642, #E8C547)',color:'#0F172A',
          fontSize:12,fontWeight:700,letterSpacing:.5,fontFamily:'inherit',
          boxShadow:'0 4px 12px rgba(232,197,71,.3)',
        }}>✨ Déclencher la célébration</button>
      </div>

    </div>
  );
};

// ─── Root renderer with phone frame + tweaks ────────────────────────────────
const Root = () => {
  const {React} = window;

  const TWEAK_DEFAULTS = /*EDITMODE-BEGIN*/{
    "theme": "light",
    "celebFromIdx": 4,
    "celebToIdx": 5,
    "badgesRankPlacement": "A"
  }/*EDITMODE-END*/;

  const [tweaks, setTweaks] = React.useState(TWEAK_DEFAULTS);
  const [showTweaks, setShowTweaks] = React.useState(false);
  const [themeKey, setThemeKey] = React.useState(0);

  // Apply theme by mutating window.T then forcing remount
  React.useEffect(()=>{
    window.applyTheme(tweaks.theme || 'light');
    setThemeKey(k=>k+1);
  },[tweaks.theme]);

  const handleTweakChange = (key, val) => {
    setTweaks(t=>({...t,[key]:val}));
    window.parent.postMessage({type:'__edit_mode_set_keys', edits:{[key]:val}},'*');
  };

  React.useEffect(()=>{
    window.addEventListener('message', e=>{
      if (e.data?.type==='__activate_edit_mode') setShowTweaks(true);
      if (e.data?.type==='__deactivate_edit_mode') setShowTweaks(false);
    });
    window.parent.postMessage({type:'__edit_mode_available'},'*');
  },[]);

  // Scale phone to fit viewport
  const [scale, setScale] = React.useState(1);
  React.useEffect(()=>{
    const calc = () => {
      const scaleX = (window.innerWidth - 48) / 390;
      const scaleY = (window.innerHeight - 48) / 844;
      setScale(Math.min(scaleX, scaleY, 1));
    };
    calc();
    window.addEventListener('resize', calc);
    return ()=>window.removeEventListener('resize', calc);
  },[]);

  return (
    <>
      <div style={{width:'100vw',height:'100vh',background:'#0D1117',display:'flex',alignItems:'center',justifyContent:'center',overflow:'hidden'}}>
        <div style={{transform:`scale(${scale})`,transformOrigin:'center center'}}>
          <App key={themeKey} tweaks={tweaks}/>
        </div>
      </div>
      <TweaksPanel show={showTweaks} tweaks={tweaks} onChange={handleTweakChange}/>
    </>
  );
};

const rootEl = document.getElementById('root');
ReactDOM.createRoot(rootEl).render(<Root/>);
