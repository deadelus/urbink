'use strict';
// ─── Mes Villes — écran dédié à la maîtrise par ville ─────────────────────────

const MASTERY_TIERS = [
  {key:'none',         label:'Non visitée',     min:0,    seal:false},
  {key:'visiteur',     label:'Visiteur',        min:0.001, seal:true},
  {key:'connaisseur',  label:'Connaisseur',     min:0.10, seal:true},
  {key:'memoire',      label:'Mémoire',         min:0.25, seal:true},
  {key:'gardien',      label:'Gardien',         min:0.50, seal:true},
  {key:'legende',      label:'Légende',         min:0.90, seal:true},
];

const tierFor = (mon, tot) => {
  const r = tot ? mon/tot : 0;
  let t = MASTERY_TIERS[0];
  for (const c of MASTERY_TIERS) if (r >= c.min) t = c;
  return t;
};
const nextTier = (mon, tot) => {
  const r = tot ? mon/tot : 0;
  return MASTERY_TIERS.find(c => c.min > r) || null;
};
const masteryTitle = (cityName, tier) => {
  if (!tier || !tier.seal) return null;
  const articles = {
    'Paris':'de Paris','Lisbonne':'de Lisbonne','Londres':'de Londres',
    'New York':'de New York','Tokyo':'de Tokyo','Rome':'de Rome',
    'Barcelone':'de Barcelone','Amsterdam':'d\u2019Amsterdam',
  };
  return `${tier.label} ${articles[cityName] || ''}`.trim();
};

// Mock progress data per city id (monuments découverts) — à brancher sur état réel
const MOCK_PROGRESS = {
  paris:    {monuments:42, lastVisit:'Aujourd\u2019hui'},
  lisbon:   {monuments:4,  lastVisit:'il y a 2 mois'},
  london:   {monuments:2,  lastVisit:'il y a 8 mois'},
};

