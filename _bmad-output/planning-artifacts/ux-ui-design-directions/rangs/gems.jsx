'use strict';
// ─── Les 11 emblèmes — gemmes facettées SVG ──────────────────────────────────
// Chaque gemme: viewBox 0 0 200 200, taille variable via prop `size`
// Composées de polygones facettés + halo radial + ombre portée

const GEM_DATA = [
  { id:'cristal',    name:'Cristal',    halo:'#A8C4D6', xp:0,    next:5    },
  { id:'opale',      name:'Opale',      halo:'#D4B5E8', xp:5,    next:15   },
  { id:'turquoise',  name:'Turquoise',  halo:'#3FB8B0', xp:15,   next:35   },
  { id:'ambre',      name:'Ambre',      halo:'#E89B3F', xp:35,   next:75   },
  { id:'topaze',     name:'Topaze',     halo:'#E8C547', xp:75,   next:140  },
  { id:'jade',       name:'Jade',       halo:'#3D9B6E', xp:140,  next:240  },
  { id:'saphir',     name:'Saphir',     halo:'#3461C9', xp:240,  next:380  },
  { id:'rubis',      name:'Rubis',      halo:'#C9344B', xp:380,  next:560  },
  { id:'emeraude',   name:'Émeraude',   halo:'#1F8A5B', xp:560,  next:800  },
  { id:'diamant',    name:'Diamant',    halo:'#C8E0F0', xp:800,  next:1100 },
  { id:'legendaire', name:'Légendaire', halo:'#D4A642', xp:1100, next:null },
];

// Reusable shadow ellipse on dark bg
const Shadow = ({cx=100,cy=180,rx=44,ry=6,o=.55}) => (
  <ellipse cx={cx} cy={cy} rx={rx} ry={ry} fill="#000" opacity={o}/>
);

// Reusable outer halo
const Halo = ({color, r=92, intensity=.3}) => (
  <circle cx="100" cy="100" r={r} fill={`url(#halo-${color.replace('#','')})`}/>
);

// ═══ 1. CRISTAL — pointe hexagonale bipyramide (cristal de roche brut) ═════
const GemCristal = ({size=140}) => (
  <svg viewBox="0 0 200 200" width={size} height={size} style={{display:'block'}}>
    <defs>
      <radialGradient id="cristal-halo" cx="50%" cy="55%" r="55%">
        <stop offset="0%" stopColor="#A8C4D6" stopOpacity=".30"/>
        <stop offset="100%" stopColor="#A8C4D6" stopOpacity="0"/>
      </radialGradient>
    </defs>
    <circle cx="100" cy="100" r="92" fill="url(#cristal-halo)"/>
    <Shadow rx={38} ry={5} o={.55}/>
    {/* Bipyramide hexagonale vue de face */}
    <polygon points="100,28 65,75 100,72" fill="#DCE8EE"/>
    <polygon points="100,28 100,72 135,75" fill="#B5C8D2"/>
    <polygon points="65,75 100,72 100,148 65,150" fill="#9CB4C0"/>
    <polygon points="100,72 135,75 135,150 100,148" fill="#7A93A1"/>
    <polygon points="65,150 100,148 100,172" fill="#56697A"/>
    <polygon points="100,148 135,150 100,172" fill="#3D4D5C"/>
    {/* Reflets prismatiques */}
    <polygon points="100,28 100,72 92,55" fill="#fff" opacity=".55"/>
    <polygon points="73,82 80,85 80,140 73,138" fill="#fff" opacity=".18"/>
  </svg>
);

