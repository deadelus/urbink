'use strict';
// ─── Settings Screen + Sub-screens ───────────────────────────────────────────

// ─── Shared sub-screen shell ──────────────────────────────────────────────────
const SubShell = ({title, onBack, children, T, IC}) => (
  <div style={{position:'absolute',inset:0,background:T.bg,zIndex:10,animation:'slideUp .25s ease',overflowY:'auto',fontFamily:'Inter,sans-serif'}}>
    <div style={{position:'sticky',top:0,background:T.surface,borderBottom:`1px solid ${T.border}`,padding:'10px 12px',display:'flex',alignItems:'center',gap:10,zIndex:5}}>
      <div onClick={onBack} style={{width:36,height:36,borderRadius:10,background:T.surfVar,display:'flex',alignItems:'center',justifyContent:'center',cursor:'pointer',flexShrink:0}}>
        <IC.chevL/>
      </div>
      <span style={{fontSize:16,fontWeight:700,color:T.text}}>{title}</span>
    </div>
    <div style={{padding:'16px'}}>{children}</div>
  </div>
);

// ─── Input field ──────────────────────────────────────────────────────────────
const InputField = ({label, type='text', placeholder, T}) => (
  <div style={{marginBottom:14}}>
    <div style={{fontSize:12,fontWeight:600,color:'#64748B',marginBottom:6}}>{label}</div>
    <input type={type} placeholder={placeholder} style={{
      width:'100%', height:48, borderRadius:14, border:`1.5px solid ${T.border}`,
      padding:'0 14px', fontSize:14, color:T.text, background:T.surface,
      fontFamily:'Inter,sans-serif', outline:'none',
    }}/>
  </div>
);

// ─── Radio option ─────────────────────────────────────────────────────────────
const RadioOption = ({label, sub, selected, onSelect, T, preview}) => (
  <div onClick={onSelect} style={{
    display:'flex', alignItems:'center', gap:14, padding:'14px 16px',
    background:T.surface, borderRadius:16, border:`1.5px solid ${selected?T.primary:T.border}`,
    marginBottom:10, cursor:'pointer', transition:'all .15s',
    background: selected ? T.p06 : T.surface,
  }}>
    {preview && <div style={{width:48,height:36,borderRadius:8,overflow:'hidden',flexShrink:0}}>{preview}</div>}
    <div style={{flex:1}}>
      <div style={{fontSize:14,fontWeight:600,color:T.text}}>{label}</div>
      {sub && <div style={{fontSize:12,color:'#64748B',marginTop:2}}>{sub}</div>}
    </div>
    <div style={{width:20,height:20,borderRadius:'50%',border:`2px solid ${selected?T.primary:'#CBD5E1'}`,display:'flex',alignItems:'center',justifyContent:'center',flexShrink:0}}>
      {selected && <div style={{width:9,height:9,borderRadius:'50%',background:T.primary}}/>}
    </div>
  </div>
);

// ─── Map style mini previews ──────────────────────────────────────────────────
const MapPreview = ({bg, streetColor, gridColor}) => (
  <svg viewBox="0 0 48 36" style={{width:48,height:36}}>
    <rect width="48" height="36" fill={bg}/>
    <line x1="0" y1="12" x2="48" y2="12" stroke={streetColor} strokeWidth="2"/>
    <line x1="0" y1="24" x2="48" y2="24" stroke={gridColor} strokeWidth="1" opacity="0.5"/>
    <line x1="16" y1="0" x2="16" y2="36" stroke={streetColor} strokeWidth="2"/>
    <line x1="32" y1="0" x2="32" y2="36" stroke={gridColor} strokeWidth="1" opacity="0.5"/>
    <rect x="18" y="2" width="12" height="8" rx="1" fill={gridColor} opacity="0.6"/>
    <rect x="2" y="14" width="12" height="8" rx="1" fill={gridColor} opacity="0.6"/>
  </svg>
);

