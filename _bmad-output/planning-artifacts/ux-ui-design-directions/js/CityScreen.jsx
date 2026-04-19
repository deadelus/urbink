'use strict';
// ─── City Picker Screen ───────────────────────────────────────────────────────

const CityScreen = ({onBack, currentCity, lang, onSelectCity}) => {
  const {React} = window;
  const {T, IC, StatusBar, DynamicIsland, PrimaryBtn} = window;
  const {t, CITIES} = window;

  const [search, setSearch] = React.useState('');
  const [selected, setSelected] = React.useState(currentCity);

  const filtered = CITIES.filter(c => {
    const name = c.name[lang] || c.name.fr;
    const country = c.country[lang] || c.country.fr;
    return name.toLowerCase().includes(search.toLowerCase()) ||
           country.toLowerCase().includes(search.toLowerCase());
  });

  const confirm = () => {
    onSelectCity(selected);
    onBack();
  };

  return (
    <div style={{position:'relative',width:390,height:844,overflow:'hidden',background:T.bg,fontFamily:'Inter,sans-serif'}}>
      <DynamicIsland/>
      <StatusBar/>

      {/* Header */}
      <div style={{position:'absolute',top:50,left:0,right:0,background:T.surface,borderBottom:`1px solid ${T.border}`,padding:'10px 12px',display:'flex',alignItems:'center',gap:10,zIndex:20}}>
        <div onClick={onBack} style={{width:36,height:36,display:'flex',alignItems:'center',justifyContent:'center',cursor:'pointer',borderRadius:10,background:T.surfVar,flexShrink:0}}>
          <IC.chevL/>
        </div>
        <div style={{flex:1}}>
          <div style={{fontSize:17,fontWeight:700,color:T.text}}>{t(lang,'city_change')}</div>
          <div style={{fontSize:11,color:T.muted,marginTop:1}}>{t(lang,'city_sub')}</div>
        </div>
      </div>

      {/* Search */}
      <div style={{position:'absolute',top:114,left:0,right:0,padding:'12px 16px',background:T.bg,zIndex:10}}>
        <div style={{height:44,background:T.surface,borderRadius:14,border:`1px solid ${T.border}`,display:'flex',alignItems:'center',padding:'0 12px',gap:10}}>
          <IC.search c={T.muted} s={16}/>
          <input
            value={search}
            onChange={e=>setSearch(e.target.value)}
            placeholder={lang==='ja'?'都市を検索…':lang==='es'?'Buscar ciudad…':lang==='pt'?'Buscar cidade…':'Search city…'}
            style={{flex:1,border:'none',outline:'none',fontSize:14,color:T.text,background:'transparent',fontFamily:'Inter,sans-serif'}}
          />
          {search && <span onClick={()=>setSearch('')} style={{fontSize:16,color:T.muted,cursor:'pointer'}}>✕</span>}
        </div>
      </div>

      {/* City list */}
      <div style={{position:'absolute',top:172,left:0,right:0,bottom:80,overflowY:'auto',padding:'0 16px 16px'}}>
        {filtered.map((city, i) => {
          const name = city.name[lang] || city.name.fr;
          const country = city.country[lang] || city.country.fr;
          const isSelected = selected === city.id;
          const isCurrent = currentCity === city.id;

          return (
            <div key={city.id} onClick={()=>setSelected(city.id)} style={{
              background: isSelected ? T.p06 : T.surface,
              borderRadius:18, border:`1.5px solid ${isSelected?T.primary:T.border}`,
              padding:'14px 16px', marginBottom:10,
              boxShadow:'0 1px 6px rgba(0,0,0,.04)', cursor:'pointer',
              transition:'all .15s',
            }}>
              <div style={{display:'flex',alignItems:'center',gap:14}}>
                {/* Flag + color dot */}
                <div style={{
                  width:48,height:48,borderRadius:14,
                  background:`${city.color}18`,
                  display:'flex',alignItems:'center',justifyContent:'center',
                  fontSize:26,flexShrink:0,
                  border:`1.5px solid ${city.color}30`,
                }}>
                  {city.flag}
                </div>

                <div style={{flex:1}}>
                  <div style={{display:'flex',alignItems:'center',gap:8,marginBottom:2}}>
                    <span style={{fontSize:15,fontWeight:700,color:T.text}}>{name}</span>
                    {isCurrent && (
                      <div style={{background:T.p10,borderRadius:20,padding:'2px 8px',fontSize:10,fontWeight:700,color:T.primary}}>
                        {t(lang,'city_active')}
                      </div>
                    )}
                  </div>
                  <div style={{fontSize:12,color:T.muted}}>{country}</div>

                  {/* Progress bar */}
                  {city.pct > 0 ? (
                    <div style={{marginTop:8}}>
                      <div style={{display:'flex',alignItems:'center',justifyContent:'space-between',marginBottom:4}}>
                        <span style={{fontSize:10,color:T.muted}}>
                          {city.explored.toLocaleString()} / {city.streets.toLocaleString()} {t(lang,'city_streets')}
                        </span>
                        <span style={{fontSize:10,fontWeight:700,color:city.color}}>{city.pct}% {t(lang,'city_explored')}</span>
                      </div>
                      <div style={{height:4,background:T.surfVar,borderRadius:2,overflow:'hidden'}}>
                        <div style={{width:`${city.pct}%`,height:'100%',background:city.color,borderRadius:2}}/>
                      </div>
                    </div>
                  ) : (
                    <div style={{marginTop:6,fontSize:10,color:T.muted}}>
                      {city.streets.toLocaleString()} {t(lang,'city_streets')} · {t(lang,'city_select')}
                    </div>
                  )}
                </div>

                {/* Radio */}
                <div style={{width:22,height:22,borderRadius:'50%',border:`2px solid ${isSelected?T.primary:T.border}`,display:'flex',alignItems:'center',justifyContent:'center',flexShrink:0}}>
                  {isSelected && <div style={{width:10,height:10,borderRadius:'50%',background:T.primary}}/>}
                </div>
              </div>
            </div>
          );
        })}

        {filtered.length === 0 && (
          <div style={{textAlign:'center',padding:'40px 16px',color:T.muted}}>
            <div style={{fontSize:32,marginBottom:8}}>🔍</div>
            <div style={{fontSize:14,fontWeight:500}}>Aucune ville trouvée</div>
          </div>
        )}
      </div>

      {/* Confirm button */}
      <div style={{position:'absolute',bottom:0,left:0,right:0,padding:'12px 16px 28px',background:T.surface,borderTop:`1px solid ${T.border}`}}>
        <PrimaryBtn
          label={`${CITIES.find(c=>c.id===selected)?.flag || '🌍'} ${CITIES.find(c=>c.id===selected)?.name[lang] || ''}`}
          onClick={confirm}
          disabled={selected===currentCity}
        />
      </div>
    </div>
  );
};

Object.assign(window, {CityScreen});
