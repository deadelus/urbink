'use strict';
// ─── Page principale — galerie + 3 iPhones + maîtrise ville + tweaks ─────────

const RANK_INDEX_DEFAULT = 4; // Topaze (5e rang)
const XP_DEFAULT = 32;        // dans la barre vers Jade (Topaze: 0..65)

// ─── iPhone Frame ────────────────────────────────────────────────────────────
const PhoneFrame = ({children, label}) => (
  <div style={{display:'flex',flexDirection:'column',alignItems:'center',gap:14}}>
    <div style={{
      position:'relative',width:390,height:844,
      borderRadius:50,background:'#0A0A0A',
      boxShadow:'0 0 0 12px #1A1A1D, 0 0 0 13px #2A2A2D, 0 40px 80px rgba(0,0,0,.7), 0 16px 40px rgba(0,0,0,.5)',
      overflow:'hidden',
    }}>
      {children}
    </div>
    {label && <div style={{fontFamily:'Crimson Pro,serif',fontStyle:'italic',fontSize:14,color:'#9A9A9F',letterSpacing:.3}}>{label}</div>}
  </div>
);

// ─── Profile Screen (full iPhone content) ────────────────────────────────────
const ProfileScreen = ({variant='A', rankIdx, xp, gemStyle}) => {
  const Card = variant==='A' ? RankCardA : RankCardB;
  const meta = GEM_DATA[rankIdx];

  const cities = [
    {name:'Paris',     monuments:42, total:156, locked:false, title:'Mémoire de Paris'},
    {name:'Lisbonne',  monuments:4,  total:72,  locked:false, title:'Visiteur de Lisbonne'},
    {name:'Londres',   monuments:2,  total:98,  locked:false, title:'Visiteur de Londres'},
    {name:'New York',  monuments:0,  total:180, locked:true,  title:'À débloquer'},
    {name:'Tokyo',     monuments:0,  total:210, locked:true,  title:'À débloquer'},
    {name:'Rome',      monuments:0,  total:120, locked:true,  title:'À débloquer'},
  ];

  return (
    <div style={{position:'absolute',inset:0,background:DARK.bg,fontFamily:'-apple-system,Inter,sans-serif',color:DARK.text}}>
      <DynamicIslandDark/>
      <DarkStatusBar/>
      <div style={{position:'absolute',top:54,left:0,right:0,bottom:0,overflowY:'auto',paddingBottom:100}}>
        {/* Header — avatar + name */}
        <div style={{padding:'16px 20px 18px',display:'flex',alignItems:'center',gap:14}}>
          <div style={{
            width:56,height:56,borderRadius:'50%',
            background:`linear-gradient(135deg, #2A2A2D, #1A1A1D)`,
            border:`1.5px solid ${meta.halo}55`,
            display:'flex',alignItems:'center',justifyContent:'center',
            fontFamily:'Crimson Pro,serif',fontSize:22,fontWeight:600,color:meta.halo,
            boxShadow:`0 0 20px ${meta.halo}22`,
          }}>EM</div>
          <div style={{flex:1}}>
            <div style={{fontFamily:'Crimson Pro,serif',fontSize:22,fontWeight:600,letterSpacing:'-.3px',color:DARK.text}}>Élise Moreau</div>
            <div style={{fontSize:12,color:DARK.textMute,marginTop:2}}>Membre depuis mars 2024 · 47 jours d'exploration</div>
          </div>
          <div style={{width:32,height:32,borderRadius:10,background:DARK.surface,border:`1px solid ${DARK.border}`,display:'flex',alignItems:'center',justifyContent:'center',cursor:'pointer'}}>
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke={DARK.textDim} strokeWidth="1.8" strokeLinecap="round"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 1 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 1 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 1 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 1 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>
          </div>
        </div>

        {/* Rank Card — main hero */}
        <div style={{padding:'0 20px'}}>
          <Card rankIdx={rankIdx} xp={xp} gemStyle={gemStyle}/>
        </div>

        {/* Section: progression complète */}
        <div style={{padding:'24px 20px 8px'}}>
          <div style={{display:'flex',justifyContent:'space-between',alignItems:'baseline',marginBottom:12}}>
            <div style={{fontFamily:'Crimson Pro,serif',fontSize:17,fontWeight:600,color:DARK.text}}>Les 11 rangs</div>
            <span style={{fontSize:11,color:DARK.textMute,letterSpacing:.5}}>{rankIdx+1} sur 11</span>
          </div>
          <RankPreview currentIdx={rankIdx} gemStyle={gemStyle}/>
        </div>

        {/* Stats — 3 colonnes */}
        <div style={{padding:'12px 20px 0',display:'grid',gridTemplateColumns:'1fr 1fr 1fr',gap:10}}>
          {[
            {val:'234', label:'monuments'},
            {val:'18,4', label:'km à pied'},
            {val:'4', label:'villes'},
          ].map((s,i)=>(
            <div key={i} style={{background:DARK.surface,border:`1px solid ${DARK.border}`,borderRadius:14,padding:'14px 12px',textAlign:'center'}}>
              <div style={{fontFamily:'Crimson Pro,serif',fontSize:24,fontWeight:600,color:DARK.text,letterSpacing:'-.5px'}}>{s.val}</div>
              <div style={{fontSize:10,color:DARK.textMute,marginTop:2,letterSpacing:.5}}>{s.label}</div>
            </div>
          ))}
        </div>

        {/* City Mastery — distinct du rang global */}
        <div style={{padding:'24px 0 0'}}>
          <div style={{padding:'0 20px',display:'flex',justifyContent:'space-between',alignItems:'baseline',marginBottom:14}}>
            <div>
              <div style={{fontFamily:'Crimson Pro,serif',fontSize:17,fontWeight:600,color:DARK.text}}>Maîtrise des villes</div>
              <div style={{fontSize:11,color:DARK.textMute,marginTop:2}}>Titres honorifiques par ville</div>
            </div>
            <span style={{fontSize:12,color:DARK.green,fontWeight:500,cursor:'pointer'}}>Voir tout ›</span>
          </div>
          <div style={{paddingLeft:20}}>
            <CityMasteryRow cities={cities}/>
          </div>
        </div>

        <div style={{height:20}}/>
      </div>

      {/* Bottom nav */}
      <div style={{position:'absolute',bottom:0,left:0,right:0,height:84,background:'rgba(15,15,15,.85)',backdropFilter:'blur(20px)',WebkitBackdropFilter:'blur(20px)',borderTop:`.5px solid ${DARK.border}`,display:'flex',padding:'10px 0 28px'}}>
        {[
          {l:'Carte',i:'M9 20l-5.4-2.7A1 1 0 013 16.4V5.6a1 1 0 011.4-.9L9 7m0 13l6-3m-6 3V7m6 10l4.5 2.3A1 1 0 0021 18.4V7.6a1 1 0 00-1.4-.9L15 9m0 8V9m0 0L9 7'},
          {l:'Parcours',i:'M16 7l-2-3.4M8 7l2-3.4M12 19v3M5 9l7-5 7 5v6l-7 5-7-5V9z'},
          {l:'Social',i:'M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2M9 11a4 4 0 100-8 4 4 0 000 8z'},
          {l:'Badges',i:'M12 2l3 6 7 1-5 5 1 7-6-3-6 3 1-7-5-5 7-1 3-6z'},
          {l:'Profil',active:true,i:'M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2M12 11a4 4 0 100-8 4 4 0 000 8z'},
        ].map((tab,i)=>(
          <div key={i} style={{flex:1,display:'flex',flexDirection:'column',alignItems:'center',gap:3,cursor:'pointer'}}>
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke={tab.active?meta.halo:DARK.textMute} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><path d={tab.i}/></svg>
            <span style={{fontSize:10,color:tab.active?meta.halo:DARK.textMute,fontWeight:tab.active?600:500}}>{tab.l}</span>
          </div>
        ))}
      </div>

      {/* Home indicator */}
      <div style={{position:'absolute',bottom:8,left:'50%',transform:'translateX(-50%)',width:134,height:5,background:DARK.text,borderRadius:3,opacity:.9}}/>
    </div>
  );
};