// ─── Sub-screens ──────────────────────────────────────────────────────────────
const CreateAccountSub = ({onBack, T, IC, lang}) => {
  const tFn = window.t || ((l,k)=>k);
  const {React} = window;
  const [done, setDone] = React.useState(false);
  return (
    <SubShell title={lang==='en'?'Create account':lang==='es'?'Crear cuenta':lang==='pt'?'Criar conta':lang==='ja'?'アカウント作成':'Créer un compte'} onBack={onBack} T={T} IC={IC}>
      {!done ? <>
        <div style={{textAlign:'center',padding:'16px 0 24px'}}>
          <div style={{width:64,height:64,borderRadius:20,background:T.p10,display:'flex',alignItems:'center',justifyContent:'center',fontSize:28,margin:'0 auto 12px'}}>👤</div>
          <div style={{fontSize:16,fontWeight:700,color:T.text,marginBottom:6}}>{lang==='en'?'Join Urbink':lang==='es'?'Únete a Urbink':lang==='pt'?'Junte-se ao Urbink':lang==='ja'?'Urbinkに参加':'Rejoignez Urbink'}</div>
          <div style={{fontSize:13,color:'#64748B',lineHeight:1.5}}>{lang==='en'?'Save your progress across devices':lang==='es'?'Guarda tu progreso en todos los dispositivos':lang==='pt'?'Salve seu progresso em todos os dispositivos':lang==='ja'?'デバイス間で進捗を保存':'Sauvegardez votre progression sur tous vos appareils'}</div>
        </div>
        <InputField label="Email" type="email" placeholder="alex@exemple.com" T={T}/>
        <InputField label={lang==='en'?'Password':lang==='es'?'Contraseña':lang==='pt'?'Senha':lang==='ja'?'パスワード':'Mot de passe'} type="password" placeholder="••••••••" T={T}/>
        <InputField label={lang==='en'?'Confirm password':lang==='es'?'Confirmar contraseña':lang==='pt'?'Confirmar senha':lang==='ja'?'パスワードを確認':'Confirmer le mot de passe'} type="password" placeholder="••••••••" T={T}/>
        <button onClick={()=>setDone(true)} style={{width:'100%',height:52,borderRadius:16,background:T.primary,color:'white',border:'none',fontSize:15,fontWeight:600,cursor:'pointer',marginTop:8,boxShadow:'0 4px 14px rgba(37,111,76,.35)',fontFamily:'Inter,sans-serif'}}>
          {lang==='en'?'Create account':lang==='es'?'Crear cuenta':lang==='pt'?'Criar conta':lang==='ja'?'アカウントを作成':'Créer mon compte'}
        </button>
        <div style={{textAlign:'center',marginTop:16,fontSize:13,color:'#64748B'}}>
          {lang==='en'?'Already have an account?':lang==='es'?'¿Ya tienes cuenta?':lang==='pt'?'Já tem uma conta?':lang==='ja'?'すでにアカウントをお持ちですか？':'Déjà un compte ?'}
          <span onClick={onBack} style={{color:T.primary,fontWeight:600,marginLeft:4,cursor:'pointer'}}>{lang==='en'?'Sign in':lang==='es'?'Iniciar sesión':lang==='pt'?'Entrar':lang==='ja'?'ログイン':'Se connecter'}</span>
        </div>
      </> : (
        <div style={{textAlign:'center',padding:'40px 0'}}>
          <div style={{fontSize:52,marginBottom:16}}>🎉</div>
          <div style={{fontSize:20,fontWeight:700,color:T.text,marginBottom:8}}>{lang==='en'?'Welcome!':lang==='es'?'¡Bienvenido!':lang==='pt'?'Bem-vindo!':lang==='ja'?'ようこそ！':'Bienvenue !'}</div>
          <div style={{fontSize:13,color:'#64748B',marginBottom:24}}>{lang==='en'?'Your account has been created':lang==='es'?'Tu cuenta ha sido creada':lang==='pt'?'Sua conta foi criada':lang==='ja'?'アカウントが作成されました':'Votre compte a été créé'}</div>
          <button onClick={onBack} style={{height:48,padding:'0 32px',borderRadius:14,background:T.primary,color:'white',border:'none',fontSize:14,fontWeight:600,cursor:'pointer',fontFamily:'Inter,sans-serif'}}>OK</button>
        </div>
      )}
    </SubShell>
  );
};

const LoginSub = ({onBack, T, IC, lang}) => {
  const {React} = window;
  const [done, setDone] = React.useState(false);
  return (
    <SubShell title={lang==='en'?'Sign in':lang==='es'?'Iniciar sesión':lang==='pt'?'Entrar':lang==='ja'?'ログイン':'Se connecter'} onBack={onBack} T={T} IC={IC}>
      {!done ? <>
        <div style={{textAlign:'center',padding:'16px 0 24px'}}>
          <div style={{width:64,height:64,borderRadius:20,background:T.p10,display:'flex',alignItems:'center',justifyContent:'center',fontSize:28,margin:'0 auto 12px'}}>🔑</div>
          <div style={{fontSize:16,fontWeight:700,color:T.text}}>{lang==='en'?'Welcome back':lang==='es'?'Bienvenido de nuevo':lang==='pt'?'Bem-vindo de volta':lang==='ja'?'おかえりなさい':'Bon retour'}</div>
        </div>
        <InputField label="Email" type="email" placeholder="alex@exemple.com" T={T}/>
        <InputField label={lang==='en'?'Password':lang==='es'?'Contraseña':lang==='pt'?'Senha':lang==='ja'?'パスワード':'Mot de passe'} type="password" placeholder="••••••••" T={T}/>
        <div style={{textAlign:'right',marginBottom:16}}>
          <span style={{fontSize:13,color:T.primary,cursor:'pointer',fontWeight:500}}>{lang==='en'?'Forgot password?':lang==='es'?'¿Olvidaste tu contraseña?':lang==='pt'?'Esqueceu a senha?':lang==='ja'?'パスワードをお忘れですか？':'Mot de passe oublié ?'}</span>
        </div>
        <button onClick={()=>setDone(true)} style={{width:'100%',height:52,borderRadius:16,background:T.primary,color:'white',border:'none',fontSize:15,fontWeight:600,cursor:'pointer',boxShadow:'0 4px 14px rgba(37,111,76,.35)',fontFamily:'Inter,sans-serif'}}>
          {lang==='en'?'Sign in':lang==='es'?'Iniciar sesión':lang==='pt'?'Entrar':lang==='ja'?'ログイン':'Se connecter'}
        </button>
      </> : (
        <div style={{textAlign:'center',padding:'40px 0'}}>
          <div style={{fontSize:52,marginBottom:16}}>✅</div>
          <div style={{fontSize:20,fontWeight:700,color:T.text,marginBottom:24}}>{lang==='en'?'Signed in!':lang==='es'?'¡Sesión iniciada!':lang==='pt'?'Conectado!':lang==='ja'?'ログインしました！':'Connecté !'}</div>
          <button onClick={onBack} style={{height:48,padding:'0 32px',borderRadius:14,background:T.primary,color:'white',border:'none',fontSize:14,fontWeight:600,cursor:'pointer',fontFamily:'Inter,sans-serif'}}>OK</button>
        </div>
      )}
    </SubShell>
  );
};

