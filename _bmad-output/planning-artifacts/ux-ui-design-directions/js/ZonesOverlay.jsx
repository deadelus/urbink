'use strict';
// ─── Zones Overlay — 6 variations for Paris arrondissements & quartiers ──────
// Each variation exports a <ZonesVariant N /> component that renders on top of
// the Urbink MapView at a given zoom level ('far' = arrondissements, 'near' = quartiers).

const PARIS_COLORS = {
  primary:'#256F4C', primaryLight:'#4A9070', primaryDark:'#1a5438',
  accent:'#F59E0B', accentDark:'#B8832E',
  mapBg:'#E8E4D8', mapFg:'#D6D0C2',
  ink:'#0F172A', muted:'#64748B',
};

// ─── Shared MapShell — mini Paris map used inside each phone frame ───────────
// Renders the Urbink map style (beige, parks, buildings hints, Seine) AND
// lets children render overlay SVG layered on top.
const MapShell = ({children, zoom='far', width=390, height=520}) => {
  const {ARRONDISSEMENTS, QUARTIERS_4E, SEINE_PATH, PARIS_OUTLINE} = window;
  // Far viewBox shows all of Paris; near zooms into the 4e arrondissement.
  const vb = zoom==='far' ? '30 60 420 360' : '150 150 260 220';

  // Soft "underlay" — simulates the OSM-style urban texture beneath the overlay.
  return (
    <svg viewBox={vb} preserveAspectRatio="xMidYMid slice"
      style={{position:'absolute',inset:0,width:'100%',height:'100%',background:PARIS_COLORS.mapBg}}>
      {/* Grid texture */}
      <defs>
        <pattern id="pgrid" width="32" height="32" patternUnits="userSpaceOnUse">
          <path d="M32 0H0V32" fill="none" stroke="#D6D0C2" strokeWidth="0.4" opacity=".5"/>
        </pattern>
        <pattern id="diagStripes" width="6" height="6" patternUnits="userSpaceOnUse" patternTransform="rotate(45)">
          <line x1="0" y1="0" x2="0" y2="6" stroke="#256F4C" strokeWidth="1.6" opacity=".18"/>
        </pattern>
      </defs>
      <rect x="0" y="0" width="520" height="480" fill="url(#pgrid)"/>

      {/* Subtle park patches */}
      {[{x:45,y:220,w:28,h:55},{x:410,y:280,w:22,h:40},{x:250,y:90,w:18,h:28},
        {x:155,y:320,w:24,h:35},{x:380,y:130,w:20,h:30}].map((p,i)=>
        <rect key={i} x={p.x} y={p.y} width={p.w} height={p.h} rx="3" fill="#C5D5A8" opacity=".6"/>
      )}

      {/* Seine */}
      <path d={SEINE_PATH} fill="none" stroke="#B0CDE8" strokeWidth="14" opacity=".55" strokeLinecap="round"/>
      <path d={SEINE_PATH} fill="none" stroke="#C8DFF0" strokeWidth="8" opacity=".7" strokeLinecap="round"/>

      {/* Faint historical street grid — implied, not literal */}
      <g opacity=".35" stroke="#BFB9AF" strokeWidth="1.4" strokeLinecap="round">
        <line x1="80" y1="180" x2="430" y2="180"/>
        <line x1="80" y1="250" x2="430" y2="250"/>
        <line x1="80" y1="325" x2="430" y2="325"/>
        <line x1="150" y1="90" x2="150" y2="380"/>
        <line x1="250" y1="90" x2="250" y2="380"/>
        <line x1="340" y1="90" x2="340" y2="380"/>
      </g>

      {/* Sparse explored streets (primary green) */}
      <g stroke={PARIS_COLORS.primary} strokeWidth="2" opacity=".78" strokeLinecap="round">
        <line x1="210" y1="250" x2="310" y2="250"/>
        <line x1="250" y1="180" x2="250" y2="290"/>
        <line x1="285" y1="220" x2="330" y2="280"/>
      </g>

      {children}
    </svg>
  );
};

// ═══════ V1 — Contour pointillé minimal ══════════════════════════════════════
// Most restrained: dashed outlines only, hairline thin, matching border token.
const V1_DottedOutline = ({zoom}) => {
  const data = zoom==='far' ? window.ARRONDISSEMENTS : window.QUARTIERS_4E;
  return (
    <g>
      {data.map(z => (
        <g key={z.id}>
          <polygon points={z.poly} fill="none"
            stroke={PARIS_COLORS.ink} strokeOpacity=".35"
            strokeWidth={zoom==='far'?1.2:1.4}
            strokeDasharray="3,2.5" strokeLinejoin="round"/>
        </g>
      ))}
      {data.map(z => (
        <text key={'t'+z.id} x={z.cx} y={z.cy+2}
          textAnchor="middle" fontSize={zoom==='far'?11:9}
          fontFamily="Inter, sans-serif" fontWeight="500"
          fill={PARIS_COLORS.muted} style={{letterSpacing:'.5px'}}>
          {zoom==='far'?z.num:z.name.toUpperCase()}
        </text>
      ))}
    </g>
  );
};

