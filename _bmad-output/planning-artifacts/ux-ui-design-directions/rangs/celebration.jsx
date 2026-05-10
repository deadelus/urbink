'use strict';
// ─── Celebration overlay — passage de rang, animée timeline ──────────────────

const CelebrationRank = ({fromIdx=0, toIdx=1, gemStyle='realistic', onClose, replayKey=0}) => {
  const {React} = window;
  const meta = GEM_DATA[toIdx];
  const fromMeta = GEM_DATA[fromIdx];
  const [t, setT] = React.useState(0); // 0 → 1 over animation duration

  // Timeline driver — 4 seconds total
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
  }, [replayKey]);

  // Easings
  const ease = (x) => 1 - Math.pow(1-x, 3);
  const easeOut = ease;
  const easeInOut = (x) => x<.5 ? 2*x*x : 1 - Math.pow(-2*x+2,2)/2;

  // Phase windows (clamped 0-1):
  // 0.00–0.10: bg fade in
  // 0.05–0.30: light beam reveals
  // 0.15–0.55: gem rises + scales up
  // 0.40–0.65: gem pulse + label "NOUVEAU RANG"
  // 0.55–0.80: name appears (Crimson Pro, large)
  // 0.70–0.95: subtitle + xp counter
  // 0.85–1.00: button reveals
  const seg = (s,e) => Math.max(0, Math.min(1, (t-s)/(e-s)));

  const bgOp = easeOut(seg(0,.10));
  const beamOp = easeOut(seg(.05,.30));
  const beamScale = .3 + easeOut(seg(.05,.40))*.7;

  const gemRise = easeOut(seg(.15,.55));
  const gemY = -40 * gemRise + 40 * (1-gemRise); // rises from 40 → -40 (reaching -40 at end? no, just centered)
  const gemScale = .4 + easeOut(seg(.15,.55)) * .6; // .4 → 1
  const gemRotate = (1-easeOut(seg(.15,.55))) * 25; // initial spin
  const gemOpacity = easeOut(seg(.10,.30));

  // Pulse during reveal
  const pulse = seg(.40,.70);
  const pulseScale = 1 + Math.sin(pulse*Math.PI)*.06;

  // Label cap
  const labelOp = easeOut(seg(.30,.50));
  const labelY = (1-easeOut(seg(.30,.50))) * 12;

  // Name
  const nameOp = easeOut(seg(.55,.80));
  const nameY = (1-easeOut(seg(.55,.80))) * 16;

  // Subtitle
  const subOp = easeOut(seg(.70,.95));

  // CTA
  const ctaOp = easeOut(seg(.85,1));
  const ctaY = (1-easeOut(seg(.85,1))) * 12;

  // Particles — 12 small light specks rising
  const particles = Array.from({length:14}).map((_,i)=>{
    const phase = (i / 14 + t*.6) % 1;
    const x = (i*73 % 100); // pseudo-random
    const opacity = Math.sin(phase*Math.PI) * easeOut(seg(.20,.95)) * .8;
    const y = 100 - phase*100;
    return {x, y, opacity, size: 2 + (i%3)};
  });

  return (
    <div style={{
      position:'absolute',inset:0,background:`rgba(8,8,10,${bgOp*.97})`,
      backdropFilter:`blur(${bgOp*16}px)`,WebkitBackdropFilter:`blur(${bgOp*16}px)`,
      zIndex:600,overflow:'hidden',display:'flex',flexDirection:'column',
      alignItems:'center',justifyContent:'center',
    }}>
      {/* Light beams behind gem */}
      <div style={{
        position:'absolute',top:'40%',left:'50%',
        width:480,height:480,marginLeft:-240,marginTop:-240,
        opacity:beamOp,transform:`translate(0,0) scale(${beamScale}) rotate(${t*60}deg)`,
        background:`conic-gradient(from 0deg, transparent 0deg, ${meta.halo}55 30deg, transparent 60deg, transparent 90deg, ${meta.halo}33 120deg, transparent 150deg, transparent 180deg, ${meta.halo}55 210deg, transparent 240deg, transparent 270deg, ${meta.halo}33 300deg, transparent 330deg, transparent 360deg)`,
        WebkitMask:'radial-gradient(circle, transparent 22%, black 25%, black 65%, transparent 70%)',
        mask:'radial-gradient(circle, transparent 22%, black 25%, black 65%, transparent 70%)',
        pointerEvents:'none',mixBlendMode:'screen',
      }}/>

      {/* Particles rising */}
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

      {/* Center column */}
      <div style={{position:'relative',display:'flex',flexDirection:'column',alignItems:'center',padding:'0 32px',marginTop:-30}}>
        {/* Cap label */}
        <div style={{
          fontSize:11,fontWeight:700,letterSpacing:5,color:meta.halo,textTransform:'uppercase',
          opacity:labelOp,transform:`translateY(${labelY}px)`,marginBottom:24,
          textShadow:`0 0 12px ${meta.halo}88`,
        }}>
          Nouveau rang
        </div>

        {/* Gem (animated) */}
        <div style={{
          opacity:gemOpacity,
          transform:`translateY(${gemY*0}px) scale(${gemScale*pulseScale}) rotate(${gemRotate}deg)`,
          filter:`drop-shadow(0 0 ${20+pulse*30}px ${meta.halo}AA) drop-shadow(0 8px 30px rgba(0,0,0,.6))`,
          transition:'none',
        }}>
          <Gem id={meta.id} size={200} style={gemStyle}/>
        </div>

        {/* Name */}
        <div style={{
          fontFamily:'Crimson Pro,serif',fontSize:48,fontWeight:600,
          color:DARK.text,letterSpacing:'-1px',lineHeight:1,marginTop:24,
          opacity:nameOp,transform:`translateY(${nameY}px)`,
          textShadow:`0 0 24px ${meta.halo}55`,
        }}>
          {meta.name}
        </div>

        {/* Subtitle */}
        <div style={{
          fontSize:13,color:DARK.textDim,marginTop:12,letterSpacing:.5,
          opacity:subOp,textAlign:'center',
        }}>
          Vous avez atteint le rang <span style={{color:meta.halo,fontWeight:600}}>{toIdx+1}</span> sur 11
        </div>

        {/* XP delta */}
        <div style={{
          display:'flex',alignItems:'center',gap:12,marginTop:18,opacity:subOp,
          background:'rgba(255,255,255,.04)',border:'1px solid rgba(255,255,255,.08)',
          borderRadius:14,padding:'10px 16px',
        }}>
          <span style={{fontSize:11,color:DARK.textMute,fontFamily:'Crimson Pro,serif',fontStyle:'italic'}}>
            {fromMeta.name}
          </span>
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke={meta.halo} strokeWidth="2.5"><path d="M5 12h14M13 6l6 6-6 6" strokeLinecap="round"/></svg>
          <span style={{fontSize:13,fontWeight:600,color:meta.halo,fontFamily:'Crimson Pro,serif'}}>
            {meta.name}
          </span>
        </div>
      </div>

      {/* CTA — bottom */}
      <div style={{position:'absolute',bottom:48,left:24,right:24,opacity:ctaOp,transform:`translateY(${ctaY}px)`}}>
        <button onClick={onClose} style={{
          width:'100%',height:54,borderRadius:16,border:'none',cursor:'pointer',
          background:DARK.text,color:'#0A0A0A',fontSize:15,fontWeight:600,letterSpacing:.3,
          fontFamily:'-apple-system,Inter,sans-serif',
          boxShadow:`0 8px 24px ${meta.halo}33, 0 4px 14px rgba(0,0,0,.4)`,
        }}>Continuer l'exploration</button>
      </div>
    </div>
  );
};

Object.assign(window, { CelebrationRank });