const MAP_STYLES = [
  {id:'classic', label:'Classique', sub:'Tons chauds désaturés — style Urbink', bg:'#E8E4D8', sc:'#8FAF8F', gc:'#CEC9BD'},
  {id:'warm',    label:'Chaud',     sub:'Ocre et terre cuite — vintage illustré', bg:'#F0E6D2', sc:'#B8832E', gc:'#D4B896'},
  {id:'night',   label:'Nuit',      sub:'Fond sombre — idéal en soirée', bg:'#1A1F2E', sc:'#34A76A', gc:'#2A3040'},
  {id:'sepia',   label:'Sépia',     sub:'Style carte ancienne gravée', bg:'#EDE0C8', sc:'#7A6040', gc:'#C8B898'},
];

const MapStyleSub = ({onBack, T, IC, lang}) => {
  const {React} = window;
  const [sel, setSel] = React.useState('classic');
  const labels = {classic:lang==='en'?'Classic':lang==='es'?'Clásico':lang==='pt'?'Clássico':lang==='ja'?'クラシック':'Classique', warm:lang==='en'?'Warm':lang==='es'?'Cálido':lang==='pt'?'Quente':lang==='ja'?'ウォーム':'Chaud', night:lang==='en'?'Night':lang==='es'?'Noche':lang==='pt'?'Noite':lang==='ja'?'ナイト':'Nuit', sepia:lang==='en'?'Sepia':lang==='es'?'Sepia':lang==='pt'?'Sépia':lang==='ja'?'セピア':'Sépia'};
  return (
    <SubShell title={lang==='en'?'Map style':lang==='es'?'Estilo de mapa':lang==='pt'?'Estilo do mapa':lang==='ja'?'マップスタイル':'Style de carte'} onBack={onBack} T={T} IC={IC}>
      {MAP_STYLES.map(s=>(
        <RadioOption key={s.id} label={labels[s.id]} sub={s.sub} selected={sel===s.id} onSelect={()=>setSel(s.id)} T={T}
          preview={<MapPreview bg={s.bg} streetColor={s.sc} gridColor={s.gc}/>}/>
      ))}
    </SubShell>
  );
};

const UnitsSub = ({onBack, T, IC, lang}) => {
  const {React} = window;
  const [sel, setSel] = React.useState('km');
  return (
    <SubShell title={lang==='en'?'Units':lang==='es'?'Unidades':lang==='pt'?'Unidades':lang==='ja'?'単位':'Unités'} onBack={onBack} T={T} IC={IC}>
      <RadioOption label="Kilomètres (km)" sub="1,0 km · 2,4 km · 10,5 km" selected={sel==='km'} onSelect={()=>setSel('km')} T={T}/>
      <RadioOption label="Miles (mi)" sub="0.6 mi · 1.5 mi · 6.5 mi" selected={sel==='mi'} onSelect={()=>setSel('mi')} T={T}/>
    </SubShell>
  );
};

const ThemeSub = ({onBack, T, IC, lang}) => {
  const {React} = window;
  const [sel, setSel] = React.useState('light');
  const opts = [
    {id:'light', label:lang==='en'?'Light':lang==='es'?'Claro':lang==='pt'?'Claro':lang==='ja'?'ライト':'Clair', sub:lang==='en'?'White background':lang==='es'?'Fondo blanco':lang==='pt'?'Fundo branco':lang==='ja'?'白い背景':'Fond blanc', emoji:'☀️'},
    {id:'dark',  label:lang==='en'?'Dark':lang==='es'?'Oscuro':lang==='pt'?'Escuro':lang==='ja'?'ダーク':'Sombre', sub:lang==='en'?'Dark background (coming soon)':lang==='es'?'Fondo oscuro (próximamente)':lang==='pt'?'Fundo escuro (em breve)':lang==='ja'?'ダーク背景（近日公開）':'Fond sombre (bientôt disponible)', emoji:'🌙'},
    {id:'auto',  label:lang==='en'?'System':lang==='es'?'Sistema':lang==='pt'?'Sistema':lang==='ja'?'システム':'Système', sub:lang==='en'?'Follows your device setting':lang==='es'?'Sigue la configuración de tu dispositivo':lang==='pt'?'Segue a configuração do dispositivo':lang==='ja'?'デバイス設定に従う':'Suit les réglages de votre appareil', emoji:'📱'},
  ];
  return (
    <SubShell title={lang==='en'?'Theme':lang==='es'?'Tema':lang==='pt'?'Tema':lang==='ja'?'テーマ':'Thème'} onBack={onBack} T={T} IC={IC}>
      {opts.map(o=>(
        <RadioOption key={o.id} label={`${o.emoji} ${o.label}`} sub={o.sub} selected={sel===o.id} onSelect={()=>setSel(o.id)} T={T}/>
      ))}
    </SubShell>
  );
};

