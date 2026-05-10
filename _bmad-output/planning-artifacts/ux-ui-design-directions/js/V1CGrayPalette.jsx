'use strict';
// ─── Grayscale palette for arrondissements ───────────────────────────────────
// 20 distinct grays spanning light ivory → near-black.
// Hand-tuned so adjacent arrondissements in the escargot spiral stay distinct.
const GRAYSCALE_20 = [
  '#F4F2ED', '#D9D4C8', '#BFB7A6', '#A69E8D', '#8D8575',
  '#737063', '#5F5A4F', '#4C4841', '#3B3833', '#2A2826',
  '#E8E4D8', '#CCC6B5', '#B2AA99', '#988F7E', '#7D7567',
  '#666054', '#524E44', '#403D37', '#2F2D29', '#1C1B18',
];

Object.assign(window, {GRAYSCALE_20});