// ═══ 2. OPALE — cabochon ovale irisé multicolore ═══════════════════════════
const GemOpale = ({size=140}) => (
  <svg viewBox="0 0 200 200" width={size} height={size} style={{display:'block'}}>
    <defs>
      <radialGradient id="opale-halo" cx="50%" cy="50%" r="60%">
        <stop offset="0%" stopColor="#D4B5E8" stopOpacity=".35"/>
        <stop offset="100%" stopColor="#D4B5E8" stopOpacity="0"/>
      </radialGradient>
      <radialGradient id="opale-base" cx="40%" cy="35%" r="70%">
        <stop offset="0%" stopColor="#F0E8F4"/>
        <stop offset="55%" stopColor="#C8B8D4"/>
        <stop offset="100%" stopColor="#7E6E94"/>
      </radialGradient>
      <clipPath id="opale-clip"><ellipse cx="100" cy="100" rx="58" ry="68"/></clipPath>
    </defs>
    <circle cx="100" cy="100" r="92" fill="url(#opale-halo)"/>
    <Shadow rx={48} ry={6}/>
    <ellipse cx="100" cy="100" rx="58" ry="68" fill="url(#opale-base)"/>
    {/* Taches iridescentes — feux d'opale */}
    <g clipPath="url(#opale-clip)" opacity=".75">
      <ellipse cx="78" cy="78" rx="22" ry="14" fill="#7FE0C4" opacity=".55" transform="rotate(-25 78 78)"/>
      <ellipse cx="120" cy="92" rx="18" ry="11" fill="#FFB37C" opacity=".55" transform="rotate(15 120 92)"/>
      <ellipse cx="92" cy="125" rx="20" ry="13" fill="#7FA4FF" opacity=".5" transform="rotate(-10 92 125)"/>
      <ellipse cx="125" cy="135" rx="14" ry="9" fill="#E07FE0" opacity=".5" transform="rotate(30 125 135)"/>
      <ellipse cx="70" cy="115" rx="11" ry="8" fill="#F2E97F" opacity=".55"/>
      <ellipse cx="105" cy="62" rx="12" ry="7" fill="#FF6FA0" opacity=".4"/>
    </g>
    {/* Reflet cabochon */}
    <ellipse cx="82" cy="72" rx="18" ry="10" fill="#fff" opacity=".55" transform="rotate(-25 82 72)"/>
    <ellipse cx="100" cy="100" rx="58" ry="68" fill="none" stroke="#000" strokeWidth=".5" opacity=".25"/>
  </svg>
);

// ═══ 3. TURQUOISE — cabochon rond avec matrice (veines noires) ═════════════
const GemTurquoise = ({size=140}) => (
  <svg viewBox="0 0 200 200" width={size} height={size} style={{display:'block'}}>
    <defs>
      <radialGradient id="turquoise-halo" cx="50%" cy="50%" r="55%">
        <stop offset="0%" stopColor="#3FB8B0" stopOpacity=".30"/>
        <stop offset="100%" stopColor="#3FB8B0" stopOpacity="0"/>
      </radialGradient>
      <radialGradient id="turquoise-base" cx="38%" cy="35%" r="70%">
        <stop offset="0%" stopColor="#A8E6DC"/>
        <stop offset="50%" stopColor="#3FB8B0"/>
        <stop offset="100%" stopColor="#1A5F5C"/>
      </radialGradient>
      <clipPath id="turquoise-clip"><circle cx="100" cy="100" r="64"/></clipPath>
    </defs>
    <circle cx="100" cy="100" r="92" fill="url(#turquoise-halo)"/>
    <Shadow rx={48} ry={6}/>
    <circle cx="100" cy="100" r="64" fill="url(#turquoise-base)"/>
    {/* Matrice — veinages caractéristiques */}
    <g clipPath="url(#turquoise-clip)" stroke="#1a1a1a" strokeWidth="1.5" fill="none" opacity=".65">
      <path d="M 50,90 Q 75,82 95,95 Q 110,108 145,98"/>
      <path d="M 60,130 Q 90,140 130,128"/>
      <path d="M 78,55 Q 88,75 80,100"/>
      <path d="M 130,55 Q 138,80 145,115"/>
      <path d="M 70,145 Q 95,150 115,145"/>
    </g>
    <ellipse cx="82" cy="78" rx="20" ry="12" fill="#fff" opacity=".4" transform="rotate(-30 82 78)"/>
    <circle cx="100" cy="100" r="64" fill="none" stroke="#000" strokeWidth=".5" opacity=".3"/>
  </svg>
);

