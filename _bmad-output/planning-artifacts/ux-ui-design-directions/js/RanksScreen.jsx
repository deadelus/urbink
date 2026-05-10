'use strict';
// ─── Rangs d'Explorateur — écran dédié (toute la progression 1 → 11) ──────────

const RANK_DESCRIPTIONS = {
  cristal:    'Premier pas d\u2019exploration. La pierre transparente accueille les nouveaux venus.',
  opale:      'Le regard se pose. L\u2019irisation r\u00e9v\u00e8le les premiers d\u00e9tails du patrimoine.',
  turquoise:  'L\u2019app\u00e9tit s\u2019\u00e9veille. Couleur des voyages et des d\u00e9couvertes lointaines.',
  ambre:      'L\u2019histoire se fige dans la pierre chaude. Le pass\u00e9 prend forme.',
  topaze:     'Lumi\u00e8re dor\u00e9e des explorateurs aguerris. Vous reconnaissez les styles.',
  jade:       'Sagesse et harmonie. La ville se lit \u00e0 livre ouvert.',
  saphir:     'Profondeur royale. Vous lisez l\u2019architecture comme un manuscrit.',
  rubis:      'Passion intense. Chaque pierre est une histoire personnelle.',
  emeraude:   'Connaissance pure. Peu d\u2019explorateurs atteignent cet \u00e9clat.',
  diamant:    'Le sommet conventionnel. Ma\u00eetrise compl\u00e8te du patrimoine urbain.',
  legendaire: 'Au-del\u00e0 du Diamant. R\u00e9serv\u00e9 \u00e0 ceux qui ont parcouru les villes du monde.',
};

// ─── Hero — gemme courante en grand ───────────────────────────────────────────
const RanksHero = ({rankIdx, xpInRank}) => {
  const {T} = window;
  const meta = window.GEM_DATA[rankIdx];
  const next = window.GEM_DATA[rankIdx+1];
  const total = next ? (next.xp - meta.xp) : 1;
  const pct = next ? Math.min(100, (xpInRank/total)*100) : 100;
  const totalXp = meta.xp + xpInRank;

  return (
    <div style={{
      margin:'12px 16px 0',background:T.surface,borderRadius:22,
      border:`1px solid ${T.border}`,padding:'22px 18px 18px',
      position:'relative',overflow:'hidden',
      boxShadow:'0 1px 8px rgba(0,0,0,.05)',
    }}>
      <div style={{position:'absolute',top:-60,right:-60,width:240,height:240,
        background:`radial-gradient(circle, ${meta.halo}24 0%, transparent 70%)`,pointerEvents:'none'}}/>

      <div style={{position:'relative',display:'flex',flexDirection:'column',alignItems:'center'}}>
        <div style={{fontSize:9,fontWeight:700,letterSpacing:2,color:T.muted,textTransform:'uppercase',marginBottom:14}}>
          Rang actuel · {rankIdx+1} sur 11
        </div>
        <div style={{filter:`drop-shadow(0 6px 18px ${meta.halo}55) drop-shadow(0 2px 6px rgba(0,0,0,.08))`}}>
          <window.Gem id={meta.id} size={120} style="realistic"/>
        </div>
        <div style={{fontFamily:'Crimson Pro,serif',fontSize:34,fontWeight:600,color:T.text,letterSpacing:'-.5px',lineHeight:1,marginTop:14}}>
          {meta.name}
        </div>
        <div style={{fontSize:12,color:T.muted,marginTop:6,fontFamily:'Crimson Pro,serif',fontStyle:'italic',letterSpacing:.2,textAlign:'center',maxWidth:280,lineHeight:1.4}}>
          {RANK_DESCRIPTIONS[meta.id]}
        </div>
        <div style={{fontSize:11,color:T.muted,marginTop:14,fontWeight:500}}>
          {totalXp} monuments découverts au total
        </div>
      </div>

      {next && (
        <div style={{marginTop:18,paddingTop:16,borderTop:`1px solid ${T.border}`}}>
          <div style={{display:'flex',justifyContent:'space-between',alignItems:'baseline',marginBottom:8}}>
            <div style={{display:'flex',alignItems:'center',gap:6}}>
              <span style={{fontSize:11,color:T.muted}}>Prochain rang</span>
              <span style={{fontSize:13,color:next.halo,fontWeight:700,fontFamily:'Crimson Pro,serif',letterSpacing:.2}}>{next.name}</span>
            </div>
            <span style={{fontSize:11,fontWeight:600,color:T.text,fontVariantNumeric:'tabular-nums'}}>
              {xpInRank} <span style={{color:T.muted,fontWeight:400}}>/ {total}</span>
            </span>
          </div>
          <div style={{height:6,background:T.surfVar,borderRadius:3,overflow:'hidden'}}>
            <div style={{width:`${pct}%`,height:'100%',
              background:`linear-gradient(90deg, ${meta.halo}, ${next.halo})`,
              borderRadius:3,boxShadow:`0 0 8px ${meta.halo}88`}}/>
          </div>
          <div style={{fontSize:10,color:T.muted,marginTop:8,letterSpacing:.2}}>
            Encore <span style={{color:T.text,fontWeight:600}}>{total-xpInRank}</span> monument{total-xpInRank>1?'s':''} pour atteindre <span style={{color:next.halo,fontFamily:'Crimson Pro,serif',fontStyle:'italic',fontWeight:600}}>{next.name}</span>
          </div>
        </div>
      )}
    </div>
  );
};