// ═══════ V2 — Teinte progressive verte (data-driven choropleth) ══════════════
// Fill opacity scales with exploration %. The more you've walked, the greener.
const V2_ProgressTint = ({zoom}) => {
  const data = zoom==='far' ? window.ARRONDISSEMENTS : window.QUARTIERS_4E;
  return (
    <g>
      {data.map(z => {
        const op = 0.08 + (z.pct/100) * 0.42; // 0.08 → 0.50
        return (
          <polygon key={z.id} points={z.poly}
            fill={PARIS_COLORS.primary} fillOpacity={op}
            stroke={PARIS_COLORS.primary} strokeOpacity=".55"
            strokeWidth="0.8" strokeLinejoin="round"/>
        );
      })}
      {data.map(z => (
        <g key={'l'+z.id} transform={`translate(${z.cx},${z.cy})`}>
          <text textAnchor="middle" fontSize={zoom==='far'?10:8.5}
            fontFamily="Inter,sans-serif" fontWeight="700"
            fill={z.pct>60?'#fff':PARIS_COLORS.primaryDark}>
            {zoom==='far'?z.num:z.name.split(' ')[0]}
          </text>
          <text y={zoom==='far'?11:9} textAnchor="middle"
            fontSize={zoom==='far'?7:6}
            fontFamily="Inter,sans-serif" fontWeight="600"
            fill={z.pct>60?'rgba(255,255,255,.85)':PARIS_COLORS.muted}>
            {z.pct}%
          </text>
        </g>
      ))}
    </g>
  );
};

// ═══════ V3 — Découpe papier (paper-cut shadows, editorial) ══════════════════
const V3_PaperCut = ({zoom}) => {
  const data = zoom==='far' ? window.ARRONDISSEMENTS : window.QUARTIERS_4E;
  return (
    <g>
      <defs>
        <filter id="papercut" x="-10%" y="-10%" width="120%" height="120%">
          <feDropShadow dx="1" dy="2" stdDeviation="1.2" floodOpacity="0.18"/>
        </filter>
      </defs>
      {data.map(z => {
        // Palette: cycle two tones of ivory so adjacent pieces read distinct
        const isEven = z.id % 2 === 0;
        return (
          <polygon key={z.id} points={z.poly}
            fill={isEven?'#F5F1E6':'#EEE8D6'}
            stroke="#BDB296" strokeWidth="0.6" strokeLinejoin="round"
            filter="url(#papercut)"/>
        );
      })}
      {/* Progress "seal" — tiny filled circle on each piece */}
      {data.map(z => (
        <g key={'s'+z.id} transform={`translate(${z.cx},${z.cy})`}>
          <circle r={zoom==='far'?7:9} fill={PARIS_COLORS.primary} opacity={0.15+z.pct/300}/>
          <text textAnchor="middle" y="1" fontSize={zoom==='far'?8:9}
            fontFamily="Crimson Pro,serif" fontWeight="700"
            fill={PARIS_COLORS.primaryDark}>
            {zoom==='far'?z.num:z.name.split(/[\s-]/)[0].slice(0,4)}
          </text>
        </g>
      ))}
    </g>
  );
};

// ═══════ V4 — Étiquettes ancrées (cartographic labels + Crimson numerals) ════
// Inspired by real Parisian tourist maps: outlined zones, serif numerals float.
const V4_CartographicLabels = ({zoom}) => {
  const data = zoom==='far' ? window.ARRONDISSEMENTS : window.QUARTIERS_4E;
  return (
    <g>
      {data.map(z => (
        <polygon key={z.id} points={z.poly}
          fill={PARIS_COLORS.primary} fillOpacity=".05"
          stroke={PARIS_COLORS.primaryDark} strokeOpacity=".55"
          strokeWidth="1.2" strokeLinejoin="round"/>
      ))}
      {data.map(z => (
        <g key={'l'+z.id} transform={`translate(${z.cx},${z.cy})`}>
          {zoom==='far' ? (
            <>
              <circle r="11" fill="#fff" stroke={PARIS_COLORS.primary} strokeWidth="1.3"/>
              <text textAnchor="middle" y="4.5"
                fontSize="13" fontFamily="Crimson Pro,serif" fontWeight="700"
                fill={PARIS_COLORS.primaryDark}>{z.num}</text>
              <text textAnchor="middle" y="21"
                fontSize="6" fontFamily="Inter,sans-serif" fontWeight="600"
                fill={PARIS_COLORS.muted}
                style={{letterSpacing:'1px',textTransform:'uppercase'}}>
                {z.name.slice(0,10)}
              </text>
            </>
          ) : (
            <>
              <rect x="-28" y="-9" width="56" height="18" rx="4"
                fill="#fff" stroke={PARIS_COLORS.primary} strokeWidth="1"/>
              <text textAnchor="middle" y="4"
                fontSize="7.5" fontFamily="Crimson Pro,serif" fontWeight="700"
                fill={PARIS_COLORS.primaryDark}>{z.name}</text>
            </>
          )}
        </g>
      ))}
    </g>
  );
};

