'use strict';
// ─── V1 Color Variants — per-quartier hue + opacity-by-progress ──────────────
// Core idea: each arrondissement gets its own color (categorical palette),
// fill opacity scales with exploration % but caps so you can still see the
// streets & landmarks under the overlay (max 0.55).

const PARIS_COLORS = window.PARIS_COLORS;

// ─── Palette A: Métro-inspired (the 20 lines of Paris metro, roughly) ────────
// Distinct, saturated, reads like a transit map.
const METRO_PALETTE = [
  '#FFCE00', // 1 - jaune
  '#0064B0', // 2 - bleu
  '#9F9825', // 3 - olive
  '#C04191', // 4 - magenta
  '#F28E42', // 5 - orange
  '#83C491', // 6 - vert d'eau
  '#F3A4BA', // 7 - rose
  '#CEADD2', // 8 - lilas
  '#D5C900', // 9 - jaune-vert
  '#E3B32A', // 10 - moutarde
  '#8D5E2A', // 11 - brun
  '#007E49', // 12 - vert foncé
  '#6EC4E8', // 13 - cyan
  '#62259D', // 14 - violet
  '#B90845', // 15 - bordeaux (RER)
  '#F0B6C2', // 16 - rose pâle
  '#888888', // 17 - gris
  '#007C6E', // 18 - teal
  '#BDE2B5', // 19 - vert pâle
  '#79CBA8', // 20 - menthe
];

// ─── Palette B: Earthy cartographic (muted, editorial, feels like a field guide)
const EARTHY_PALETTE = [
  '#B8734A','#8B6F47','#A89968','#6B8E5A','#4A7C6F',
  '#5C7C9E','#7B6B9E','#9E6B8B','#B86B6B','#C48A5C',
  '#8E7953','#5C8B6B','#7E9C7C','#A8A878','#9E8E5C',
  '#78956B','#6B7C9E','#8B6B78','#9E7C6B','#B89E7C',
];

// ─── Palette C: Seasonal (spring/summer hues, bright but low-sat)
const SEASONAL_PALETTE = [
  '#E9A78F','#F4C976','#D6E086','#A8D9A0','#8DD1C6',
  '#92C8E6','#A3ADE5','#C7A4D8','#E69ACB','#F0A5B0',
  '#D9B896','#B5C98E','#9BD4B5','#93C7DA','#A8B3E1',
  '#C9A2DD','#E9A3C9','#EAC498','#CBCC92','#9FD5AE',
];

// Build a color map indexed by arrondissement id
const colorByArr = (palette) => {
  const m = {};
  (window.ARRONDISSEMENTS || []).forEach((a,i)=> m[a.id] = palette[i % palette.length]);
  return m;
};

// Opacity ramp: 0.08 (empty) → 0.55 (full) — always see-through
const opacityByPct = (pct) => 0.08 + (pct/100) * 0.47;

// ─── Generic V1-per-arr renderer ─────────────────────────────────────────────
// dashStyle: how the border renders. labelStyle: where/how numbers sit.
const V1PerArr = ({zoom, palette, dashStyle='dashed', labelStyle='muted', strokeMode='border'}) => {
  const data = zoom==='far' ? window.ARRONDISSEMENTS : window.QUARTIERS_4E;
  // For zoomed quartiers, pick colors from a sub-slice of the palette
  const colors = zoom==='far' ? colorByArr(palette) : {
    '4a':palette[3], '4b':palette[7], '4c':palette[11], '4d':palette[15],
  };

  const stroke = (c)=>{
    if (dashStyle==='dashed')  return {strokeDasharray:'3,2.5'};
    if (dashStyle==='dotted')  return {strokeDasharray:'1,3'};
    if (dashStyle==='solid')   return {};
    return {};
  };

  return (
    <g>
      {data.map(z => {
        const c = colors[z.id];
        const op = opacityByPct(z.pct);
        return (
          <polygon key={z.id} points={z.poly}
            fill={c} fillOpacity={op}
            stroke={c} strokeOpacity={strokeMode==='border'?0.7:0.0}
            strokeWidth={zoom==='far'?1.2:1.6}
            strokeLinejoin="round"
            {...stroke(c)}/>
        );
      })}
      {data.map(z => {
        const c = colors[z.id];
        // darken stroke-ish for label contrast
        return (
          <g key={'t'+z.id} transform={`translate(${z.cx},${z.cy})`}>
            {labelStyle==='pill' && (
              <rect x={zoom==='far'?-13:-28} y="-8.5"
                width={zoom==='far'?26:56} height="17" rx="8.5"
                fill="#fff" fillOpacity=".85"
                stroke={c} strokeOpacity=".7" strokeWidth="0.9"/>
            )}
            {labelStyle==='plain' && (
              <text textAnchor="middle" y={zoom==='far'?4:3.5}
                fontSize={zoom==='far'?11.5:9}
                fontFamily="Inter,sans-serif" fontWeight="700"
                fill={c}>
                {zoom==='far'?z.num:z.name}
              </text>
            )}
            {labelStyle==='pill' && (
              <text textAnchor="middle" y={zoom==='far'?4:3.5}
                fontSize={zoom==='far'?10.5:8}
                fontFamily="Inter,sans-serif" fontWeight="700"
                fill={c}>
                {zoom==='far'?z.num:z.name}
              </text>
            )}
            {labelStyle==='muted' && (
              <text textAnchor="middle" y={zoom==='far'?4:3.5}
                fontSize={zoom==='far'?10:8.5}
                fontFamily="Inter,sans-serif" fontWeight="600"
                fill={PARIS_COLORS.ink} opacity=".75"
                style={{letterSpacing:'.4px'}}>
                {zoom==='far'?z.num:z.name}
              </text>
            )}
            {labelStyle==='serif' && (
              <>
                <circle r={zoom==='far'?11:14}
                  fill="#fff" fillOpacity=".88"
                  stroke={c} strokeWidth="1.3"/>
                <text textAnchor="middle" y={zoom==='far'?4.2:4.8}
                  fontSize={zoom==='far'?12:11}
                  fontFamily="Crimson Pro,serif" fontWeight="700"
                  fill={c}>
                  {zoom==='far'?z.num:z.name.slice(0,3)}
                </text>
              </>
            )}
          </g>
        );
      })}
    </g>
  );
};

Object.assign(window, {V1PerArr, METRO_PALETTE, EARTHY_PALETTE, SEASONAL_PALETTE});