// ─── Une ligne de rang dans la timeline ───────────────────────────────────────
const RankRow = ({gem, idx, status, threshold}) => {
  const {T} = window;
  const isCurrent = status==='current';
  const isReached = status==='reached' || isCurrent;
  const isLegendary = gem.id==='legendaire';

  return (
    <div style={{
      position:'relative',display:'flex',alignItems:'center',gap:14,
      padding:'12px 14px',
      background:isCurrent ? `${gem.halo}0F` : 'transparent',
      borderRadius:14,
      border:isCurrent ? `1.5px solid ${gem.halo}66` : '1.5px solid transparent',
    }}>
      {/* Connecteur vertical */}
      {idx>0 && (
        <div style={{
          position:'absolute',left:36,top:-8,width:2,height:18,
          background:isReached ? gem.halo+'66' : T.border,borderRadius:1,
        }}/>
      )}

      {/* Gemme */}
      <div style={{
        width:54,height:54,borderRadius:14,flexShrink:0,
        background:isReached ? `${gem.halo}10` : T.surfVar,
        border:isCurrent ? `1.5px solid ${gem.halo}` : `1px solid ${T.border}`,
        display:'flex',alignItems:'center',justifyContent:'center',
        filter:isReached ? 'none' : 'grayscale(.85) opacity(.55)',
        boxShadow:isCurrent ? `0 0 14px ${gem.halo}55` : 'none',
      }}>
        <window.Gem id={gem.id} size={42} style="realistic" animate={false}/>
      </div>

      {/* Texte */}
      <div style={{flex:1,minWidth:0}}>
        <div style={{display:'flex',alignItems:'baseline',gap:8,flexWrap:'wrap'}}>
          <span style={{fontSize:9,fontWeight:700,color:T.muted,letterSpacing:1,fontVariantNumeric:'tabular-nums'}}>
            {String(idx+1).padStart(2,'0')}
          </span>
          <span style={{
            fontFamily:'Crimson Pro,serif',fontSize:isLegendary?20:18,fontWeight:600,
            color:isReached ? T.text : T.muted,letterSpacing:'-.2px',lineHeight:1,
            background:isLegendary && isReached
              ? 'linear-gradient(90deg, #D4A642, #E8C547, #D4A642)'
              : 'none',
            WebkitBackgroundClip:isLegendary && isReached?'text':'unset',
            WebkitTextFillColor:isLegendary && isReached?'transparent':'unset',
          }}>{gem.name}</span>
          {isCurrent && (
            <span style={{fontSize:9,fontWeight:700,letterSpacing:1.2,color:gem.halo,textTransform:'uppercase',
              background:`${gem.halo}1A`,padding:'2px 7px',borderRadius:6}}>Vous êtes ici</span>
          )}
          {isLegendary && (
            <span style={{fontSize:9,fontWeight:700,letterSpacing:1.2,color:'#8A6E2E',textTransform:'uppercase',
              background:'linear-gradient(135deg, #FFF7E0, #F4E4B0)',padding:'2px 7px',borderRadius:6,
              border:'1px solid #D4A64255'}}>Mythique</span>
          )}
        </div>
        <div style={{fontSize:11,color:T.muted,marginTop:4,fontFamily:'Crimson Pro,serif',fontStyle:'italic',letterSpacing:.1,lineHeight:1.35}}>
          {RANK_DESCRIPTIONS[gem.id]}
        </div>
        <div style={{fontSize:10,color:isReached ? T.text : T.muted,marginTop:4,fontWeight:isReached?600:400,fontVariantNumeric:'tabular-nums'}}>
          {threshold === 0 ? 'Point de départ' : `À partir de ${threshold} monuments`}
        </div>
      </div>

      {/* Statut */}
      <div style={{flexShrink:0,marginLeft:6}}>
        {isReached && !isCurrent ? (
          <div style={{width:22,height:22,borderRadius:'50%',background:gem.halo,display:'flex',alignItems:'center',justifyContent:'center'}}>
            <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="3" strokeLinecap="round"><path d="M5 13l4 4L19 7"/></svg>
          </div>
        ) : !isReached ? (
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke={T.muted} strokeWidth="2" strokeLinecap="round" opacity=".6">
            <rect x="5" y="11" width="14" height="10" rx="2"/><path d="M8 11V7a4 4 0 018 0v4"/>
          </svg>
        ) : null}
      </div>
    </div>
  );
};