// ─── Celebration screen wrapper (full iPhone) ────────────────────────────────
const CelebrationScreen = ({fromIdx, toIdx, gemStyle, replayKey, onReplay}) => {
  return (
    <div style={{position:'absolute',inset:0,background:DARK.bg}}>
      {/* Subtle background — profile glimpse */}
      <DynamicIslandDark/>
      <DarkStatusBar/>
      <CelebrationRank fromIdx={fromIdx} toIdx={toIdx} gemStyle={gemStyle} replayKey={replayKey} onClose={onReplay}/>
      {/* Replay button outside the overlay area */}
      <div onClick={onReplay} style={{
        position:'absolute',top:64,right:20,zIndex:700,
        background:'rgba(255,255,255,.08)',border:'1px solid rgba(255,255,255,.12)',
        borderRadius:20,padding:'6px 12px',display:'flex',alignItems:'center',gap:6,
        cursor:'pointer',backdropFilter:'blur(12px)',WebkitBackdropFilter:'blur(12px)',
      }}>
        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#F2F2F2" strokeWidth="2" strokeLinecap="round"><path d="M3 12a9 9 0 109-9M3 12V4M3 12h8"/></svg>
        <span style={{fontSize:11,color:'#F2F2F2',fontWeight:500}}>Rejouer</span>
      </div>
      <div style={{position:'absolute',bottom:8,left:'50%',transform:'translateX(-50%)',width:134,height:5,background:DARK.text,borderRadius:3,opacity:.9,zIndex:700}}/>
    </div>
  );
};

