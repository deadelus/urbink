'use strict';
// ─── Parcours, Social, Badges, Profil screens ─────────────────────────────────

// ═══════ PARCOURS ═══════════════════════════════════════════════════════════
const PARCOURS_DATA = [
  {emoji:'🗺️',name:'Tour de Montmartre',meta:'4,2 km · 55 min · 5 étapes',color:'#256F4C',pct:82},
  {emoji:'📚',name:'Quartier Latin',meta:'3,1 km · 40 min · 4 étapes',color:'#F59E0B',pct:100},
  {emoji:'🌊',name:'Berges de la Seine',meta:'6,8 km · 1h20 · 6 étapes',color:'#256F4C',pct:34},
  {emoji:'🏛️',name:'Marais & Archives',meta:'2,8 km · 35 min · 3 étapes',color:'#F59E0B',pct:0},
  {emoji:'🌿',name:'Circuit Belleville',meta:'2,1 km · 28 min · 3 étapes',color:'#256F4C',pct:0},
];

const THEMATIC = [
  {emoji:'⛪',name:'Toutes les églises',progress:7,total:32},
  {emoji:'🌳',name:'Parcs & Jardins',progress:12,total:28},
  {emoji:'🛒',name:'Marchés de Paris',progress:5,total:18},
];

const ParcoursScreen = ({onNavigate, onCreateItin, lang='fr', cityData}) => {
  const {React} = window;
  const {T,IC,StatusBar,DynamicIsland,BottomNav,PrimaryBtn,CityHeaderBar} = window;
  const tFn = window.t || ((l,k)=>k);
  const [tab, setTab] = React.useState('mes');
  const cityName = cityData?.name?.[lang] || cityData?.name?.fr || 'Paris';

  return (
    <div style={{position:'relative',width:390,height:844,overflow:'hidden',background:T.bg,fontFamily:'Inter,sans-serif'}}>
      <DynamicIsland/>
      <StatusBar/>
      <div style={{position:'absolute',top:50,left:0,right:0,bottom:74,overflowY:'auto'}}>
        {/* Header */}
        <div style={{padding:'20px 16px 12px',display:'flex',alignItems:'flex-start',justifyContent:'space-between'}}>
          <div>
            <div style={{fontFamily:'Crimson Pro,serif',fontSize:26,fontWeight:700,color:T.text,letterSpacing:'-.5px'}}>{tFn(lang,'parcours_title')}</div>
            <div style={{marginTop:6}}>
              <CityHeaderBar cityData={cityData} lang={lang} onChangeCity={()=>onNavigate('city')}/>
            </div>
          </div>
          <div onClick={onCreateItin} style={{width:40,height:40,borderRadius:12,background:T.primary,display:'flex',alignItems:'center',justifyContent:'center',cursor:'pointer',boxShadow:'0 4px 12px rgba(37,111,76,.3)',marginTop:4}}>
            <IC.plus c="white" s={20}/>
          </div>
        </div>

        {/* City context banner */}
        <div style={{margin:'0 16px 14px',background:T.p06,borderRadius:14,padding:'10px 14px',border:`1px solid ${T.p18}`,display:'flex',alignItems:'center',gap:10}}>
          <span style={{fontSize:18}}>{cityData?.flag||'🇫🇷'}</span>
          <div style={{flex:1}}>
            <div style={{fontSize:12,fontWeight:600,color:T.primary}}>{cityName}</div>
            <div style={{fontSize:11,color:T.muted}}>{cityData?.explored?.toLocaleString()||'1 234'} {tFn(lang,'city_streets')} {tFn(lang,'city_explored')} · {cityData?.pct||8}%</div>
          </div>
          <div style={{height:32,width:60,background:T.surfVar,borderRadius:8,overflow:'hidden'}}>
            <div style={{width:`${cityData?.pct||8}%`,height:'100%',background:T.primary,borderRadius:8}}/>
          </div>
        </div>

        {/* Tabs */}
        <div style={{display:'flex',margin:'0 16px 16px',background:T.surfVar,borderRadius:12,padding:4}}>
          {[['mes',tFn(lang,'tab_mes')],['thematiques',tFn(lang,'tab_thematiques')]].map(([k,l])=>(
            <div key={k} onClick={()=>setTab(k)} style={{flex:1,padding:'8px 12px',borderRadius:10,fontSize:13,fontWeight:600,textAlign:'center',cursor:'pointer',background:tab===k?T.surface:'transparent',color:tab===k?T.text:T.muted,boxShadow:tab===k?'0 1px 4px rgba(0,0,0,.08)':'none',transition:'all .2s'}}>{l}</div>
          ))}
        </div>

        {tab==='mes' ? (
          <div style={{padding:'0 16px'}}>
            {PARCOURS_DATA.map((p,i)=>(
              <div key={i} style={{background:T.surface,borderRadius:20,border:`1px solid ${T.border}`,padding:'14px 16px',marginBottom:10,boxShadow:'0 1px 6px rgba(0,0,0,.04)',cursor:'pointer'}}>
                <div style={{display:'flex',alignItems:'center',gap:12,marginBottom:p.pct>0?10:0}}>
                  <div style={{width:46,height:46,borderRadius:14,background:`${p.color}15`,display:'flex',alignItems:'center',justifyContent:'center',fontSize:22,flexShrink:0}}>{p.emoji}</div>
                  <div style={{flex:1}}>
                    <div style={{fontSize:14,fontWeight:700,color:T.text}}>{p.name}</div>
                    <div style={{fontSize:11,color:T.muted,marginTop:2}}>{p.meta}</div>
                  </div>
                  <div style={{display:'flex',flexDirection:'column',alignItems:'flex-end',gap:4}}>
                    {p.pct===100 && <div style={{background:'rgba(37,111,76,.1)',borderRadius:20,padding:'3px 8px',fontSize:10,fontWeight:700,color:T.primary}}>{tFn(lang,'completed')}</div>}
                    {p.pct>0&&p.pct<100 && <div style={{fontSize:12,fontWeight:600,color:p.color}}>{p.pct}%</div>}
                    <span style={{fontSize:18,color:T.muted}}>›</span>
                  </div>
                </div>
                {p.pct>0 && (
                  <div style={{height:4,background:T.surfVar,borderRadius:2,overflow:'hidden'}}>
                    <div style={{width:`${p.pct}%`,height:'100%',background:p.color,borderRadius:2,transition:'width .6s ease'}}/>
                  </div>
                )}
              </div>
            ))}
            <div style={{padding:'8px 0 20px'}}>
              <div onClick={onCreateItin} style={{height:52,borderRadius:16,border:`2px dashed ${T.border}`,display:'flex',alignItems:'center',justifyContent:'center',gap:8,cursor:'pointer',color:T.muted,fontSize:14,fontWeight:500}}>
                <IC.plus c={T.muted}/> {tFn(lang,'btn_new_itin')}
              </div>
            </div>
          </div>
        ) : (
          <div style={{padding:'0 16px'}}>
            <div style={{fontSize:13,color:T.muted,marginBottom:12,lineHeight:1.5}}>{tFn(lang,'thematic_sub')}</div>
            {THEMATIC.map((t,i)=>(
              <div key={i} style={{background:T.surface,borderRadius:20,border:`1px solid ${T.border}`,padding:'14px 16px',marginBottom:10,boxShadow:'0 1px 6px rgba(0,0,0,.04)',cursor:'pointer'}}>
                <div style={{display:'flex',alignItems:'center',gap:12,marginBottom:10}}>
                  <div style={{width:46,height:46,borderRadius:14,background:T.p10,display:'flex',alignItems:'center',justifyContent:'center',fontSize:22,flexShrink:0}}>{t.emoji}</div>
                  <div style={{flex:1}}>
                    <div style={{fontSize:14,fontWeight:700,color:T.text}}>{t.name}</div>
                    <div style={{fontSize:11,color:T.muted,marginTop:2}}>{t.progress}/{t.total} lieux visités</div>
                  </div>
                  <div style={{fontSize:12,fontWeight:700,color:T.primary}}>{Math.round(t.progress/t.total*100)}%</div>
                </div>
                <div style={{height:6,background:T.surfVar,borderRadius:3,overflow:'hidden'}}>
                  <div style={{width:`${t.progress/t.total*100}%`,height:'100%',background:T.primary,borderRadius:3}}/>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
      <BottomNav active="parcours" onChange={onNavigate} lang={lang}/>
    </div>
  );
};

// ═══════ SOCIAL ═════════════════════════════════════════════════════════════
const FEED = [
  {avatar:'JM',name:'Julie M.',city:'Paris 11e',time:'il y a 12 min',km:3.2,rues:18,dur:'38 min',badges:['🏛️','🌿'],reaction:7,tracePts:'30,10 60,40 90,20 130,50 160,30'},
  {avatar:'TL',name:'Thomas L.',city:'Montmartre',time:'il y a 1h',km:5.8,rues:31,dur:'1h12',badges:['🏆','☕','🏛️'],reaction:14,tracePts:'10,50 50,20 90,45 140,15 180,40'},
  {avatar:'CM',name:'Chloé M.',city:'Paris 6e',time:'il y a 2h',km:2.1,rues:12,dur:'26 min',badges:['🌿'],reaction:4,tracePts:'20,30 60,50 100,25 130,45'},
  {avatar:'AR',name:'Alexandre R.',city:'Belleville',time:'il y a 3h',km:4.5,rues:24,dur:'55 min',badges:['🏛️','🌊'],reaction:11,tracePts:'10,40 50,15 100,35 150,10 190,30'},
];

const SocialScreen = ({onNavigate, lang='fr'}) => {
  const {React} = window;
  const {T,IC,StatusBar,DynamicIsland,BottomNav} = window;
  const [liked, setLiked] = React.useState({});

  return (
    <div style={{position:'relative',width:390,height:844,overflow:'hidden',background:T.bg,fontFamily:'Inter,sans-serif'}}>
      <DynamicIsland/>
      <StatusBar/>
      <div style={{position:'absolute',top:50,left:0,right:0,bottom:74,overflowY:'auto'}}>
        {/* Header */}
        <div style={{padding:'20px 16px 12px',display:'flex',alignItems:'center',justifyContent:'space-between'}}>
          <div style={{fontFamily:'Crimson Pro,serif',fontSize:26,fontWeight:700,color:T.text,letterSpacing:'-.5px'}}>Social</div>
          <div style={{display:'flex',gap:8}}>
            <div style={{width:36,height:36,borderRadius:10,background:T.surfVar,display:'flex',alignItems:'center',justifyContent:'center',cursor:'pointer'}}><IC.users c={T.muted} s={18}/></div>
          </div>
        </div>

        {/* Stories row */}
        <div style={{display:'flex',gap:10,padding:'0 16px 16px',overflowX:'auto'}}>
          {['Ma carte','Julie','Thomas','Chloé','Alex','Emma'].map((n,i)=>(
            <div key={i} style={{display:'flex',flexDirection:'column',alignItems:'center',gap:6,flexShrink:0}}>
              <div style={{width:52,height:52,borderRadius:'50%',background:i===0?T.primary:`hsl(${i*60},50%,65%)`,display:'flex',alignItems:'center',justifyContent:'center',border:i===0?`2px solid ${T.primary}`:`2px solid #e0e0e0`,fontSize:i===0?20:14,color:'white',fontWeight:700}}>
                {i===0?'🗺️':n[0]}
              </div>
              <span style={{fontSize:10,color:T.muted,width:52,textAlign:'center',overflow:'hidden',textOverflow:'ellipsis',whiteSpace:'nowrap'}}>{n}</span>
            </div>
          ))}
        </div>

        {/* Feed */}
        <div style={{padding:'0 16px'}}>
          {FEED.map((f,i)=>(
            <div key={i} style={{background:T.surface,borderRadius:20,border:`1px solid ${T.border}`,padding:16,marginBottom:12,boxShadow:'0 1px 6px rgba(0,0,0,.04)'}}>
              <div style={{display:'flex',alignItems:'center',gap:10,marginBottom:12}}>
                <div style={{width:38,height:38,borderRadius:'50%',background:`hsl(${i*60+120},45%,60%)`,display:'flex',alignItems:'center',justifyContent:'center',fontSize:13,fontWeight:700,color:'white',flexShrink:0}}>{f.avatar}</div>
                <div style={{flex:1}}>
                  <div style={{fontSize:14,fontWeight:600,color:T.text}}>{f.name}</div>
                  <div style={{fontSize:11,color:T.muted}}>{f.city} · {f.time}</div>
                </div>
                <span style={{fontSize:18,color:T.muted,cursor:'pointer'}}>···</span>
              </div>
              {/* Stats */}
              <div style={{display:'flex',gap:12,marginBottom:12}}>
                {[{icon:'🗺️',v:f.rues+' rues'},{icon:'📏',v:f.km+'km'},{icon:'⏱',v:f.dur}].map((s,j)=>(
                  <div key={j} style={{display:'flex',alignItems:'center',gap:4}}>
                    <span style={{fontSize:12}}>{s.icon}</span>
                    <span style={{fontSize:12,fontWeight:600,color:T.primary}}>{s.v}</span>
                  </div>
                ))}
              </div>
              {/* Mini trace */}
              <div style={{background:'#E8E4D8',borderRadius:12,height:80,marginBottom:12,overflow:'hidden',position:'relative'}}>
                <svg viewBox={`0 0 200 60`} style={{width:'100%',height:'100%',padding:8}} preserveAspectRatio="none">
                  <polyline points={f.tracePts} fill="none" stroke="#256F4C" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round" opacity="0.8"/>
                </svg>
              </div>
              {/* Badges */}
              <div style={{display:'flex',alignItems:'center',gap:8,marginBottom:10}}>
                <div style={{display:'flex',gap:4}}>
                  {f.badges.map((b,j)=><span key={j} style={{fontSize:16}}>{b}</span>)}
                </div>
                <span style={{fontSize:11,color:T.muted}}>{f.badges.length} badge{f.badges.length>1?'s':''} débloqué{f.badges.length>1?'s':''}</span>
              </div>
              {/* Actions */}
              <div style={{display:'flex',alignItems:'center',gap:16,paddingTop:10,borderTop:`1px solid ${T.border}`}}>
                <div onClick={()=>setLiked(l=>({...l,[i]:!l[i]}))} style={{display:'flex',alignItems:'center',gap:4,cursor:'pointer'}}>
                  <span style={{fontSize:16}}>{liked[i]?'🔥':'🤍'}</span>
                  <span style={{fontSize:12,fontWeight:500,color:liked[i]?T.accent:T.muted}}>{f.reaction+(liked[i]?1:0)}</span>
                </div>
                <div style={{display:'flex',alignItems:'center',gap:4,cursor:'pointer'}}>
                  <span style={{fontSize:16}}>💬</span>
                  <span style={{fontSize:12,fontWeight:500,color:T.muted}}>Commenter</span>
                </div>
                <div style={{flex:1}}/>
                <IC.share c={T.muted}/>
              </div>
            </div>
          ))}
        </div>
      </div>
      <BottomNav active="social" onChange={onNavigate} lang={lang}/>
    </div>
  );
};

// ═══════ BADGES ════════════════════════════════════════════════════════════
const MONUMENTS = [
  {emoji:'🏰',name:'Notre-Dame',locked:false},{emoji:'🗼',name:'Tour Eiffel',locked:false},
  {emoji:'🏛️',name:'Louvre',locked:false},{emoji:'⛪',name:'Sacré-Cœur',locked:true},
  {emoji:'🌉',name:'Pont Neuf',locked:true},{emoji:'🏰',name:'Versailles',locked:true},
  {emoji:'🎭',name:'Opéra Garnier',locked:true},{emoji:'🏛️',name:'Panthéon',locked:false},
  {emoji:'🌆',name:'Montparnasse',locked:true},{emoji:'🏗️',name:'Centre Pompidou',locked:true},
  {emoji:'🛖',name:'Place des Vosges',locked:false},{emoji:'🌊',name:'Pont d\'Iéna',locked:true},
];

const DISTRICTS = [
  {name:'Marais',pct:78},{name:'Montmartre',pct:55},{name:'Saint-Germain',pct:100},
  {name:'Bastille',pct:32},{name:'Pigalle',pct:18},{name:'Oberkampf',pct:90},
];

const BadgesScreen = ({onNavigate, lang='fr', cityData}) => {
  const {React} = window;
  const {T,IC,StatusBar,DynamicIsland,BottomNav,CityHeaderBar} = window;
  const tFn = window.t || ((l,k)=>k);
  const [tab,setTab] = React.useState('monuments');
  const cityName = cityData?.name?.[lang] || cityData?.name?.fr || 'Paris';

  return (
    <div style={{position:'relative',width:390,height:844,overflow:'hidden',background:T.bg,fontFamily:'Inter,sans-serif'}}>
      <DynamicIsland/>
      <StatusBar/>
      <div style={{position:'absolute',top:50,left:0,right:0,bottom:74,overflowY:'auto'}}>
        <div style={{padding:'20px 16px 12px'}}>
          <div style={{display:'flex',alignItems:'flex-start',justifyContent:'space-between',marginBottom:6}}>
            <div style={{fontFamily:'Crimson Pro,serif',fontSize:26,fontWeight:700,color:T.text,letterSpacing:'-.5px'}}>{tFn(lang,'badges_title')}</div>
            <CityHeaderBar cityData={cityData} lang={lang} onChangeCity={()=>onNavigate('city')}/>
          </div>
          <div style={{fontSize:12,color:T.muted}}>7 / 32 · 2 {tFn(lang,'badge_explored')} — {cityName}</div>
        </div>

        {/* Stats banner */}
        <div style={{margin:'0 16px 16px',background:T.a10,border:`1px solid ${T.a22}`,borderRadius:16,padding:'12px 16px',display:'flex',justifyContent:'space-around'}}>
          {[{v:'7',l:'Badges'},{ v:'2',l:'Quartiers'},{v:'18',l:'Km total'}].map((s,i)=>(
            <div key={i} style={{textAlign:'center'}}>
              <div style={{fontFamily:'Crimson Pro,serif',fontSize:26,fontWeight:700,color:T.accent}}>{s.v}</div>
              <div style={{fontSize:11,color:T.muted}}>{s.l}</div>
            </div>
          ))}
        </div>

        {/* Tab toggle */}
        <div style={{display:'flex',margin:'0 16px 16px',background:T.surfVar,borderRadius:12,padding:4}}>
          {[['monuments',tFn(lang,'tab_monuments')],['quartiers',tFn(lang,'tab_quartiers')]].map(([k,l])=>(
            <div key={k} onClick={()=>setTab(k)} style={{flex:1,padding:'8px 0',borderRadius:10,fontSize:13,fontWeight:600,textAlign:'center',cursor:'pointer',background:tab===k?T.surface:'transparent',color:tab===k?T.text:T.muted,transition:'all .2s'}}>{l}</div>
          ))}
        </div>

        {tab==='monuments' ? (
          <div style={{display:'grid',gridTemplateColumns:'repeat(3,1fr)',gap:10,padding:'0 16px 20px'}}>
            {MONUMENTS.map((m,i)=>(
              <div key={i} style={{background:T.surface,borderRadius:16,border:`1px solid ${T.border}`,padding:'14px 8px',textAlign:'center',opacity:m.locked?.5:1,boxShadow:'0 1px 4px rgba(0,0,0,.04)',position:'relative'}}>
                {!m.locked && <div style={{position:'absolute',top:-4,right:-4,width:16,height:16,background:T.primary,borderRadius:'50%',display:'flex',alignItems:'center',justifyContent:'center'}}><IC.check c="white" s={10}/></div>}
                <div style={{fontSize:28,marginBottom:6,filter:m.locked?'grayscale(1)':'none'}}>{m.emoji}</div>
                <div style={{fontSize:10,fontWeight:600,color:m.locked?T.muted:T.text,lineHeight:1.2}}>{m.name}</div>
                {m.locked && <IC.lock c={T.muted} s={12}/>}
              </div>
            ))}
          </div>
        ) : (
          <div style={{padding:'0 16px 20px'}}>
            {DISTRICTS.map((d,i)=>(
              <div key={i} style={{background:T.surface,borderRadius:16,border:`1px solid ${T.border}`,padding:'12px 16px',marginBottom:8,boxShadow:'0 1px 4px rgba(0,0,0,.04)'}}>
                <div style={{display:'flex',alignItems:'center',marginBottom:8}}>
                  <div style={{flex:1}}>
                    <div style={{fontSize:14,fontWeight:600,color:T.text}}>{d.name}</div>
                    <div style={{fontSize:11,color:T.muted}}>{d.pct}% {tFn(lang,'badge_explored')}</div>
                  </div>
                  {d.pct===100 && <div style={{background:T.p10,borderRadius:20,padding:'4px 10px',fontSize:11,fontWeight:700,color:T.primary}}>{tFn(lang,'badge_unlocked')}</div>}
                </div>
                <div style={{height:6,background:T.surfVar,borderRadius:3}}>
                  <div style={{width:`${d.pct}%`,height:'100%',background:d.pct===100?T.accent:T.primary,borderRadius:3,transition:'width .6s'}}/>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
      <BottomNav active="badges" onChange={onNavigate} lang={lang}/>
    </div>
  );
};

// ═══════ PROFIL ═════════════════════════════════════════════════════════════
const SORTIES = [
  {date:'Aujourd\'hui',emoji:'🚶',km:2.4,rues:14,dur:'28 min',badges:1,new:true},
  {date:'Hier',emoji:'🚴',km:8.2,rues:41,dur:'52 min',badges:2,new:false},
  {date:'Lundi',emoji:'🚶',km:3.1,rues:18,dur:'36 min',badges:0,new:false},
  {date:'Dimanche',emoji:'🚶',km:5.6,rues:29,dur:'1h08',badges:3,new:false},
  {date:'Vendredi',emoji:'🚴',km:11.3,rues:58,dur:'1h24',badges:1,new:false},
];

const WEEK = [
  {d:'L',rues:18},{d:'M',rues:0},{d:'M',rues:41},{d:'J',rues:14},{d:'V',rues:58},{d:'S',rues:29},{d:'D',rues:0},
];

const GearIcon = ({c='white',s=20}) => (
  <svg width={s} height={s} fill="none" viewBox="0 0 24 24">
    <path d="M12 15a3 3 0 100-6 3 3 0 000 6z" stroke={c} strokeWidth="1.8"/>
    <path d="M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 010 2.83 2 2 0 01-2.83 0l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 01-4 0v-.09A1.65 1.65 0 009 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 01-2.83-2.83l.06-.06A1.65 1.65 0 004.68 15a1.65 1.65 0 00-1.51-1H3a2 2 0 010-4h.09A1.65 1.65 0 004.6 9a1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 012.83-2.83l.06.06A1.65 1.65 0 009 4.68a1.65 1.65 0 001-1.51V3a2 2 0 014 0v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 012.83 2.83l-.06.06A1.65 1.65 0 0019.4 9a1.65 1.65 0 001.51 1H21a2 2 0 010 4h-.09a1.65 1.65 0 00-1.51 1z" stroke={c} strokeWidth="1.8"/>
  </svg>
);

const ProfilScreen = ({onNavigate, onSettings, lang='fr', cityData, onChangeCity}) => {
  const {React} = window;
  const {T,IC,StatusBar,DynamicIsland,BottomNav,CityBadge} = window;
  const maxRues = Math.max(...WEEK.map(w=>w.rues));
  const cityName = cityData?.name?.[lang] || cityData?.name?.fr || 'Paris';

  return (
    <div style={{position:'relative',width:390,height:844,overflow:'hidden',background:T.bg,fontFamily:'Inter,sans-serif'}}>
      <DynamicIsland/>
      <StatusBar/>
      <div style={{position:'absolute',top:50,left:0,right:0,bottom:74,overflowY:'auto'}}>
        {/* Profile header */}
        <div style={{background:T.primary,padding:'20px 16px 24px',position:'relative',overflow:'hidden'}}>
          <div style={{position:'absolute',top:-20,right:-20,width:120,height:120,borderRadius:'50%',background:'rgba(255,255,255,.05)',pointerEvents:'none'}}/>
          <div style={{position:'absolute',top:10,right:30,width:80,height:80,borderRadius:'50%',background:'rgba(255,255,255,.05)',pointerEvents:'none'}}/>
          {/* Top row: avatar + name + gear */}
          <div style={{display:'flex',alignItems:'center',gap:14,marginBottom:16}}>
            <div style={{width:56,height:56,borderRadius:'50%',background:'rgba(255,255,255,.2)',display:'flex',alignItems:'center',justifyContent:'center',fontSize:24,fontWeight:700,color:'white',border:'2px solid rgba(255,255,255,.4)'}}>A</div>
            <div style={{flex:1}}>
              <div style={{fontSize:18,fontWeight:700,color:'white',fontFamily:'Crimson Pro,serif'}}>Alex Dupont</div>
              <div style={{fontSize:12,color:'rgba(255,255,255,.7)',marginTop:2}}>{lang==='en'?'Explorer since April 2026':lang==='es'?'Explorador desde Abril 2026':lang==='pt'?'Explorador desde Abril 2026':lang==='ja'?'2026年4月から探索者':'Explorateur depuis Avril 2026'}</div>
            </div>
            <div onClick={onSettings} style={{width:38,height:38,borderRadius:12,background:'rgba(255,255,255,.18)',border:'1.5px solid rgba(255,255,255,.35)',display:'flex',alignItems:'center',justifyContent:'center',cursor:'pointer',flexShrink:0,position:'relative',zIndex:10}}>
              <svg width="18" height="18" fill="none" viewBox="0 0 24 24"><path d="M12 15a3 3 0 100-6 3 3 0 000 6z" stroke="white" strokeWidth="1.8"/><path d="M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 010 2.83 2 2 0 01-2.83 0l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 01-4 0v-.09A1.65 1.65 0 009 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 01-2.83-2.83l.06-.06A1.65 1.65 0 004.68 15a1.65 1.65 0 00-1.51-1H3a2 2 0 010-4h.09A1.65 1.65 0 004.6 9a1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 012.83-2.83l.06.06A1.65 1.65 0 009 4.68a1.65 1.65 0 001-1.51V3a2 2 0 014 0v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 012.83 2.83l-.06.06A1.65 1.65 0 0019.4 9a1.65 1.65 0 001.51 1H21a2 2 0 010 4h-.09a1.65 1.65 0 00-1.51 1z" stroke="white" strokeWidth="1.8"/></svg>
            </div>
          </div>
          {/* City pill + stats */}
          <div style={{display:'flex',alignItems:'center',gap:10,marginBottom:16}}>
            <CityBadge cityData={cityData} lang={lang} onChangeCity={()=>onNavigate('city')}/>
            <div style={{flex:1,height:4,background:'rgba(255,255,255,.15)',borderRadius:2,overflow:'hidden'}}>
              <div style={{width:`${cityData?.pct||8}%`,height:'100%',background:'rgba(255,255,255,.7)',borderRadius:2}}/>
            </div>
            <span style={{fontSize:11,color:'rgba(255,255,255,.7)',fontWeight:600}}>{cityData?.pct||8}%</span>
          </div>
          <div style={{display:'flex',justifyContent:'space-around'}}>
            {[{v:'160',l:lang==='en'?'Streets':lang==='es'?'Calles':lang==='pt'?'Ruas':lang==='ja'?'通り':'Rues'},{v:'24,3km',l:lang==='en'?'Distance':'Distance'},{v:'7',l:lang==='en'?'Badges':'Badges'},{v:'2',l:lang==='en'?'Districts':lang==='es'?'Barrios':lang==='pt'?'Bairros':lang==='ja'?'地区':'Quartiers'}].map((s,i)=>(
              <div key={i} style={{textAlign:'center'}}>
                <div style={{fontFamily:'Crimson Pro,serif',fontSize:20,fontWeight:700,color:'white'}}>{s.v}</div>
                <div style={{fontSize:10,color:'rgba(255,255,255,.7)'}}>{s.l}</div>
              </div>
            ))}
          </div>
        </div>

        {/* Settings row — large tap target */}
        <div onClick={onSettings} style={{margin:'12px 16px 0',background:T.surface,borderRadius:16,border:`1px solid ${T.border}`,padding:'14px 16px',display:'flex',alignItems:'center',gap:12,cursor:'pointer',boxShadow:'0 1px 4px rgba(0,0,0,.04)'}}>
          <div style={{width:38,height:38,borderRadius:11,background:T.surfVar,display:'flex',alignItems:'center',justifyContent:'center',fontSize:18,flexShrink:0}}>⚙️</div>
          <div style={{flex:1}}>
            <div style={{fontSize:14,fontWeight:600,color:T.text}}>{lang==='en'?'Settings':lang==='es'?'Ajustes':lang==='pt'?'Configurações':lang==='ja'?'設定':'Paramètres'}</div>
            <div style={{fontSize:11,color:T.muted,marginTop:1}}>{lang==='en'?'Account, privacy, map style':lang==='es'?'Cuenta, privacidad, mapa':lang==='pt'?'Conta, privacidade, mapa':lang==='ja'?'アカウント、プライバシー、マップ':'Compte, confidentialité, carte'}</div>
          </div>
          <svg width="16" height="16" fill="none" viewBox="0 0 24 24"><path d="M9 18l6-6-6-6" stroke={T.muted} strokeWidth="2" strokeLinecap="round"/></svg>
        </div>

        {/* Week histogram */}
        <div style={{background:T.surface,margin:'16px 16px 0',borderRadius:20,padding:'16px',border:`1px solid ${T.border}`,boxShadow:'0 1px 6px rgba(0,0,0,.04)'}}>
          <div style={{fontSize:13,fontWeight:700,color:T.text,marginBottom:12}}>Cette semaine</div>
          <div style={{display:'flex',alignItems:'flex-end',gap:6,height:60}}>
            {WEEK.map((w,i)=>{
              const isToday=i===3; const pct=maxRues>0?w.rues/maxRues:0;
              return (
                <div key={i} style={{flex:1,display:'flex',flexDirection:'column',alignItems:'center',gap:4}}>
                  <div style={{width:'100%',height:48,display:'flex',alignItems:'flex-end'}}>
                    <div style={{width:'100%',height:w.rues===0?4:`${pct*48}px`,background:isToday?T.accent:w.rues===0?T.surfVar:T.primary,borderRadius:'3px 3px 0 0',transition:'height .6s ease',opacity:w.rues===0?.3:1}}/>
                  </div>
                  <div style={{fontSize:10,color:isToday?T.accent:T.muted,fontWeight:isToday?700:400}}>{w.d}</div>
                </div>
              );
            })}
          </div>
          <div style={{display:'flex',justifyContent:'space-between',marginTop:12,paddingTop:12,borderTop:`1px solid ${T.border}`}}>
            {[{v:'160',l:'Rues / sem.'},{v:'5',l:'Sorties'},{v:'30,6km',l:'Distance'}].map((s,i)=>(
              <div key={i} style={{textAlign:'center'}}>
                <div style={{fontSize:16,fontWeight:700,color:T.primary}}>{s.v}</div>
                <div style={{fontSize:10,color:T.muted}}>{s.l}</div>
              </div>
            ))}
          </div>
        </div>

        {/* Sorties list */}
        <div style={{padding:'16px 16px 20px'}}>
          <div style={{fontSize:14,fontWeight:700,color:T.text,marginBottom:12}}>Dernières sorties</div>
          {SORTIES.map((s,i)=>(
            <div key={i} style={{background:T.surface,borderRadius:16,border:`1px solid ${T.border}`,padding:'12px 14px',marginBottom:8,boxShadow:'0 1px 4px rgba(0,0,0,.04)',cursor:'pointer'}}>
              <div style={{display:'flex',alignItems:'center',gap:12}}>
                <div style={{width:40,height:40,borderRadius:12,background:T.p10,display:'flex',alignItems:'center',justifyContent:'center',fontSize:18,flexShrink:0}}>{s.emoji}</div>
                <div style={{flex:1}}>
                  <div style={{display:'flex',alignItems:'center',gap:8}}>
                    <span style={{fontSize:13,fontWeight:600,color:T.text}}>{s.date}</span>
                    {s.new && <div style={{background:T.primary,borderRadius:20,padding:'1px 6px',fontSize:9,fontWeight:700,color:'white'}}>NOUVEAU</div>}
                  </div>
                  <div style={{fontSize:11,color:T.muted,marginTop:2}}>{s.rues} rues · {s.km}km · {s.dur}</div>
                </div>
                <div style={{textAlign:'right'}}>
                  {s.badges>0 && <div style={{fontSize:11,color:T.accent,fontWeight:600}}>+{s.badges} 🏆</div>}
                  <span style={{fontSize:18,color:T.muted}}>›</span>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
      <BottomNav active="profil" onChange={onNavigate} lang={lang}/>
    </div>
  );
};

Object.assign(window, {ParcoursScreen, SocialScreen, BadgesScreen, ProfilScreen});