// ─── Écran principal ──────────────────────────────────────────────────────────
const RanksScreen = ({onBack, rankIdx=4, xpInRank=32}) => {
  const {React, T, StatusBar, DynamicIsland} = window;

  return (
    <div style={{position:'absolute',inset:0,background:T.bg,fontFamily:'-apple-system,Inter,sans-serif',color:T.text,overflowY:'auto'}}>
      <DynamicIsland/>
      <StatusBar/>

      {/* Header */}
      <div style={{position:'sticky',top:0,zIndex:5,background:T.bg,padding:'8px 16px 12px',borderBottom:`1px solid ${T.border}`}}>
        <div style={{display:'flex',alignItems:'center',gap:8,marginTop:48}}>
          <div onClick={onBack} style={{width:36,height:36,borderRadius:10,background:T.surface,border:`1px solid ${T.border}`,display:'flex',alignItems:'center',justifyContent:'center',cursor:'pointer'}}>
            <svg width="18" height="18" fill="none" viewBox="0 0 24 24"><path d="M15 18l-6-6 6-6" stroke={T.text} strokeWidth="2" strokeLinecap="round"/></svg>
          </div>
          <div style={{flex:1}}>
            <div style={{fontFamily:'Crimson Pro,serif',fontSize:22,fontWeight:700,color:T.text,letterSpacing:'-.4px',lineHeight:1}}>Rang d'explorateur</div>
            <div style={{fontSize:11,color:T.muted,marginTop:3}}>Progression globale · 1 monument découvert = 1 XP</div>
          </div>
        </div>
      </div>

      <div style={{padding:'4px 0 100px'}}>
        <RanksHero rankIdx={rankIdx} xpInRank={xpInRank}/>

        {/* Section: tous les rangs */}
        <div style={{padding:'24px 16px 0'}}>
          <div style={{display:'flex',alignItems:'baseline',gap:8,marginBottom:12}}>
            <div style={{fontSize:11,fontWeight:700,letterSpacing:1.5,color:T.muted,textTransform:'uppercase'}}>Les 11 rangs</div>
            <div style={{flex:1,height:1,background:T.border}}/>
          </div>
          <div style={{display:'flex',flexDirection:'column',gap:6}}>
            {window.GEM_DATA.map((g, i) => {
              const status = i < rankIdx ? 'reached' : i === rankIdx ? 'current' : 'locked';
              return (
                <RankRow key={g.id} gem={g} idx={i} status={status} threshold={g.xp}/>
              );
            })}
          </div>
        </div>

        {/* Note */}
        <div style={{
          margin:'20px 16px 0',padding:'12px 14px',background:T.surface,
          border:`1px solid ${T.border}`,borderRadius:12,
          display:'flex',gap:10,alignItems:'flex-start',
        }}>
          <div style={{
            width:22,height:22,borderRadius:6,flexShrink:0,
            background:`${T.primary}1A`,
            display:'flex',alignItems:'center',justifyContent:'center',
          }}>
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke={T.primary} strokeWidth="2.5" strokeLinecap="round"><circle cx="12" cy="12" r="9"/><path d="M12 8v4M12 16h.01"/></svg>
          </div>
          <div style={{flex:1,fontSize:11,color:T.muted,lineHeight:1.45}}>
            Le rang d'explorateur compte les monuments d\u00e9couverts dans <span style={{color:T.text,fontWeight:600}}>toutes les villes</span>. Distinct des titres de ma\u00eetrise sp\u00e9cifiques \u00e0 chaque ville.
          </div>
        </div>
      </div>
    </div>
  );
};

Object.assign(window, {RanksScreen, RANK_DESCRIPTIONS});