// ─── Carte d'une ville explorée ──────────────────────────────────────────────
const ExploredCityCard = ({city, isActive, onSelect}) => {
  const {T} = window;
  const tier = tierFor(city.monuments, city.total);
  const next = nextTier(city.monuments, city.total);
  const title = masteryTitle(city.name, tier);
  const r = city.monuments / city.total;
  const nextNeeded = next ? Math.ceil(next.min * city.total) : city.total;
  const remaining = next ? Math.max(0, nextNeeded - city.monuments) : 0;
  const segPct = next ? Math.min(100, ((r - tier.min) / (next.min - tier.min)) * 100) : 100;

  return (
    <div onClick={onSelect} style={{
      background:T.surface,
      borderRadius:18,
      border:`1.5px solid ${isActive?city.color:T.border}`,
      padding:'16px',
      boxShadow: isActive ? `0 4px 16px ${city.color}22` : '0 1px 6px rgba(0,0,0,.04)',
      cursor:'pointer',position:'relative',overflow:'hidden',
      transition:'border-color .15s, box-shadow .15s',
    }}>
      <div style={{display:'flex',alignItems:'flex-start',gap:12,marginBottom:14}}>
        <div style={{
          width:46,height:46,borderRadius:13,flexShrink:0,
          background:`${city.color}18`,border:`1.5px solid ${city.color}30`,
          display:'flex',alignItems:'center',justifyContent:'center',fontSize:24,
        }}>{city.flag}</div>
        <div style={{flex:1,minWidth:0}}>
          <div style={{display:'flex',alignItems:'center',gap:8,flexWrap:'wrap'}}>
            <div style={{fontFamily:'Crimson Pro,serif',fontSize:22,fontWeight:600,color:T.text,letterSpacing:'-.3px',lineHeight:1}}>
              {city.name}
            </div>
            {isActive && (
              <span style={{fontSize:9,fontWeight:700,letterSpacing:1,color:city.color,textTransform:'uppercase',
                background:`${city.color}1A`,padding:'2px 7px',borderRadius:6}}>Active</span>
            )}
          </div>
          <div style={{fontSize:11,color:T.muted,marginTop:3}}>
            {city.country} · {city.lastVisit}
          </div>
          {title ? (
            <div style={{fontFamily:'Crimson Pro,serif',fontStyle:'italic',fontSize:13,color:'#8A6E2E',marginTop:6,letterSpacing:.2}}>
              « {title} »
            </div>
          ) : (
            <div style={{fontSize:11,color:T.muted,marginTop:6,fontStyle:'italic'}}>Aucun titre encore — découvrez 1 monument</div>
          )}
        </div>
        {/* Radio — switch active */}
        <div style={{
          width:22,height:22,borderRadius:'50%',flexShrink:0,
          border:`2px solid ${isActive?city.color:T.border}`,
          display:'flex',alignItems:'center',justifyContent:'center',
        }}>
          {isActive && <div style={{width:10,height:10,borderRadius:'50%',background:city.color}}/>}
        </div>
      </div>

      {/* Progression vers le prochain titre */}
      <div>
        <div style={{display:'flex',justifyContent:'space-between',alignItems:'baseline',marginBottom:6}}>
          <span style={{fontSize:11,color:T.muted}}>
            {next ? <>Vers <span style={{color:'#8A6E2E',fontWeight:600,fontFamily:'Crimson Pro,serif',fontStyle:'italic'}}>{next.label}</span></> : 'Maîtrise complète'}
          </span>
          <span style={{fontSize:11,fontWeight:600,color:T.text,fontVariantNumeric:'tabular-nums'}}>
            {city.monuments} <span style={{color:T.muted,fontWeight:400}}>/ {next ? nextNeeded : city.total}</span>
          </span>
        </div>
        <div style={{height:5,background:T.surfVar,borderRadius:3,overflow:'hidden'}}>
          <div style={{width:`${segPct}%`,height:'100%',
            background:'linear-gradient(90deg, #C9A24C, #E8C547)',borderRadius:3,
            boxShadow:'0 0 6px rgba(232,197,71,.4)'}}/>
        </div>
        {next && remaining > 0 && (
          <div style={{fontSize:10,color:T.muted,marginTop:6}}>
            Encore <span style={{color:T.text,fontWeight:600}}>{remaining}</span> monument{remaining>1?'s':''} pour le titre suivant
          </div>
        )}
      </div>
    </div>
  );
};

// ─── Carte d'une ville verrouillée ───────────────────────────────────────────
const LockedCityCard = ({city, onSelect, isActive}) => {
  const {T} = window;
  return (
    <div onClick={onSelect} style={{
      background:T.surface,borderRadius:14,
      border: isActive ? `1.5px solid ${city.color}` : `1px dashed ${T.border}`,
      padding:'12px 14px',
      display:'flex',alignItems:'center',gap:12,
      opacity: isActive ? 1 : .85,
      cursor:'pointer',transition:'all .15s',
    }}>
      <div style={{
        width:36,height:36,borderRadius:10,flexShrink:0,
        background:`${city.color}14`,
        display:'flex',alignItems:'center',justifyContent:'center',fontSize:18,
        filter: isActive ? 'none' : 'grayscale(.4)',
      }}>{city.flag}</div>
      <div style={{flex:1,minWidth:0}}>
        <div style={{display:'flex',alignItems:'center',gap:8}}>
          <div style={{fontFamily:'Crimson Pro,serif',fontSize:15,fontWeight:600,color:T.text,letterSpacing:'-.2px'}}>
            {city.name}
          </div>
          {isActive && (
            <span style={{fontSize:9,fontWeight:700,letterSpacing:1,color:city.color,textTransform:'uppercase',
              background:`${city.color}1A`,padding:'2px 7px',borderRadius:6}}>Active</span>
          )}
        </div>
        <div style={{fontSize:10,color:T.muted,marginTop:2}}>{city.country} · {city.total} monuments</div>
      </div>
      {isActive ? (
        <div style={{width:22,height:22,borderRadius:'50%',border:`2px solid ${city.color}`,display:'flex',alignItems:'center',justifyContent:'center',flexShrink:0}}>
          <div style={{width:10,height:10,borderRadius:'50%',background:city.color}}/>
        </div>
      ) : (
        <div style={{display:'flex',alignItems:'center',gap:5,padding:'5px 10px',
          background:T.surfVar,borderRadius:99,border:`1px solid ${T.border}`}}>
          <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke={T.muted} strokeWidth="2" strokeLinecap="round"><rect x="5" y="11" width="14" height="10" rx="2"/><path d="M8 11V7a4 4 0 018 0v4"/></svg>
          <span style={{fontSize:10,fontWeight:600,color:T.muted,letterSpacing:.3}}>EXPLORER</span>
        </div>
      )}
    </div>
  );
};

