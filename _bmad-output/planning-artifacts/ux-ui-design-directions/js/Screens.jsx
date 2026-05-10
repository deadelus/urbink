'use strict';
// ─── Parcours, Social, Badges, Profil screens ─────────────────────────────────

// ═══════ PARCOURS ═══════════════════════════════════════════════════════════
const PARCOURS_DATA = [
  {emoji:'🗺️',name:'Tour de Montmartre',meta:'4,2 km · 55 min · 5 étapes',color:'#256F4C',pct:82},
  {emoji:'📚',name:'Quartier Latin',meta:'3,1 km · 40 min · 4 étapes',color:'#F59E0B',pct:100},
  {emoji:'🌊',name:'Berges de la Seine',meta:'6,8 km · 1h20 · 6 étapes',color:'#256F4C',pct:34},
  {emoji:'🏛️',name:'Marais & Archives',meta:'2,8 km · 35 min · 3 étapes',color:'#F59E0B',pct:0},
  {emoji:'🌿',name:'Circuit Belleville',meta:'2,1 km · 28 min · 3 étapes',color:'#256F4C',pct:0},
];

const THEMATIC = [
  {emoji:'⛪',name:'Toutes les églises',progress:7,total:32},
  {emoji:'🌳',name:'Parcs & Jardins',progress:12,total:28},
  {emoji:'🛒',name:'Marchés de Paris',progress:5,total:18},
];