// ═══ 4. AMBRE — coussin organique chaud avec inclusion ═════════════════════
const GemAmbre = ({size=140}) => (
  <svg viewBox="0 0 200 200" width={size} height={size} style={{display:'block'}}>
    <defs>
      <radialGradient id="ambre-halo" cx="50%" cy="50%" r="55%">
        <stop offset="0%" stopColor="#E89B3F" stopOpacity=".32"/>
        <stop offset="100%" stopColor="#E89B3F" stopOpacity="0"/>
      </radialGradient>
      <radialGradient id="ambre-base" cx="35%" cy="30%" r="80%">
        <stop offset="0%" stopColor="#FFD89A"/>
        <stop offset="50%" stopColor="#E89B3F"/>
        <stop offset="100%" stopColor="#7A3E14"/>
      </radialGradient>
    </defs>
    <circle cx="100" cy="100" r="92" fill="url(#ambre-halo)"/>
    <Shadow rx={50} ry={6}/>
    {/* Forme coussin organique */}
    <path d="M 50,70 Q 50,40 80,38 Q 100,30 122,38 Q 152,42 152,72 Q 158,100 152,128 Q 148,162 118,162 Q 100,170 78,160 Q 48,158 48,128 Q 42,100 50,70 Z"
          fill="url(#ambre-base)"/>
    {/* Facets internes — légères lignes de réfraction */}
    <path d="M 70,60 L 130,60 L 145,90 L 130,140 L 70,140 L 55,90 Z"
          fill="none" stroke="#fff" strokeWidth=".8" opacity=".15"/>
    {/* Inclusion — petite bulle/insecte fossile */}
    <ellipse cx="115" cy="115" rx="6" ry="4" fill="#3D1E08" opacity=".75"/>
    <circle cx="113" cy="113" r="1.5" fill="#fff" opacity=".4"/>
    {/* Reflet */}
    <ellipse cx="78" cy="62" rx="22" ry="12" fill="#fff" opacity=".55" transform="rotate(-30 78 62)"/>
    <path d="M 50,70 Q 50,40 80,38 Q 100,30 122,38 Q 152,42 152,72 Q 158,100 152,128 Q 148,162 118,162 Q 100,170 78,160 Q 48,158 48,128 Q 42,100 50,70 Z"
          fill="none" stroke="#000" strokeWidth=".5" opacity=".3"/>
  </svg>
);

// ═══ 5. TOPAZE — taille poire (pear cut) ═══════════════════════════════════
const GemTopaze = ({size=140}) => (
  <svg viewBox="0 0 200 200" width={size} height={size} style={{display:'block'}}>
    <defs>
      <radialGradient id="topaze-halo" cx="50%" cy="50%" r="55%">
        <stop offset="0%" stopColor="#E8C547" stopOpacity=".32"/>
        <stop offset="100%" stopColor="#E8C547" stopOpacity="0"/>
      </radialGradient>
    </defs>
    <circle cx="100" cy="100" r="92" fill="url(#topaze-halo)"/>
    <Shadow rx={42} ry={5}/>
    {/* Contour poire */}
    <path d="M 100,30 Q 60,45 55,110 Q 55,165 100,170 Q 145,165 145,110 Q 140,45 100,30 Z"
          fill="#7A5F0A"/>
    {/* Couronne — facets supérieurs */}
    <polygon points="100,38 78,65 100,70" fill="#FFE066"/>
    <polygon points="100,38 100,70 122,65" fill="#E8C547"/>
    <polygon points="78,65 100,70 88,95 70,90" fill="#D4B135"/>
    <polygon points="122,65 100,70 112,95 130,90" fill="#B89220"/>
    <polygon points="100,70 88,95 100,100 112,95" fill="#FFE9A0"/>
    {/* Pavillon — facets inférieurs */}
    <polygon points="70,90 88,95 80,140 60,128" fill="#A88018"/>
    <polygon points="130,90 112,95 120,140 140,128" fill="#7A5F0A"/>
    <polygon points="88,95 100,100 100,160 80,140" fill="#D4B135"/>
    <polygon points="112,95 100,100 100,160 120,140" fill="#B89220"/>
    <polygon points="60,128 80,140 100,160 100,165" fill="#5A4308"/>
    <polygon points="140,128 120,140 100,160 100,165" fill="#3F2E04"/>
    {/* Reflet spéculaire */}
    <polygon points="100,38 95,52 100,70" fill="#fff" opacity=".7"/>
  </svg>
);