// ─── Gallery — les 11 emblèmes ───────────────────────────────────────────────
const GemGallery = ({gemStyle}) => {
  return (
    <div style={{display:'grid',gridTemplateColumns:'repeat(4, 1fr)',gap:18}}>
      {GEM_DATA.map((g, i) => (
        <div key={g.id} style={{
          background:'#161617',
          borderRadius:20,
          border:`1px solid ${g.id==='legendaire'?'#3A2D10':DARK.border}`,
          padding:'24px 16px 18px',
          display:'flex',flexDirection:'column',alignItems:'center',gap:10,
          position:'relative',overflow:'hidden',
        }}>
          {/* Halo bg subtle */}
          <div style={{position:'absolute',inset:0,background:`radial-gradient(ellipse at 50% 35%, ${g.halo}1A 0%, transparent 65%)`,pointerEvents:'none'}}/>
          <div style={{position:'relative'}}>
            <Gem id={g.id} size={120} style={gemStyle}/>
          </div>
          <div style={{position:'relative',textAlign:'center',marginTop:4}}>
            <div style={{fontSize:9,fontWeight:700,letterSpacing:2,color:DARK.textMute,textTransform:'uppercase'}}>RANG {String(i+1).padStart(2,'0')}</div>
            <div style={{fontFamily:'Crimson Pro,serif',fontSize:20,fontWeight:600,color:DARK.text,marginTop:4,letterSpacing:'-.3px'}}>{g.name}</div>
            <div style={{fontSize:11,color:g.halo,marginTop:4,fontVariantNumeric:'tabular-nums',fontWeight:500}}>
              {g.next ? `${g.xp} → ${g.next} XP` : `${g.xp}+ XP`}
            </div>
          </div>
        </div>
      ))}
    </div>
  );
};

