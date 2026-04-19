'use strict';
// ─── Design Tokens ────────────────────────────────────────────────────────────
const T = {
  primary:'#256F4C', primaryD:'#1a5438',
  p10:'rgba(37,111,76,.10)', p06:'rgba(37,111,76,.06)', p18:'rgba(37,111,76,.18)',
  accent:'#F59E0B', a10:'rgba(245,158,11,.10)', a22:'rgba(245,158,11,.22)',
  bg:'#F8FAFC', surface:'#FFFFFF', surfVar:'#F1F5F9',
  text:'#0F172A', muted:'#64748B', border:'#E2E8F0',
  pill:'#CBD5E1', red:'#DC2626',
};

// ─── Icons ────────────────────────────────────────────────────────────────────
const IC = {
  map:({c='#64748B',s=22})=><svg width={s} height={s} fill="none" viewBox="0 0 24 24"><path d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l4.553 2.276A1 1 0 0021 18.382V7.618a1 1 0 00-1.447-.894L15 9m0 8V9m0 0L9 7" stroke={c} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"/></svg>,
  compass:({c='#64748B',s=22})=><svg width={s} height={s} fill="none" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10" stroke={c} strokeWidth="1.8"/><path d="M16.24 7.76l-2.12 6.36-6.36 2.12 2.12-6.36 6.36-2.12z" stroke={c} strokeWidth="1.8" strokeLinejoin="round"/></svg>,
  users:({c='#64748B',s=22})=><svg width={s} height={s} fill="none" viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" stroke={c} strokeWidth="1.8"/><circle cx="9" cy="7" r="4" stroke={c} strokeWidth="1.8"/><path d="M23 21v-2a4 4 0 0 0-3-3.87M16 3.13a4 4 0 0 1 0 7.75" stroke={c} strokeWidth="1.8"/></svg>,
  star:({c='#64748B',s=22})=><svg width={s} height={s} fill="none" viewBox="0 0 24 24"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z" stroke={c} strokeWidth="1.8" strokeLinejoin="round"/></svg>,
  user:({c='#64748B',s=22})=><svg width={s} height={s} fill="none" viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" stroke={c} strokeWidth="1.8"/><circle cx="12" cy="7" r="4" stroke={c} strokeWidth="1.8"/></svg>,
  search:({c='#64748B',s=18})=><svg width={s} height={s} fill="none" viewBox="0 0 24 24"><path d="M21 21l-4.35-4.35M17 11A6 6 0 1 1 5 11a6 6 0 0 1 12 0z" stroke={c} strokeWidth="2" strokeLinecap="round"/></svg>,
  mic:({c='#64748B',s=18})=><svg width={s} height={s} fill="none" viewBox="0 0 24 24"><path d="M12 2a3 3 0 0 1 3 3v7a3 3 0 0 1-6 0V5a3 3 0 0 1 3-3z" stroke={c} strokeWidth="1.8"/><path d="M19 10v1a7 7 0 0 1-14 0v-1" stroke={c} strokeWidth="1.8" strokeLinecap="round"/></svg>,
  chevL:({c='#0F172A',s=18})=><svg width={s} height={s} fill="none" viewBox="0 0 24 24"><path d="M15 19l-7-7 7-7" stroke={c} strokeWidth="2" strokeLinecap="round"/></svg>,
  chevUp:({c='#64748B',s=16})=><svg width={s} height={s} fill="none" viewBox="0 0 24 24"><path d="M5 15l7-7 7 7" stroke={c} strokeWidth="2" strokeLinecap="round"/></svg>,
  chevDn:({c='#64748B',s=16})=><svg width={s} height={s} fill="none" viewBox="0 0 24 24"><path d="M19 9l-7 7-7-7" stroke={c} strokeWidth="2" strokeLinecap="round"/></svg>,
  plus:({c='#256F4C',s=18})=><svg width={s} height={s} fill="none" viewBox="0 0 24 24"><path d="M12 5v14m-7-7h14" stroke={c} strokeWidth="2" strokeLinecap="round"/></svg>,
  gps:({c='#256F4C',s=14})=><svg width={s} height={s} viewBox="0 0 24 24"><circle cx="12" cy="12" r="3" fill={c}/><path d="M12 2v3m0 14v3M2 12h3m14 0h3" stroke={c} strokeWidth="2" strokeLinecap="round"/></svg>,
  stop:()=><svg width="22" height="22" fill="white" viewBox="0 0 24 24"><rect x="5" y="5" width="14" height="14" rx="3"/></svg>,
  play:()=><svg width="18" height="18" fill="white" viewBox="0 0 24 24"><path d="M5 3l14 9-14 9V3z"/></svg>,
  edit:({c='#64748B',s=16})=><svg width={s} height={s} fill="none" viewBox="0 0 24 24"><path d="M17 3a2.828 2.828 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5L17 3z" stroke={c} strokeWidth="1.8"/></svg>,
  filter:({c='#64748B',s=18})=><svg width={s} height={s} fill="none" viewBox="0 0 24 24"><path d="M22 3H2l8 9.46V19l4 2v-8.54L22 3z" stroke={c} strokeWidth="1.8" strokeLinejoin="round"/></svg>,
  fire:({c='#F59E0B',s=16})=><svg width={s} height={s} viewBox="0 0 24 24" fill={c}><path d="M12 2C8 8 4 10 4 14a8 8 0 0 0 16 0c0-5-4-8-8-12zm0 18a5 5 0 0 1-5-5c0-3 2-5 5-8 3 3 5 5 5 8a5 5 0 0 1-5 5z"/></svg>,
  share:({c='#64748B',s=18})=><svg width={s} height={s} fill="none" viewBox="0 0 24 24"><path d="M4 12v8a2 2 0 002 2h12a2 2 0 002-2v-8M16 6l-4-4-4 4M12 2v13" stroke={c} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"/></svg>,
  lock:({c='#64748B',s=16})=><svg width={s} height={s} fill="none" viewBox="0 0 24 24"><rect x="3" y="11" width="18" height="11" rx="2" stroke={c} strokeWidth="1.8"/><path d="M7 11V7a5 5 0 0 1 10 0v4" stroke={c} strokeWidth="1.8"/></svg>,
  check:({c='#256F4C',s=16})=><svg width={s} height={s} fill="none" viewBox="0 0 24 24"><path d="M20 6L9 17l-5-5" stroke={c} strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"/></svg>,
  trophy:({c='#F59E0B',s=20})=><svg width={s} height={s} fill="none" viewBox="0 0 24 24"><path d="M6 9H4a2 2 0 01-2-2V5h4M18 9h2a2 2 0 002-2V5h-4M6 9a6 6 0 0012 0M12 15v4m-4 2h8" stroke={c} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"/></svg>,
  camera:({c='#64748B',s=18})=><svg width={s} height={s} fill="none" viewBox="0 0 24 24"><path d="M23 19a2 2 0 01-2 2H3a2 2 0 01-2-2V8a2 2 0 012-2h4l2-3h6l2 3h4a2 2 0 012 2z" stroke={c} strokeWidth="1.8"/><circle cx="12" cy="13" r="4" stroke={c} strokeWidth="1.8"/></svg>,
};