const DensitySub = ({onBack, T, IC, lang}) => {
  const {React} = window;
  const [sel, setSel] = React.useState('normal');
  const opts = [
    {id:'low',    label:lang==='en'?'Low':lang==='es'?'Baja':lang==='pt'?'Baixa':lang==='ja'?'低':'Faible',    sub:lang==='en'?'Only major landmarks':lang==='es'?'Solo puntos de referencia principales':lang==='pt'?'Apenas marcos principais':lang==='ja'?'主要なランドマークのみ':'Monuments majeurs uniquement'},
    {id:'normal', label:lang==='en'?'Normal':lang==='es'?'Normal':lang==='pt'?'Normal':lang==='ja'?'通常':'Normale',  sub:lang==='en'?'Recommended':lang==='es'?'Recomendado':lang==='pt'?'Recomendado':lang==='ja'?'推奨':'Recommandée'},
    {id:'high',   label:lang==='en'?'High':lang==='es'?'Alta':lang==='pt'?'Alta':lang==='ja'?'高':'Élevée',    sub:lang==='en'?'All POIs visible':lang==='es'?'Todos los POIs visibles':lang==='pt'?'Todos os POIs visíveis':lang==='ja'?'すべてのPOIを表示':'Tous les POIs visibles'},
  ];
  return (
    <SubShell title={lang==='en'?'POI density':lang==='es'?'Densidad de POI':lang==='pt'?'Densidade de POI':lang==='ja'?'POI密度':'Densité des POI'} onBack={onBack} T={T} IC={IC}>
      {opts.map(o=>(
        <RadioOption key={o.id} label={o.label} sub={o.sub} selected={sel===o.id} onSelect={()=>setSel(o.id)} T={T}/>
      ))}
    </SubShell>
  );
};

const HelpSub = ({onBack, T, IC, lang}) => {
  const items = lang==='en'
    ? [['🗺️','How does street coloring work?','The GPS tracks your position and colors explored streets in real time.'],['🔋','Battery impact','Passive mode uses ~3% per hour. Recorded sessions ~6% per hour.'],['📍','GPS accuracy','Urbink requires "Always allow" for passive tracking. Your data never leaves your device.'],['🏆','How to unlock badges','Pass within 100m of a landmark. Badges unlock automatically, no tap needed.'],['🔄','Can I reset my progress?','Yes, in Settings > Danger > Delete all data. This is irreversible.']]
    : lang==='es'
    ? [['🗺️','¿Cómo funciona el coloreado?','El GPS rastrea tu posición y colorea las calles exploradas en tiempo real.'],['🔋','Impacto en la batería','El modo pasivo usa ~3% por hora. Las sesiones grabadas ~6% por hora.'],['📍','Precisión del GPS','Urbink requiere "Permitir siempre" para el rastreo pasivo.'],['🏆','¿Cómo desbloquear insignias?','Pasa a 100m de un monumento. Las insignias se desbloquean automáticamente.'],['🔄','¿Puedo restablecer mi progreso?','Sí, en Ajustes > Peligro > Borrar todos los datos.']]
    : [['🗺️','Comment fonctionne la coloration ?','Le GPS suit votre position et colorie les rues explorées en temps réel.'],['🔋','Impact sur la batterie','Mode passif : ~3% par heure. Sessions enregistrées : ~6% par heure.'],['📍','Précision GPS','Urbink nécessite "Toujours autoriser" pour le tracking passif. Vos données ne quittent jamais votre appareil.'],['🏆','Comment débloquer des badges ?','Passez à moins de 100m d\'un monument. Les badges se débloquent automatiquement, sans manipulation.'],['🔄','Puis-je réinitialiser ma progression ?','Oui, dans Paramètres > Danger > Effacer toutes mes données. C\'est irréversible.']];
  return (
    <SubShell title={lang==='en'?'Help & FAQ':lang==='es'?'Ayuda y FAQ':lang==='pt'?'Ajuda e FAQ':lang==='ja'?'ヘルプとFAQ':'Aide & FAQ'} onBack={onBack} T={T} IC={IC}>
      {items.map(([icon,q,a],i)=>(
        <div key={i} style={{background:T.surface,borderRadius:16,border:`1px solid ${T.border}`,padding:'14px 16px',marginBottom:10}}>
          <div style={{display:'flex',alignItems:'center',gap:10,marginBottom:8}}>
            <span style={{fontSize:18}}>{icon}</span>
            <span style={{fontSize:14,fontWeight:600,color:T.text}}>{q}</span>
          </div>
          <div style={{fontSize:13,color:'#64748B',lineHeight:1.6}}>{a}</div>
        </div>
      ))}
    </SubShell>
  );
};

