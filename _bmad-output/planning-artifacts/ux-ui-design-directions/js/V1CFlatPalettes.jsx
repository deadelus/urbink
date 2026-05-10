'use strict';
// ─── V1-C Flat palettes — curated 20-color sets, all flat (no gradients) ─────

// Palette 1: "Mid-century" — think 1960s Scandinavian poster. Muted flats.
const FLAT_MIDCENTURY = [
  '#C75D4C','#E0A24A','#D9C25B','#8FA85A','#5E9378',
  '#4E8BA6','#6F7BB3','#9A6FB0','#B86090','#C97D6F',
  '#A67250','#7D8C4A','#5A9880','#629BB8','#5E77A8',
  '#8567A3','#A86085','#BD8560','#9C8A4E','#6D9470',
];

// Palette 2: "Risograph" — bright flat inks, slightly off-register feel.
const FLAT_RISO = [
  '#FF4E50','#F5A623','#F7D83C','#7FC046','#3FB8AF',
  '#3A99D8','#4E5EBE','#8565C4','#C24AA1','#E86A92',
  '#D67C2C','#B8C93A','#56BE7E','#3FAEC7','#5773C4',
  '#A560C4','#D4588B','#E5874A','#A0B43A','#4CB89F',
];

// Palette 3: "Gouache" — flat paints, slightly dusty, high hue rotation.
const FLAT_GOUACHE = [
  '#D66A5C','#E39A4F','#C9B24A','#7FA35A','#4F9080',
  '#4B86A4','#6C7BAE','#8E6BA8','#B35F85','#C17860',
  '#A06B49','#8F9C4A','#5A937F','#5C94AC','#5C72A8',
  '#8063A0','#AA6280','#BA8158','#97884B','#6C9069',
];

// Palette 4: "Pastel" — true flats but higher lightness. Bright, airy.
const FLAT_PASTEL = [
  '#F2B5A7','#F7D1A3','#F2E29E','#C8DDAB','#A8D4C3',
  '#A8CEE3','#B5BDE5','#C7B3DE','#E0A9C7','#EEB4B0',
  '#D6B59C','#C1CE9C','#A6D4B5','#B0CFDE','#ADB7DD',
  '#BCA5D5','#D8A5BE','#DFBB9B','#C7BE9B','#ACD1B0',
];

Object.assign(window, {FLAT_MIDCENTURY, FLAT_RISO, FLAT_GOUACHE, FLAT_PASTEL});