// ─── Status Bar ───────────────────────────────────────────────────────────────
const StatusBar = ({light=false}) => {
  const c = light ? '#fff' : T.text;
  return (
    <div style={{position:'absolute',top:0,left:0,right:0,height:50,display:'flex',alignItems:'flex-end',padding:'0 28px 8px',justifyContent:'space-between',zIndex:100}}>
      <span style={{fontSize:15,fontWeight:600,color:c}}>9:41</span>
      <div style={{display:'flex',alignItems:'center',gap:6}}>
        <svg width="16" height="12" viewBox="0 0 16 12" fill={c}><rect x="0" y="3" width="3" height="9" rx="1"/><rect x="4" y="2" width="3" height="10" rx="1"/><rect x="8" y="0" width="3" height="12" rx="1"/><rect x="12" y="0" width="4" height="12" rx="1" opacity=".3"/></svg>
        <svg width="16" height="12" viewBox="0 0 16 12" fill="none"><path d="M8 2C5.2 2 2.8 3.3 1.2 5.3L0 4C2 1.5 4.8 0 8 0s6 1.5 8 4l-1.2 1.3C13.2 3.3 10.8 2 8 2z" fill={c} opacity=".3"/><path d="M8 6c-1.7 0-3.2.8-4.2 2L2.5 6.7C3.9 5 5.8 4 8 4s4.1 1 5.5 2.7L12.2 8C11.2 6.8 9.7 6 8 6z" fill={c} opacity=".6"/><circle cx="8" cy="11" r="1.5" fill={c}/></svg>
        <svg width="25" height="12" viewBox="0 0 25 12" fill="none"><rect x="0" y="1" width="21" height="10" rx="2" stroke={c} strokeWidth="1.5"/><rect x="1.5" y="2.5" width="16" height="7" rx="1" fill={c}/><path d="M23 4.5v3c.8-.3 1.3-.9 1.3-1.5S23.8 4.8 23 4.5z" fill={c} opacity=".4"/></svg>
      </div>
    </div>
  );
};