// ─── Écran principal — fusion Mes Villes + Changer de ville ──────────────────
const MyCitiesScreen = ({onBack, currentCity='paris', lang='fr', onSelectCity}) => {
  const {React, T, IC, StatusBar, DynamicIsland, CITIES} = window;
  const [search, setSearch] = React.useState('');

  // Build derived list from real CITIES, with mock progress
  const enriched = (CITIES || []).map(c => {
    const name = c.name?.[lang] || c.name?.fr || c.id;
    const country = c.country?.[lang] || c.country?.fr || '';
    const prog = MOCK_PROGRESS[c.id];
    const monuments = prog?.monuments ?? 0;
    const total = c.streets ? Math.round(c.streets/1000) : 100; // approx total monuments
    return {
      id: c.id, name, country, flag: c.flag, color: c.color || T.primary,
      monuments, total,
      lastVisit: prog?.lastVisit || (monuments>0 ? 'Récemment' : 'Jamais visitée'),
      explored: monuments > 0,
    };
  });

  const filtered = enriched.filter(c =>
    !search ||
    c.name.toLowerCase().includes(search.toLowerCase()) ||
    c.country.toLowerCase().includes(search.toLowerCase())
  );
  const exploredList = filtered.filter(c => c.explored);
  const lockedList = filtered.filter(c => !c.explored);

  const totalMonuments = exploredList.reduce((s,c)=>s+c.monuments,0);
  const totalSeals = exploredList.filter(c => tierFor(c.monuments,c.total).seal).length;

  const switchCity = (id) => {
    if (id === currentCity) return;
    onSelectCity?.(id);
    onBack?.();
  };

  return (
    <div style={{position:'absolute',inset:0,background:T.bg,fontFamily:'-apple-system,Inter,sans-serif',color:T.text,overflowY:'auto'}}>
      <DynamicIsland/>
      <StatusBar/>

      {/* Header bar */}
      <div style={{position:'sticky',top:0,zIndex:5,background:T.bg,padding:'8px 16px 12px',borderBottom:`1px solid ${T.border}`}}>
        <div style={{display:'flex',alignItems:'center',gap:8,marginTop:48}}>
          <div onClick={onBack} style={{width:36,height:36,borderRadius:10,background:T.surface,border:`1px solid ${T.border}`,display:'flex',alignItems:'center',justifyContent:'center',cursor:'pointer'}}>
            <svg width="18" height="18" fill="none" viewBox="0 0 24 24"><path d="M15 18l-6-6 6-6" stroke={T.text} strokeWidth="2" strokeLinecap="round"/></svg>
          </div>
          <div style={{flex:1}}>
            <div style={{fontFamily:'Crimson Pro,serif',fontSize:22,fontWeight:700,color:T.text,letterSpacing:'-.4px',lineHeight:1}}>Mes villes</div>
            <div style={{fontSize:11,color:T.muted,marginTop:3}}>{exploredList.length} explorées · {totalMonuments} monuments · {totalSeals} sceau{totalSeals>1?'x':''}</div>
          </div>
        </div>

        {/* Search */}
        <div style={{marginTop:12,height:40,background:T.surface,borderRadius:12,border:`1px solid ${T.border}`,display:'flex',alignItems:'center',padding:'0 12px',gap:10}}>
          <IC.search c={T.muted} s={15}/>
          <input
            value={search}
            onChange={e=>setSearch(e.target.value)}
            placeholder={lang==='ja'?'都市を検索…':lang==='es'?'Buscar ciudad…':lang==='pt'?'Buscar cidade…':lang==='en'?'Search city…':'Rechercher une ville…'}
            style={{flex:1,border:'none',outline:'none',fontSize:13,color:T.text,background:'transparent',fontFamily:'inherit'}}
          />
          {search && <span onClick={()=>setSearch('')} style={{fontSize:14,color:T.muted,cursor:'pointer'}}>✕</span>}
        </div>
      </div>

      <div style={{padding:'16px 16px 32px'}}>
        {exploredList.length > 0 && (
          <>
            <div style={{display:'flex',alignItems:'baseline',gap:8,marginBottom:10}}>
              <div style={{fontSize:11,fontWeight:700,letterSpacing:1.5,color:T.muted,textTransform:'uppercase'}}>Explorées · maîtrise</div>
              <div style={{flex:1,height:1,background:T.border}}/>
            </div>
            <div style={{display:'flex',flexDirection:'column',gap:10}}>
              {exploredList.map(c => (
                <ExploredCityCard key={c.id} city={c} isActive={c.id===currentCity} onSelect={()=>switchCity(c.id)}/>
              ))}
            </div>

            <div style={{
              marginTop:14,padding:'10px 14px',background:T.surface,
              border:`1px solid ${T.border}`,borderRadius:12,
              display:'flex',gap:10,alignItems:'flex-start',
            }}>
              <div style={{width:18,height:18,borderRadius:5,flexShrink:0,
                background:'linear-gradient(135deg, #E8C547, #C9A24C)',
                display:'flex',alignItems:'center',justifyContent:'center'}}>
                <svg width="9" height="9" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2.5" strokeLinecap="round"><path d="M5 13l4 4L19 7"/></svg>
              </div>
              <div style={{flex:1,fontSize:10.5,color:T.muted,lineHeight:1.45}}>
                Chaque ville a ses titres de maîtrise (Visiteur → Légende), distincts du <span style={{color:T.text,fontWeight:600}}>rang d'explorateur global</span>.
              </div>
            </div>
          </>
        )}

        {lockedList.length > 0 && (
          <>
            <div style={{display:'flex',alignItems:'baseline',gap:8,marginTop:exploredList.length?22:0,marginBottom:10}}>
              <div style={{fontSize:11,fontWeight:700,letterSpacing:1.5,color:T.muted,textTransform:'uppercase'}}>À découvrir</div>
              <div style={{flex:1,height:1,background:T.border}}/>
            </div>
            <div style={{display:'flex',flexDirection:'column',gap:8}}>
              {lockedList.map(c => (
                <LockedCityCard key={c.id} city={c} isActive={c.id===currentCity} onSelect={()=>switchCity(c.id)}/>
              ))}
            </div>
            <div style={{textAlign:'center',marginTop:14,fontSize:10,color:T.muted,fontFamily:'Crimson Pro,serif',fontStyle:'italic',letterSpacing:.3}}>
              Les sceaux de maîtrise se débloquent en visitant la ville et y découvrant des monuments.
            </div>
          </>
        )}

        {filtered.length === 0 && (
          <div style={{textAlign:'center',padding:'40px 16px',color:T.muted}}>
            <div style={{fontSize:32,marginBottom:8}}>🔍</div>
            <div style={{fontSize:13,fontWeight:500}}>Aucune ville trouvée</div>
          </div>
        )}
      </div>
    </div>
  );
};

Object.assign(window, {MyCitiesScreen, MASTERY_TIERS, tierFor, nextTier, masteryTitle});
