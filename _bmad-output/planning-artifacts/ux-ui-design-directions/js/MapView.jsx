'use strict';
// ─── Map View — SVG street map with live exploration coloring ─────────────────

const STREET_SEGS = [
  // Main horizontals
  {id:0,x1:0,y1:180,x2:390,y2:180,w:5},
  {id:1,x1:0,y1:310,x2:390,y2:310,w:5},
  {id:2,x1:0,y1:440,x2:390,y2:440,w:5},
  {id:3,x1:0,y1:570,x2:390,y2:570,w:4},
  // Secondary horizontals
  {id:4,x1:0,y1:110,x2:210,y2:110,w:3},
  {id:5,x1:80,y1:245,x2:390,y2:245,w:3},
  {id:6,x1:0,y1:375,x2:300,y2:375,w:3},
  {id:7,x1:120,y1:505,x2:390,y2:505,w:3},
  {id:8,x1:0,y1:635,x2:260,y2:635,w:3},
  // Main verticals
  {id:9,x1:100,y1:0,x2:100,y2:760,w:5},
  {id:10,x1:220,y1:0,x2:220,y2:760,w:5},
  {id:11,x1:330,y1:80,x2:330,y2:760,w:4},
  // Secondary verticals
  {id:12,x1:50,y1:100,x2:50,y2:440,w:3},
  {id:13,x1:160,y1:0,x2:160,y2:310,w:3},
  {id:14,x1:275,y1:180,x2:275,y2:570,w:3},
  {id:15,x1:370,y1:310,x2:370,y2:760,w:3},
  // Diagonals (Haussmann)
  {id:16,x1:0,y1:140,x2:220,y2:310,w:4,diag:true},
  {id:17,x1:160,y1:0,x2:390,y2:280,w:4,diag:true},
  {id:18,x1:0,y1:480,x2:180,y2:635,w:3,diag:true},
  {id:19,x1:220,y1:440,x2:390,y2:560,w:3,diag:true},
  // Small cross streets
  {id:20,x1:0,y1:70,x2:100,y2:70,w:2.5},
  {id:21,x1:100,y1:420,x2:220,y2:420,w:2.5},
  {id:22,x1:220,y1:350,x2:330,y2:350,w:2.5},
  {id:23,x1:50,y1:530,x2:100,y2:530,w:2.5},
  {id:24,x1:330,y1:490,x2:390,y2:490,w:2.5},
];

// Streets "already explored" before session starts
const HISTORICAL_STREETS = new Set([0,1,4,5,9,10,12,13,16,20,21]);

const PARKS = [
  {x:22,y:60,w:68,h:42},
  {x:130,y:48,w:22,h:55},
  {x:235,y:88,w:80,h:52},
  {x:340,y:330,w:42,h:70},
  {x:10,y:340,w:32,h:80},
  {x:148,y:460,w:64,h:70},
];

const BUILDINGS = [
  {x:110,y:18,w:42,h:34},{x:165,y:18,w:44,h:30},{x:232,y:18,w:84,h:40},
  {x:10,y:195,w:32,h:40},{x:56,y:195,w:32,h:38},{x:110,y:195,w:96,h:44},
  {x:232,y:195,w:30,h:42},{x:342,y:195,w:40,h:44},
  {x:10,y:260,w:36,h:38},{x:56,y:260,w:22,h:36},{x:110,y:327,w:42,h:38},
  {x:168,y:320,w:40,h:38},{x:232,y:327,w:40,h:38},{x:340,y:327,w:40,h:38},
  {x:10,y:460,w:28,h:34},{x:56,y:460,w:40,h:34},{x:110,y:456,w:26,h:28},
  {x:232,y:456,w:36,h:38},{x:342,y:456,w:40,h:38},
  {x:10,y:590,w:38,h:34},{x:56,y:590,w:26,h:32},{x:108,y:590,w:100,h:34},
  {x:232,y:590,w:88,h:38},{x:342,y:590,w:40,h:38},
];

// POI markers on the map
const POI_MARKERS = [
  {x:100,y:180,label:'🏛️'},{x:220,y:310,label:'🌿'},{x:330,y:440,label:'☕'},
  {x:160,y:500,label:'🏛️'},{x:60,y:375,label:'🌿'},
];

