'use strict';
// ─── Paris arrondissements — simplified spiral polygons (escargot layout) ─────
// Viewport: 520×480. Centered around the Louvre/Île de la Cité.
// Polygons approximate the real "escargot" spiral. Not surveyor-grade,
// but recognizable: I, II, III, IV around the center, then spiraling out clockwise.

const ARRONDISSEMENTS = [
  // {id, num, name, centroid:{cx,cy}, polygon:"x,y x,y …", explored%}
  {id:1,  num:'1',  name:'Louvre',          pct:82, cx:250, cy:245,
   poly:'220,230 265,225 285,240 278,265 250,275 225,260'},
  {id:2,  num:'2',  name:'Bourse',          pct:64, cx:265, cy:215,
   poly:'235,200 295,195 305,220 285,235 265,225 230,225'},
  {id:3,  num:'3',  name:'Temple',          pct:71, cx:300, cy:230,
   poly:'285,205 335,205 345,235 310,245 295,230 288,215'},
  {id:4,  num:'4',  name:'Hôtel-de-Ville',  pct:88, cx:290, cy:265,
   poly:'278,245 312,240 325,265 310,290 275,285 255,270'},
  {id:5,  num:'5',  name:'Panthéon',        pct:58, cx:272, cy:305,
   poly:'252,285 310,285 320,320 290,335 252,328 235,305'},
  {id:6,  num:'6',  name:'Luxembourg',      pct:41, cx:235, cy:295,
   poly:'200,280 250,280 250,320 230,330 200,320 188,300'},
  {id:7,  num:'7',  name:'Palais-Bourbon',  pct:34, cx:190, cy:260,
   poly:'140,240 215,230 220,280 188,295 150,285 132,265'},
  {id:8,  num:'8',  name:'Élysée',          pct:22, cx:180, cy:200,
   poly:'130,180 225,175 225,220 180,220 145,215 125,200'},
  {id:9,  num:'9',  name:'Opéra',           pct:48, cx:240, cy:175,
   poly:'215,150 290,150 290,195 250,200 225,195 215,175'},
  {id:10, num:'10', name:'Enclos-St-Laurent',pct:30,cx:295, cy:170,
   poly:'280,140 345,140 355,185 320,195 290,188 278,165'},
  {id:11, num:'11', name:'Popincourt',      pct:26, cx:340, cy:240,
   poly:'325,200 380,210 385,265 355,275 320,260 315,225'},
  {id:12, num:'12', name:'Reuilly',         pct:18, cx:365, cy:305,
   poly:'330,275 395,275 415,315 395,345 345,340 320,310'},
  {id:13, num:'13', name:'Gobelins',        pct:12, cx:305, cy:355,
   poly:'260,335 335,335 345,380 300,395 260,385 245,360'},
  {id:14, num:'14', name:'Observatoire',    pct:15, cx:235, cy:360,
   poly:'195,340 260,340 255,390 215,400 180,385 175,360'},
  {id:15, num:'15', name:'Vaugirard',       pct:28, cx:165, cy:335,
   poly:'110,300 195,305 195,380 150,385 110,370 95,335'},
  {id:16, num:'16', name:'Passy',           pct:8,  cx:105, cy:245,
   poly:'60,195 140,200 150,290 115,300 70,280 50,230'},
  {id:17, num:'17', name:'Batignolles',     pct:11, cx:140, cy:155,
   poly:'80,120 215,120 215,170 150,180 95,165 75,140'},
  {id:18, num:'18', name:'Butte-Montmartre',pct:52, cx:245, cy:110,
   poly:'210,80 300,80 305,130 285,145 225,145 210,120'},
  {id:19, num:'19', name:'Buttes-Chaumont', pct:19, cx:340, cy:115,
   poly:'305,80 405,85 410,145 375,155 320,150 305,130'},
  {id:20, num:'20', name:'Ménilmontant',    pct:33, cx:390, cy:180,
   poly:'360,150 425,155 430,220 395,225 365,215 360,175'},
];

// Neighborhoods (quartiers) inside the 4th arrondissement — shown in zoom-in view
// Each arr has 4 quartiers; we detail the 4e as an example.
const QUARTIERS_4E = [
  {id:'4a', name:'Saint-Merri',        pct:92, cx:225, cy:200, poly:'180,160 260,160 270,215 230,230 195,220 170,190'},
  {id:'4b', name:'Saint-Gervais',      pct:76, cx:325, cy:195, poly:'265,160 395,165 400,220 340,230 280,220 270,195'},
  {id:'4c', name:'Arsenal',            pct:54, cx:325, cy:295, poly:'260,235 400,230 410,345 340,360 275,340 260,290'},
  {id:'4d', name:'Notre-Dame (Île)',   pct:68, cx:215, cy:300, poly:'160,250 260,245 270,340 220,360 160,340 140,290'},
];

// Major feature lines for context: Seine, bois, etc (kept simple — one river)
const SEINE_PATH = 'M 40,280 Q 120,310 200,285 Q 280,260 360,290 Q 420,310 480,285';

// Approximate Paris outer boundary (the "hexagone parisien")
const PARIS_OUTLINE = '80,115 215,80 305,75 410,85 425,155 430,225 415,310 400,345 345,395 260,400 180,395 105,380 65,335 50,230 60,175';

Object.assign(window, {ARRONDISSEMENTS, QUARTIERS_4E, SEINE_PATH, PARIS_OUTLINE});