// ─── Dynamic Island ───────────────────────────────────────────────────────────
const DynamicIsland = () => (
  <div style={{position:'absolute',top:10,left:'50%',transform:'translateX(-50%)',width:120,height:34,background:'#000',borderRadius:20,zIndex:200}}/>
);

// ─── Bottom Nav ───────────────────────────────────────────────────────────────
const NAV_TABS=[
  {id:'carte',   key:'nav_carte',   I:IC.map},
  {id:'parcours',key:'nav_parcours',I:IC.compass},
  {id:'social',  key:'nav_social',  I:IC.users},
  {id:'badges',  key:'nav_badges',  I:IC.star},
  {id:'profil',  key:'nav_profil',  I:IC.user},
];

const BottomNav = ({active, onChange, lang='fr'}) => {
  const tFn = window.t || ((l,k)=>k);
  return (
    <div style={{position:'absolute',bottom:0,left:0,right:0,height:74,background:T.surface,borderTop:`1px solid ${T.border}`,display:'flex',alignItems:'flex-start',paddingTop:10,zIndex:50}}>
      {NAV_TABS.map(({id,key,I})=>{
        const on=active===id; const c=on?T.primary:T.muted;
        const label = tFn(lang, key);
        return <div key={id} onClick={()=>onChange(id)} style={{flex:1,display:'flex',flexDirection:'column',alignItems:'center',gap:4,cursor:'pointer'}}>
          <div style={{width:24,height:24,display:'flex',alignItems:'center',justifyContent:'center'}}><I c={c} s={22}/></div>
          <span style={{fontSize:10,fontWeight:on?600:500,color:c}}>{label}</span>
        </div>;
      })}
    </div>
  );
};

// ─── Search Bar ───────────────────────────────────────────────────────────────
const SearchBar = ({onClick}) => (
  <div onClick={onClick} style={{height:48,background:T.surface,borderRadius:16,boxShadow:'0 4px 16px rgba(0,0,0,.10)',display:'flex',alignItems:'center',padding:'0 14px',gap:10,cursor:'pointer'}}>
    <IC.search c={T.muted}/>
    <span style={{fontSize:14,color:T.muted,flex:1}}>Rechercher un lieu…</span>
    <IC.mic c={T.muted}/>
  </div>
);

// ─── Chip ─────────────────────────────────────────────────────────────────────
const Chip = ({label,active,onClick}) => (
  <div onClick={onClick} style={{display:'flex',alignItems:'center',gap:5,padding:'6px 12px',borderRadius:10,fontSize:12,fontWeight:500,cursor:'pointer',flexShrink:0,whiteSpace:'nowrap',background:active?T.primary:T.surface,color:active?'#fff':T.text,border:active?`1px solid ${T.primary}`:`1px solid ${T.border}`}}>{label}</div>
);

// ─── Drag Handle ──────────────────────────────────────────────────────────────
const DragHandle = () => <div style={{width:40,height:4,background:T.pill,borderRadius:2,margin:'10px auto 0'}}/>;

// ─── Zones Pill ───────────────────────────────────────────────────────────────
const ZonesPill = ({active,onToggle}) => (
  <div onClick={onToggle} style={{display:'inline-flex',alignItems:'center',gap:6,background:T.surface,borderRadius:20,padding:'8px 14px',boxShadow:'0 2px 12px rgba(0,0,0,.12)',cursor:'pointer',fontSize:12,fontWeight:600,color:T.text}}>
    <div style={{width:8,height:8,background:active?T.primary:T.muted,borderRadius:'50%'}}/>
    Zones {active?'ON':'OFF'}
  </div>
);

// ─── Session Bar ──────────────────────────────────────────────────────────────
const SessionBar = ({km,streets,secs}) => {
  const m=Math.floor(secs/60), s=String(secs%60).padStart(2,'0');
  return (
    <div style={{position:'absolute',top:50,left:0,right:0,height:44,background:T.primary,display:'flex',alignItems:'center',padding:'0 16px',gap:8,zIndex:80}}>
      <div style={{width:8,height:8,background:'#4ADE80',borderRadius:'50%'}}/>
      <span style={{fontSize:13,fontWeight:600,color:'#fff',flex:1}}>{km.toFixed(1)} km · {streets} rues · {m}:{s}</span>
      <IC.camera c="white"/>
    </div>
  );
};

