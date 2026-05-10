'use strict';
// ─── Rangs d'Explorateur — composants intégrés dans l'app (thème clair) ──────
// Réutilise window.Gem + GEM_DATA de rangs/gems.jsx

const RankUtils = {
  // État global du joueur (mock — à brancher sur le vrai état plus tard)
  current: () => ({rankIdx: 4, xpInRank: 32}), // Topaze, 32/65 XP
  meta: (i) => window.GEM_DATA[i],
  next: (i) => window.GEM_DATA[i+1],
};

// ═══ Rank Card (Profile, light theme) ════════════════════════════════════════
const RankCard = ({rankIdx, xpInRank, onPress}) => {
  const {T} = window;
  const meta = RankUtils.meta(rankIdx);
  const next = RankUtils.next(rankIdx);
  const total = next ? (next.xp - meta.xp) : 1;
  const pct = next ? Math.min(100, (xpInRank/total)*100) : 100;
  const totalXp = meta.xp + xpInRank;

  return (
    <div onClick={onPress} style={{
      margin:'12px 16px 0',background:T.surface,borderRadius:20,border:`1px solid ${T.border}`,
      padding:'16px',position:'relative',overflow:'hidden',
      boxShadow:'0 1px 6px rgba(0,0,0,.04)',cursor:'pointer',
    }}>
      {/* Halo subtil teinté pierre */}
      <div style={{position:'absolute',top:-30,right:-30,width:160,height:160,
        background:`radial-gradient(circle, ${meta.halo}22 0%, transparent 70%)`,pointerEvents:'none'}}/>
      <div style={{display:'flex',alignItems:'center',gap:14,position:'relative'}}>
        <div style={{filter:'drop-shadow(0 4px 12px rgba(0,0,0,.08))'}}>
          <window.Gem id={meta.id} size={72} style="realistic"/>
        </div>
        <div style={{flex:1,minWidth:0}}>
          <div style={{fontSize:9,fontWeight:700,letterSpacing:1.5,color:T.muted,textTransform:'uppercase',marginBottom:2}}>
            Rang d'explorateur · {rankIdx+1}/11
          </div>
          <div style={{fontFamily:'Crimson Pro,serif',fontSize:24,fontWeight:600,color:T.text,lineHeight:1,letterSpacing:'-.3px'}}>
            {meta.name}
          </div>
          <div style={{fontSize:11,color:T.muted,marginTop:4}}>
            {totalXp} monuments découverts
          </div>
        </div>
        <span style={{fontSize:18,color:T.muted,marginLeft:4}}>›</span>
      </div>

      {next && (
        <div style={{marginTop:14,position:'relative'}}>
          <div style={{display:'flex',justifyContent:'space-between',alignItems:'baseline',marginBottom:6}}>
            <span style={{fontSize:11,color:T.muted}}>Vers <span style={{color:next.halo,fontWeight:600}}>{next.name}</span></span>
            <span style={{fontSize:11,fontWeight:600,color:T.text,fontVariantNumeric:'tabular-nums'}}>
              {xpInRank} <span style={{color:T.muted,fontWeight:400}}>/ {total}</span>
            </span>
          </div>
          <div style={{height:5,background:T.surfVar,borderRadius:3,overflow:'hidden'}}>
            <div style={{width:`${pct}%`,height:'100%',
              background:`linear-gradient(90deg, ${meta.halo}, ${next.halo})`,
              borderRadius:3,boxShadow:`0 0 6px ${meta.halo}88`}}/>
          </div>
        </div>
      )}
    </div>
  );
};

