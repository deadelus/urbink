'use strict';
// ─── Root App — Phone Frame + Navigation + Global State ──────────────────────

const App = () => {
  const {React} = window;
  const {T, StatusBar, DynamicIsland, BottomNav,
    CarteScreen, ParcoursScreen, SocialScreen, BadgesScreen, ProfilScreen,
    FiltersScreen, CreateItineraireScreen, SessionSummary, CelebrationOverlay,
    SettingsScreen, CityScreen, t, CITIES} = window;

  // Global state
  const [tab, setTab] = React.useState('carte');
  const [overlay, setOverlay] = React.useState(null); // 'filters'|'createItin'|'summary'|'celebration'
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
    else if (dest === 'city')         { setOverlay('city'); }
  };

  const lang = globalState.lang || 'fr';
  const city = globalState.city || 'paris';
  const cityData = CITIES && CITIES.find(c=>c.id===city);

  const renderScreen = () => {
    switch(tab) {
      case 'carte':     return <CarteScreen onNavigate={handleNavigate} globalState={globalState} setGlobalState={setGlobalState} lang={lang} cityData={cityData}/>;
      case 'parcours':  return <ParcoursScreen onNavigate={handleNavigate} onCreateItin={()=>setOverlay('createItin')} lang={lang} cityData={cityData}/>;
      case 'social':    return <SocialScreen onNavigate={handleNavigate} lang={lang}/>;
      case 'badges':    return <BadgesScreen onNavigate={handleNavigate} lang={lang} cityData={cityData}/>;
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
      {overlay === 'city' && (
        <div style={{position:'absolute',inset:0,zIndex:500,animation:'fadeIn .2s ease'}}>
          <CityScreen onBack={()=>setOverlay(null)} currentCity={city} lang={lang}
            onSelectCity={c=>setGlobalState(g=>({...g,city:c,exploredStreets:[]}))}/>
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
        <CelebrationOverlay onDone={()=>setOverlay(null)}/>
      )}
    </div>
  );
};

// ─── Tweaks Panel ─────────────────────────────────────────────────────────────
const TweaksPanel = ({show, tweaks, onChange}) => {
  const {React} = window;
  if (!show) return null;
  return (
    <div style={{position:'fixed',bottom:24,right:24,width:240,background:'white',borderRadius:20,boxShadow:'0 8px 32px rgba(0,0,0,.18), 0 2px 8px rgba(0,0,0,.08)',padding:'16px',zIndex:9999,fontFamily:'Inter,sans-serif'}}>
      <div style={{fontSize:13,fontWeight:700,color:'#0F172A',marginBottom:14,letterSpacing:.5}}>TWEAKS</div>

      <div style={{marginBottom:12}}>
        <div style={{fontSize:11,fontWeight:600,color:'#64748B',marginBottom:6,textTransform:'uppercase',letterSpacing:.5}}>Couleur primaire</div>
        <div style={{display:'flex',gap:8}}>
          {[['#256F4C','Forêt'],['#B8832E','Ocre'],['#2563EB','Bleu']].map(([c,l])=>(
            <div key={c} onClick={()=>onChange('primaryColor',c)} style={{flex:1,height:28,borderRadius:8,background:c,cursor:'pointer',border:tweaks.primaryColor===c?'2px solid #0F172A':'2px solid transparent',display:'flex',alignItems:'center',justifyContent:'center'}}>
              {tweaks.primaryColor===c && <div style={{width:8,height:8,borderRadius:'50%',background:'white'}}/>}
            </div>
          ))}
        </div>
      </div>

      <div style={{marginBottom:12}}>
        <div style={{fontSize:11,fontWeight:600,color:'#64748B',marginBottom:6,textTransform:'uppercase',letterSpacing:.5}}>Style carte</div>
        <div style={{display:'flex',gap:6}}>
          {[['classic','Classique'],['warm','Chaud'],['night','Nuit']].map(([k,l])=>(
            <div key={k} onClick={()=>onChange('mapStyle',k)} style={{flex:1,padding:'5px 0',borderRadius:8,fontSize:11,fontWeight:500,textAlign:'center',cursor:'pointer',background:tweaks.mapStyle===k?'#0F172A':'#F1F5F9',color:tweaks.mapStyle===k?'white':'#64748B'}}>{l}</div>
          ))}
        </div>
      </div>

      <div style={{marginBottom:0}}>
        <div style={{fontSize:11,fontWeight:600,color:'#64748B',marginBottom:6,textTransform:'uppercase',letterSpacing:.5}}>Police</div>
        <div style={{display:'flex',gap:6}}>
          {[['Inter','Moderne'],['serif','Classique']].map(([k,l])=>(
            <div key={k} onClick={()=>onChange('fontStyle',k)} style={{flex:1,padding:'5px 0',borderRadius:8,fontSize:11,fontWeight:500,textAlign:'center',cursor:'pointer',fontFamily:k==='serif'?'Crimson Pro,serif':'Inter,sans-serif',background:tweaks.fontStyle===k?'#0F172A':'#F1F5F9',color:tweaks.fontStyle===k?'white':'#64748B'}}>{l}</div>
          ))}
        </div>
      </div>
    </div>
  );
};

// ─── Root renderer with phone frame + tweaks ────────────────────────────────
const Root = () => {
  const {React} = window;

  const TWEAK_DEFAULTS = /*EDITMODE-BEGIN*/{
    "primaryColor": "#256F4C",
    "mapStyle": "classic",
    "fontStyle": "Inter"
  }/*EDITMODE-END*/;

  const [tweaks, setTweaks] = React.useState(TWEAK_DEFAULTS);
  const [showTweaks, setShowTweaks] = React.useState(false);

  // Apply tweaks to CSS variables
  React.useEffect(()=>{
    document.documentElement.style.setProperty('--primary', tweaks.primaryColor);
  },[tweaks.primaryColor]);

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
          <App/>
        </div>
      </div>
      <TweaksPanel show={showTweaks} tweaks={tweaks} onChange={handleTweakChange}/>
    </>
  );
};

const rootEl = document.getElementById('root');
ReactDOM.createRoot(rootEl).render(<Root/>);
