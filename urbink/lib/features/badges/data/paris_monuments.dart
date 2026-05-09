import 'package:latlong2/latlong.dart';
import 'package:urbink/features/badges/data/collection_model.dart';

// ---------------------------------------------------------------------------
// Table maître — monuments Paris gamifiables
// IDs alignés avec les IDs du GeoJSON assets/geo/paris/monuments.json
// ---------------------------------------------------------------------------

const Map<String, CollectionMonument> kParisMonuments = {
  // ── Monuments emblématiques ──────────────────────────────────────────────
  'PA00088801': CollectionMonument(
    id: 'PA00088801',
    emoji: '🗼',
    name: 'Tour Eiffel',
    location: LatLng(48.8584, 2.2945),
    arrondissement: '7e',
    era: '1889',
    description:
        'Le symbole de Paris, 330 m de fer forgé. Construite par Gustave Eiffel pour l\'Exposition Universelle de 1889.',
  ),
  'PA00086250': CollectionMonument(
    id: 'PA00086250',
    emoji: '🏰',
    name: 'Notre-Dame',
    location: LatLng(48.8530, 2.3499),
    arrondissement: '4e',
    era: 'XIIᵉ',
    description:
        'Cathédrale gothique sur l\'Île de la Cité, chef-d\'œuvre du Moyen Âge. En cours de restauration après l\'incendie de 2019.',
  ),
  'PA00085992': CollectionMonument(
    id: 'PA00085992',
    emoji: '🏛️',
    name: 'Musée du Louvre',
    location: LatLng(48.8606, 2.3376),
    arrondissement: '1er',
    era: 'XIIᵉ',
    description:
        'Ancien palais royal devenu le plus grand musée du monde. La Joconde et la Vénus de Milo y résident depuis des siècles.',
  ),
  'PA75180004': CollectionMonument(
    id: 'PA75180004',
    emoji: '⛪',
    name: 'Sacré-Cœur',
    location: LatLng(48.8867, 2.3431),
    arrondissement: '18e',
    era: '1914',
    description:
        'Basilique blanche de Montmartre perchée à 130 m d\'altitude. Sa coupole offre une vue à 360° sur Paris.',
  ),
  'PA00088420': CollectionMonument(
    id: 'PA00088420',
    emoji: '🏛️',
    name: 'Panthéon',
    location: LatLng(48.8462, 2.3461),
    arrondissement: '5e',
    era: '1790',
    description:
        'Mausolée des grands hommes de la République. Voltaire, Victor Hugo, Marie Curie et Zola y reposent.',
  ),
  'PA00088804': CollectionMonument(
    id: 'PA00088804',
    emoji: '🌉',
    name: 'Arc de Triomphe',
    location: LatLng(48.8738, 2.2950),
    arrondissement: '8e',
    era: '1836',
    description:
        'Érigé à la gloire des armées napoléoniennes. La Tombe du Soldat inconnu brûle sous ses voûtes depuis 1921.',
  ),
  // ── Édifices religieux ───────────────────────────────────────────────────
  'PA00088812': CollectionMonument(
    id: 'PA00088812',
    emoji: '⛪',
    name: 'La Madeleine',
    location: LatLng(48.8700, 2.3249),
    arrondissement: '8e',
    era: '1842',
    description:
        'Temple grec néoclassique dédié à Marie-Madeleine, commandé par Napoléon. Ses 52 colonnes corinthiennes dominent la place.',
  ),
  'PA00088510': CollectionMonument(
    id: 'PA00088510',
    emoji: '⛪',
    name: 'Saint-Sulpice',
    location: LatLng(48.8509, 2.3337),
    arrondissement: '6e',
    era: 'XVIIᵉ',
    description:
        'Deuxième plus grande église de Paris après Notre-Dame. Ses fresques de Delacroix en font un musée à ciel ouvert.',
  ),
  'PA00085795': CollectionMonument(
    id: 'PA00085795',
    emoji: '⛪',
    name: 'Saint-Eustache',
    location: LatLng(48.8607, 2.3476),
    arrondissement: '1er',
    era: 'XVIᵉ',
    description:
        'Joyau gothique aux Halles, aux dimensions quasi-cathédrale. Liszt et Rameau y jouèrent leurs premières œuvres.',
  ),
  'PA00086001': CollectionMonument(
    id: 'PA00086001',
    emoji: '⛪',
    name: 'Sainte-Chapelle',
    location: LatLng(48.8554, 2.3450),
    arrondissement: '1er',
    era: '1248',
    description:
        'Joyau gothique de Louis IX. Ses 1113 vitraux racontent la Bible sur 15 m de hauteur dans un écrin de lumière.',
  ),
  'PA00088392': CollectionMonument(
    id: 'PA00088392',
    emoji: '⛪',
    name: 'Val-de-Grâce',
    location: LatLng(48.8444, 2.3443),
    arrondissement: '5e',
    era: 'XVIIᵉ',
    description:
        'Ancienne abbaye royale bâtie pour Anne d\'Autriche. Chef-d\'œuvre du baroque français, aujourd\'hui musée militaire.',
  ),
  'PA00088414': CollectionMonument(
    id: 'PA00088414',
    emoji: '⛪',
    name: 'Saint-Étienne-du-Mont',
    location: LatLng(48.8484, 2.3497),
    arrondissement: '5e',
    era: 'XVIᵉ',
    description:
        'Église gothique abritant les reliques de Sainte-Geneviève, patronne de Paris. Son jubé sculpté est unique en France.',
  ),
  // ── Ponts ────────────────────────────────────────────────────────────────
  'PA00085999': CollectionMonument(
    id: 'PA00085999',
    emoji: '🌉',
    name: 'Pont Neuf',
    location: LatLng(48.8572, 2.3413),
    arrondissement: '1er',
    era: '1607',
    description:
        'Le plus vieux pont de Paris, malgré son nom. Ses 400 ans d\'histoire en font un témoignage exceptionnel de la capitale.',
  ),
  'PA00088798': CollectionMonument(
    id: 'PA00088798',
    emoji: '🌉',
    name: 'Pont Alexandre III',
    location: LatLng(48.8638, 2.3130),
    arrondissement: '8e',
    era: '1900',
    description:
        'Pont Belle Époque le plus orné de Paris. Ses quatre piliers dorés et ses candélabres en font un chef-d\'œuvre Beaux-Arts.',
  ),
  'PA00088800': CollectionMonument(
    id: 'PA00088800',
    emoji: '🌉',
    name: "Pont d'Iéna",
    location: LatLng(48.8579, 2.2929),
    arrondissement: '7e',
    era: '1814',
    description:
        'Pont napoléonien reliant le Trocadéro à la Tour Eiffel. Ses aigles impériaux ornent ses culées en pierre.',
  ),
  'PA00085998': CollectionMonument(
    id: 'PA00085998',
    emoji: '🌉',
    name: 'Pont des Arts',
    location: LatLng(48.8582, 2.3376),
    arrondissement: '6e',
    era: '1804',
    description:
        'Passerelle piétonne et premier pont en métal de Paris. Anciennement couvert de cadenas d\'amoureux déposés sur la Seine.',
  ),
  'PA00086659': CollectionMonument(
    id: 'PA00086659',
    emoji: '🌉',
    name: 'Pont Mirabeau',
    location: LatLng(48.8503, 2.2849),
    arrondissement: '15e',
    era: '1897',
    description:
        'Rendu immortel par le poème d\'Apollinaire. Ses allégories en bronze et sa vue sur la Seine en font un pont-poème.',
  ),
  'PA00086658': CollectionMonument(
    id: 'PA00086658',
    emoji: '🌉',
    name: 'Pont de Bir-Hakeim',
    location: LatLng(48.8535, 2.2898),
    arrondissement: '15e',
    era: '1905',
    description:
        'Pont à double niveau iconique portant le métro aérien. Décor de films cultes dont Inception et Bernardo Bertolucci.',
  ),
  // ── Palais & Résidences royales ──────────────────────────────────────────
  'DN00000008': CollectionMonument(
    id: 'DN00000008',
    emoji: '🏛️',
    name: 'Palais-Royal',
    location: LatLng(48.8637, 2.3371),
    arrondissement: '1er',
    era: 'XVIIᵉ',
    description:
        'Ancien palais du cardinal Richelieu, cédé à la Couronne. Ses galeries abritent cafés, boutiques et le Conseil d\'État.',
  ),
  'PA00085991': CollectionMonument(
    id: 'PA00085991',
    emoji: '🏰',
    name: 'Conciergerie',
    location: LatLng(48.8556, 2.3466),
    arrondissement: '1er',
    era: 'XIVᵉ',
    description:
        'Ancienne prison royale sur l\'Île de la Cité. Marie-Antoinette y attendit son exécution lors de la Révolution.',
  ),
  'PA00088714': CollectionMonument(
    id: 'PA00088714',
    emoji: '🏛️',
    name: 'Hôtel des Invalides',
    location: LatLng(48.8558, 2.3124),
    arrondissement: '7e',
    era: '1676',
    description:
        'Fondé par Louis XIV pour ses soldats blessés. Le tombeau de Napoléon repose sous sa célèbre coupole dorée.',
  ),
  'DN00000009': CollectionMonument(
    id: 'DN00000009',
    emoji: '🏰',
    name: 'Château de Vincennes',
    location: LatLng(48.8448, 2.4353),
    arrondissement: '12e',
    era: 'XIVᵉ',
    description:
        'Château médiéval aux portes de Paris, résidence royale pendant deux siècles. Son donjon de 52 m est le plus haut de France.',
  ),
  'DN00000005': CollectionMonument(
    id: 'DN00000005',
    emoji: '🏛️',
    name: "Palais de l'Élysée",
    location: LatLng(48.8708, 2.3162),
    arrondissement: '8e',
    era: 'XVIIIᵉ',
    description:
        'Résidence officielle du Président de la République depuis 1848. Son parc et ses salons restent inaccessibles au public.',
  ),
  'PA00088653': CollectionMonument(
    id: 'PA00088653',
    emoji: '🏛️',
    name: 'Palais du Luxembourg',
    location: LatLng(48.8462, 2.3372),
    arrondissement: '6e',
    era: '1625',
    description:
        'Construit pour Marie de Médicis, siège du Sénat depuis 1799. Ses jardins à la française sont les plus beaux de la Rive Gauche.',
  ),
  // ── Scènes & Spectacles ──────────────────────────────────────────────────
  'PA00089004': CollectionMonument(
    id: 'PA00089004',
    emoji: '🎭',
    name: 'Opéra Garnier',
    location: LatLng(48.8720, 2.3314),
    arrondissement: '9e',
    era: '1875',
    description:
        'Chef-d\'œuvre Beaux-Arts de Charles Garnier. Son grand foyer et son lustre de 6 tonnes ont inspiré le Fantôme de l\'Opéra.',
  ),
  'ACR0000698': CollectionMonument(
    id: 'ACR0000698',
    emoji: '🎭',
    name: 'Opéra Bastille',
    location: LatLng(48.8530, 2.3692),
    arrondissement: '12e',
    era: '1989',
    description:
        'Inauguré pour le bicentenaire de la Révolution, accessible à tous. Sa grande salle de 2745 places est une référence acoustique mondiale.',
  ),
  'PA00085993': CollectionMonument(
    id: 'PA00085993',
    emoji: '🎭',
    name: 'Comédie Française',
    location: LatLng(48.8636, 2.3367),
    arrondissement: '1er',
    era: '1799',
    description:
        'La doyenne des scènes nationales, fondée sous Louis XIV. Molière, Racine et Corneille y sont joués depuis des générations.',
  ),
  'PA00086003': CollectionMonument(
    id: 'PA00086003',
    emoji: '🎭',
    name: 'Théâtre du Châtelet',
    location: LatLng(48.8584, 2.3468),
    arrondissement: '1er',
    era: '1862',
    description:
        'Grande salle lyrique sur les bords de la Seine. Carmen et Samson et Dalila y connurent leurs premières parisiennes.',
  ),
  'PA00086015': CollectionMonument(
    id: 'PA00086015',
    emoji: '🎬',
    name: 'Grand Rex',
    location: LatLng(48.8678, 2.3498),
    arrondissement: '2e',
    era: '1932',
    description:
        'Cinéma Art Déco emblématique dont la grande salle de 2700 places est classée monument historique.',
  ),
  'PA00089012': CollectionMonument(
    id: 'PA00089012',
    emoji: '🎵',
    name: "L'Olympia",
    location: LatLng(48.8727, 2.3283),
    arrondissement: '9e',
    era: '1893',
    description:
        'La salle de spectacle la plus mythique de Paris. Édith Piaf, Jacques Brel et les Beatles s\'y sont produits sur scène.',
  ),
  // ── Architecture moderne ─────────────────────────────────────────────────
  'ACR0000721': CollectionMonument(
    id: 'ACR0000721',
    emoji: '🏗️',
    name: 'Centre Pompidou',
    location: LatLng(48.8607, 2.3520),
    arrondissement: '4e',
    era: '1977',
    description:
        'Architecture inside-out révolutionnaire de Renzo Piano et Richard Rogers. Musée d\'art moderne et bibliothèque publique.',
  ),
  'WIKI_TOUR_MONTPARNASSE': CollectionMonument(
    id: 'WIKI_TOUR_MONTPARNASSE',
    emoji: '🌆',
    name: 'Tour Montparnasse',
    location: LatLng(48.8420, 2.3220),
    arrondissement: '15e',
    era: '1973',
    description:
        'Seul gratte-ciel de Paris intra-muros, 210 m. Sa terrasse offre l\'une des vues les plus dégagées sur la capitale.',
  ),
  'WIKI_FONDATION_VUITTON': CollectionMonument(
    id: 'WIKI_FONDATION_VUITTON',
    emoji: '🏛️',
    name: 'Fondation Louis Vuitton',
    location: LatLng(48.8764, 2.2639),
    arrondissement: '16e',
    era: '2014',
    description:
        'Vaisseau de verre et d\'acier de Frank Gehry dans le Bois de Boulogne. Collection d\'art contemporain de renommée mondiale.',
  ),
  'WIKI_PHILHARMONIE': CollectionMonument(
    id: 'WIKI_PHILHARMONIE',
    emoji: '🎼',
    name: 'Philharmonie de Paris',
    location: LatLng(48.8895, 2.3940),
    arrondissement: '19e',
    era: '2015',
    description:
        'Salle de concert de Jean Nouvel au parc de la Villette, aux 2400 places. Son acoustique fait partie des meilleures au monde.',
  ),
  'WIKI_PYRAMIDE_LOUVRE': CollectionMonument(
    id: 'WIKI_PYRAMIDE_LOUVRE',
    emoji: '🔺',
    name: 'Pyramide du Louvre',
    location: LatLng(48.8603, 2.3358),
    arrondissement: '1er',
    era: '1989',
    description:
        'Audacieuse pyramide de verre et métal de I.M. Pei. Devenue l\'entrée principale du Louvre et une icône de l\'architecture.',
  ),
  'WIKI_INSTITUT_MONDE_ARABE': CollectionMonument(
    id: 'WIKI_INSTITUT_MONDE_ARABE',
    emoji: '🌙',
    name: 'Institut du monde arabe',
    location: LatLng(48.8519, 2.3549),
    arrondissement: '5e',
    era: '1987',
    description:
        'Façade aux 240 moucharabiehs motorisés de Jean Nouvel. Dialogue poétique entre architecture arabe et modernité parisienne.',
  ),
  // ── Places & Jardins ─────────────────────────────────────────────────────
  'PA00086476': CollectionMonument(
    id: 'PA00086476',
    emoji: '🌳',
    name: 'Place des Vosges',
    location: LatLng(48.8554, 2.3626),
    arrondissement: '4e',
    era: '1612',
    description:
        'La plus ancienne place planifiée de Paris. Ses briques rouges et ses arcades au cœur du Marais abritèrent Victor Hugo.',
  ),
  'PA00088880': CollectionMonument(
    id: 'PA00088880',
    emoji: '🌉',
    name: 'Place de la Concorde',
    location: LatLng(48.8656, 2.3212),
    arrondissement: '8e',
    era: '1763',
    description:
        'La plus grande place de Paris. Théâtre des exécutions révolutionnaires, l\'obélisque de Louxor la domine depuis 1836.',
  ),
  'PA00085790': CollectionMonument(
    id: 'PA00085790',
    emoji: '💎',
    name: 'Colonne Vendôme',
    location: LatLng(48.8674, 2.3297),
    arrondissement: '1er',
    era: '1810',
    description:
        'Colonne napoléonienne fondue à partir de 1200 canons pris à Austerlitz. Imitation directe de la colonne Trajane de Rome.',
  ),
  'WIKI_JARDIN_LUXEMBOURG': CollectionMonument(
    id: 'WIKI_JARDIN_LUXEMBOURG',
    emoji: '🌳',
    name: 'Jardin du Luxembourg',
    location: LatLng(48.8462, 2.3372),
    arrondissement: '6e',
    era: '1612',
    description:
        'Jardin de Marie de Médicis, symbole de la Rive Gauche. Son bassin central, ses ruches et son kiosque à musique en font un havre.',
  ),
  'WIKI_JARDIN_TUILERIES': CollectionMonument(
    id: 'WIKI_JARDIN_TUILERIES',
    emoji: '🌳',
    name: 'Jardin des Tuileries',
    location: LatLng(48.8638, 2.3272),
    arrondissement: '1er',
    era: '1564',
    description:
        'Premier jardin public de Paris, entre le Louvre et la Concorde. Redessiné à la française par Le Nôtre pour Louis XIV.',
  ),
  'PA00088879': CollectionMonument(
    id: 'PA00088879',
    emoji: '🌳',
    name: 'Parc Monceau',
    location: LatLng(48.8795, 2.3087),
    arrondissement: '17e',
    era: '1778',
    description:
        'Parc anglais aux folies architecturales : pyramide, colonnade, pont égyptien. Conçu pour le duc d\'Orléans à la veille de la Révolution.',
  ),
  // ── Trésors cachés ───────────────────────────────────────────────────────
  'PA00088431': CollectionMonument(
    id: 'PA00088431',
    emoji: '🏛️',
    name: 'Musée de Cluny',
    location: LatLng(48.8522, 2.3441),
    arrondissement: '5e',
    era: 'XIVᵉ',
    description:
        'Musée national du Moyen Âge dans d\'anciens thermes gallo-romains. La Dame à la Licorne, ses six tapisseries, y est exposée.',
  ),
  'PA00086278': CollectionMonument(
    id: 'PA00086278',
    emoji: '🏛️',
    name: 'Hôtel de Sully',
    location: LatLng(48.8554, 2.3624),
    arrondissement: '4e',
    era: 'XVIIᵉ',
    description:
        'Hôtel particulier Louis XIII au cœur du Marais. Ses jardins en enfilade débouchent secrètement sur la Place des Vosges.',
  ),
  'PA00086709': CollectionMonument(
    id: 'PA00086709',
    emoji: '📚',
    name: 'Maison de Balzac',
    location: LatLng(48.8575, 2.2815),
    arrondissement: '16e',
    era: 'XIXᵉ',
    description:
        'Pavillon où Balzac vécut sept ans, traqué par ses créanciers. Ses manuscrits et son mobilier d\'époque sont conservés à l\'identique.',
  ),
  'PA00086125': CollectionMonument(
    id: 'PA00086125',
    emoji: '🏛️',
    name: 'Musée Carnavalet',
    location: LatLng(48.8573, 2.3627),
    arrondissement: '3e',
    era: 'XVIᵉ',
    description:
        'Musée de l\'histoire de Paris dans deux hôtels particuliers du Marais. 625 000 œuvres, entrée permanente gratuite.',
  ),
  'PA00086239': CollectionMonument(
    id: 'PA00086239',
    emoji: '🗺️',
    name: "Pavillon de l'Arsenal",
    location: LatLng(48.8508, 2.3584),
    arrondissement: '4e',
    era: 'XIXᵉ',
    description:
        'Centre d\'urbanisme et d\'architecture de Paris. Sa maquette interactive permanente de Paris est fascinante et l\'entrée gratuite.',
  ),
  // ── Hôtels particuliers ──────────────────────────────────────────────────
  'PA00086135': CollectionMonument(
    id: 'PA00086135',
    emoji: '🏰',
    name: 'Hôtel Guénégaud',
    location: LatLng(48.8612, 2.3587),
    arrondissement: '3e',
    era: 'XVIIᵉ',
    description:
        'L\'un des rares hôtels particuliers du Marais encore intacts depuis le XVIIe. Abritait le musée de la Chasse et de la Nature.',
  ),
  'PA00086297': CollectionMonument(
    id: 'PA00086297',
    emoji: '🏰',
    name: 'Hôtel de Lauzun',
    location: LatLng(48.8515, 2.3589),
    arrondissement: '4e',
    era: 'XVIIᵉ',
    description:
        'Joyau de l\'architecture classique sur l\'île Saint-Louis. Baudelaire et Théophile Gautier y tenaient leur club secret du haschisch.',
  ),
  'PA00088722': CollectionMonument(
    id: 'PA00088722',
    emoji: '🏰',
    name: 'Hôtel Matignon',
    location: LatLng(48.8533, 2.3204),
    arrondissement: '7e',
    era: 'XVIIIᵉ',
    description:
        'Résidence officielle du Premier ministre. Son jardin privé de 3 ha est le plus grand de Paris, inaccessible au public.',
  ),
  'PA00088693': CollectionMonument(
    id: 'PA00088693',
    emoji: '🏰',
    name: 'Hôtel de Beauharnais',
    location: LatLng(48.8611, 2.3225),
    arrondissement: '7e',
    era: 'Empire',
    description:
        'Chef-d\'œuvre du style Empire, aménagé par Eugène de Beauharnais, beau-fils de Napoléon. Résidence de l\'ambassadeur d\'Allemagne.',
  ),
  'PA00088821': CollectionMonument(
    id: 'PA00088821',
    emoji: '🏰',
    name: 'Hôtel de Camondo',
    location: LatLng(48.8787, 2.3124),
    arrondissement: '17e',
    era: '1914',
    description:
        'Réplique du Petit Trianon construite par le comte Camondo. Musée des arts décoratifs du XVIIIe siècle, tragiquement préservé.',
  ),
  // ── Statues & sculptures ─────────────────────────────────────────────────
  'PA00086002': CollectionMonument(
    id: 'PA00086002',
    emoji: '🗿',
    name: 'Statue de Louis XIV',
    location: LatLng(48.8657, 2.3412),
    arrondissement: '1er',
    era: '1830',
    description:
        'Statue équestre dans la cour Napoléon du Louvre. Copie d\'un original fondu à la Révolution — le Roi-Soleil monte encore la garde.',
  ),
  'PA00086006': CollectionMonument(
    id: 'PA00086006',
    emoji: '🗿',
    name: 'Statue de Henri IV',
    location: LatLng(48.8573, 2.3409),
    arrondissement: '1er',
    era: '1818',
    description:
        'Le roi du peuple à cheval sur le Pont Neuf, veillant sur Paris depuis 400 ans. Restaurée après avoir été fondue à la Révolution.',
  ),
  'PA00086007': CollectionMonument(
    id: 'PA00086007',
    emoji: '🗿',
    name: "Statue de Jeanne d'Arc",
    location: LatLng(48.8639, 2.3322),
    arrondissement: '1er',
    era: '1874',
    description:
        'La Pucelle d\'Orléans dorée place des Pyramides. Œuvre d\'Emmanuel Frémiet, lieu de rassemblement patriotique depuis 150 ans.',
  ),
  'WIKI_STATUE_LIBERTE': CollectionMonument(
    id: 'WIKI_STATUE_LIBERTE',
    emoji: '🗽',
    name: 'Statue de la Liberté',
    location: LatLng(48.8497, 2.2796),
    arrondissement: '15e',
    era: '1889',
    description:
        'Réplique à l\'échelle 1/4 de la grande sœur new-yorkaise. Offerte par les résidents américains de Paris pour l\'Exposition Universelle.',
  ),
  'WIKI_LION_BELFORT': CollectionMonument(
    id: 'WIKI_LION_BELFORT',
    emoji: '🦁',
    name: 'Lion de Belfort',
    location: LatLng(48.8336, 2.3320),
    arrondissement: '14e',
    era: '1878',
    description:
        'Réplique en bronze du Lion de Bartholdi, symbole de la résistance de Belfort face à la Prusse en 1870. Rugissant sous Denfert.',
  ),
  'WIKI_PENSEUR': CollectionMonument(
    id: 'WIKI_PENSEUR',
    emoji: '🗿',
    name: 'Le Penseur',
    location: LatLng(48.8553, 2.3155),
    arrondissement: '7e',
    era: '1906',
    description:
        'Bronze monumental d\'Auguste Rodin devant son musée. Méditation silencieuse sur l\'existence, figure universelle de l\'art.',
  ),
  'WIKI_CHARLEMAGNE': CollectionMonument(
    id: 'WIKI_CHARLEMAGNE',
    emoji: '⚔️',
    name: 'Charlemagne',
    location: LatLng(48.8534, 2.3494),
    arrondissement: '4e',
    era: '1878',
    description:
        'Groupe équestre imposant de l\'Empereur et ses paladins, parvis de Notre-Dame. Par Louis Rochet, inauguré pour l\'Exposition.',
  ),
  'WIKI_DANTON': CollectionMonument(
    id: 'WIKI_DANTON',
    emoji: '🗿',
    name: 'Statue de Danton',
    location: LatLng(48.8527, 2.3393),
    arrondissement: '6e',
    era: '1891',
    description:
        'Le tribun de la Révolution brandissant le bras au carrefour de l\'Odéon. Sculpture d\'Auguste Paris, érigée cent ans après.',
  ),
  'WIKI_ETIENNE_MARCEL': CollectionMonument(
    id: 'WIKI_ETIENNE_MARCEL',
    emoji: '🗿',
    name: 'Étienne Marcel',
    location: LatLng(48.8557, 2.3520),
    arrondissement: '4e',
    era: '1888',
    description:
        'Prévôt des marchands médiéval, figure controversée de l\'histoire de Paris. Sa statue rappelle les premières luttes du pouvoir municipal.',
  ),
  // ── Patrimoine industriel ────────────────────────────────────────────────
  'PA00086598': CollectionMonument(
    id: 'PA00086598',
    emoji: '🎨',
    name: 'Manufacture des Gobelins',
    location: LatLng(48.8344, 2.3520),
    arrondissement: '13e',
    era: 'XVIIᵉ',
    description:
        'La plus célèbre manufacture de tapisseries au monde, fondée sous Louis XIV. Les ateliers royaux fonctionnent encore aujourd\'hui.',
  ),
  'PA00086755': CollectionMonument(
    id: 'PA00086755',
    emoji: '⚙️',
    name: 'Moulin de la Galette',
    location: LatLng(48.8877, 2.3363),
    arrondissement: '18e',
    era: 'XVIIIᵉ',
    description:
        'Dernier moulin de Montmartre, immortalisé par Renoir dans son Bal du Moulin de la Galette. Symbole de la butte populaire.',
  ),
  'PA00086734': CollectionMonument(
    id: 'PA00086734',
    emoji: '⛵',
    name: 'Bateau Lavoir',
    location: LatLng(48.8861, 2.3377),
    arrondissement: '18e',
    era: 'XIXᵉ',
    description:
        'Ateliers d\'artistes où Picasso peignit Les Demoiselles d\'Avignon. Berceau du cubisme et de la bohème montmartroise.',
  ),
  'PA00086565': CollectionMonument(
    id: 'PA00086565',
    emoji: '🍷',
    name: 'Chais de Bercy',
    location: LatLng(48.8328, 2.3893),
    arrondissement: '12e',
    era: 'XIXᵉ',
    description:
        'Anciens entrepôts vinicoles de Paris reconvertis. La Cour Saint-Émilion conserve pavés et façades de l\'époque du commerce du vin.',
  ),
  'ACR0000716': CollectionMonument(
    id: 'ACR0000716',
    emoji: '🔭',
    name: 'Cité des Sciences',
    location: LatLng(48.8958, 2.3880),
    arrondissement: '19e',
    era: '1986',
    description:
        'Plus grand musée des sciences d\'Europe, conçu par Adrien Fainsilber à la Villette. La Géode et ses 6000 m² de miroir.',
  ),
  'WIKI_EGOUTS': CollectionMonument(
    id: 'WIKI_EGOUTS',
    emoji: '🚇',
    name: 'Égouts de Paris',
    location: LatLng(48.8616, 2.3050),
    arrondissement: '7e',
    era: 'XIXᵉ',
    description:
        '600 km de galeries souterraines construites sous Haussmann. Le musée des égouts révèle les entrailles de la capitale.',
  ),
  // ── Grandes Tables & Commerces ───────────────────────────────────────────
  'PA00086004': CollectionMonument(
    id: 'PA00086004',
    emoji: '🍽️',
    name: 'Restaurant Pharamond',
    location: LatLng(48.8630, 2.3485),
    arrondissement: '1er',
    era: '1832',
    description:
        'L\'un des plus vieux restaurants de Paris, décors Belle Époque intacts. Spécialité de tripes à la mode de Caen depuis 1870.',
  ),
  'PA00086249': CollectionMonument(
    id: 'PA00086249',
    emoji: '🍺',
    name: 'Brasserie Bofinger',
    location: LatLng(48.8540, 2.3681),
    arrondissement: '4e',
    era: '1864',
    description:
        'La plus ancienne brasserie de Paris, côté Bastille. Ses décors Art Nouveau, sa coupole et ses choucroutes sont légendaires.',
  ),
  'PA00088494': CollectionMonument(
    id: 'PA00088494',
    emoji: '📚',
    name: 'Brasserie Lipp',
    location: LatLng(48.8538, 2.3324),
    arrondissement: '6e',
    era: '1880',
    description:
        'Institution de Saint-Germain-des-Prés fréquentée par Hemingway, Malraux et Mitterrand. Cervoise et intellectuels depuis 150 ans.',
  ),
  'PA00088496': CollectionMonument(
    id: 'PA00088496',
    emoji: '☕',
    name: 'Café Le Procope',
    location: LatLng(48.8530, 2.3388),
    arrondissement: '6e',
    era: '1686',
    description:
        'Le plus vieux café de Paris, ancienne adresse de Voltaire, Diderot et Benjamin Franklin. Le café y aurait été popularisé.',
  ),
  'PA00088667': CollectionMonument(
    id: 'PA00088667',
    emoji: '🍲',
    name: 'Bouillon Chartier',
    location: LatLng(48.8502, 2.3420),
    arrondissement: '9e',
    era: '1896',
    description:
        'Bouillon populaire classé monument historique. 320 couverts, petits plats à prix ouvriers dans un décor Belle Époque immaculé.',
  ),
  'PA00088881': CollectionMonument(
    id: 'PA00088881',
    emoji: '✨',
    name: "Le Fouquet's",
    location: LatLng(48.8713, 2.3014),
    arrondissement: '8e',
    era: '1899',
    description:
        'Brasserie mythique à l\'angle des Champs-Élysées. Lieu de remise des César et adresse incontournable des célébrités parisiennes.',
  ),
  'PA00086554': CollectionMonument(
    id: 'PA00086554',
    emoji: '🎵',
    name: 'Le Bataclan',
    location: LatLng(48.8631, 2.3709),
    arrondissement: '11e',
    era: '1865',
    description:
        'Salle de concert historique du boulevard Voltaire. Lieu de mémoire universel depuis les attentats de novembre 2015.',
  ),
};