// ═══ Rank Preview Strip — 11 mini gemmes ═════════════════════════════════════
const RankPreviewStrip = ({rankIdx}) => {
  const {T} = window;
  return (
    <div style={{margin:'14px 0 0',padding:'0 16px'}}>
      <div style={{display:'flex',justifyContent:'space-between',alignItems:'baseline',marginBottom:10}}>
        <div style={{fontSize:13,fontWeight:700,color:T.text}}>Les 11 rangs</div>
        <span style={{fontSize:11,color:T.muted}}>{rankIdx+1} sur 11</span>
      </div>
      <div style={{display:'flex',gap:8,overflowX:'auto',paddingBottom:4}}>
        {window.GEM_DATA.map((g,i)=>{
          const reached = i<=rankIdx;
          const isCurrent = i===rankIdx;
          return (
            <div key={g.id} style={{flexShrink:0,textAlign:'center',width:54,opacity:reached?1:.5}}>
              <div style={{
                width:54,height:54,borderRadius:14,
                background:isCurrent?`${g.halo}10`:reached?T.surface:T.surfVar,
                border:isCurrent?`1.5px solid ${g.halo}`:`1px solid ${T.border}`,
                display:'flex',alignItems:'center',justifyContent:'center',
                filter:reached?'none':'grayscale(.7)',
              }}>
                <window.Gem id={g.id} size={44} style="realistic" animate={false}/>
              </div>
              <div style={{fontSize:9,color:isCurrent?g.halo:T.muted,marginTop:4,fontWeight:isCurrent?700:500,letterSpacing:.2,whiteSpace:'nowrap'}}>{g.name}</div>
            </div>
          );
        })}
      </div>
    </div>
  );
};