// ─── Main Settings Screen ────────────────────────────────────────────────────
const SETTINGS_SECTIONS = [
  {
    title:'Compte',
    titleKey:{en:'Account',es:'Cuenta',pt:'Conta',ja:'アカウント'},
    items:[
      {icon:'👤',label:'Mode anonyme',labelKey:{en:'Anonymous mode',es:'Modo anónimo',pt:'Modo anônimo',ja:'匿名モード'},sub:'Aucun compte requis',subKey:{en:'No account required',es:'Sin cuenta requerida',pt:'Sem conta necessária',ja:'アカウント不要'},type:'badge',badge:'Actif',badgeKey:{en:'Active',es:'Activo',pt:'Ativo',ja:'有効'}},
      {icon:'✉️',label:'Créer un compte',labelKey:{en:'Create account',es:'Crear cuenta',pt:'Criar conta',ja:'アカウント作成'},sub:'Sauvegardez votre progression',subKey:{en:'Save your progress',es:'Guarda tu progreso',pt:'Salve seu progresso',ja:'進捗を保存'},type:'arrow',screen:'createAccount'},
      {icon:'🔑',label:'Se connecter',labelKey:{en:'Sign in',es:'Iniciar sesión',pt:'Entrar',ja:'ログイン'},sub:'Déjà un compte ?',subKey:{en:'Already have an account?',es:'¿Ya tienes cuenta?',pt:'Já tem conta?',ja:'アカウントをお持ちですか？'},type:'arrow',screen:'login'},
    ]
  },
  {
    title:'Confidentialité',
    titleKey:{en:'Privacy',es:'Privacidad',pt:'Privacidade',ja:'プライバシー'},
    items:[
      {icon:'📍',label:'Localisation GPS',labelKey:{en:'GPS location',es:'Ubicación GPS',pt:'Localização GPS',ja:'GPS位置情報'},sub:'Toujours autorisé',subKey:{en:'Always allowed',es:'Siempre permitido',pt:'Sempre permitido',ja:'常に許可'},type:'badge',badge:'✓ OK',badgeColor:'#256F4C'},
      {icon:'🗺️',label:'Tracking passif',labelKey:{en:'Passive tracking',es:'Rastreo pasivo',pt:'Rastreamento passivo',ja:'パッシブトラッキング'},sub:'Colorier les rues en arrière-plan',subKey:{en:'Color streets in background',es:'Colorear calles en segundo plano',pt:'Colorir ruas em segundo plano',ja:'バックグラウンドで通りを着色'},type:'toggle',key:'passiveTracking'},
      {icon:'👁️',label:'Profil public',labelKey:{en:'Public profile',es:'Perfil público',pt:'Perfil público',ja:'公開プロフィール'},sub:'Visible par les autres',subKey:{en:'Visible to others',es:'Visible para otros',pt:'Visível para outros',ja:'他のユーザーに表示'},type:'toggle',key:'publicProfile'},
      {icon:'📊',label:'Données anonymes',labelKey:{en:'Anonymous data',es:'Datos anónimos',pt:'Dados anônimos',ja:'匿名データ'},sub:'Améliore l\'app',subKey:{en:'Improves the app',es:'Mejora la app',pt:'Melhora o app',ja:'アプリを改善'},type:'toggle',key:'analytics'},
    ]
  },
  {
    title:'Notifications',
    titleKey:{en:'Notifications',es:'Notificaciones',pt:'Notificações',ja:'通知'},
    items:[
      {icon:'🏆',label:'Badges débloqués',labelKey:{en:'Badges unlocked',es:'Insignias desbloqueadas',pt:'Emblemas desbloqueados',ja:'バッジ解除'},type:'toggle',key:'notifBadges'},
      {icon:'🏘️',label:'Quartier complété',labelKey:{en:'District completed',es:'Barrio completado',pt:'Bairro completo',ja:'地区完了'},type:'toggle',key:'notifDistrict'},
      {icon:'💬',label:'Activité sociale',labelKey:{en:'Social activity',es:'Actividad social',pt:'Atividade social',ja:'ソーシャル活動'},type:'toggle',key:'notifSocial'},
      {icon:'🔔',label:'Rappels doux',labelKey:{en:'Gentle reminders',es:'Recordatorios suaves',pt:'Lembretes suaves',ja:'やさしいリマインダー'},sub:'Max 1 / semaine',subKey:{en:'Max 1/week',es:'Máx. 1/semana',pt:'Máx. 1/semana',ja:'週1回まで'},type:'toggle',key:'notifReminders'},
    ]
  },
  {
    title:'Carte',
    titleKey:{en:'Map',es:'Mapa',pt:'Mapa',ja:'地図'},
    items:[
      {icon:'🎨',label:'Style de carte',labelKey:{en:'Map style',es:'Estilo de mapa',pt:'Estilo do mapa',ja:'マップスタイル'},sub:'Classique',subKey:{en:'Classic',es:'Clásico',pt:'Clássico',ja:'クラシック'},type:'arrow',screen:'mapStyle'},
      {icon:'📏',label:'Unités',labelKey:{en:'Units',es:'Unidades',pt:'Unidades',ja:'単位'},sub:'Kilomètres',subKey:{en:'Kilometres',es:'Kilómetros',pt:'Quilômetros',ja:'キロメートル'},type:'arrow',screen:'units'},
      {icon:'🌿',label:'Couleur des rues',labelKey:{en:'Street color',es:'Color de calles',pt:'Cor das ruas',ja:'通りの色'},type:'color'},
      {icon:'🏙️',label:'Densité des POI',labelKey:{en:'POI density',es:'Densidad de POI',pt:'Densidade de POI',ja:'POI密度'},sub:'Normale',subKey:{en:'Normal',es:'Normal',pt:'Normal',ja:'通常'},type:'arrow',screen:'density'},
    ]
  },
  {
    title:'Application',
    titleKey:{en:'App',es:'Aplicación',pt:'Aplicativo',ja:'アプリ'},
    items:[
      {icon:'🌙',label:'Thème',labelKey:{en:'Theme',es:'Tema',pt:'Tema',ja:'テーマ'},sub:'Clair',subKey:{en:'Light',es:'Claro',pt:'Claro',ja:'ライト'},type:'arrow',screen:'theme'},
      {icon:'⚡',label:'Économie batterie',labelKey:{en:'Battery saver',es:'Ahorro de batería',pt:'Economia de bateria',ja:'バッテリー節約'},type:'toggle',key:'battery'},
    ]
  },
  {
    title:'Aide & Légal',
    titleKey:{en:'Help & Legal',es:'Ayuda y Legal',pt:'Ajuda e Legal',ja:'ヘルプと法的情報'},
    items:[
      {icon:'❓',label:'Aide & FAQ',labelKey:{en:'Help & FAQ',es:'Ayuda y FAQ',pt:'Ajuda e FAQ',ja:'ヘルプとFAQ'},type:'arrow',screen:'help'},
      {icon:'⭐',label:'Noter l\'app',labelKey:{en:'Rate the app',es:'Calificar app',pt:'Avaliar app',ja:'アプリを評価'},type:'arrow'},
      {icon:'📝',label:'Conditions d\'utilisation',labelKey:{en:'Terms of use',es:'Términos de uso',pt:'Termos de uso',ja:'利用規約'},type:'arrow'},
      {icon:'🔒',label:'Confidentialité',labelKey:{en:'Privacy policy',es:'Política de privacidad',pt:'Política de privacidade',ja:'プライバシーポリシー'},type:'arrow'},
      {icon:'ℹ️',label:'Version',sub:'1.0.0 (build 42)',type:'text'},
    ]
  },
];

