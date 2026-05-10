'use strict';
// ─── Composants UI dark mode pour les rangs ──────────────────────────────────

const DARK = {
  bg: '#0F0F0F',
  surface: '#1C1C1E',
  surface2: '#242427',
  border: '#2A2A2D',
  text: '#F2F2F2',
  textDim: '#9A9A9F',
  textMute: '#6E6E73',
  green: '#4ADE80',
  greenDim: 'rgba(74,222,128,.15)',
};

// ═══ Status Bar (iOS dark) ══════════════════════════════════════════════════
const DarkStatusBar = () => (
  <div style={{position:'absolute',top:0,left:0,right:0,height:54,display:'flex',alignItems:'flex-end',padding:'0 28px 10px',justifyContent:'space-between',zIndex:100,pointerEvents:'none'}}>
    <span style={{fontSize:15,fontWeight:600,color:'#fff',fontFamily:'-apple-system,SF Pro Text,Inter,sans-serif'}}>9:41</span>
    <div style={{display:'flex',alignItems:'center',gap:6}}>
      <svg width="16" height="11" viewBox="0 0 16 12" fill="#fff"><rect x="0" y="3" width="3" height="9" rx="1"/><rect x="4" y="2" width="3" height="10" rx="1"/><rect x="8" y="0" width="3" height="12" rx="1"/><rect x="12" y="0" width="3" height="12" rx="1"/></svg>
      <svg width="16" height="11" viewBox="0 0 16 12" fill="#fff"><path d="M8 2C5.2 2 2.8 3.3 1.2 5.3L0 4C2 1.5 4.8 0 8 0s6 1.5 8 4l-1.2 1.3C13.2 3.3 10.8 2 8 2z"/><path d="M8 6c-1.7 0-3.2.8-4.2 2L2.5 6.7C3.9 5 5.8 4 8 4s4.1 1 5.5 2.7L12.2 8C11.2 6.8 9.7 6 8 6z"/><circle cx="8" cy="11" r="1.5"/></svg>
      <svg width="25" height="11" viewBox="0 0 25 12" fill="none"><rect x="0" y="1" width="21" height="10" rx="2.5" stroke="#fff" strokeWidth="1" opacity=".5"/><rect x="2" y="3" width="17" height="6" rx="1" fill="#fff"/><rect x="22" y="4" width="1.5" height="4" rx=".5" fill="#fff" opacity=".5"/></svg>
    </div>
  </div>
);

const DynamicIslandDark = () => (
  <div style={{position:'absolute',top:11,left:'50%',transform:'translateX(-50%)',width:122,height:36,background:'#000',borderRadius:20,zIndex:200}}/>
);