// ─── Buttons ──────────────────────────────────────────────────────────────────
const PrimaryBtn = ({label,color='green',onClick,disabled,small}) => {
  const bg=color==='green'?T.primary:T.accent;
  return <button onClick={onClick} disabled={disabled} style={{display:'flex',alignItems:'center',justifyContent:'center',gap:8,height:small?44:52,borderRadius:16,fontSize:small?14:15,fontWeight:600,color:'#fff',border:'none',width:'100%',cursor:'pointer',background:disabled?T.border:bg,boxShadow:disabled?'none':color==='green'?'0 4px 14px rgba(37,111,76,.35)':'0 4px 14px rgba(245,158,11,.35)',transition:'opacity .15s'}}>{label}</button>;
};

const OutlineBtn = ({label,onClick,flex}) => (
  <button onClick={onClick} style={{display:'flex',alignItems:'center',justifyContent:'center',gap:6,height:52,borderRadius:16,fontSize:14,fontWeight:600,color:T.text,background:T.surface,border:`1.5px solid ${T.border}`,cursor:'pointer',flex:flex||undefined,padding:'0 16px'}}>{label}</button>
);

const TextBtn = ({label,color,onClick}) => (
  <div onClick={onClick} style={{display:'flex',alignItems:'center',gap:4,fontSize:14,fontWeight:500,color:color||T.text,padding:'8px 12px',cursor:'pointer'}}>{label}</div>
);

// ─── Mode Card ────────────────────────────────────────────────────────────────
const ModeCard = ({icon,title,sub,selected,onClick}) => (
  <div onClick={onClick} style={{flex:1,borderRadius:20,border:`1.5px solid ${selected?T.primary:T.border}`,padding:16,cursor:'pointer',background:selected?T.p06:T.surface}}>
    <div style={{width:36,height:36,borderRadius:10,display:'flex',alignItems:'center',justifyContent:'center',marginBottom:8,fontSize:18,background:selected?T.p10:T.surfVar}}>{icon}</div>
    <div style={{fontSize:13,fontWeight:700,color:T.text,marginBottom:2}}>{title}</div>
    <div style={{fontSize:11,color:selected?T.primary:T.muted}}>{sub}</div>
  </div>
);

// ─── POI Tile ─────────────────────────────────────────────────────────────────
const PoiTile = ({num,icon,name,sub,color='green',onDelete}) => {
  const bg=color==='green'?T.primary:T.accent;
  return (
    <div style={{display:'flex',alignItems:'center',gap:8,background:T.surface,borderRadius:16,border:`1px solid ${T.border}`,padding:'10px 12px',marginBottom:8,boxShadow:'0 1px 6px rgba(0,0,0,.04)'}}>
      <div style={{width:26,height:26,borderRadius:7,background:bg,display:'flex',alignItems:'center',justifyContent:'center',fontSize:12,fontWeight:700,color:'#fff',flexShrink:0}}>{num}</div>
      <div style={{width:36,height:36,borderRadius:10,display:'flex',alignItems:'center',justifyContent:'center',fontSize:16,flexShrink:0,background:color==='green'?T.p10:T.a10}}>{icon}</div>
      <div style={{flex:1,minWidth:0}}>
        <div style={{fontSize:13,fontWeight:600,color:T.text,overflow:'hidden',textOverflow:'ellipsis',whiteSpace:'nowrap'}}>{name}</div>
        <div style={{fontSize:11,color:T.muted}}>{sub}</div>
      </div>
      {onDelete && <span onClick={onDelete} style={{fontSize:18,color:T.red,cursor:'pointer',opacity:.8}}>−</span>}
      <span style={{fontSize:18,color:T.muted,cursor:'grab'}}>⠿</span>
    </div>
  );
};

// ─── Parcours Card ────────────────────────────────────────────────────────────
const ParcoursCard = ({emoji,name,meta,onClick}) => (
  <div onClick={onClick} style={{display:'flex',alignItems:'center',gap:16,background:T.surface,borderRadius:20,border:`1px solid ${T.border}`,padding:'12px 16px',boxShadow:'0 1px 6px rgba(0,0,0,.04)',marginBottom:8,cursor:'pointer'}}>
    <div style={{width:44,height:44,borderRadius:12,background:T.p10,display:'flex',alignItems:'center',justifyContent:'center',fontSize:22,flexShrink:0}}>{emoji}</div>
    <div style={{flex:1}}><div style={{fontSize:13,fontWeight:600,color:T.text}}>{name}</div><div style={{fontSize:11,color:T.muted,marginTop:2}}>{meta}</div></div>
    <span style={{fontSize:18,color:T.muted}}>›</span>
  </div>
);