const ParcoursScreen = ({onNavigate, onCreateItin, lang='fr', cityData}) => {
  const {React} = window;
  const {T,IC,StatusBar,DynamicIsland,BottomNav,PrimaryBtn,CityHeaderBar} = window;
  const tFn = window.t || ((l,k)=>k);
  const [tab, setTab] = React.useState('mes');
  const cityName = cityData?.name?.[lang] || cityData?.name?.fr || 'Paris';

  return (
    <div style={{position:'relative',width:390,height:844,overflow:'hidden',background:T.bg,fontFamily:'Inter,sans-serif'}}>
      <DynamicIsland/>
      <StatusBar/>
      <div style={{position:'absolute',top:50,left:0,right:0,bottom:74,overflowY:'auto'}}>
        {/* Header */}
        <div style={{padding:'20px 16px 12px',display:'flex',alignItems:'flex-start',justifyContent:'space-between'}}>
          <div>
            <div style={{fontFamily:'Crimson Pro,serif',fontSize:26,fontWeight:700,color:T.text,letterSpacing:'-.5px'}}>{tFn(lang,'parcours_title')}</div>
            <div style={{marginTop:6}}>
              <CityHeaderBar cityData={cityData} lang={lang} onChangeCity={()=>onNavigate('city')}/>
            </div>
          </div>
          <div onClick={onCreateItin} style={{width:40,height:40,borderRadius:12,background:T.primary,display:'flex',alignItems:'center',justifyContent:'center',cursor:'pointer',boxShadow:'0 4px 12px rgba(37,111,76,.3)',marginTop:4}}>
            <IC.plus c="white" s={20}/>
          </div>
        </div>

        {/* City context banner */}
        <div style={{margin:'0 16px 14px',background:T.p06,borderRadius:14,padding:'10px 14px',border:`1px solid ${T.p18}`,display:'flex',alignItems:'center',gap:10}}>
          <span style={{fontSize:18}}>{cityData?.flag||'🇫🇷'}</span>
          <div style={{flex:1}}>
            <div style={{fontSize:12,fontWeight:600,color:T.primary}}>{cityName}</div>
            <div style={{fontSize:11,color:T.muted}}>{cityData?.explored?.toLocaleString()||'1 234'} {tFn(lang,'city_streets')} {tFn(lang,'city_explored')} · {cityData?.pct||8}%</div>
          </div>
          <div style={{height:32,width:60,background:T.surfVar,borderRadius:8,overflow:'hidden'}}>
            <div style={{width:`${cityData?.pct||8}%`,height:'100%',background:T.primary,borderRadius:8}}/>
          </div>
        </div>

        {/* Tabs */}
        <div style={{display:'flex',margin:'0 16px 16px',background:T.surfVar,borderRadius:12,padding:4}}>
          {[['mes',tFn(lang,'tab_mes')],['thematiques',tFn(lang,'tab_thematiques')]].map(([k,l])=>(
            <div key={k} onClick={()=>setTab(k)} style={{flex:1,padding:'8px 12px',borderRadius:10,fontSize:13,fontWeight:600,textAlign:'center',cursor:'pointer',background:tab===k?T.surface:'transparent',color:tab===k?T.text:T.muted,boxShadow:tab===k?'0 1px 4px rgba(0,0,0,.08)':'none',transition:'all .2s'}}>{l}</div>
          ))}
        </div>

        {tab==='mes' ? (
          <div style={{padding:'0 16px'}}>
            {PARCOURS_DATA.map((p,i)=>(
              <div key={i} style={{background:T.surface,borderRadius:20,border:`1px solid ${T.border}`,padding:'14px 16px',marginBottom:10,boxShadow:'0 1px 6px rgba(0,0,0,.04)',cursor:'pointer'}}>
                <div style={{display:'flex',alignItems:'center',gap:12,marginBottom:p.pct>0?10:0}}>
                  <div style={{width:46,height:46,borderRadius:14,background:`${p.color}15`,display:'flex',alignItems:'center',justifyContent:'center',fontSize:22,flexShrink:0}}>{p.emoji}</div>
                  <div style={{flex:1}}>
                    <div style={{fontSize:14,fontWeight:700,color:T.text}}>{p.name}</div>
                    <div style={{fontSize:11,color:T.muted,marginTop:2}}>{p.meta}</div>
                  </div>
                  <div style={{display:'flex',flexDirection:'column',alignItems:'flex-end',gap:4}}>
                    {p.pct===100 && <div style={{background:'rgba(37,111,76,.1)',borderRadius:20,padding:'3px 8px',fontSize:10,fontWeight:700,color:T.primary}}>{tFn(lang,'completed')}</div>}
                    {p.pct>0&&p.pct<100 && <div style={{fontSize:12,fontWeight:600,color:p.color}}>{p.pct}%</div>}
                    <span style={{fontSize:18,color:T.muted}}>›</span>
                  </div>
                </div>
                {p.pct>0 && (
                  <div style={{height:4,background:T.surfVar,borderRadius:2,overflow:'hidden'}}>
                    <div style={{width:`${p.pct}%`,height:'100%',background:p.color,borderRadius:2,transition:'width .6s ease'}}/>
                  </div>
                )}
              </div>
            ))}
            <div style={{padding:'8px 0 20px'}}>
              <div onClick={onCreateItin} style={{height:52,borderRadius:16,border:`2px dashed ${T.border}`,display:'flex',alignItems:'center',justifyContent:'center',gap:8,cursor:'pointer',color:T.muted,fontSize:14,fontWeight:500}}>
                <IC.plus c={T.muted}/> {tFn(lang,'btn_new_itin')}
              </div>
            </div>
          </div>
        ) : (
          <div style={{padding:'0 16px'}}>
            <div style={{fontSize:13,color:T.muted,marginBottom:12,lineHeight:1.5}}>{tFn(lang,'thematic_sub')}</div>
            {THEMATIC.map((t,i)=>(
              <div key={i} style={{background:T.surface,borderRadius:20,border:`1px solid ${T.border}`,padding:'14px 16px',marginBottom:10,boxShadow:'0 1px 6px rgba(0,0,0,.04)',cursor:'pointer'}}>
                <div style={{display:'flex',alignItems:'center',gap:12,marginBottom:10}}>
                  <div style={{width:46,height:46,borderRadius:14,background:T.p10,display:'flex',alignItems:'center',justifyContent:'center',fontSize:22,flexShrink:0}}>{t.emoji}</div>
                  <div style={{flex:1}}>
                    <div style={{fontSize:14,fontWeight:700,color:T.text}}>{t.name}</div>
                    <div style={{fontSize:11,color:T.muted,marginTop:2}}>{t.progress}/{t.total} lieux visités</div>
                  </div>
                  <div style={{fontSize:12,fontWeight:700,color:T.primary}}>{Math.round(t.progress/t.total*100)}%</div>
                </div>
                <div style={{height:6,background:T.surfVar,borderRadius:3,overflow:'hidden'}}>
                  <div style={{width:`${t.progress/t.total*100}%`,height:'100%',background:T.primary,borderRadius:3}}/>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
      <BottomNav active="parcours" onChange={onNavigate} lang={lang}/>
    </div>
  );
};

// ═══════ SOCIAL ═════════════════════════════════════════════════════════════
const FEED = [
  {avatar:'JM',name:'Julie M.',city:'Paris 11e',time:'il y a 12 min',km:3.2,rues:18,dur:'38 min',badges:['🏛️','🌿'],reaction:7,tracePts:'30,10 60,40 90,20 130,50 160,30'},
  {avatar:'TL',name:'Thomas L.',city:'Montmartre',time:'il y a 1h',km:5.8,rues:31,dur:'1h12',badges:['🏆','☕','🏛️'],reaction:14,tracePts:'10,50 50,20 90,45 140,15 180,40'},
  {avatar:'CM',name:'Chloé M.',city:'Paris 6e',time:'il y a 2h',km:2.1,rues:12,dur:'26 min',badges:['🌿'],reaction:4,tracePts:'20,30 60,50 100,25 130,45'},
  {avatar:'AR',name:'Alexandre R.',city:'Belleville',time:'il y a 3h',km:4.5,rues:24,dur:'55 min',badges:['🏛️','🌊'],reaction:11,tracePts:'10,40 50,15 100,35 150,10 190,30'},
];

const SocialScreen = ({onNavigate, lang='fr'}) => {
  const {React} = window;
  const {T,IC,StatusBar,DynamicIsland,BottomNav} = window;
  const [liked, setLiked] = React.useState({});

  return (
    <div style={{position:'relative',width:390,height:844,overflow:'hidden',background:T.bg,fontFamily:'Inter,sans-serif'}}>
      <DynamicIsland/>
      <StatusBar/>
      <div style={{position:'absolute',top:50,left:0,right:0,bottom:74,overflowY:'auto'}}>
        {/* Header */}
        <div style={{padding:'20px 16px 12px',display:'flex',alignItems:'center',justifyContent:'space-between'}}>
          <div style={{fontFamily:'Crimson Pro,serif',fontSize:26,fontWeight:700,color:T.text,letterSpacing:'-.5px'}}>Social</div>
          <div style={{display:'flex',gap:8}}>
            <div style={{width:36,height:36,borderRadius:10,background:T.surfVar,display:'flex',alignItems:'center',justifyContent:'center',cursor:'pointer'}}><IC.users c={T.muted} s={18}/></div>
          </div>
        </div>

        {/* Stories row */}
        <div style={{display:'flex',gap:10,padding:'0 16px 16px',overflowX:'auto'}}>
          {['Ma carte','Julie','Thomas','Chloé','Alex','Emma'].map((n,i)=>(
            <div key={i} style={{display:'flex',flexDirection:'column',alignItems:'center',gap:6,flexShrink:0}}>
              <div style={{width:52,height:52,borderRadius:'50%',background:i===0?T.primary:`hsl(${i*60},50%,65%)`,display:'flex',alignItems:'center',justifyContent:'center',border:i===0?`2px solid ${T.primary}`:`2px solid #e0e0e0`,fontSize:i===0?20:14,color:'white',fontWeight:700}}>
                {i===0?'🗺️':n[0]}
              </div>
              <span style={{fontSize:10,color:T.muted,width:52,textAlign:'center',overflow:'hidden',textOverflow:'ellipsis',whiteSpace:'nowrap'}}>{n}</span>
            </div>
          ))}
        </div>

        {/* Feed */}
        <div style={{padding:'0 16px'}}>
          {FEED.map((f,i)=>(
            <div key={i} style={{background:T.surface,borderRadius:20,border:`1px solid ${T.border}`,padding:16,marginBottom:12,boxShadow:'0 1px 6px rgba(0,0,0,.04)'}}>
              <div style={{display:'flex',alignItems:'center',gap:10,marginBottom:12}}>
                <div style={{width:38,height:38,borderRadius:'50%',background:`hsl(${i*60+120},45%,60%)`,display:'flex',alignItems:'center',justifyContent:'center',fontSize:13,fontWeight:700,color:'white',flexShrink:0}}>{f.avatar}</div>
                <div style={{flex:1}}>
                  <div style={{fontSize:14,fontWeight:600,color:T.text}}>{f.name}</div>
                  <div style={{fontSize:11,color:T.muted}}>{f.city} · {f.time}</div>
                </div>
                <span style={{fontSize:18,color:T.muted,cursor:'pointer'}}>···</span>
              </div>
              {/* Stats */}
              <div style={{display:'flex',gap:12,marginBottom:12}}>
                {[{icon:'🗺️',v:f.rues+' rues'},{icon:'📏',v:f.km+'km'},{icon:'⏱',v:f.dur}].map((s,j)=>(
                  <div key={j} style={{display:'flex',alignItems:'center',gap:4}}>
                    <span style={{fontSize:12}}>{s.icon}</span>
                    <span style={{fontSize:12,fontWeight:600,color:T.primary}}>{s.v}</span>
                  </div>
                ))}
              </div>
              {/* Mini trace */}
              <div style={{background:'#E8E4D8',borderRadius:12,height:80,marginBottom:12,overflow:'hidden',position:'relative'}}>
                <svg viewBox={`0 0 200 60`} style={{width:'100%',height:'100%',padding:8}} preserveAspectRatio="none">
                  <polyline points={f.tracePts} fill="none" stroke="#256F4C" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round" opacity="0.8"/>
                </svg>
              </div>
              {/* Badges */}
              <div style={{display:'flex',alignItems:'center',gap:8,marginBottom:10}}>
                <div style={{display:'flex',gap:4}}>
                  {f.badges.map((b,j)=><span key={j} style={{fontSize:16}}>{b}</span>)}
                </div>
                <span style={{fontSize:11,color:T.muted}}>{f.badges.length} badge{f.badges.length>1?'s':''} débloqué{f.badges.length>1?'s':''}</span>
              </div>
              {/* Actions */}
              <div style={{display:'flex',alignItems:'center',gap:16,paddingTop:10,borderTop:`1px solid ${T.border}`}}>
                <div onClick={()=>setLiked(l=>({...l,[i]:!l[i]}))} style={{display:'flex',alignItems:'center',gap:4,cursor:'pointer'}}>
                  <span style={{fontSize:16}}>{liked[i]?'🔥':'🤍'}</span>
                  <span style={{fontSize:12,fontWeight:500,color:liked[i]?T.accent:T.muted}}>{f.reaction+(liked[i]?1:0)}</span>
                </div>
                <div style={{display:'flex',alignItems:'center',gap:4,cursor:'pointer'}}>
                  <span style={{fontSize:16}}>💬</span>
                  <span style={{fontSize:12,fontWeight:500,color:T.muted}}>Commenter</span>
                </div>
                <div style={{flex:1}}/>
                <IC.share c={T.muted}/>
              </div>
            </div>
          ))}
        </div>
      </div>
      <BottomNav active="social" onChange={onNavigate} lang={lang}/>
    </div>
  );
};

// ═══════ BADGES ════════════════════════════════════════════════════════════
// Table maître : info détaillée par monument (description, coords normalisées 0-1
// sur une carte stylisée 200×140, époque, arrondissement). Lookup par nom.
// Coords approximatives — destinées à un placement visuel, pas à du GPS réel.
const MONUMENT_INFO = {
  'Tour Eiffel':           {arr:'7e',  era:'1889', x:.30, y:.55, desc:'Le symbole de Paris, 330m de fer forgé. Construite pour l\'Expo Universelle.'},
  'Notre-Dame':            {arr:'4e',  era:'XIIᵉ',  x:.55, y:.62, desc:'Cathédrale gothique sur l\'Île de la Cité. Chef-d\'œuvre du Moyen Âge.'},
  'Louvre':                {arr:'1er', era:'XIIᵉ',  x:.50, y:.50, desc:'Ancien palais royal, plus grand musée du monde. La Joconde y réside.'},
  'Sacré-Cœur':            {arr:'18e', era:'1914', x:.55, y:.18, desc:'Basilique blanche de Montmartre, perchée à 130m. Vue à 360° sur Paris.'},
  'Panthéon':              {arr:'5e',  era:'1790', x:.52, y:.70, desc:'Mausolée des grands hommes : Voltaire, Hugo, Curie, Zola y reposent.'},
  'Arc de Triomphe':       {arr:'8e',  era:'1836', x:.32, y:.42, desc:'À la gloire des armées napoléoniennes. Tombe du Soldat inconnu.'},
  'La Madeleine':          {arr:'8e',  era:'1842', x:.42, y:.42, desc:'Église néo-classique en forme de temple grec. 52 colonnes corinthiennes.'},
  'Saint-Sulpice':         {arr:'6e',  era:'XVIIᵉ', x:.46, y:.65, desc:'Seconde plus grande église de Paris. Fresques de Delacroix.'},
  'Saint-Eustache':        {arr:'1er', era:'XVIᵉ',  x:.50, y:.52, desc:'Gothique flamboyant et Renaissance, près des Halles.'},
  'Sainte-Chapelle':       {arr:'1er', era:'1248', x:.52, y:.58, desc:'Joyau gothique. 1113 vitraux narrant la Bible, 15m de haut.'},
  'Val-de-Grâce':          {arr:'5e',  era:'1667', x:.50, y:.78, desc:'Église baroque commandée par Anne d\'Autriche.'},
  'Pont Neuf':             {arr:'1er', era:'1607', x:.52, y:.58, desc:'Le plus vieux pont de Paris, malgré son nom. 12 arches.'},
  'Pont Alexandre III':    {arr:'8e',  era:'1900', x:.40, y:.55, desc:'Pont Belle Époque le plus orné. Style Beaux-Arts, statues dorées.'},
  'Pont d\'Iéna':           {arr:'7e',  era:'1814', x:.30, y:.55, desc:'Relie le Trocadéro à la Tour Eiffel.'},
  'Pont des Arts':         {arr:'1er', era:'1804', x:.50, y:.55, desc:'Premier pont métallique de Paris. Passerelle piétonne mythique.'},
  'Pont Mirabeau':         {arr:'15e', era:'1897', x:.18, y:.65, desc:'Immortalisé par le poème d\'Apollinaire.'},
  'Pont de Bir-Hakeim':    {arr:'15e', era:'1905', x:.22, y:.58, desc:'Pont à deux niveaux : voiture en bas, métro en haut.'},
  'Versailles':            {arr:'78',  era:'1682', x:.05, y:.92, desc:'Château royal de Louis XIV. Galerie des Glaces, jardins de Le Nôtre.'},
  'Palais-Royal':          {arr:'1er', era:'1639', x:.50, y:.48, desc:'Ancien palais de Richelieu. Galeries, colonnes de Buren.'},
  'Conciergerie':          {arr:'1er', era:'XIVᵉ',  x:.52, y:.58, desc:'Ancienne prison royale. Marie-Antoinette y fut incarcérée.'},
  'Hôtel des Invalides':   {arr:'7e',  era:'1676', x:.38, y:.60, desc:'Dôme doré, tombeau de Napoléon Iᵉʳ.'},
  'Château de Vincennes':  {arr:'12e', era:'XIVᵉ',  x:.92, y:.62, desc:'Plus haut donjon médiéval d\'Europe (52m).'},
  'Opéra Garnier':         {arr:'9e',  era:'1875', x:.45, y:.40, desc:'Palais Garnier, écrin d\'or et de marbre. Inspiré le Fantôme de l\'Opéra.'},
  'Opéra Bastille':        {arr:'12e', era:'1989', x:.68, y:.60, desc:'Opéra moderne, 2700 places. Inauguré pour le bicentenaire.'},
  'Comédie Française':     {arr:'1er', era:'1799', x:.50, y:.48, desc:'Plus vieille troupe nationale du monde. La maison de Molière.'},
  'Théâtre du Châtelet':   {arr:'1er', era:'1862', x:.52, y:.55, desc:'Théâtre lyrique et de comédies musicales.'},
  'Grand Rex':             {arr:'2e',  era:'1932', x:.55, y:.40, desc:'Plus grand cinéma d\'Europe à son ouverture, 2700 places.'},
  'Olympia':               {arr:'9e',  era:'1893', x:.45, y:.42, desc:'Mythique salle de music-hall. Piaf, Brel, Brassens y ont chanté.'},
  'Centre Pompidou':       {arr:'4e',  era:'1977', x:.55, y:.55, desc:'Architecture inside-out. Musée d\'art moderne, bibliothèque.'},
  'Tour Montparnasse':     {arr:'15e', era:'1973', x:.40, y:.75, desc:'210m, panorama sur Paris. La seule (et controversée) du centre.'},
  'La Défense':            {arr:'92',  era:'1989', x:.05, y:.30, desc:'Quartier d\'affaires et Grande Arche, axe historique de Paris.'},
  'Fondation L. Vuitton':  {arr:'16e', era:'2014', x:.10, y:.40, desc:'Voilier de verre signé Frank Gehry au Bois de Boulogne.'},
  'Philharmonie':          {arr:'19e', era:'2015', x:.85, y:.30, desc:'Salle de concert futuriste de Jean Nouvel, parc de la Villette.'},
  'Pyramide du Louvre':    {arr:'1er', era:'1989', x:.50, y:.50, desc:'Pyramide de verre de I. M. Pei dans la cour Napoléon.'},
  'Place des Vosges':      {arr:'4e',  era:'1612', x:.62, y:.55, desc:'Plus ancienne place planifiée de Paris. Briques rouges, arcades.'},
  'Place de la Concorde':  {arr:'8e',  era:'1772', x:.42, y:.48, desc:'Plus grande place de Paris. Obélisque de Louxor.'},
  'Place Vendôme':         {arr:'1er', era:'1699', x:.45, y:.45, desc:'Place octogonale, joaillerie de luxe. Colonne Vendôme.'},
  'Jardin du Luxembourg':  {arr:'6e',  era:'1612', x:.50, y:.70, desc:'Jardin de Marie de Médicis. Bassin, ruches, palais du Sénat.'},
  'Tuileries':             {arr:'1er', era:'1564', x:.46, y:.50, desc:'Plus vieux jardin public de Paris. Sculptures, bassins, chaises vertes.'},
  'Palais-Royal (jardin)': {arr:'1er', era:'1633', x:.50, y:.48, desc:'Jardin secret au cœur de Paris, entouré d\'arcades.'},
  'Parc Monceau':          {arr:'8e',  era:'1769', x:.32, y:.32, desc:'Parc romantique anglais, fabriques et colonnades.'},
  'Musée Cluny':           {arr:'5e',  era:'1340', x:.52, y:.65, desc:'Hôtel particulier médiéval. La Dame à la Licorne y trône.'},
  'Hôtel de Sully':        {arr:'4e',  era:'1630', x:.62, y:.55, desc:'Bel hôtel particulier Renaissance dans le Marais.'},
  'Saint-Étienne-du-Mont': {arr:'5e',  era:'XVIᵉ',  x:.54, y:.70, desc:'Seul jubé encore en place à Paris. Tombe de Pascal et Racine.'},
  'Maison de Balzac':      {arr:'16e', era:'XVIIIᵉ',x:.20, y:.55, desc:'Petite maison où Balzac écrivit La Comédie humaine.'},
  'Musée Carnavalet':      {arr:'3e',  era:'XVIᵉ',  x:.62, y:.52, desc:'Histoire de Paris dans deux hôtels Renaissance.'},
  'Pavillon de l\'Arsenal': {arr:'4e',  era:'1879', x:.65, y:.58, desc:'Centre d\'urbanisme et d\'architecture de Paris.'},
};

// Collections de monuments par thématique. Chaque collection contient ses
// propres monuments — un même monument peut figurer dans plusieurs collections.
const COLLECTIONS = [
  {
    id:'indispensables',
    name:'Les Indispensables',
    sub:'Les monuments incontournables de Paris',
    icon:'⭐',
    color:'#F59E0B',
    monuments:[
      {emoji:'🗼',name:'Tour Eiffel',locked:false},
      {emoji:'🏰',name:'Notre-Dame',locked:false},
      {emoji:'🏛️',name:'Louvre',locked:false},
      {emoji:'⛪',name:'Sacré-Cœur',locked:true},
      {emoji:'🏛️',name:'Panthéon',locked:false},
      {emoji:'🌉',name:'Arc de Triomphe',locked:true},
    ],
  },
  {
    id:'lumieres-cathedrales',
    name:'Lumières & Cathédrales',
    sub:'Édifices religieux et spirituels',
    icon:'⛪',
    color:'#7C3AED',
    monuments:[
      {emoji:'🏰',name:'Notre-Dame',locked:false},
      {emoji:'⛪',name:'Sacré-Cœur',locked:true},
      {emoji:'⛪',name:'La Madeleine',locked:true},
      {emoji:'⛪',name:'Saint-Sulpice',locked:false},
      {emoji:'⛪',name:'Saint-Eustache',locked:true},
      {emoji:'⛪',name:'Sainte-Chapelle',locked:true},
      {emoji:'⛪',name:'Val-de-Grâce',locked:true},
    ],
  },
  {
    id:'ponts-berges',
    name:'Ponts & Berges',
    sub:'Traversées et rives de la Seine',
    icon:'🌉',
    color:'#0891B2',
    monuments:[
      {emoji:'🌉',name:'Pont Neuf',locked:true},
      {emoji:'🌉',name:'Pont Alexandre III',locked:false},
      {emoji:'🌊',name:'Pont d\'Iéna',locked:true},
      {emoji:'🌉',name:'Pont des Arts',locked:false},
      {emoji:'🌉',name:'Pont Mirabeau',locked:true},
      {emoji:'🌊',name:'Pont de Bir-Hakeim',locked:true},
    ],
  },
  {
    id:'royal-imperial',
    name:'Royal & Impérial',
    sub:'Palais, châteaux et héritage royal',
    icon:'👑',
    color:'#B45309',
    monuments:[
      {emoji:'🏰',name:'Versailles',locked:true},
      {emoji:'🏛️',name:'Louvre',locked:false},
      {emoji:'🏛️',name:'Palais-Royal',locked:false},
      {emoji:'🏛️',name:'Conciergerie',locked:true},
      {emoji:'🏛️',name:'Hôtel des Invalides',locked:true},
      {emoji:'🏰',name:'Château de Vincennes',locked:true},
    ],
  },
  {
    id:'scenes-spectacles',
    name:'Scènes & Spectacles',
    sub:'Opéras, théâtres et lieux culturels',
    icon:'🎭',
    color:'#BE185D',
    monuments:[
      {emoji:'🎭',name:'Opéra Garnier',locked:true},
      {emoji:'🎭',name:'Opéra Bastille',locked:true},
      {emoji:'🎭',name:'Comédie Française',locked:false},
      {emoji:'🎭',name:'Théâtre du Châtelet',locked:true},
      {emoji:'🎬',name:'Grand Rex',locked:true},
      {emoji:'🎭',name:'Olympia',locked:true},
    ],
  },
  {
    id:'paris-moderne',
    name:'Paris Moderne',
    sub:'Architecture contemporaine',
    icon:'🏗️',
    color:'#475569',
    monuments:[
      {emoji:'🏗️',name:'Centre Pompidou',locked:true},
      {emoji:'🌆',name:'Tour Montparnasse',locked:true},
      {emoji:'🏛️',name:'La Défense',locked:true},
      {emoji:'🏛️',name:'Fondation L. Vuitton',locked:true},
      {emoji:'🏛️',name:'Philharmonie',locked:true},
      {emoji:'🏛️',name:'Pyramide du Louvre',locked:false},
    ],
  },
  {
    id:'places-jardins',
    name:'Places & Jardins',
    sub:'Places classées et jardins royaux',
    icon:'🌳',
    color:'#256F4C',
    monuments:[
      {emoji:'🛖',name:'Place des Vosges',locked:false},
      {emoji:'🛖',name:'Place de la Concorde',locked:true},
      {emoji:'🛖',name:'Place Vendôme',locked:false},
      {emoji:'🌳',name:'Jardin du Luxembourg',locked:false},
      {emoji:'🌳',name:'Tuileries',locked:false},
      {emoji:'🌳',name:'Palais-Royal (jardin)',locked:false},
      {emoji:'🌳',name:'Parc Monceau',locked:true},
    ],
  },
  {
    id:'tresors-caches',
    name:'Trésors Cachés',
    sub:'Pépites confidentielles à découvrir',
    icon:'🗝️',
    color:'#92400E',
    monuments:[
      {emoji:'🏛️',name:'Musée Cluny',locked:true},
      {emoji:'🏛️',name:'Hôtel de Sully',locked:true},
      {emoji:'⛪',name:'Saint-Étienne-du-Mont',locked:true},
      {emoji:'🏛️',name:'Maison de Balzac',locked:true},
      {emoji:'🏛️',name:'Musée Carnavalet',locked:false},
      {emoji:'🏛️',name:'Pavillon de l\'Arsenal',locked:true},
    ],
  },
];

// Helpers
const collectionStats = (col) => {
  const total = col.monuments.length;
  const unlocked = col.monuments.filter(m=>!m.locked).length;
  return {total, unlocked, pct: Math.round(unlocked/total*100)};
};

const totalUnlocked = COLLECTIONS.reduce((acc,c)=>{
  // Dédupliquer par nom de monument
  c.monuments.forEach(m=>{ if(!m.locked) acc.add(m.name); });
  return acc;
}, new Set()).size;

const totalMonuments = (() => {
  const set = new Set();
  COLLECTIONS.forEach(c=>c.monuments.forEach(m=>set.add(m.name)));
  return set.size;
})();

const DISTRICTS = [
  {name:'Marais',pct:78},{name:'Montmartre',pct:55},{name:'Saint-Germain',pct:100},
  {name:'Bastille',pct:32},{name:'Pigalle',pct:18},{name:'Oberkampf',pct:90},
];

const BadgesScreen = ({onNavigate, lang='fr', cityData, rankPlacement='A'}) => {
  const {React} = window;
  const {T,IC,StatusBar,DynamicIsland,BottomNav,CityHeaderBar,GEM_DATA,Gem,RankUtils} = window;
  const tFn = window.t || ((l,k)=>k);
  const [tab,setTab] = React.useState('monuments');
  const [openCollection, setOpenCollection] = React.useState(null);
  const [openMonument, setOpenMonument] = React.useState(null); // {monument, collection}
  const cityName = cityData?.name?.[lang] || cityData?.name?.fr || 'Paris';

  // ─── Rank state ────────────────────────────────────────────────────────────
  const rankIdx = 4, xpInRank = 32;
  const rankMeta = GEM_DATA?.[rankIdx];
  const rankNext = GEM_DATA?.[rankIdx+1];
  const rankTotal = rankNext ? (rankNext.xp - rankMeta.xp) : 1;
  const rankPct = rankNext ? Math.min(100, (xpInRank/rankTotal)*100) : 100;

  return (
    <div style={{position:'relative',width:390,height:844,overflow:'hidden',background:T.bg,fontFamily:'Inter,sans-serif'}}>
      <DynamicIsland/>
      <StatusBar/>
      <div style={{position:'absolute',top:50,left:0,right:0,bottom:74,overflowY:'auto'}}>
        <div style={{padding:'20px 16px 12px'}}>
          <div style={{display:'flex',alignItems:'flex-start',justifyContent:'space-between',marginBottom:6}}>
            <div style={{fontFamily:'Crimson Pro,serif',fontSize:26,fontWeight:700,color:T.text,letterSpacing:'-.5px'}}>{tFn(lang,'badges_title')}</div>
            <CityHeaderBar cityData={cityData} lang={lang} onChangeCity={()=>onNavigate('city')}/>
          </div>
          {rankPlacement === 'A' ? (
            /* ─── Option A — Rank in subtitle line ─── */
            <div onClick={()=>onNavigate('ranks')} style={{display:'flex',alignItems:'center',gap:10,marginTop:4,cursor:'pointer'}}>
              <div style={{flexShrink:0,filter:`drop-shadow(0 2px 4px ${rankMeta.halo}55)`}}>
                <Gem id={rankMeta.id} size={26} style="realistic" animate={false}/>
              </div>
              <div style={{flex:1,minWidth:0}}>
                <div style={{display:'flex',alignItems:'baseline',gap:6,marginBottom:3}}>
                  <span style={{fontFamily:'Crimson Pro,serif',fontSize:14,fontWeight:600,color:T.text,letterSpacing:'-.2px'}}>{rankMeta.name}</span>
                  <span style={{fontSize:10,color:T.muted,fontVariantNumeric:'tabular-nums'}}>· {xpInRank}/{rankTotal} → {rankNext?.name}</span>
                </div>
                <div style={{height:3,background:T.surfVar,borderRadius:2,overflow:'hidden'}}>
                  <div style={{width:`${rankPct}%`,height:'100%',background:`linear-gradient(90deg, ${rankMeta.halo}, ${rankNext?.halo||rankMeta.halo})`,borderRadius:2}}/>
                </div>
              </div>
              <span style={{fontSize:14,color:T.muted}}>›</span>
            </div>
          ) : (
            <div style={{fontSize:12,color:T.muted}}>7 / 32 · 2 {tFn(lang,'badge_explored')} — {cityName}</div>
          )}
        </div>

        {/* ─── Option B — Dedicated rank card between header & stats ─── */}
        {rankPlacement === 'B' && (
          <div onClick={()=>onNavigate('ranks')} style={{
            margin:'0 16px 12px',background:T.surface,borderRadius:16,
            border:`1px solid ${T.border}`,padding:'10px 14px',
            display:'flex',alignItems:'center',gap:12,cursor:'pointer',
            position:'relative',overflow:'hidden',
            boxShadow:'0 1px 4px rgba(0,0,0,.04)',
          }}>
            <div style={{position:'absolute',top:-20,right:-20,width:90,height:90,background:`radial-gradient(circle, ${rankMeta.halo}22 0%, transparent 70%)`,pointerEvents:'none'}}/>
            <div style={{flexShrink:0,filter:`drop-shadow(0 2px 6px ${rankMeta.halo}66)`,position:'relative'}}>
              <Gem id={rankMeta.id} size={42} style="realistic" animate={false}/>
            </div>
            <div style={{flex:1,minWidth:0,position:'relative'}}>
              <div style={{display:'flex',alignItems:'baseline',justifyContent:'space-between',marginBottom:4}}>
                <div>
                  <span style={{fontSize:9,fontWeight:700,letterSpacing:1.2,color:T.muted,textTransform:'uppercase'}}>Rang · {rankIdx+1}/11 </span>
                  <span style={{fontFamily:'Crimson Pro,serif',fontSize:16,fontWeight:600,color:T.text,letterSpacing:'-.2px',marginLeft:2}}>{rankMeta.name}</span>
                </div>
                <span style={{fontSize:10,color:T.muted,fontVariantNumeric:'tabular-nums'}}>{xpInRank}/{rankTotal}</span>
              </div>
              <div style={{height:4,background:T.surfVar,borderRadius:2,overflow:'hidden',marginBottom:3}}>
                <div style={{width:`${rankPct}%`,height:'100%',background:`linear-gradient(90deg, ${rankMeta.halo}, ${rankNext?.halo||rankMeta.halo})`,borderRadius:2,boxShadow:`0 0 4px ${rankMeta.halo}88`}}/>
              </div>
              <div style={{fontSize:10,color:T.muted}}>{rankTotal-xpInRank} monuments pour <span style={{color:rankNext?.halo,fontWeight:600}}>{rankNext?.name}</span></div>
            </div>
            <span style={{fontSize:16,color:T.muted,position:'relative'}}>›</span>
          </div>
        )}

        {/* Stats banner */}
        <div style={{margin:'0 16px 16px',background:T.a10,border:`1px solid ${T.a22}`,borderRadius:16,padding:'12px 12px',display:'flex',justifyContent:'space-around'}}>
          {(rankPlacement === 'C'
            ? [
                {v:String(totalUnlocked),l:'Monuments'},
                {v:String(COLLECTIONS.filter(c=>collectionStats(c).pct===100).length),l:'Collections'},
                {gem:rankMeta, v:rankMeta.name, l:`Rang · ${rankIdx+1}/11`},
              ]
            : [
                {v:String(totalUnlocked),l:'Monuments'},
                {v:String(COLLECTIONS.filter(c=>collectionStats(c).pct===100).length),l:'Collections'},
                {v:'2',l:'Quartiers'},
              ]
          ).map((s,i)=>(
            <div key={i} onClick={s.gem?()=>onNavigate('ranks'):undefined} style={{textAlign:'center',cursor:s.gem?'pointer':'default',flex:1,minWidth:0,position:'relative'}}>
              {s.gem ? (
                <>
                  <div style={{display:'flex',justifyContent:'center',height:30,alignItems:'center',marginBottom:1,filter:`drop-shadow(0 2px 4px ${s.gem.halo}55)`}}>
                    <Gem id={s.gem.id} size={26} style="realistic" animate={false}/>
                  </div>
                  <div style={{fontFamily:'Crimson Pro,serif',fontSize:13,fontWeight:600,color:T.text,letterSpacing:'-.1px',lineHeight:1}}>{s.v}</div>
                  <div style={{fontSize:10,color:T.muted,marginTop:3,letterSpacing:.2}}>{s.l}</div>
                </>
              ) : (
                <>
                  <div style={{fontFamily:'Crimson Pro,serif',fontSize:26,fontWeight:700,color:T.accent,lineHeight:1}}>{s.v}</div>
                  <div style={{fontSize:11,color:T.muted,marginTop:4}}>{s.l}</div>
                </>
              )}
            </div>
          ))}
        </div>

        {/* Tab toggle */}
        <div style={{display:'flex',margin:'0 16px 16px',background:T.surfVar,borderRadius:12,padding:4}}>
          {[['monuments',tFn(lang,'tab_monuments')],['quartiers',tFn(lang,'tab_quartiers')]].map(([k,l])=>(
            <div key={k} onClick={()=>setTab(k)} style={{flex:1,padding:'8px 0',borderRadius:10,fontSize:13,fontWeight:600,textAlign:'center',cursor:'pointer',background:tab===k?T.surface:'transparent',color:tab===k?T.text:T.muted,transition:'all .2s'}}>{l}</div>
          ))}
        </div>

        {tab==='monuments' ? (
          <div style={{padding:'0 16px 20px'}}>
            <div style={{fontSize:12,color:T.muted,marginBottom:12,lineHeight:1.5}}>
              Explorez Paris par thématique. Chaque collection regroupe des monuments à débloquer.
            </div>
            {COLLECTIONS.map((col)=>{
              const {total,unlocked,pct} = collectionStats(col);
              const complete = pct===100;
              return (
                <div key={col.id} onClick={()=>setOpenCollection(col.id)} style={{background:T.surface,borderRadius:18,border:`1px solid ${T.border}`,padding:'14px 14px',marginBottom:10,boxShadow:'0 1px 6px rgba(0,0,0,.04)',cursor:'pointer',position:'relative',overflow:'hidden'}}>
                  {/* Accent stripe gauche */}
                  <div style={{position:'absolute',left:0,top:0,bottom:0,width:4,background:col.color}}/>
                  <div style={{display:'flex',alignItems:'center',gap:12,marginBottom:10}}>
                    <div style={{width:48,height:48,borderRadius:14,background:col.color+'18',display:'flex',alignItems:'center',justifyContent:'center',fontSize:24,flexShrink:0}}>{col.icon}</div>
                    <div style={{flex:1,minWidth:0}}>
                      <div style={{display:'flex',alignItems:'center',gap:6}}>
                        <div style={{fontFamily:'Crimson Pro,serif',fontSize:16,fontWeight:700,color:T.text}}>{col.name}</div>
                        {complete && <span style={{fontSize:11}}>🏆</span>}
                      </div>
                      <div style={{fontSize:11,color:T.muted,marginTop:1,lineHeight:1.3}}>{col.sub}</div>
                    </div>
                    <span style={{fontSize:18,color:T.muted}}>›</span>
                  </div>
                  {/* Mini-grille des emojis (aperçu) */}
                  <div style={{display:'flex',gap:4,marginBottom:10}}>
                    {col.monuments.slice(0,6).map((m,j)=>(
                      <div key={j} style={{flex:'0 0 32px',height:32,borderRadius:8,background:m.locked?T.surfVar:col.color+'15',display:'flex',alignItems:'center',justifyContent:'center',fontSize:16,filter:m.locked?'grayscale(1) opacity(.4)':'none'}}>{m.emoji}</div>
                    ))}
                  </div>
                  {/* Progression */}
                  <div style={{display:'flex',alignItems:'center',gap:8}}>
                    <div style={{flex:1,height:5,background:T.surfVar,borderRadius:3,overflow:'hidden'}}>
                      <div style={{width:`${pct}%`,height:'100%',background:col.color,borderRadius:3,transition:'width .6s ease'}}/>
                    </div>
                    <div style={{fontSize:11,fontWeight:700,color:col.color,minWidth:42,textAlign:'right'}}>{unlocked}/{total}</div>
                  </div>
                </div>
              );
            })}
          </div>
        ) : (
          <div style={{padding:'0 16px 20px'}}>
            {DISTRICTS.map((d,i)=>(
              <div key={i} style={{background:T.surface,borderRadius:16,border:`1px solid ${T.border}`,padding:'12px 16px',marginBottom:8,boxShadow:'0 1px 4px rgba(0,0,0,.04)'}}>
                <div style={{display:'flex',alignItems:'center',marginBottom:8}}>
                  <div style={{flex:1}}>
                    <div style={{fontSize:14,fontWeight:600,color:T.text}}>{d.name}</div>
                    <div style={{fontSize:11,color:T.muted}}>{d.pct}% {tFn(lang,'badge_explored')}</div>
                  </div>
                  {d.pct===100 && <div style={{background:T.p10,borderRadius:20,padding:'4px 10px',fontSize:11,fontWeight:700,color:T.primary}}>{tFn(lang,'badge_unlocked')}</div>}
                </div>
                <div style={{height:6,background:T.surfVar,borderRadius:3}}>
                  <div style={{width:`${d.pct}%`,height:'100%',background:d.pct===100?T.accent:T.primary,borderRadius:3,transition:'width .6s'}}/>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
      <BottomNav active="badges" onChange={onNavigate} lang={lang}/>

      {/* ─── Collection Detail Overlay ─────────────────────────────────── */}
      {openCollection && (() => {
        const col = COLLECTIONS.find(c=>c.id===openCollection);
        if (!col) return null;
        const {total,unlocked,pct} = collectionStats(col);
        return (
          <div style={{position:'absolute',inset:0,background:T.bg,zIndex:300,animation:'fadeIn .2s ease',display:'flex',flexDirection:'column'}}>
            <DynamicIsland/>
            <StatusBar/>
            {/* Header coloré */}
            <div style={{background:`linear-gradient(135deg, ${col.color} 0%, ${col.color}dd 100%)`,padding:'56px 16px 20px',position:'relative',overflow:'hidden'}}>
              <div style={{position:'absolute',top:-30,right:-30,width:160,height:160,borderRadius:'50%',background:'rgba(255,255,255,.08)',pointerEvents:'none'}}/>
              <div style={{position:'absolute',bottom:-40,left:-20,width:120,height:120,borderRadius:'50%',background:'rgba(255,255,255,.05)',pointerEvents:'none'}}/>
              <div onClick={()=>setOpenCollection(null)} style={{display:'inline-flex',alignItems:'center',gap:4,fontSize:14,color:'white',cursor:'pointer',padding:'4px 10px 4px 0',marginBottom:14,fontWeight:500}}>
                <svg width="20" height="20" fill="none" viewBox="0 0 24 24"><path d="M15 19l-7-7 7-7" stroke="white" strokeWidth="2" strokeLinecap="round"/></svg>
                Retour
              </div>
              <div style={{display:'flex',alignItems:'center',gap:14,marginBottom:14}}>
                <div style={{width:64,height:64,borderRadius:18,background:'rgba(255,255,255,.22)',border:'1.5px solid rgba(255,255,255,.4)',display:'flex',alignItems:'center',justifyContent:'center',fontSize:32,flexShrink:0}}>{col.icon}</div>
                <div style={{flex:1}}>
                  <div style={{fontFamily:'Crimson Pro,serif',fontSize:22,fontWeight:700,color:'white',letterSpacing:'-.3px'}}>{col.name}</div>
                  <div style={{fontSize:12,color:'rgba(255,255,255,.85)',marginTop:2,lineHeight:1.3}}>{col.sub}</div>
                </div>
              </div>
              {/* Progression */}
              <div style={{display:'flex',alignItems:'center',gap:10}}>
                <div style={{flex:1,height:6,background:'rgba(255,255,255,.2)',borderRadius:3,overflow:'hidden'}}>
                  <div style={{width:`${pct}%`,height:'100%',background:'white',borderRadius:3,transition:'width .8s ease'}}/>
                </div>
                <div style={{fontSize:13,fontWeight:700,color:'white',minWidth:60,textAlign:'right'}}>{unlocked}/{total} · {pct}%</div>
              </div>
            </div>

            {/* Liste monuments */}
            <div style={{flex:1,overflowY:'auto',padding:'16px 16px 100px'}}>
              {pct===100 && (
                <div style={{background:T.a10,border:`1px solid ${T.a22}`,borderRadius:14,padding:'12px 14px',marginBottom:14,display:'flex',alignItems:'center',gap:10}}>
                  <span style={{fontSize:24}}>🏆</span>
                  <div style={{flex:1}}>
                    <div style={{fontSize:13,fontWeight:700,color:T.accent}}>Collection complète !</div>
                    <div style={{fontSize:11,color:T.muted,marginTop:1}}>Vous avez débloqué tous les monuments de cette collection.</div>
                  </div>
                </div>
              )}
              <div style={{display:'grid',gridTemplateColumns:'repeat(3,1fr)',gap:10}}>
                {col.monuments.map((m,i)=>(
                  <div key={i} onClick={(e)=>{e.stopPropagation();setOpenMonument({monument:m,collection:col});}} style={{background:T.surface,borderRadius:16,border:`1px solid ${m.locked?T.border:col.color+'40'}`,padding:'14px 8px',textAlign:'center',boxShadow:'0 1px 4px rgba(0,0,0,.04)',position:'relative',minHeight:96,display:'flex',flexDirection:'column',alignItems:'center',justifyContent:'center',gap:4,cursor:'pointer'}}>
                    {!m.locked && <div style={{position:'absolute',top:-4,right:-4,width:18,height:18,background:col.color,borderRadius:'50%',display:'flex',alignItems:'center',justifyContent:'center',boxShadow:`0 2px 6px ${col.color}66`}}><IC.check c="white" s={11}/></div>}
                    <div style={{fontSize:30,filter:m.locked?'grayscale(1)':'none',opacity:m.locked?.4:1}}>{m.emoji}</div>
                    <div style={{fontSize:10,fontWeight:600,color:m.locked?T.muted:T.text,lineHeight:1.2,padding:'0 2px'}}>{m.name}</div>
                    {m.locked && <IC.lock c={T.muted} s={11}/>}
                  </div>
                ))}
              </div>
            </div>

            {/* ─── Monument Detail Bottom Sheet ─── */}
            {openMonument && (() => {
              const m = openMonument.monument;
              const c = openMonument.collection;
              const info = MONUMENT_INFO[m.name] || {arr:'—',era:'—',x:.5,y:.5,desc:'Monument emblématique de Paris.'};
              return (
                <React.Fragment>
                  {/* Backdrop */}
                  <div onClick={()=>setOpenMonument(null)} style={{position:'absolute',inset:0,background:'rgba(15,23,42,.5)',zIndex:400,animation:'fadeIn .2s ease'}}/>
                  {/* Sheet */}
                  <div style={{position:'absolute',left:0,right:0,bottom:0,background:T.surface,borderRadius:'24px 24px 0 0',padding:'10px 0 24px',zIndex:401,maxHeight:'78%',overflowY:'auto',boxShadow:'0 -8px 30px rgba(0,0,0,.25)',animation:'slideUp .25s cubic-bezier(.4,0,.2,1)'}}>
                    <DragHandle/>
                    {/* Mini map */}
                    <div style={{margin:'12px 16px 0',borderRadius:16,overflow:'hidden',position:'relative',height:140,background:'#E8E4D8',border:`1px solid ${T.border}`}}>
                      <svg viewBox="0 0 200 140" style={{width:'100%',height:'100%',display:'block'}} preserveAspectRatio="xMidYMid slice">
                        {/* grid streets */}
                        <g stroke="#CEC9BD" strokeWidth=".5" opacity=".7">
                          <path d="M0,30 L200,30"/><path d="M0,55 L200,55"/><path d="M0,80 L200,80"/><path d="M0,105 L200,105"/>
                          <path d="M30,0 L30,140"/><path d="M70,0 L70,140"/><path d="M110,0 L110,140"/><path d="M150,0 L150,140"/><path d="M180,0 L180,140"/>
                        </g>
                        {/* Seine */}
                        <path d="M-5,75 Q40,82 90,72 Q140,60 200,80" fill="none" stroke="#C8DFF0" strokeWidth="9" strokeLinecap="round"/>
                        {/* Parc */}
                        <rect x="20" y="92" width="32" height="22" fill="#C5D5A8" opacity=".7" rx="3"/>
                        <rect x="140" y="20" width="28" height="20" fill="#C5D5A8" opacity=".7" rx="3"/>
                        {/* Pin */}
                        <g transform={`translate(${info.x*200} ${info.y*140})`}>
                          {!m.locked && <circle r="22" fill={c.color} opacity=".15"/>}
                          {!m.locked && <circle r="14" fill={c.color} opacity=".25"/>}
                          <circle r="9" fill={m.locked?'#94A3B8':c.color} stroke="white" strokeWidth="2.5"/>
                          <text y="3" textAnchor="middle" fontSize="9">{m.emoji}</text>
                        </g>
                      </svg>
                      {/* Coords overlay */}
                      <div style={{position:'absolute',top:8,left:10,background:'rgba(255,255,255,.92)',borderRadius:8,padding:'3px 8px',fontSize:10,fontWeight:600,color:T.muted,fontFamily:'ui-monospace,monospace'}}>
                        {info.arr} arr.
                      </div>
                      {!m.locked && (
                        <div style={{position:'absolute',top:8,right:10,background:c.color,borderRadius:8,padding:'3px 8px',fontSize:10,fontWeight:700,color:'white',display:'flex',alignItems:'center',gap:4}}>
                          <IC.check c="white" s={10}/> Visité
                        </div>
                      )}
                    </div>
                    {/* Header */}
                    <div style={{padding:'14px 16px 8px',display:'flex',alignItems:'flex-start',gap:12}}>
                      <div style={{width:54,height:54,borderRadius:14,background:m.locked?T.surfVar:c.color+'18',display:'flex',alignItems:'center',justifyContent:'center',fontSize:30,filter:m.locked?'grayscale(1)':'none',opacity:m.locked?.5:1,flexShrink:0}}>{m.emoji}</div>
                      <div style={{flex:1,minWidth:0}}>
                        <div style={{fontFamily:'Crimson Pro,serif',fontSize:20,fontWeight:700,color:T.text,letterSpacing:'-.3px',lineHeight:1.15}}>{m.name}</div>
                        <div style={{display:'flex',alignItems:'center',gap:6,marginTop:4,flexWrap:'wrap'}}>
                          <span style={{fontSize:11,fontWeight:600,color:c.color,background:c.color+'18',borderRadius:6,padding:'2px 7px'}}>{c.icon} {c.name}</span>
                          <span style={{fontSize:11,color:T.muted}}>· {info.era}</span>
                        </div>
                      </div>
                      <div onClick={()=>setOpenMonument(null)} style={{width:30,height:30,borderRadius:'50%',background:T.surfVar,display:'flex',alignItems:'center',justifyContent:'center',cursor:'pointer',flexShrink:0,fontSize:16,color:T.muted,fontWeight:600}}>×</div>
                    </div>
                    {/* Description */}
                    <div style={{padding:'4px 16px 14px'}}>
                      <p style={{fontSize:13,color:T.text,lineHeight:1.5,margin:0}}>{info.desc}</p>
                    </div>
                    {/* Status row */}
                    <div style={{margin:'0 16px 14px',padding:'12px 14px',background:m.locked?T.surfVar:c.color+'10',borderRadius:14,border:`1px solid ${m.locked?T.border:c.color+'30'}`,display:'flex',alignItems:'center',gap:10}}>
                      <span style={{fontSize:20}}>{m.locked?'🔒':'🏆'}</span>
                      <div style={{flex:1}}>
                        <div style={{fontSize:12,fontWeight:700,color:m.locked?T.muted:c.color}}>{m.locked?'Pas encore visité':'Badge débloqué'}</div>
                        <div style={{fontSize:11,color:T.muted,marginTop:1}}>{m.locked?'Approchez-vous à moins de 100m pour débloquer':'Visité lors d\'une de vos sorties'}</div>
                      </div>
                    </div>
                    {/* Actions */}
                    <div style={{padding:'0 16px',display:'flex',gap:8}}>
                      <button onClick={()=>setOpenMonument(null)} style={{flex:1,height:48,borderRadius:14,background:T.surface,border:`1.5px solid ${T.border}`,fontSize:13,fontWeight:600,color:T.text,cursor:'pointer',display:'flex',alignItems:'center',justifyContent:'center',gap:6}}>
                        <IC.share c={T.text} s={16}/> Partager
                      </button>
                      <button onClick={()=>{setOpenMonument(null);setOpenCollection(null);onNavigate('carte');}} style={{flex:2,height:48,borderRadius:14,background:c.color,border:'none',fontSize:13,fontWeight:600,color:'white',cursor:'pointer',display:'flex',alignItems:'center',justifyContent:'center',gap:6,boxShadow:`0 4px 12px ${c.color}55`}}>
                        🧭 Voir sur la carte
                      </button>
                    </div>
                  </div>
                </React.Fragment>
              );
            })()}
          </div>
        );
      })()}
    </div>
  );
};

// ═══════ PROFIL ═════════════════════════════════════════════════════════════
const SORTIES = [
  {date:'Aujourd\'hui',emoji:'🚶',km:2.4,rues:14,dur:'28 min',badges:1,new:true},
  {date:'Hier',emoji:'🚴',km:8.2,rues:41,dur:'52 min',badges:2,new:false},
  {date:'Lundi',emoji:'🚶',km:3.1,rues:18,dur:'36 min',badges:0,new:false},
  {date:'Dimanche',emoji:'🚶',km:5.6,rues:29,dur:'1h08',badges:3,new:false},
  {date:'Vendredi',emoji:'🚴',km:11.3,rues:58,dur:'1h24',badges:1,new:false},
];

const WEEK = [
  {d:'L',rues:18},{d:'M',rues:0},{d:'M',rues:41},{d:'J',rues:14},{d:'V',rues:58},{d:'S',rues:29},{d:'D',rues:0},
];

const GearIcon = ({c='white',s=20}) => (
  <svg width={s} height={s} fill="none" viewBox="0 0 24 24">
    <path d="M12 15a3 3 0 100-6 3 3 0 000 6z" stroke={c} strokeWidth="1.8"/>
    <path d="M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 010 2.83 2 2 0 01-2.83 0l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 01-4 0v-.09A1.65 1.65 0 009 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 01-2.83-2.83l.06-.06A1.65 1.65 0 004.68 15a1.65 1.65 0 00-1.51-1H3a2 2 0 010-4h.09A1.65 1.65 0 004.6 9a1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 012.83-2.83l.06.06A1.65 1.65 0 009 4.68a1.65 1.65 0 001-1.51V3a2 2 0 014 0v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 012.83 2.83l-.06.06A1.65 1.65 0 0019.4 9a1.65 1.65 0 001.51 1H21a2 2 0 010 4h-.09a1.65 1.65 0 00-1.51 1z" stroke={c} strokeWidth="1.8"/>
  </svg>
);

const ProfilScreen = ({onNavigate, onSettings, lang='fr', cityData, onChangeCity}) => {
  const {React} = window;
  const {T,IC,StatusBar,DynamicIsland,BottomNav,GEM_DATA} = window;
  const meta = GEM_DATA[4]; // Topaze
  const cityName = cityData?.name?.[lang] || cityData?.name?.fr || 'Paris';
  const cityPct = cityData?.pct ?? 8;
  const cityColor = cityData?.color || T.primary;

  const memberLabel = lang==='en'?'Member since March 2026 · 47 exploration days'
                    : lang==='es'?'Miembro desde marzo 2026 · 47 días de exploración'
                    : lang==='pt'?'Membro desde março 2026 · 47 dias de exploração'
                    : lang==='ja'?'2026年3月からメンバー · 47日間の探索'
                    : 'Membre depuis mars 2026 · 47 jours d\'exploration';

  const STATS = [
    {val:'234',   label:lang==='en'?'monuments':lang==='es'?'monumentos':lang==='pt'?'monumentos':lang==='ja'?'記念碑':'monuments'},
    {val:'18,4',  label:lang==='en'?'km on foot':lang==='es'?'km a pie':lang==='pt'?'km a pé':lang==='ja'?'徒歩キロ':'km à pied'},
    {val:'4',     label:lang==='en'?'cities':lang==='es'?'ciudades':lang==='pt'?'cidades':lang==='ja'?'都市':'villes'},
  ];

  return (
    <div style={{position:'relative',width:390,height:844,overflow:'hidden',background:T.bg,fontFamily:'Inter,sans-serif'}}>
      <DynamicIsland/>
      <StatusBar/>
      <div style={{position:'absolute',top:50,left:0,right:0,bottom:74,overflowY:'auto'}}>

        {/* ─── Header — avatar + name + settings ─── */}
        <div style={{padding:'18px 20px 14px',display:'flex',alignItems:'center',gap:14}}>
          <div style={{
            width:56,height:56,borderRadius:'50%',
            background: T.bg === '#0F0F0F'
              ? `linear-gradient(135deg, ${T.surface}, ${T.surfVar})`
              : `linear-gradient(135deg, #1F2A37, #0F172A)`,
            border: T.bg === '#0F0F0F'
              ? `1.5px solid ${meta.halo}55`
              : `1.5px solid ${T.border}`,
            display:'flex',alignItems:'center',justifyContent:'center',
            fontFamily:'Crimson Pro,serif',fontSize:22,fontWeight:600,
            color: T.bg === '#0F0F0F' ? meta.halo : '#F8FAFC',
            boxShadow: T.bg === '#0F0F0F'
              ? `0 0 20px ${meta.halo}22`
              : `0 2px 10px rgba(15,23,42,.18)`,
          }}>AD</div>
          <div style={{flex:1,minWidth:0}}>
            <div style={{fontFamily:'Crimson Pro,serif',fontSize:22,fontWeight:600,letterSpacing:'-.3px',color:T.text,lineHeight:1.1}}>Alex Dupont</div>
            <div style={{fontSize:11,color:T.muted,marginTop:3,whiteSpace:'nowrap',overflow:'hidden',textOverflow:'ellipsis'}}>{memberLabel}</div>
          </div>
          <div onClick={onSettings} style={{width:34,height:34,borderRadius:11,background:T.surface,border:`1px solid ${T.border}`,display:'flex',alignItems:'center',justifyContent:'center',cursor:'pointer',flexShrink:0}}>
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke={T.muted} strokeWidth="1.8" strokeLinecap="round"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 1 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 1 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 1 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 1 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>
          </div>
        </div>

        {/* ─── City selector + progress bar ─── */}
        <div onClick={()=>onNavigate('city')} style={{
          margin:'4px 20px 0',padding:'12px 14px',
          background:T.surface,border:`1px solid ${T.border}`,borderRadius:14,
          display:'flex',alignItems:'center',gap:10,cursor:'pointer',
        }}>
          <span style={{fontSize:18}}>{cityData?.flag||'🇫🇷'}</span>
          <div style={{flex:1,minWidth:0}}>
            <div style={{display:'flex',alignItems:'baseline',gap:6,marginBottom:5}}>
              <span style={{fontSize:13,fontWeight:600,color:T.text}}>{cityName}</span>
              <span style={{fontSize:10,color:T.muted}}>· ville active</span>
              <span style={{flex:1}}/>
              <span style={{fontSize:11,fontWeight:700,color:cityColor,fontVariantNumeric:'tabular-nums'}}>{cityPct}%</span>
            </div>
            <div style={{height:4,background:T.surfVar,borderRadius:2,overflow:'hidden'}}>
              <div style={{width:`${cityPct}%`,height:'100%',background:cityColor,borderRadius:2}}/>
            </div>
          </div>
          <svg width="14" height="14" fill="none" viewBox="0 0 24 24"><path d="M9 18l6-6-6-6" stroke={T.muted} strokeWidth="2" strokeLinecap="round"/></svg>
        </div>

        {/* ─── Rank Card — hero ─── */}
        <div style={{padding:'14px 4px 0'}}>
          <window.RankCard rankIdx={4} xpInRank={32} onPress={()=>onNavigate('ranks')}/>
        </div>

        {/* ─── Stats — 3 colonnes Crimson Pro (style Rangs Explorateur) ─── */}
        <div style={{padding:'16px 20px 0',display:'grid',gridTemplateColumns:'1fr 1fr 1fr',gap:10}}>
          {STATS.map((s,i)=>(
            <div key={i} style={{
              background:T.surface,border:`1px solid ${T.border}`,borderRadius:14,
              padding:'14px 12px',textAlign:'center',
              boxShadow:'0 1px 4px rgba(0,0,0,.04)',
            }}>
              <div style={{fontFamily:'Crimson Pro,serif',fontSize:26,fontWeight:600,color:T.text,letterSpacing:'-.5px',lineHeight:1}}>{s.val}</div>
              <div style={{fontSize:10,color:T.muted,marginTop:5,letterSpacing:.5,fontStyle:'italic',fontFamily:'Crimson Pro,serif'}}>{s.label}</div>
            </div>
          ))}
        </div>

        {/* ─── Sorties list ─── */}
        <div style={{padding:'20px 20px 24px'}}>
          <div style={{fontFamily:'Crimson Pro,serif',fontSize:16,fontWeight:600,color:T.text,marginBottom:12}}>Dernières sorties</div>
          {SORTIES.map((s,i)=>(
            <div key={i} style={{background:T.surface,borderRadius:14,border:`1px solid ${T.border}`,padding:'12px 14px',marginBottom:8,boxShadow:'0 1px 4px rgba(0,0,0,.04)',cursor:'pointer'}}>
              <div style={{display:'flex',alignItems:'center',gap:12}}>
                <div style={{width:38,height:38,borderRadius:11,background:T.surfVar,display:'flex',alignItems:'center',justifyContent:'center',fontSize:17,flexShrink:0}}>{s.emoji}</div>
                <div style={{flex:1,minWidth:0}}>
                  <div style={{display:'flex',alignItems:'center',gap:8}}>
                    <span style={{fontSize:13,fontWeight:600,color:T.text}}>{s.date}</span>
                    {s.new && <div style={{background:T.primary,borderRadius:20,padding:'1px 7px',fontSize:9,fontWeight:700,color:'#fff',letterSpacing:.5}}>NOUVEAU</div>}
                  </div>
                  <div style={{fontSize:11,color:T.muted,marginTop:2,fontVariantNumeric:'tabular-nums'}}>{s.rues} rues · {s.km}km · {s.dur}</div>
                </div>
                <div style={{textAlign:'right'}}>
                  {s.badges>0 && <div style={{fontSize:11,color:T.accent,fontWeight:600}}>+{s.badges} 🏆</div>}
                  <span style={{fontSize:18,color:T.muted}}>›</span>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
      <BottomNav active="profil" onChange={onNavigate} lang={lang}/>
    </div>
  );
};

Object.assign(window, {ParcoursScreen, SocialScreen, BadgesScreen, ProfilScreen});