// ═══════ V5 — Heatmap ambre inversée (focus on what's NOT explored) ══════════
// Bolder: zones with low exploration glow amber, urging the user to go there.
const V5_InverseHeatmap = ({zoom}) => {
  const data = zoom==='far' ? window.ARRONDISSEMENTS : window.QUARTIERS_4E;
  return (
    <g>
      <defs>
        <radialGradient id="amberGlow">
          <stop offset="0%" stopColor={PARIS_COLORS.accent} stopOpacity=".55"/>
          <stop offset="100%" stopColor={PARIS_COLORS.accent} stopOpacity="0"/>
        </radialGradient>
      </defs>
      {data.map(z => {
        const unexplored = 1 - z.pct/100;
        // Amber fill for unexplored, green fill for explored
        const isUnexplored = z.pct < 40;
        return (
          <g key={z.id}>
            <polygon points={z.poly}
              fill={isUnexplored ? PARIS_COLORS.accent : PARIS_COLORS.primary}
              fillOpacity={isUnexplored ? 0.15 + unexplored*0.3 : 0.08 + (z.pct/100)*0.18}
              stroke={isUnexplored?PARIS_COLORS.accentDark:PARIS_COLORS.primary}
              strokeOpacity={isUnexplored?".55":".45"}
              strokeWidth="1" strokeLinejoin="round"/>
            {isUnexplored && (
              <circle cx={z.cx} cy={z.cy} r={zoom==='far'?16:22}
                fill="url(#amberGlow)"/>
            )}
          </g>
        );
      })}
      {data.map(z => {
        const isUnex = z.pct < 40;
        return (
          <g key={'l'+z.id} transform={`translate(${z.cx},${z.cy})`}>
            <text textAnchor="middle" y="-1"
              fontSize={zoom==='far'?10:9} fontFamily="Inter,sans-serif" fontWeight="700"
              fill={isUnex?PARIS_COLORS.accentDark:PARIS_COLORS.primaryDark}>
              {zoom==='far'?z.num:z.name.split(/[\s-]/)[0]}
            </text>
            <text textAnchor="middle" y={zoom==='far'?9:8}
              fontSize={zoom==='far'?6.5:6} fontFamily="Inter,sans-serif" fontWeight="600"
              fill={isUnex?PARIS_COLORS.accentDark:PARIS_COLORS.primary}
              opacity=".8">
              {z.pct}%
            </text>
          </g>
        );
      })}
    </g>
  );
};

// ═══════ V6 — Pastilles flottantes + contour hairline ════════════════════════
// Bold idea: zone fill is a soft striped pattern (diagonal stripes = terrain
// vague / zone non-visitée); floating pill in Crimson Pro shows number + %.
const V6_StripedPill = ({zoom}) => {
  const data = zoom==='far' ? window.ARRONDISSEMENTS : window.QUARTIERS_4E;
  return (
    <g>
      {/* Zone fills: solid-green if >50%, striped otherwise */}
      {data.map(z => (
        <polygon key={z.id} points={z.poly}
          fill={z.pct>=50 ? PARIS_COLORS.primary : 'url(#diagStripes)'}
          fillOpacity={z.pct>=50 ? (0.15+z.pct/400) : 1}
          stroke={PARIS_COLORS.primaryDark} strokeOpacity=".45"
          strokeWidth="0.7" strokeLinejoin="round"/>
      ))}
      {/* Floating pills */}
      {data.map(z => {
        const complete = z.pct >= 80;
        return (
          <g key={'p'+z.id} transform={`translate(${z.cx},${z.cy})`}>
            <rect x={zoom==='far'?-14:-22} y="-8"
              width={zoom==='far'?28:44} height="16" rx="8"
              fill={complete?PARIS_COLORS.accent:'#fff'}
              stroke={complete?PARIS_COLORS.accentDark:PARIS_COLORS.primary}
              strokeWidth="0.9"
              style={{filter:'drop-shadow(0 1px 2px rgba(0,0,0,.15))'}}/>
            {zoom==='far' ? (
              <text textAnchor="middle" y="3.8"
                fontSize="9" fontFamily="Crimson Pro,serif" fontWeight="700"
                fill={complete?'#fff':PARIS_COLORS.primaryDark}>
                {z.num}<tspan fontSize="6" fontWeight="600" fill={complete?'#fff':PARIS_COLORS.muted}>·{z.pct}%</tspan>
              </text>
            ) : (
              <text textAnchor="middle" y="3.5"
                fontSize="7" fontFamily="Crimson Pro,serif" fontWeight="700"
                fill={complete?'#fff':PARIS_COLORS.primaryDark}>
                {z.name.slice(0,11)}
              </text>
            )}
          </g>
        );
      })}
    </g>
  );
};

Object.assign(window, {MapShell, V1_DottedOutline, V2_ProgressTint, V3_PaperCut, V4_CartographicLabels, V5_InverseHeatmap, V6_StripedPill, PARIS_COLORS});