// ─── Tweaks Panel ────────────────────────────────────────────────────────────
const TweaksPanel = ({show, gemStyle, onChange, rankIdx, xp, onRankChange, onXpChange}) => {
  if (!show) return null;
  const meta = GEM_DATA[rankIdx];
  const next = GEM_DATA[rankIdx+1];
  return (
    <div style={{
      position:'fixed',top:24,right:24,width:280,
      background:'rgba(22,22,23,.96)',backdropFilter:'blur(20px)',WebkitBackdropFilter:'blur(20px)',
      borderRadius:18,border:`1px solid ${DARK.border}`,padding:18,zIndex:9999,
      fontFamily:'-apple-system,Inter,sans-serif',color:DARK.text,
      boxShadow:'0 20px 60px rgba(0,0,0,.6)',
    }}>
      <div style={{fontSize:11,fontWeight:700,letterSpacing:2,color:DARK.textMute,textTransform:'uppercase',marginBottom:14}}>TWEAKS</div>

      <div style={{marginBottom:18}}>
        <div style={{fontSize:11,fontWeight:600,color:DARK.textDim,marginBottom:8,letterSpacing:.5}}>Style des gemmes</div>
        <div style={{display:'flex',gap:6,background:'#0A0A0A',borderRadius:10,padding:4}}>
          {[
            ['realistic','Réaliste'],
            ['glyph','Glyphe'],
            ['abstract','Aplat'],
          ].map(([k,l])=>(
            <div key={k} onClick={()=>onChange('gemStyle',k)} style={{
              flex:1,padding:'7px 0',borderRadius:7,fontSize:11,fontWeight:600,textAlign:'center',
              cursor:'pointer',
              background:gemStyle===k?DARK.surface:'transparent',
              color:gemStyle===k?DARK.text:DARK.textMute,
              border:gemStyle===k?`1px solid ${DARK.border}`:'1px solid transparent',
            }}>{l}</div>
          ))}
        </div>
      </div>

      <div style={{marginBottom:14}}>
        <div style={{display:'flex',justifyContent:'space-between',alignItems:'baseline',marginBottom:6}}>
          <span style={{fontSize:11,fontWeight:600,color:DARK.textDim,letterSpacing:.5}}>Rang actuel</span>
          <span style={{fontSize:11,fontWeight:600,color:meta.halo,fontFamily:'Crimson Pro,serif'}}>{meta.name}</span>
        </div>
        <input type="range" min="0" max="10" step="1" value={rankIdx}
          onChange={e=>onRankChange(parseInt(e.target.value))}
          style={{width:'100%',accentColor:meta.halo}}/>
      </div>

      <div style={{marginBottom:14}}>
        <div style={{display:'flex',justifyContent:'space-between',alignItems:'baseline',marginBottom:6}}>
          <span style={{fontSize:11,fontWeight:600,color:DARK.textDim,letterSpacing:.5}}>XP dans le rang</span>
          <span style={{fontSize:11,fontWeight:600,color:DARK.text,fontVariantNumeric:'tabular-nums'}}>
            {next ? `${xp} / ${next.xp - meta.xp}` : 'max'}
          </span>
        </div>
        <input type="range" min="0" max={next ? (next.xp - meta.xp) : 100} step="1"
          value={xp} onChange={e=>onXpChange(parseInt(e.target.value))}
          disabled={!next}
          style={{width:'100%',accentColor:meta.halo,opacity:next?1:.4}}/>
      </div>

      <div style={{padding:'10px 12px',background:'#0A0A0A',border:`1px solid ${DARK.border}`,borderRadius:10,fontSize:10,color:DARK.textMute,lineHeight:1.5}}>
        <span style={{color:DARK.textDim,fontWeight:600}}>Astuce</span> · Bouge le rang à <span style={{color:'#D4A642',fontWeight:600}}>Légendaire</span> pour voir le traitement spécial.
      </div>
    </div>
  );
};