// ═══ 6. JADE — cabochon rond profond ═══════════════════════════════════════
const GemJade = ({size=140}) => (
  <svg viewBox="0 0 200 200" width={size} height={size} style={{display:'block'}}>
    <defs>
      <radialGradient id="jade-halo" cx="50%" cy="50%" r="55%">
        <stop offset="0%" stopColor="#3D9B6E" stopOpacity=".30"/>
        <stop offset="100%" stopColor="#3D9B6E" stopOpacity="0"/>
      </radialGradient>
      <radialGradient id="jade-base" cx="38%" cy="35%" r="75%">
        <stop offset="0%" stopColor="#9DDBB7"/>
        <stop offset="45%" stopColor="#3D9B6E"/>
        <stop offset="100%" stopColor="#0E3D27"/>
      </radialGradient>
      <clipPath id="jade-clip"><circle cx="100" cy="100" r="62"/></clipPath>
    </defs>
    <circle cx="100" cy="100" r="92" fill="url(#jade-halo)"/>
    <Shadow rx={46} ry={6}/>
    <circle cx="100" cy="100" r="62" fill="url(#jade-base)"/>
    {/* Variations de teinte naturelles */}
    <g clipPath="url(#jade-clip)" opacity=".4">
      <ellipse cx="120" cy="120" rx="28" ry="20" fill="#0E3D27" transform="rotate(20 120 120)"/>
      <ellipse cx="80" cy="110" rx="18" ry="12" fill="#5BB888" transform="rotate(-15 80 110)"/>
    </g>
    {/* Sheen — reflet doux caractéristique du jade */}
    <ellipse cx="80" cy="78" rx="22" ry="14" fill="#fff" opacity=".4" transform="rotate(-30 80 78)"/>
    <ellipse cx="78" cy="76" rx="10" ry="5" fill="#fff" opacity=".5" transform="rotate(-30 78 76)"/>
    <circle cx="100" cy="100" r="62" fill="none" stroke="#000" strokeWidth=".5" opacity=".3"/>
  </svg>
);

// ═══ 7. SAPHIR — taille coussin (cushion cut) ══════════════════════════════
const GemSaphir = ({size=140}) => (
  <svg viewBox="0 0 200 200" width={size} height={size} style={{display:'block'}}>
    <defs>
      <radialGradient id="saphir-halo" cx="50%" cy="50%" r="55%">
        <stop offset="0%" stopColor="#3461C9" stopOpacity=".35"/>
        <stop offset="100%" stopColor="#3461C9" stopOpacity="0"/>
      </radialGradient>
    </defs>
    <circle cx="100" cy="100" r="92" fill="url(#saphir-halo)"/>
    <Shadow rx={48} ry={6}/>
    {/* Contour coussin (carré arrondi) */}
    <path d="M 50,55 Q 50,40 65,40 L 135,40 Q 150,40 150,55 L 150,145 Q 150,160 135,160 L 65,160 Q 50,160 50,145 Z"
          fill="#0F2654"/>
    {/* Couronne — table + 4 étoiles */}
    <polygon points="100,40 65,40 75,72 100,68" fill="#5985E0"/>
    <polygon points="100,40 135,40 125,72 100,68" fill="#3461C9"/>
    <polygon points="65,40 50,55 50,100 75,72" fill="#264AAB"/>
    <polygon points="135,40 150,55 150,100 125,72" fill="#1B3787"/>
    <polygon points="75,72 100,68 100,100 90,95" fill="#7AA0F0"/>
    <polygon points="125,72 100,68 100,100 110,95" fill="#4570D8"/>
    {/* Pavillon */}
    <polygon points="50,100 75,72 90,95 70,130" fill="#1B3787"/>
    <polygon points="150,100 125,72 110,95 130,130" fill="#0F2654"/>
    <polygon points="50,100 70,130 50,145" fill="#0A1A3D"/>
    <polygon points="150,100 130,130 150,145" fill="#06122A"/>
    <polygon points="90,95 100,100 110,95 130,130 100,160 70,130" fill="#264AAB"/>
    <polygon points="100,100 130,130 100,160 70,130" fill="#1B3787"/>
    <polygon points="50,145 70,130 100,160 65,160 50,145" fill="#0A1A3D"/>
    <polygon points="150,145 130,130 100,160 135,160 150,145" fill="#06122A"/>
    {/* Reflet — table */}
    <polygon points="78,52 92,48 92,62 78,66" fill="#fff" opacity=".55"/>
    <polygon points="100,40 100,68 95,55" fill="#fff" opacity=".4"/>
  </svg>
);