// ═══ Hexagonal city seal — médaille patrimoniale ═════════════════════════════
const CitySeal = ({cityName='Paris', monuments=12, total=156, size=120, locked=false}) => {
  const pct = monuments / total;
  return (
    <svg viewBox="0 0 200 220" width={size} height={size*220/200} style={{display:'block'}}>
      <defs>
        <linearGradient id={`seal-metal-${cityName}`} x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stopColor={locked?"#3A3A3D":"#C9A656"}/>
          <stop offset="50%" stopColor={locked?"#26262A":"#8A6E2E"}/>
          <stop offset="100%" stopColor={locked?"#1A1A1D":"#5A4818"}/>
        </linearGradient>
        <linearGradient id={`seal-inner-${cityName}`} x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stopColor={locked?"#1A1A1D":"#3A2D10"}/>
          <stop offset="100%" stopColor="#0A0A0A"/>
        </linearGradient>
      </defs>
      <ellipse cx="100" cy="200" rx="42" ry="5" fill="#000" opacity=".5"/>
      {/* Hexagonal écusson — pointe vers le bas */}
      <polygon points="100,20 168,55 168,140 100,190 32,140 32,55"
               fill={`url(#seal-metal-${cityName})`}/>
      {/* Bordure intérieure gravée */}
      <polygon points="100,32 158,62 158,134 100,178 42,134 42,62"
               fill={`url(#seal-inner-${cityName})`}
               stroke={locked?"#3A3A3D":"#C9A656"} strokeWidth="1"/>
      {/* Anneau intérieur */}
      <polygon points="100,42 148,68 148,128 100,168 52,128 52,68"
               fill="none" stroke={locked?"#26262A":"#8A6E2E"} strokeWidth=".7" opacity=".7"/>
      {/* Monument stylisé centré — silhouette tour */}
      <g fill={locked?"#3A3A3D":"#D4B566"} opacity={locked?.5:.95}>
        {/* Tour Eiffel abstraite si Paris, sinon arc générique */}
        {cityName==='Paris' ? (
          <>
            <polygon points="92,72 108,72 102,80 98,80"/>
            <rect x="98" y="80" width="4" height="8"/>
            <polygon points="88,90 112,90 108,108 92,108"/>
            <rect x="91" y="108" width="18" height="3"/>
            <polygon points="84,114 116,114 108,140 92,140"/>
            <rect x="80" y="140" width="40" height="3"/>
          </>
        ) : (
          <>
            <path d="M 80,140 L 80,100 Q 80,80 100,80 Q 120,80 120,100 L 120,140 Z" stroke={locked?"#3A3A3D":"#D4B566"} strokeWidth="1" fill="none"/>
            <rect x="98" y="70" width="4" height="12"/>
          </>
        )}
      </g>
      {/* Couronne supérieure — laurier minimaliste */}
      <g fill={locked?"#3A3A3D":"#C9A656"} opacity=".75">
        <circle cx="78" cy="55" r="2"/>
        <circle cx="100" cy="50" r="2.5"/>
        <circle cx="122" cy="55" r="2"/>
      </g>
      {/* Nom de ville gravé en bas */}
      <text x="100" y="158" textAnchor="middle" fontFamily="Crimson Pro,serif" fontSize="14" fontWeight="700"
            fill={locked?"#5A5A5F":"#E8D49A"} letterSpacing="2">{cityName.toUpperCase()}</text>
      {/* XP / monuments découverts */}
      <text x="100" y="172" textAnchor="middle" fontFamily="Inter,sans-serif" fontSize="8"
            fill={locked?"#3A3A3D":"#8A6E2E"} letterSpacing="1.5">
        {locked ? 'VERROUILLÉ' : `${monuments}/${total}`}
      </text>
      {/* Reflet métal */}
      {!locked && <polygon points="100,20 168,55 130,55 100,38" fill="#fff" opacity=".15"/>}
    </svg>
  );
};

// ═══ Profile rank card — Variante A: emblème dominant ════════════════════════
const RankCardA = ({rankIdx, xp, gemStyle='realistic'}) => {
  const meta = GEM_DATA[rankIdx];
  const next = GEM_DATA[rankIdx+1];
  const pct = next ? Math.min(100, ((xp-meta.xp)/(next.xp-meta.xp))*100) : 100;
  return (
    <div style={{background:DARK.surface,borderRadius:20,padding:'24px 20px',border:`1px solid ${DARK.border}`,position:'relative',overflow:'hidden'}}>
      {/* Halo lumineux teinté pierre */}
      <div style={{position:'absolute',top:-40,right:-40,width:200,height:200,background:`radial-gradient(circle, ${meta.halo}22 0%, transparent 70%)`,pointerEvents:'none'}}/>
      <div style={{display:'flex',alignItems:'center',gap:18,position:'relative'}}>
        <Gem id={meta.id} size={84} style={gemStyle}/>
        <div style={{flex:1,minWidth:0}}>
          <div style={{fontSize:10,fontWeight:600,letterSpacing:2,color:DARK.textMute,textTransform:'uppercase',marginBottom:4}}>Rang d'explorateur</div>
          <div style={{fontFamily:'Crimson Pro,serif',fontSize:28,fontWeight:600,color:DARK.text,lineHeight:1,letterSpacing:'-.5px'}}>{meta.name}</div>
          <div style={{fontSize:12,color:DARK.textDim,marginTop:6}}>{xp.toLocaleString('fr-FR')} monuments découverts</div>
        </div>
      </div>
      {/* Progress vers prochain rang */}
      {next && (
        <div style={{marginTop:18,position:'relative'}}>
          <div style={{display:'flex',justifyContent:'space-between',alignItems:'baseline',marginBottom:8}}>
            <span style={{fontSize:11,color:DARK.textDim}}>Vers {next.name}</span>
            <span style={{fontSize:11,fontWeight:600,color:DARK.text,fontVariantNumeric:'tabular-nums'}}>{xp - meta.xp} <span style={{color:DARK.textMute,fontWeight:400}}>/ {next.xp - meta.xp}</span></span>
          </div>
          <div style={{height:5,background:'#0A0A0A',borderRadius:3,overflow:'hidden',position:'relative'}}>
            <div style={{width:`${pct}%`,height:'100%',background:`linear-gradient(90deg, ${meta.halo}, ${next.halo})`,borderRadius:3,boxShadow:`0 0 8px ${meta.halo}66`}}/>
          </div>
        </div>
      )}
    </div>
  );
};