const SettingsToggle = ({active, onToggle}) => {
  const {T} = window;
  return (
    <div onClick={onToggle} style={{width:44,height:26,borderRadius:13,background:active?T.primary:'#CBD5E1',position:'relative',cursor:'pointer',transition:'background .2s',flexShrink:0}}>
      <div style={{position:'absolute',top:3,left:active?21:3,width:20,height:20,borderRadius:'50%',background:'white',boxShadow:'0 1px 4px rgba(0,0,0,.2)',transition:'left .2s'}}/>
    </div>
  );
};

const GearIcon = ({c='#0F172A',s=20}) => (
  <svg width={s} height={s} fill="none" viewBox="0 0 24 24">
    <path d="M12 15a3 3 0 100-6 3 3 0 000 6z" stroke={c} strokeWidth="1.8"/>
    <path d="M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 010 2.83 2 2 0 01-2.83 0l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 01-4 0v-.09A1.65 1.65 0 009 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 01-2.83-2.83l.06-.06A1.65 1.65 0 004.68 15a1.65 1.65 0 00-1.51-1H3a2 2 0 010-4h.09A1.65 1.65 0 004.6 9a1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 012.83-2.83l.06.06A1.65 1.65 0 009 4.68a1.65 1.65 0 001-1.51V3a2 2 0 014 0v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 012.83 2.83l-.06.06A1.65 1.65 0 0019.4 9a1.65 1.65 0 001.51 1H21a2 2 0 010 4h-.09a1.65 1.65 0 00-1.51 1z" stroke={c} strokeWidth="1.8"/>
  </svg>
);