// ═══ 8. RUBIS — taille ovale brillant ═══════════════════════════════════════
const GemRubis = ({size=140}) => (
  <svg viewBox="0 0 200 200" width={size} height={size} style={{display:'block'}}>
    <defs>
      <radialGradient id="rubis-halo" cx="50%" cy="50%" r="55%">
        <stop offset="0%" stopColor="#C9344B" stopOpacity=".35"/>
        <stop offset="100%" stopColor="#C9344B" stopOpacity="0"/>
      </radialGradient>
    </defs>
    <circle cx="100" cy="100" r="92" fill="url(#rubis-halo)"/>
    <Shadow rx={44} ry={6}/>
    {/* Contour ovale */}
    <ellipse cx="100" cy="100" rx="50" ry="65" fill="#3D0A14"/>
    {/* Couronne ovale brillant */}
    <polygon points="100,35 70,55 100,70" fill="#E85870"/>
    <polygon points="100,35 130,55 100,70" fill="#C9344B"/>
    <polygon points="70,55 100,70 88,95 60,82" fill="#A82238"/>
    <polygon points="130,55 100,70 112,95 140,82" fill="#85182A"/>
    <polygon points="100,70 88,95 100,100 112,95" fill="#F08498"/>
    <polygon points="60,82 88,95 70,118 50,100" fill="#85182A"/>
    <polygon points="140,82 112,95 130,118 150,100" fill="#5C0E1C"/>
    {/* Pavillon */}
    <polygon points="50,100 70,118 80,148 60,140" fill="#5C0E1C"/>
    <polygon points="150,100 130,118 120,148 140,140" fill="#3D0A14"/>
    <polygon points="70,118 100,100 100,165 80,148" fill="#85182A"/>
    <polygon points="130,118 100,100 100,165 120,148" fill="#5C0E1C"/>
    <polygon points="60,140 80,148 100,165" fill="#2A060E"/>
    <polygon points="140,140 120,148 100,165" fill="#1A040A"/>
    {/* Reflet */}
    <polygon points="100,35 100,70 92,52" fill="#fff" opacity=".7"/>
    <polygon points="78,55 88,55 88,68 78,68" fill="#fff" opacity=".25"/>
  </svg>
);

// ═══ 9. ÉMERAUDE — taille émeraude (step cut rectangulaire) ═════════════════
const GemEmeraude = ({size=140}) => (
  <svg viewBox="0 0 200 200" width={size} height={size} style={{display:'block'}}>
    <defs>
      <radialGradient id="emeraude-halo" cx="50%" cy="50%" r="55%">
        <stop offset="0%" stopColor="#1F8A5B" stopOpacity=".35"/>
        <stop offset="100%" stopColor="#1F8A5B" stopOpacity="0"/>
      </radialGradient>
    </defs>
    <circle cx="100" cy="100" r="92" fill="url(#emeraude-halo)"/>
    <Shadow rx={44} ry={6}/>
    {/* Contour octogonal allongé (taille émeraude classique) */}
    <polygon points="70,30 130,30 160,60 160,140 130,170 70,170 40,140 40,60"
             fill="#0A2E1F"/>
    {/* Step cuts — gradins extérieurs */}
    <polygon points="70,30 130,30 140,42 60,42" fill="#3DAE7A"/>
    <polygon points="130,30 160,60 148,68 140,42" fill="#247A52"/>
    <polygon points="160,60 160,140 148,132 148,68" fill="#1A5C3E"/>
    <polygon points="160,140 130,170 140,158 148,132" fill="#0F4029"/>
    <polygon points="130,170 70,170 60,158 140,158" fill="#0A2E1F"/>
    <polygon points="70,170 40,140 52,132 60,158" fill="#0F4029"/>
    <polygon points="40,140 40,60 52,68 52,132" fill="#1A5C3E"/>
    <polygon points="40,60 70,30 60,42 52,68" fill="#247A52"/>
    {/* Step intermédiaire */}
    <polygon points="60,42 140,42 132,52 68,52" fill="#1F8A5B"/>
    <polygon points="140,42 148,68 138,72 132,52" fill="#155F3F"/>
    <polygon points="148,68 148,132 138,128 138,72" fill="#0A2E1F"/>
    <polygon points="148,132 140,158 132,148 138,128" fill="#155F3F"/>
    <polygon points="140,158 60,158 68,148 132,148" fill="#0A2E1F"/>
    <polygon points="60,158 52,132 62,128 68,148" fill="#155F3F"/>
    <polygon points="52,132 52,68 62,72 62,128" fill="#0A2E1F"/>
    <polygon points="52,68 60,42 68,52 62,72" fill="#155F3F"/>
    {/* Table centrale */}
    <polygon points="68,52 132,52 138,72 138,128 132,148 68,148 62,128 62,72"
             fill="#3DAE7A"/>
    {/* Lignes de step internes — caractéristique de la taille émeraude */}
    <polygon points="68,52 132,52 138,72 138,128 132,148 68,148 62,128 62,72"
             fill="none" stroke="#0A2E1F" strokeWidth="1" opacity=".6"/>
    <polygon points="76,62 124,62 130,75 130,125 124,138 76,138 70,125 70,75"
             fill="none" stroke="#0A2E1F" strokeWidth="1" opacity=".5"/>
    {/* Reflet table */}
    <polygon points="72,58 92,58 92,75 72,75" fill="#fff" opacity=".35"/>
  </svg>
);