// ─── ROOT PAGE ───────────────────────────────────────────────────────────────
const Root = () => {
  const {React} = window;

  const TWEAK_DEFAULTS = /*EDITMODE-BEGIN*/{
    "gemStyle": "realistic"
  }/*EDITMODE-END*/;

  const [tweaks, setTweaks] = React.useState(TWEAK_DEFAULTS);
  const [showTweaks, setShowTweaks] = React.useState(false);
  const [rankIdx, setRankIdx] = React.useState(RANK_INDEX_DEFAULT);
  const [xp, setXp] = React.useState(XP_DEFAULT);
  const [celebrationKey, setCelebrationKey] = React.useState(0);

  // Tweaks protocol
  React.useEffect(()=>{
    const handler = (e) => {
      if (e.data?.type==='__activate_edit_mode') setShowTweaks(true);
      if (e.data?.type==='__deactivate_edit_mode') setShowTweaks(false);
    };
    window.addEventListener('message', handler);
    window.parent.postMessage({type:'__edit_mode_available'}, '*');
    return () => window.removeEventListener('message', handler);
  },[]);

  const handleTweak = (key, val) => {
    setTweaks(t=>({...t,[key]:val}));
    window.parent.postMessage({type:'__edit_mode_set_keys', edits:{[key]:val}}, '*');
  };

  // Recompute celebration from→to based on rankIdx
  const celFromIdx = Math.max(0, rankIdx-1);
  const celToIdx = rankIdx;

  const replay = () => setCelebrationKey(k=>k+1);

  return (
    <div style={{minHeight:'100vh',background:DARK.bg,fontFamily:'-apple-system,Inter,sans-serif',color:DARK.text,padding:'48px 32px 64px'}}>
      <style>{`
        ::-webkit-scrollbar { width: 0; height: 0; }
        * { -webkit-tap-highlight-color: transparent; }
        input[type=range] {
          -webkit-appearance: none; appearance: none; height: 4px;
          background: #2A2A2D; border-radius: 2px; outline: none;
        }
        input[type=range]::-webkit-slider-thumb {
          -webkit-appearance: none; appearance: none; width: 14px; height: 14px;
          border-radius: 50%; background: #F2F2F2; cursor: pointer;
          border: 2px solid #1C1C1E;
        }
        body { background: ${DARK.bg}; }
      `}</style>

      {/* HERO */}
      <div data-screen-label="00 Hero" style={{maxWidth:1280,margin:'0 auto 56px'}}>
        <div style={{fontSize:11,fontWeight:700,letterSpacing:4,color:DARK.green,textTransform:'uppercase',marginBottom:12}}>
          URBINK · FEATURE EXPLORATION
        </div>
        <h1 style={{fontFamily:'Crimson Pro,serif',fontSize:68,fontWeight:600,letterSpacing:'-2px',lineHeight:1,color:DARK.text,margin:0}}>
          Rang d'Explorateur
        </h1>
        <p style={{fontSize:15,color:DARK.textDim,marginTop:18,maxWidth:640,lineHeight:1.6}}>
          Système de progression en onze pierres précieuses. Chaque monument découvert avance
          le rang global, toutes villes confondues. La maîtrise par ville reste un titre
          distinct — une médaille hexagonale séparée du rang.
        </p>
      </div>

      {/* SECTION A — Galerie des 11 emblèmes */}
      <div data-screen-label="01 Galerie" style={{maxWidth:1280,margin:'0 auto 80px'}}>
        <SectionHeader letter="A" title="Les 11 emblèmes" subtitle="Du cristal brut au sceau de l'Ordre — chaque pierre a sa taille, sa couleur naturelle, son halo." />
        <div style={{marginTop:32}}>
          <GemGallery gemStyle={tweaks.gemStyle}/>
        </div>
      </div>

      {/* SECTION B + C — Profil + Célébration (3 iPhones) */}
      <div data-screen-label="02 Profil & Celebration" style={{maxWidth:1400,margin:'0 auto 80px'}}>
        <SectionHeader letter="B + C" title="Composant rang & passage de rang" subtitle="Deux variantes du composant dans l'écran Profil — emblème latéral ou centré cérémonial — et l'overlay plein écran de célébration." />
        <div style={{display:'flex',gap:48,justifyContent:'center',marginTop:40,flexWrap:'wrap'}}>
          <PhoneFrame label="Variante A — Emblème latéral">
            <ProfileScreen variant="A" rankIdx={rankIdx} xp={xp+GEM_DATA[rankIdx].xp} gemStyle={tweaks.gemStyle}/>
          </PhoneFrame>
          <PhoneFrame label="Variante B — Centré cérémonial">
            <ProfileScreen variant="B" rankIdx={rankIdx} xp={xp+GEM_DATA[rankIdx].xp} gemStyle={tweaks.gemStyle}/>
          </PhoneFrame>
          <PhoneFrame label="Overlay de célébration (animée — clique “Rejouer”)">
            <CelebrationScreen fromIdx={celFromIdx} toIdx={celToIdx} gemStyle={tweaks.gemStyle} replayKey={celebrationKey} onReplay={replay}/>
          </PhoneFrame>
        </div>
      </div>

      {/* SECTION D — Maîtrise de ville */}
      <div data-screen-label="03 Maitrise ville" style={{maxWidth:1280,margin:'0 auto 80px'}}>
        <SectionHeader letter="D" title="Maîtrise de ville" subtitle="Sceau hexagonal métal patiné — médaille honorifique distincte du rang global, format collection." />
        <div style={{marginTop:40,background:'#161617',border:`1px solid ${DARK.border}`,borderRadius:24,padding:'48px 32px'}}>
          <div style={{display:'grid',gridTemplateColumns:'repeat(5, 1fr)',gap:32,alignItems:'end',justifyItems:'center'}}>
            {[
              {name:'Paris',  monuments:42, total:156, locked:false, title:'Mémoire de Paris',     active:true},
              {name:'Lyon',   monuments:8,  total:84,  locked:false, title:'Apprenti Lyonnais',   active:false},
              {name:'Bordeaux',monuments:3, total:62,  locked:false, title:'Visiteur de Bordeaux',active:false},
              {name:'Rome',   monuments:0,  total:120, locked:true,  title:'À débloquer',         active:false},
              {name:'Athènes',monuments:0,  total:96,  locked:true,  title:'À débloquer',         active:false},
            ].map((c,i)=>(
              <div key={c.name} style={{textAlign:'center'}}>
                <CitySeal cityName={c.name} monuments={c.monuments} total={c.total} locked={c.locked} size={140}/>
                <div style={{fontFamily:'Crimson Pro,serif',fontStyle:'italic',fontSize:14,color:c.locked?DARK.textMute:DARK.text,marginTop:10,letterSpacing:.3}}>
                  {c.title}
                </div>
                <div style={{fontSize:10,color:DARK.textMute,marginTop:4,letterSpacing:1.5,textTransform:'uppercase'}}>
                  {c.locked ? '— — —' : `${c.monuments}/${c.total} monuments`}
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* SECTION E — Specs / décisions de design */}
      <div data-screen-label="04 Specs" style={{maxWidth:1280,margin:'0 auto'}}>
        <SectionHeader letter="·" title="Décisions de design" subtitle="Pour pré-validation avec l'équipe." />
        <div style={{marginTop:32,display:'grid',gridTemplateColumns:'repeat(2, 1fr)',gap:20}}>
          {[
            ['Tailles & formes',`Chaque pierre porte une taille distincte — bipyramide hexagonale (Cristal), cabochon ovale (Opale), cabochon rond avec matrice (Turquoise), coussin organique (Ambre), poire (Topaze), cabochon profond (Jade), coussin (Saphir), ovale brillant (Rubis), step-cut (Émeraude), brilliant rond (Diamant), octogone gravé (Légendaire). Le Légendaire rompt avec les pierres pour devenir un sceau — l'objet de l'Ordre des Explorateurs.`],
            ['Halo & ambiance',`Chaque emblème projette un halo radial à sa couleur naturelle (~30% opacité), suffisant pour s'imposer sur #0F0F0F sans dominer la lecture. Le Légendaire ajoute une aura dorée pulsante (3.5s) — seul emblème animé en idle.`],
            ['Rang vs Maîtrise',`Le rang global est une pierre, vivante et personnelle. La maîtrise est un sceau métal — un titre formel, une plaque commémorative. La distinction visuelle est intentionnelle: deux registres (gemme organique / médaille gravée).`],
            ['Animation célébration',`Timeline 4s — fond fade + flou (0–10%), faisceaux de lumière (5–30%), pierre qui apparaît en rotation et scale (15–55%), pulse + label "Nouveau rang" (30–50%), nom en Crimson Pro (55–80%), sous-titre + delta XP (70–95%), CTA (85–100%). Sobre, sans confettis.`],
          ].map(([title, body])=>(
            <div key={title} style={{background:'#161617',border:`1px solid ${DARK.border}`,borderRadius:18,padding:'22px 24px'}}>
              <div style={{fontFamily:'Crimson Pro,serif',fontSize:17,fontWeight:600,color:DARK.text,marginBottom:8}}>{title}</div>
              <div style={{fontSize:13,color:DARK.textDim,lineHeight:1.6}}>{body}</div>
            </div>
          ))}
        </div>
      </div>

      {/* TWEAKS BUTTON HINT */}
      {!showTweaks && (
        <div style={{position:'fixed',bottom:24,right:24,background:'rgba(22,22,23,.92)',border:`1px solid ${DARK.border}`,borderRadius:24,padding:'10px 16px',backdropFilter:'blur(10px)',fontSize:11,color:DARK.textDim,letterSpacing:.3,zIndex:100,pointerEvents:'none'}}>
          ⚙ Active <span style={{color:DARK.text,fontWeight:600}}>Tweaks</span> dans la barre d'outils
        </div>
      )}

      <TweaksPanel
        show={showTweaks}
        gemStyle={tweaks.gemStyle}
        onChange={handleTweak}
        rankIdx={rankIdx}
        xp={xp}
        onRankChange={(i)=>{setRankIdx(i); setXp(0);}}
        onXpChange={setXp}
      />
    </div>
  );
};

// Section header
const SectionHeader = ({letter, title, subtitle}) => (
  <div style={{display:'flex',alignItems:'flex-start',gap:24}}>
    <div style={{
      width:56,height:56,borderRadius:14,
      background:'#161617',border:`1px solid ${DARK.border}`,
      display:'flex',alignItems:'center',justifyContent:'center',
      fontFamily:'Crimson Pro,serif',fontSize:24,fontWeight:600,color:DARK.green,
      flexShrink:0,marginTop:4,
    }}>{letter}</div>
    <div>
      <h2 style={{fontFamily:'Crimson Pro,serif',fontSize:36,fontWeight:600,letterSpacing:'-1px',lineHeight:1.05,color:DARK.text,margin:0}}>{title}</h2>
      <p style={{fontSize:14,color:DARK.textDim,marginTop:8,maxWidth:720,lineHeight:1.6}}>{subtitle}</p>
    </div>
  </div>
);

// Mount
ReactDOM.createRoot(document.getElementById('root')).render(<Root/>);