const MapView = ({exploredStreets, sessionActive, top=50, bottom=74, showUserDot=true}) => {
  const {React} = window;
  const [userPos, setUserPos] = React.useState({x:195,y:340});

  // Animate user dot during session
  React.useEffect(()=>{
    if (!sessionActive) return;
    const positions = [
      {x:195,y:340},{x:220,y:310},{x:220,y:245},{x:275,y:245},{x:275,y:180},
      {x:330,y:180},{x:330,y:245},{x:390,y:245},{x:275,y:375},{x:220,y:440},
    ];
    let idx = 0;
    const iv = setInterval(()=>{
      idx = (idx+1) % positions.length;
      setUserPos(positions[idx]);
    }, 2800);
    return ()=>clearInterval(iv);
  },[sessionActive]);

  const allExplored = new Set([...HISTORICAL_STREETS, ...exploredStreets]);

  return (
    <div style={{position:'absolute',top,left:0,right:0,bottom,overflow:'hidden'}}>
      <svg viewBox="0 0 390 760" preserveAspectRatio="xMidYMid slice"
        style={{width:'100%',height:'100%'}}>

        {/* Background */}
        <rect width="390" height="760" fill="#E8E4D8"/>

        {/* Subtle grid */}
        <defs>
          <pattern id="mapgrid" width="46" height="46" patternUnits="userSpaceOnUse">
            <path d="M46 0H0V46" fill="none" stroke="#D6D0C2" strokeWidth="0.5" opacity="0.6"/>
          </pattern>
        </defs>
        <rect width="390" height="760" fill="url(#mapgrid)" opacity="0.5"/>

        {/* Parks */}
        {PARKS.map((p,i)=>
          <rect key={i} x={p.x} y={p.y} width={p.w} height={p.h} rx="5" fill="#C5D5A8" opacity="0.65"/>
        )}

        {/* Buildings */}
        {BUILDINGS.map((b,i)=>
          <rect key={i} x={b.x} y={b.y} width={b.w} height={b.h} rx="2" fill="#CEC9BD"/>
        )}

        {/* Historical streets (unexplored, faint) */}
        {STREET_SEGS.map(s=>
          !allExplored.has(s.id) &&
          <line key={s.id} x1={s.x1} y1={s.y1} x2={s.x2} y2={s.y2}
            stroke="#BFB9AF" strokeWidth={s.w} strokeLinecap="round" opacity="0.5"/>
        )}

        {/* Explored streets (green, animated in) */}
        {STREET_SEGS.map(s=>
          allExplored.has(s.id) &&
          <line key={s.id} x1={s.x1} y1={s.y1} x2={s.x2} y2={s.y2}
            stroke="#256F4C" strokeWidth={s.w+1} strokeLinecap="round" opacity="0.78"
            style={{transition:'stroke-dashoffset 1s ease'}}/>
        )}

        {/* Session active: current path highlight */}
        {sessionActive && (
          <polyline
            points="195,340 220,310 220,245 275,245 275,180"
            fill="none" stroke="#34A76A" strokeWidth="6" strokeLinecap="round"
            strokeLinejoin="round" opacity="0.9"
            style={{filter:'drop-shadow(0 0 3px rgba(37,111,76,.5))'}}/>
        )}

        {/* POI markers */}
        {POI_MARKERS.map((p,i)=>(
          <g key={i} transform={`translate(${p.x-12},${p.y-28})`}>
            <ellipse cx="12" cy="30" rx="4" ry="2" fill="rgba(0,0,0,.15)"/>
            <path d="M12 0 C7 0 3 4 3 9 C3 16 12 24 12 24 C12 24 21 16 21 9 C21 4 17 0 12 0z" fill="white" filter="drop-shadow(0 2px 4px rgba(0,0,0,.2))"/>
            <text x="12" y="13" textAnchor="middle" fontSize="11">{p.label}</text>
          </g>
        ))}

        {/* User location dot */}
        {showUserDot && (
          <g transform={`translate(${userPos.x},${userPos.y})`} style={{transition:'transform 2.5s ease'}}>
            <circle r="20" fill="rgba(37,111,76,.12)"/>
            <circle r="10" fill="rgba(37,111,76,.2)"/>
            <circle r="6" fill="#256F4C"/>
            <circle r="3" fill="white"/>
          </g>
        )}

        {/* River Seine (bottom) */}
        <path d="M0 700 Q100 680 200 700 Q300 720 390 700" fill="none" stroke="#B0CDE8" strokeWidth="12" opacity="0.5"/>
        <path d="M0 700 Q100 680 200 700 Q300 720 390 700" fill="none" stroke="#C8DFF0" strokeWidth="8" opacity="0.6"/>
      </svg>
    </div>
  );
};

Object.assign(window, {MapView, STREET_SEGS, HISTORICAL_STREETS});