// ═══ 10. DIAMANT — taille brillant ronde ════════════════════════════════════
const GemDiamant = ({size=140}) => (
  <svg viewBox="0 0 200 200" width={size} height={size} style={{display:'block'}}>
    <defs>
      <radialGradient id="diamant-halo" cx="50%" cy="50%" r="60%">
        <stop offset="0%" stopColor="#fff" stopOpacity=".35"/>
        <stop offset="50%" stopColor="#A8C8E0" stopOpacity=".25"/>
        <stop offset="100%" stopColor="#fff" stopOpacity="0"/>
      </radialGradient>
    </defs>
    <circle cx="100" cy="100" r="92" fill="url(#diamant-halo)"/>
    {/* Sparkles diffus */}
    <g opacity=".7">
      <circle cx="40" cy="45" r="1.5" fill="#fff"/>
      <circle cx="160" cy="60" r="1" fill="#fff"/>
      <circle cx="170" cy="135" r="1.5" fill="#fff"/>
      <circle cx="35" cy="155" r="1" fill="#fff"/>
    </g>
    <Shadow rx={42} ry={5}/>
    {/* Contour rond — couronne */}
    <circle cx="100" cy="100" r="58" fill="#1A2530"/>
    {/* 8 facets de couronne (kite) */}
    {[0,1,2,3,4,5,6,7].map(i=>{
      const a=i*45-90, a2=(i+1)*45-90;
      const r1=58, r2=32;
      const p1=[100+Math.cos(a*Math.PI/180)*r1, 100+Math.sin(a*Math.PI/180)*r1];
      const p2=[100+Math.cos(a2*Math.PI/180)*r1, 100+Math.sin(a2*Math.PI/180)*r1];
      const mid=[(p1[0]+p2[0])/2*0.7+100*0.3, (p1[1]+p2[1])/2*0.7+100*0.3];
      const colors=['#F0F8FF','#C8DCEF','#A8C0DC','#84A0BC','#6F8AA8','#84A0BC','#A8C0DC','#C8DCEF'];
      return <polygon key={i} points={`100,100 ${p1.join(',')} ${mid.join(',')} ${p2.join(',')}`} fill={colors[i]}/>;
    })}
    {/* Table centrale (octogonale) */}
    <polygon points="100,72 119,79 126,98 119,117 100,124 81,117 74,98 81,79"
             fill="#E8F4FF"/>
    <polygon points="100,72 119,79 126,98 119,117 100,124 81,117 74,98 81,79"
             fill="none" stroke="#5A7090" strokeWidth=".8" opacity=".6"/>
    {/* Reflets prismatiques (flares) */}
    <polygon points="100,72 95,90 100,98 105,90" fill="#fff" opacity=".75"/>
    <polygon points="84,82 78,98 88,92" fill="#FFD4F0" opacity=".5"/>
    <polygon points="118,118 124,102 112,108" fill="#A0D8FF" opacity=".5"/>
    {/* Étoile centrale */}
    <circle cx="100" cy="98" r="3" fill="#fff" opacity=".9"/>
  </svg>
);