// ─── Nav Option Card ──────────────────────────────────────────────────────────
const NavOptionCard = ({icon,title,sub,selected,onClick}) => (
  <div onClick={onClick} style={{display:'flex',alignItems:'center',gap:16,borderRadius:20,border:`1.5px solid ${selected?T.primary:T.border}`,padding:'12px 16px',background:selected?T.p06:T.surface,marginBottom:8,cursor:'pointer'}}>
    <div style={{width:40,height:40,borderRadius:12,display:'flex',alignItems:'center',justifyContent:'center',fontSize:18,flexShrink:0,background:selected?T.p10:T.surfVar}}>{icon}</div>
    <div style={{flex:1}}><div style={{fontSize:13,fontWeight:600,color:T.text}}>{title}</div><div style={{fontSize:11,color:T.muted}}>{sub}</div></div>
    <span style={{fontSize:20,color:selected?T.primary:T.border}}>{selected?'●':'○'}</span>
  </div>
);

// ─── Stats Row ────────────────────────────────────────────────────────────────
const StatsRow = ({items,color='green'}) => {
  const bg=color==='green'?T.p06:T.a10, bord=color==='green'?T.p18:T.a22, c=color==='green'?T.primary:T.accent;
  return <div style={{display:'flex',alignItems:'center',justifyContent:'space-around',margin:'0 16px',borderRadius:10,padding:'10px 16px',background:bg,border:`1px solid ${bord}`}}>
    {items.map((it,i)=>[
      i>0 && <div key={'d'+i} style={{width:1,height:20,background:bord}}/>,
      <div key={i} style={{display:'flex',alignItems:'center',gap:5}}><span style={{fontSize:13}}>{it.icon}</span><span style={{fontSize:12,fontWeight:600,color:c}}>{it.val}</span></div>
    ])}
  </div>;
};

// ─── City Badge (reusable header pill) ───────────────────────────────────────
const CityBadge = ({cityData, lang, onChangeCity, style}) => {
  if (!cityData) return null;
  const name = cityData.name?.[lang] || cityData.name?.fr || 'Paris';
  return (
    <div onClick={onChangeCity} style={{display:'inline-flex',alignItems:'center',gap:6,background:'rgba(255,255,255,.15)',borderRadius:20,padding:'5px 10px 5px 8px',cursor:onChangeCity?'pointer':'default',border:'1px solid rgba(255,255,255,.25)',...style}}>
      <span style={{fontSize:14}}>{cityData.flag}</span>
      <span style={{fontSize:12,fontWeight:600,color:'white'}}>{name}</span>
      {onChangeCity && <svg width="10" height="10" fill="none" viewBox="0 0 24 24"><path d="M19 9l-7 7-7-7" stroke="white" strokeWidth="2.5" strokeLinecap="round"/></svg>}
    </div>
  );
};

// ─── City Header Bar (for white-bg screens) ────────────────────────────────
const CityHeaderBar = ({cityData, lang, onChangeCity}) => {
  if (!cityData) return null;
  const name = cityData.name?.[lang] || cityData.name?.fr || 'Paris';
  return (
    <div onClick={onChangeCity} style={{display:'inline-flex',alignItems:'center',gap:6,background:cityData.color+'18',border:`1px solid ${cityData.color}30`,borderRadius:20,padding:'5px 12px 5px 8px',cursor:onChangeCity?'pointer':'default'}}>
      <span style={{fontSize:14}}>{cityData.flag}</span>
      <span style={{fontSize:12,fontWeight:600,color:cityData.color||'#256F4C'}}>{name}</span>
      {onChangeCity && <svg width="10" height="10" fill="none" viewBox="0 0 24 24"><path d="M19 9l-7 7-7-7" stroke={cityData.color||'#256F4C'} strokeWidth="2.5" strokeLinecap="round"/></svg>}
    </div>
  );
};

Object.assign(window,{T,IC,StatusBar,DynamicIsland,BottomNav,SearchBar,Chip,DragHandle,ZonesPill,SessionBar,PrimaryBtn,OutlineBtn,TextBtn,ModeCard,PoiTile,ParcoursCard,NavOptionCard,StatsRow,NAV_TABS,CityBadge,CityHeaderBar});