// ═══ City Mastery Row (light variant) ═════════════════════════════════════════
const CityMasteryStrip = ({cities}) => {
  const {T} = window;
  return (
    <div style={{padding:'16px 16px 0'}}>
      <div style={{display:'flex',justifyContent:'space-between',alignItems:'baseline',marginBottom:10}}>
        <div style={{fontSize:13,fontWeight:700,color:T.text}}>Maîtrise des villes</div>
        <span style={{fontSize:11,color:T.primary,fontWeight:500,cursor:'pointer'}}>Voir tout ›</span>
      </div>
      <div style={{display:'flex',gap:14,overflowX:'auto',paddingBottom:4}}>
        {cities.map(c=>(
          <div key={c.name} style={{flexShrink:0,textAlign:'center',width:84}}>
            <CitySealLight name={c.name} monuments={c.monuments} total={c.total} locked={c.locked}/>
            <div style={{fontFamily:'Crimson Pro,serif',fontStyle:'italic',fontSize:11,color:c.locked?T.muted:T.text,marginTop:4,letterSpacing:.2}}>
              {c.title}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

// ═══ Hex city seal — light theme version ═════════════════════════════════════
const CitySealLight = ({name, monuments=0, total=100, locked=false}) => {
  const goldDark = locked ? '#94A3B8' : '#8A6E2E';
  const goldLight = locked ? '#CBD5E1' : '#D4A642';
  const goldHi = locked ? '#E2E8F0' : '#E8C547';
  return (
    <svg viewBox="0 0 200 220" width="80" height="88" style={{display:'block',margin:'0 auto'}}>
      <defs>
        <linearGradient id={`csl-m-${name}`} x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stopColor={goldHi}/>
          <stop offset="50%" stopColor={goldLight}/>
          <stop offset="100%" stopColor={goldDark}/>
        </linearGradient>
        <linearGradient id={`csl-i-${name}`} x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stopColor={locked?'#F1F5F9':'#FFF7E0'}/>
          <stop offset="100%" stopColor={locked?'#E2E8F0':'#F4E4B0'}/>
        </linearGradient>
      </defs>
      <ellipse cx="100" cy="200" rx="40" ry="4" fill="#000" opacity=".15"/>
      <polygon points="100,20 168,55 168,140 100,190 32,140 32,55" fill={`url(#csl-m-${name})`}/>
      <polygon points="100,32 158,62 158,134 100,178 42,134 42,62" fill={`url(#csl-i-${name})`} stroke={goldDark} strokeWidth="1"/>
      <polygon points="100,42 148,68 148,128 100,168 52,128 52,68" fill="none" stroke={goldDark} strokeWidth=".7" opacity=".6"/>
      {/* Monument silhouette */}
      <g fill={goldDark} opacity={locked?.5:.85}>
        {name==='Paris' ? (
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
            <path d="M 80,140 L 80,100 Q 80,80 100,80 Q 120,80 120,100 L 120,140 Z" stroke={goldDark} strokeWidth="1.5" fill="none"/>
            <rect x="98" y="68" width="4" height="14"/>
          </>
        )}
      </g>
      <text x="100" y="158" textAnchor="middle" fontFamily="Crimson Pro,serif" fontSize="13" fontWeight="700"
            fill={goldDark} letterSpacing="1.5">{name.toUpperCase()}</text>
      <text x="100" y="172" textAnchor="middle" fontFamily="Inter,sans-serif" fontSize="7"
            fill={goldDark} opacity=".7" letterSpacing="1">
        {locked ? 'VERROUILLÉ' : `${monuments}/${total}`}
      </text>
      {!locked && <polygon points="100,20 168,55 130,55 100,38" fill="#fff" opacity=".35"/>}
    </svg>
  );
};

// ═══ Rank-up celebration overlay (light theme — but stays full-screen dark for drama) ═══
const RankCelebrationOverlay = ({fromIdx=3, toIdx=4, onDone}) => {
  const {React} = window;
  const meta = RankUtils.meta(toIdx);
  const fromMeta = RankUtils.meta(fromIdx);
  const [t, setT] = React.useState(0);
  const [replay, setReplay] = React.useState(0);

  React.useEffect(()=>{
    setT(0);
    let raf;
    const start = performance.now();
    const DUR = 4000;
    const tick = (now) => {
      const e = Math.min(1, (now-start)/DUR);
      setT(e);
      if (e<1) raf = requestAnimationFrame(tick);
    };
    raf = requestAnimationFrame(tick);
    return ()=>cancelAnimationFrame(raf);
  }, [replay]);

  const ease = (x) => 1 - Math.pow(1-x, 3);
  const seg = (s,e) => Math.max(0, Math.min(1, (t-s)/(e-s)));

  const bgOp = ease(seg(0,.10));
  const beamOp = ease(seg(.05,.30));
  const beamScale = .3 + ease(seg(.05,.40))*.7;
  const gemScale = .4 + ease(seg(.15,.55)) * .6;
  const gemRotate = (1-ease(seg(.15,.55))) * 25;
  const gemOpacity = ease(seg(.10,.30));
  const pulse = seg(.40,.70);
  const pulseScale = 1 + Math.sin(pulse*Math.PI)*.06;
  const labelOp = ease(seg(.30,.50));
  const labelY = (1-ease(seg(.30,.50))) * 12;
  const nameOp = ease(seg(.55,.80));
  const nameY = (1-ease(seg(.55,.80))) * 16;
  const subOp = ease(seg(.70,.95));
  const ctaOp = ease(seg(.85,1));
  const ctaY = (1-ease(seg(.85,1))) * 12;

  const particles = Array.from({length:14}).map((_,i)=>{
    const phase = (i / 14 + t*.6) % 1;
    const x = (i*73 % 100);
    const opacity = Math.sin(phase*Math.PI) * ease(seg(.20,.95)) * .8;
    const y = 100 - phase*100;
    return {x, y, opacity, size: 2 + (i%3)};
  });

  return (
    <div style={{
      position:'absolute',inset:0,zIndex:600,overflow:'hidden',
      background:`rgba(8,8,10,${bgOp*.97})`,
      backdropFilter:`blur(${bgOp*16}px)`,WebkitBackdropFilter:`blur(${bgOp*16}px)`,
      display:'flex',flexDirection:'column',alignItems:'center',justifyContent:'center',
      animation:'fadeIn .2s ease',
    }}>
      <div style={{
        position:'absolute',top:'42%',left:'50%',
        width:480,height:480,marginLeft:-240,marginTop:-240,
        opacity:beamOp,transform:`scale(${beamScale}) rotate(${t*60}deg)`,
        background:`conic-gradient(from 0deg, transparent 0deg, ${meta.halo}55 30deg, transparent 60deg, transparent 90deg, ${meta.halo}33 120deg, transparent 150deg, transparent 180deg, ${meta.halo}55 210deg, transparent 240deg, transparent 270deg, ${meta.halo}33 300deg, transparent 330deg, transparent 360deg)`,
        WebkitMask:'radial-gradient(circle, transparent 22%, black 25%, black 65%, transparent 70%)',
        mask:'radial-gradient(circle, transparent 22%, black 25%, black 65%, transparent 70%)',
        pointerEvents:'none',mixBlendMode:'screen',
      }}/>
      <div style={{position:'absolute',inset:0,pointerEvents:'none'}}>
        {particles.map((p,i)=>(
          <div key={i} style={{
            position:'absolute',left:`${p.x}%`,top:`${p.y}%`,
            width:p.size,height:p.size,borderRadius:'50%',
            background:meta.halo,opacity:p.opacity,
            boxShadow:`0 0 ${p.size*3}px ${meta.halo}`,
          }}/>
        ))}
      </div>
      <div style={{position:'relative',display:'flex',flexDirection:'column',alignItems:'center',padding:'0 32px',marginTop:-30}}>
        <div style={{
          fontSize:11,fontWeight:700,letterSpacing:5,color:meta.halo,textTransform:'uppercase',
          opacity:labelOp,transform:`translateY(${labelY}px)`,marginBottom:24,
          textShadow:`0 0 12px ${meta.halo}88`,
        }}>
          Nouveau rang
        </div>
        <div style={{
          opacity:gemOpacity,
          transform:`scale(${gemScale*pulseScale}) rotate(${gemRotate}deg)`,
          filter:`drop-shadow(0 0 ${20+pulse*30}px ${meta.halo}AA) drop-shadow(0 8px 30px rgba(0,0,0,.6))`,
        }}>
          <window.Gem id={meta.id} size={200} style="realistic"/>
        </div>
        <div style={{
          fontFamily:'Crimson Pro,serif',fontSize:48,fontWeight:600,
          color:'#F2F2F2',letterSpacing:'-1px',lineHeight:1,marginTop:24,
          opacity:nameOp,transform:`translateY(${nameY}px)`,
          textShadow:`0 0 24px ${meta.halo}55`,
        }}>{meta.name}</div>
        <div style={{fontSize:13,color:'#9A9A9F',marginTop:12,letterSpacing:.5,opacity:subOp,textAlign:'center'}}>
          Vous avez atteint le rang <span style={{color:meta.halo,fontWeight:600}}>{toIdx+1}</span> sur 11
        </div>
        <div style={{
          display:'flex',alignItems:'center',gap:12,marginTop:18,opacity:subOp,
          background:'rgba(255,255,255,.06)',border:'1px solid rgba(255,255,255,.10)',
          borderRadius:14,padding:'10px 16px',
        }}>
          <span style={{fontSize:11,color:'#6E6E73',fontFamily:'Crimson Pro,serif',fontStyle:'italic'}}>{fromMeta.name}</span>
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke={meta.halo} strokeWidth="2.5"><path d="M5 12h14M13 6l6 6-6 6" strokeLinecap="round"/></svg>
          <span style={{fontSize:13,fontWeight:600,color:meta.halo,fontFamily:'Crimson Pro,serif'}}>{meta.name}</span>
        </div>
      </div>
      <div style={{position:'absolute',bottom:36,left:24,right:24,opacity:ctaOp,transform:`translateY(${ctaY}px)`}}>
        <button onClick={onDone} style={{
          width:'100%',height:52,borderRadius:16,border:'none',cursor:'pointer',
          background:'#F2F2F2',color:'#0A0A0A',fontSize:15,fontWeight:600,letterSpacing:.3,
          fontFamily:'Inter,sans-serif',
          boxShadow:`0 8px 24px ${meta.halo}33, 0 4px 14px rgba(0,0,0,.4)`,
        }}>Continuer l'exploration</button>
      </div>
      {/* Replay (debug) */}
      {t>=1 && (
        <div onClick={()=>setReplay(r=>r+1)} style={{
          position:'absolute',top:64,right:20,
          background:'rgba(255,255,255,.08)',border:'1px solid rgba(255,255,255,.12)',
          borderRadius:20,padding:'6px 12px',display:'flex',alignItems:'center',gap:6,
          cursor:'pointer',backdropFilter:'blur(12px)',
        }}>
          <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#F2F2F2" strokeWidth="2" strokeLinecap="round"><path d="M3 12a9 9 0 109-9M3 12V4M3 12h8"/></svg>
          <span style={{fontSize:11,color:'#F2F2F2',fontWeight:500}}>Rejouer</span>
        </div>
      )}
    </div>
  );
};

Object.assign(window, {RankUtils, RankCard, RankPreviewStrip, CityMasteryStrip, CitySealLight, RankCelebrationOverlay});