// ═══ 11. LÉGENDAIRE — sceau d'obsidienne octogonale gravé d'or ══════════════
// Concept: au-delà du diamant (qui est minéral), le rang ultime est un OBJET
// — un sceau de l'Ordre des Explorateurs. Obsidienne polie noire,
// inlay d'or fin gravé d'une rosace des vents centrée sur un monument abstrait.
// Aura dorée pulsante.
const GemLegendaire = ({size=140, animate=true}) => (
  <svg viewBox="0 0 200 200" width={size} height={size} style={{display:'block'}}>
    <defs>
      <radialGradient id="leg-halo" cx="50%" cy="50%" r="55%">
        <stop offset="0%" stopColor="#F5C95A" stopOpacity=".55"/>
        <stop offset="40%" stopColor="#D4A642" stopOpacity=".3"/>
        <stop offset="100%" stopColor="#D4A642" stopOpacity="0"/>
      </radialGradient>
      <radialGradient id="leg-obs" cx="35%" cy="30%" r="80%">
        <stop offset="0%" stopColor="#3A2A4D"/>
        <stop offset="40%" stopColor="#1A0F2A"/>
        <stop offset="100%" stopColor="#000"/>
      </radialGradient>
      <linearGradient id="leg-gold" x1="0" y1="0" x2="1" y2="1">
        <stop offset="0%" stopColor="#FFE9A0"/>
        <stop offset="50%" stopColor="#D4A642"/>
        <stop offset="100%" stopColor="#7A5C1A"/>
      </linearGradient>
      <linearGradient id="leg-edge" x1="0" y1="0" x2="0" y2="1">
        <stop offset="0%" stopColor="#7A5C1A"/>
        <stop offset="50%" stopColor="#D4A642"/>
        <stop offset="100%" stopColor="#3A2A0A"/>
      </linearGradient>
    </defs>
    {/* Aura dorée pulsante */}
    <circle cx="100" cy="100" r="95" fill="url(#leg-halo)">
      {animate && <animate attributeName="r" values="92;98;92" dur="3.5s" repeatCount="indefinite"/>}
      {animate && <animate attributeName="opacity" values=".9;1;.9" dur="3.5s" repeatCount="indefinite"/>}
    </circle>
    <Shadow rx={50} ry={6} o={.7}/>
    {/* Forme octogonale — sceau */}
    <polygon points="78,28 122,28 162,58 172,100 162,142 122,172 78,172 38,142 28,100 38,58"
             fill="url(#leg-edge)"/>
    <polygon points="80,34 120,34 156,62 165,100 156,138 120,166 80,166 44,138 35,100 44,62"
             fill="url(#leg-obs)"/>
    {/* Bordure intérieure gravée */}
    <polygon points="80,34 120,34 156,62 165,100 156,138 120,166 80,166 44,138 35,100 44,62"
             fill="none" stroke="url(#leg-gold)" strokeWidth="1.2" opacity=".9"/>
    {/* Anneau gravé concentrique */}
    <polygon points="86,46 114,46 146,68 152,100 146,132 114,154 86,154 54,132 48,100 54,68"
             fill="none" stroke="url(#leg-gold)" strokeWidth=".8" opacity=".7"/>
    {/* Rosace des vents — branche cardinale (gravée or) */}
    <g stroke="url(#leg-gold)" fill="url(#leg-gold)" strokeLinejoin="round">
      {/* 8 pointes */}
      <polygon points="100,55 104,98 100,104 96,98" opacity=".9"/>
      <polygon points="100,145 104,102 100,96 96,102" opacity=".9"/>
      <polygon points="55,100 98,96 104,100 98,104" opacity=".9"/>
      <polygon points="145,100 102,96 96,100 102,104" opacity=".9"/>
      {/* Diagonales plus fines */}
      <polygon points="70,70 97,97 100,100 97,100" opacity=".55"/>
      <polygon points="130,70 103,97 100,100 100,97" opacity=".55"/>
      <polygon points="70,130 97,103 100,100 97,100" opacity=".55"/>
      <polygon points="130,130 103,103 100,100 100,103" opacity=".55"/>
    </g>
    {/* Centre — petit dôme façon monument stylisé (Panthéon abstrait) */}
    <circle cx="100" cy="100" r="9" fill="url(#leg-gold)"/>
    <circle cx="100" cy="100" r="9" fill="none" stroke="#3A2A0A" strokeWidth=".6"/>
    <rect x="97" y="91" width="6" height="3" fill="url(#leg-gold)"/>
    {/* Petites étoiles aux coins */}
    {[[60,60],[140,60],[60,140],[140,140]].map(([x,y],i)=>(
      <circle key={i} cx={x} cy={y} r="1.6" fill="url(#leg-gold)" opacity=".8">
        {animate && <animate attributeName="opacity" values=".4;1;.4" dur="2.5s" begin={`${i*.3}s`} repeatCount="indefinite"/>}
      </circle>
    ))}
    {/* Reflet sur l'obsidienne */}
    <polygon points="80,34 120,34 110,60 88,58" fill="#fff" opacity=".12"/>
  </svg>
);