const SettingsScreen = ({onBack, lang='fr', onLangChange}) => {
  const {React} = window;
  const {T, IC, StatusBar, DynamicIsland, LANGUAGES} = window;
  const tFn = window.t || ((l,k)=>k);
  const [toggles, setToggles] = React.useState({passiveTracking:true,publicProfile:false,analytics:true,notifBadges:true,notifDistrict:true,notifSocial:false,notifReminders:false,battery:true});
  const [subScreen, setSubScreen] = React.useState(null);
  const flip = k => setToggles(t=>({...t,[k]:!t[k]}));

  const getLbl = (item) => item.labelKey?.[lang] || item.label;
  const getSub = (item) => item.subKey?.[lang] || item.sub;
  const getSecTitle = (s) => s.titleKey?.[lang] || s.title;

  // Sub-screen routing
  if (subScreen==='createAccount') return <CreateAccountSub onBack={()=>setSubScreen(null)} T={T} IC={IC} lang={lang}/>;
  if (subScreen==='login')         return <LoginSub         onBack={()=>setSubScreen(null)} T={T} IC={IC} lang={lang}/>;
  if (subScreen==='mapStyle')      return <MapStyleSub      onBack={()=>setSubScreen(null)} T={T} IC={IC} lang={lang}/>;
  if (subScreen==='units')         return <UnitsSub         onBack={()=>setSubScreen(null)} T={T} IC={IC} lang={lang}/>;
  if (subScreen==='theme')         return <ThemeSub         onBack={()=>setSubScreen(null)} T={T} IC={IC} lang={lang}/>;
  if (subScreen==='density')       return <DensitySub       onBack={()=>setSubScreen(null)} T={T} IC={IC} lang={lang}/>;
  if (subScreen==='help')          return <HelpSub          onBack={()=>setSubScreen(null)} T={T} IC={IC} lang={lang}/>;

  return (
    <div style={{position:'relative',width:390,height:844,overflow:'hidden',background:T.bg,fontFamily:'Inter,sans-serif'}}>
      <DynamicIsland/>
      <StatusBar/>
      <div style={{position:'absolute',top:50,left:0,right:0,background:T.surface,borderBottom:`1px solid ${T.border}`,padding:'10px 8px',display:'flex',alignItems:'center',gap:8,zIndex:20}}>
        <div onClick={onBack} style={{width:36,height:36,display:'flex',alignItems:'center',justifyContent:'center',cursor:'pointer',borderRadius:10,background:T.surfVar}}>
          <IC.chevL/>
        </div>
        <span style={{fontSize:17,fontWeight:700,color:T.text,flex:1}}>{tFn(lang,'settings_title')}</span>
        <div style={{width:36,height:36,display:'flex',alignItems:'center',justifyContent:'center'}}>
          <GearIcon c={T.muted} s={18}/>
        </div>
      </div>

      <div style={{position:'absolute',top:106,left:0,right:0,bottom:0,overflowY:'auto',paddingBottom:32}}>
        {/* Profile + language */}
        <div style={{margin:'16px 16px 8px',background:`linear-gradient(135deg,${T.primary},#1a5438)`,borderRadius:20,padding:'16px'}}>
          <div style={{display:'flex',alignItems:'center',gap:14,marginBottom:16}}>
            <div style={{width:50,height:50,borderRadius:'50%',background:'rgba(255,255,255,.2)',display:'flex',alignItems:'center',justifyContent:'center',fontSize:22,fontWeight:700,color:'white',border:'2px solid rgba(255,255,255,.3)',flexShrink:0}}>A</div>
            <div style={{flex:1}}>
              <div style={{fontSize:16,fontWeight:700,color:'white'}}>Alex Dupont</div>
              <div style={{fontSize:12,color:'rgba(255,255,255,.65)',marginTop:2}}>{lang==='en'?'Anonymous explorer':lang==='es'?'Explorador anónimo':lang==='pt'?'Explorador anônimo':lang==='ja'?'匿名エクスプローラー':'Explorateur anonyme'} · Paris</div>
            </div>
            <div style={{background:'rgba(255,255,255,.15)',borderRadius:20,padding:'6px 12px',fontSize:12,fontWeight:600,color:'white',cursor:'pointer'}}>{lang==='en'?'Edit':lang==='es'?'Editar':lang==='pt'?'Editar':lang==='ja'?'編集':'Éditer'}</div>
          </div>
          <div style={{borderTop:'1px solid rgba(255,255,255,.15)',paddingTop:14}}>
            <div style={{fontSize:10,fontWeight:700,color:'rgba(255,255,255,.6)',letterSpacing:1,textTransform:'uppercase',marginBottom:8}}>{tFn(lang,'lang_title')}</div>
            <div style={{display:'flex',gap:6,flexWrap:'wrap'}}>
              {LANGUAGES && LANGUAGES.map(l=>(
                <div key={l.id} onClick={()=>onLangChange&&onLangChange(l.id)} style={{display:'flex',alignItems:'center',gap:6,padding:'5px 10px',borderRadius:20,cursor:'pointer',background:lang===l.id?'rgba(255,255,255,.25)':'rgba(255,255,255,.08)',border:`1.5px solid ${lang===l.id?'rgba(255,255,255,.6)':'rgba(255,255,255,.12)'}`,transition:'all .15s'}}>
                  <span style={{fontSize:13}}>{l.flag}</span>
                  <span style={{fontSize:11,fontWeight:600,color:'white'}}>{l.native}</span>
                </div>
              ))}
            </div>
          </div>
        </div>

        {SETTINGS_SECTIONS.map((section,si)=>(
          <div key={si} style={{marginTop:24}}>
            <div style={{fontSize:11,fontWeight:700,color:T.muted,letterSpacing:1,textTransform:'uppercase',padding:'0 16px',marginBottom:8}}>{getSecTitle(section)}</div>
            <div style={{background:T.surface,borderRadius:16,margin:'0 16px',border:`1px solid ${T.border}`,overflow:'hidden',boxShadow:'0 1px 4px rgba(0,0,0,.04)'}}>
              {section.items.map((item,ii)=>(
                <div key={ii} onClick={()=>item.screen?setSubScreen(item.screen):null}
                  style={{display:'flex',alignItems:'center',gap:12,padding:'13px 16px',borderBottom:ii<section.items.length-1?`1px solid ${T.border}`:'none',cursor:item.type==='text'?'default':'pointer',background:T.surface}}>
                  <div style={{width:36,height:36,borderRadius:10,background:T.surfVar,display:'flex',alignItems:'center',justifyContent:'center',fontSize:17,flexShrink:0}}>{item.icon}</div>
                  <div style={{flex:1,minWidth:0}}>
                    <div style={{fontSize:14,fontWeight:500,color:T.text}}>{getLbl(item)}</div>
                    {item.type!=='text' && getSub(item) && !['createAccount','login','mapStyle','units','theme','density','help'].includes(getSub(item)) && <div style={{fontSize:12,color:T.muted,marginTop:1}}>{getSub(item)}</div>}
                  </div>
                  {item.type==='toggle' && <SettingsToggle active={toggles[item.key]} onToggle={()=>flip(item.key)}/>}
                  {item.type==='arrow' && <svg width="16" height="16" fill="none" viewBox="0 0 24 24"><path d="M9 18l6-6-6-6" stroke={T.muted} strokeWidth="2" strokeLinecap="round"/></svg>}
                  {item.type==='badge' && <div style={{background:item.badgeColor?`${item.badgeColor}18`:T.p10,borderRadius:20,padding:'3px 10px',fontSize:11,fontWeight:600,color:item.badgeColor||T.primary}}>{item.badgeKey?.[lang]||item.badge}</div>}
                  {item.type==='color' && <div style={{width:22,height:22,borderRadius:'50%',background:T.primary,border:`2px solid ${T.border}`}}/>}
                </div>
              ))}
            </div>
          </div>
        ))}

        {/* Danger zone */}
        <div style={{margin:'24px 16px 0'}}>
          <div style={{fontSize:11,fontWeight:700,color:T.muted,letterSpacing:1,textTransform:'uppercase',marginBottom:8}}>{lang==='en'?'Danger':lang==='es'?'Peligro':lang==='pt'?'Perigo':lang==='ja'?'危険':'Danger'}</div>
          <div style={{background:T.surface,borderRadius:16,border:`1px solid ${T.border}`,overflow:'hidden'}}>
            <div style={{display:'flex',alignItems:'center',gap:12,padding:'13px 16px',borderBottom:`1px solid ${T.border}`,cursor:'pointer'}}>
              <div style={{width:36,height:36,borderRadius:10,background:'rgba(220,38,38,.08)',display:'flex',alignItems:'center',justifyContent:'center',fontSize:17}}>🗑️</div>
              <div style={{flex:1}}><div style={{fontSize:14,fontWeight:500,color:T.red}}>{lang==='en'?'Delete all data':lang==='es'?'Borrar todos los datos':lang==='pt'?'Excluir todos os dados':lang==='ja'?'すべてのデータを削除':'Effacer toutes mes données'}</div><div style={{fontSize:12,color:T.muted}}>{lang==='en'?'Irreversible':lang==='es'?'Irreversible':lang==='pt'?'Irreversível':lang==='ja'?'元に戻せません':'Irréversible'}</div></div>
              <svg width="16" height="16" fill="none" viewBox="0 0 24 24"><path d="M9 18l6-6-6-6" stroke={T.muted} strokeWidth="2" strokeLinecap="round"/></svg>
            </div>
            <div style={{display:'flex',alignItems:'center',gap:12,padding:'13px 16px',cursor:'pointer'}}>
              <div style={{width:36,height:36,borderRadius:10,background:'rgba(220,38,38,.08)',display:'flex',alignItems:'center',justifyContent:'center',fontSize:17}}>🚪</div>
              <div style={{flex:1}}><div style={{fontSize:14,fontWeight:500,color:T.red}}>{lang==='en'?'Sign out':lang==='es'?'Cerrar sesión':lang==='pt'?'Sair':lang==='ja'?'サインアウト':'Se déconnecter'}</div></div>
              <svg width="16" height="16" fill="none" viewBox="0 0 24 24"><path d="M9 18l6-6-6-6" stroke={T.muted} strokeWidth="2" strokeLinecap="round"/></svg>
            </div>
          </div>
        </div>
        <div style={{textAlign:'center',marginTop:24,fontSize:11,color:T.muted}}>Urbink v1.0.0 · {lang==='en'?'Made with':lang==='es'?'Hecho con':lang==='pt'?'Feito com':lang==='ja'?'パリで作成':'Fait avec'} ❤️ {lang==='en'||lang==='ja'?'in Paris':'à Paris'}</div>
      </div>
    </div>
  );
};

Object.assign(window, {SettingsScreen});