// ═══ Profile rank card — Variante B: emblème centré, plus cérémonial ═══════════
const RankCardB = ({rankIdx, xp, gemStyle='realistic'}) => {
  const meta = GEM_DATA[rankIdx];
  const next = GEM_DATA[rankIdx+1];
  const pct = next ? Math.min(100, ((xp-meta.xp)/(next.xp-meta.xp))*100) : 100;
  return (
    <div style={{background:DARK.surface,borderRadius:20,padding:'28px 20px 22px',border:`1px solid ${DARK.border}`,position:'relative',overflow:'hidden',textAlign:'center'}}>
      <div style={{position:'absolute',inset:0,background:`radial-gradient(ellipse at 50% 30%, ${meta.halo}1A 0%, transparent 60%)`,pointerEvents:'none'}}/>
      <div style={{position:'relative'}}>
        <div style={{fontSize:10,fontWeight:600,letterSpacing:3,color:DARK.textMute,textTransform:'uppercase'}}>Rang d'explorateur</div>
        <div style={{display:'flex',justifyContent:'center',margin:'10px 0 8px'}}>
          <Gem id={meta.id} size={110} style={gemStyle}/>
        </div>
        <div style={{fontFamily:'Crimson Pro,serif',fontSize:30,fontWeight:600,color:DARK.text,lineHeight:1,letterSpacing:'-.5px'}}>{meta.name}</div>
        <div style={{fontSize:11,color:DARK.textDim,marginTop:6}}>{xp.toLocaleString('fr-FR')} monuments · rang {rankIdx+1}/11</div>
        {next && (
          <div style={{marginTop:18,padding:'0 4px'}}>
            <div style={{height:5,background:'#0A0A0A',borderRadius:3,overflow:'hidden'}}>
              <div style={{width:`${pct}%`,height:'100%',background:`linear-gradient(90deg, ${meta.halo}, ${next.halo})`,borderRadius:3,boxShadow:`0 0 10px ${meta.halo}77`}}/>
            </div>
            <div style={{display:'flex',justifyContent:'space-between',marginTop:8,fontSize:10,color:DARK.textDim}}>
              <span>{xp - meta.xp} XP</span>
              <span style={{color:DARK.textMute}}>{next.xp - xp} avant <span style={{color:next.halo,fontWeight:600}}>{next.name}</span></span>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

// ═══ Mini rank list — preview des prochains rangs ═══════════════════════════
const RankPreview = ({currentIdx, gemStyle='realistic'}) => (
  <div style={{display:'flex',gap:10,padding:'2px 4px',overflowX:'auto'}}>
    {GEM_DATA.map((g,i)=>{
      const reached = i<=currentIdx;
      return (
        <div key={g.id} style={{flexShrink:0,opacity:reached?1:.35,filter:reached?'none':'grayscale(.6)',textAlign:'center',cursor:'pointer'}}>
          <div style={{width:48,height:48,display:'flex',alignItems:'center',justifyContent:'center',background:reached?'#0A0A0A':'transparent',borderRadius:12,border:i===currentIdx?`1px solid ${g.halo}`:'1px solid transparent'}}>
            <Gem id={g.id} size={42} style={gemStyle} animate={false}/>
          </div>
          <div style={{fontSize:9,color:i===currentIdx?g.halo:DARK.textMute,marginTop:5,fontWeight:i===currentIdx?700:500,letterSpacing:.3}}>{g.name}</div>
        </div>
      );
    })}
  </div>
);

// ═══ Maîtrise de ville — collection de sceaux ═══════════════════════════════
const CityMasteryRow = ({cities=[]}) => (
  <div style={{display:'flex',gap:14,overflowX:'auto',padding:'8px 0 4px'}}>
    {cities.map(c => (
      <div key={c.name} style={{flexShrink:0,textAlign:'center',cursor:'pointer'}}>
        <CitySeal cityName={c.name} monuments={c.monuments} total={c.total} locked={c.locked} size={88}/>
        <div style={{fontFamily:'Crimson Pro,serif',fontSize:11,color:c.locked?DARK.textMute:DARK.text,marginTop:4,fontStyle:'italic',letterSpacing:.3}}>{c.title}</div>
      </div>
    ))}
  </div>
);

Object.assign(window, {
  DARK, DarkStatusBar, DynamicIslandDark, CitySeal, RankCardA, RankCardB, RankPreview, CityMasteryRow,
});