// ═══ Glyphe variant — médaille gravée minimaliste (alt style) ═══════════════
const GemGlyph = ({color='#A8C4D6', label='C', size=140}) => (
  <svg viewBox="0 0 200 200" width={size} height={size} style={{display:'block'}}>
    <defs>
      <radialGradient id={`gly-${label}-h`} cx="50%" cy="50%" r="55%">
        <stop offset="0%" stopColor={color} stopOpacity=".25"/>
        <stop offset="100%" stopColor={color} stopOpacity="0"/>
      </radialGradient>
      <linearGradient id={`gly-${label}-r`} x1="0" y1="0" x2="0" y2="1">
        <stop offset="0%" stopColor="#3A3A3D"/>
        <stop offset="100%" stopColor="#1A1A1D"/>
      </linearGradient>
    </defs>
    <circle cx="100" cy="100" r="92" fill={`url(#gly-${label}-h)`}/>
    <Shadow rx={44} ry={5}/>
    <circle cx="100" cy="100" r="62" fill={`url(#gly-${label}-r)`} stroke={color} strokeWidth="1.5"/>
    <circle cx="100" cy="100" r="54" fill="none" stroke={color} strokeWidth=".6" opacity=".5"/>
    <text x="100" y="118" textAnchor="middle" fontFamily="Crimson Pro, serif" fontSize="48" fontWeight="600" fill={color}>{label}</text>
  </svg>
);

// ═══ Abstract variant — aplat géométrique sobre (alt style) ═════════════════
const GemAbstract = ({color='#A8C4D6', shape='hex', size=140}) => {
  const shapes = {
    hex: 'M 100,30 L 152,60 L 152,140 L 100,170 L 48,140 L 48,60 Z',
    diamond: 'M 100,30 L 160,100 L 100,170 L 40,100 Z',
    circle: null,
    oval: null,
  };
  return (
    <svg viewBox="0 0 200 200" width={size} height={size} style={{display:'block'}}>
      <defs>
        <radialGradient id={`abs-${color.slice(1)}-h`} cx="50%" cy="50%" r="55%">
          <stop offset="0%" stopColor={color} stopOpacity=".25"/>
          <stop offset="100%" stopColor={color} stopOpacity="0"/>
        </radialGradient>
        <linearGradient id={`abs-${color.slice(1)}-g`} x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stopColor={color}/>
          <stop offset="100%" stopColor={color} stopOpacity=".4"/>
        </linearGradient>
      </defs>
      <circle cx="100" cy="100" r="92" fill={`url(#abs-${color.slice(1)}-h)`}/>
      <Shadow rx={44} ry={5}/>
      {shape==='circle' ? <circle cx="100" cy="100" r="62" fill={`url(#abs-${color.slice(1)}-g)`}/> :
       shape==='oval' ? <ellipse cx="100" cy="100" rx="50" ry="64" fill={`url(#abs-${color.slice(1)}-g)`}/> :
       <path d={shapes[shape]} fill={`url(#abs-${color.slice(1)}-g)`}/>}
      <path d="M 100,30 L 100,170" stroke="#fff" strokeWidth=".6" opacity=".25" pointerEvents="none"/>
    </svg>
  );
};

// ═══ Map id → component (réaliste par défaut) ═══════════════════════════════
const GEM_REALISTIC = {
  cristal: GemCristal, opale: GemOpale, turquoise: GemTurquoise, ambre: GemAmbre,
  topaze: GemTopaze, jade: GemJade, saphir: GemSaphir, rubis: GemRubis,
  emeraude: GemEmeraude, diamant: GemDiamant, legendaire: GemLegendaire,
};

const GEM_GLYPH_LABELS = {
  cristal:'C', opale:'O', turquoise:'T', ambre:'A', topaze:'T',
  jade:'J', saphir:'S', rubis:'R', emeraude:'É', diamant:'D', legendaire:'★',
};

const GEM_ABSTRACT_SHAPES = {
  cristal:'hex', opale:'oval', turquoise:'circle', ambre:'hex', topaze:'diamond',
  jade:'circle', saphir:'diamond', rubis:'oval', emeraude:'hex', diamant:'diamond', legendaire:'hex',
};

// Universal renderer — choisit le style selon le mode
const Gem = ({id, size=140, style='realistic', animate=true}) => {
  const meta = GEM_DATA.find(g=>g.id===id);
  if (!meta) return null;
  if (style==='glyph') return <GemGlyph color={meta.halo} label={GEM_GLYPH_LABELS[id]} size={size}/>;
  if (style==='abstract') return <GemAbstract color={meta.halo} shape={GEM_ABSTRACT_SHAPES[id]} size={size}/>;
  const C = GEM_REALISTIC[id];
  return id==='legendaire' ? <C size={size} animate={animate}/> : <C size={size}/>;
};

Object.assign(window, {
  GEM_DATA, Gem,
  GemCristal, GemOpale, GemTurquoise, GemAmbre, GemTopaze, GemJade,
  GemSaphir, GemRubis, GemEmeraude, GemDiamant, GemLegendaire,
});
