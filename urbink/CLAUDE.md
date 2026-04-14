# Urbink — AI System

## CONTEXT

Flutter iOS app: explore city → color streets via GPS
Read architecture.md before coding

## STACK

Flutter + Riverpod + Firestore + Go

## RULES

* no Firestore in widgets
* use Riverpod providers
* no API keys in Flutter
* feature-first structure

## STRUCTURE

features/{domain}/
shared/{widgets,utils,constants}
core/{firebase,providers,router}
functions/{domain}/

## NAMING

camelCase vars
snake_case files
PascalCase classes
providers = camelCase + Provider

## ROLES

ARCHITECT → plan (≤5 bullets)
DEVELOPER → implement minimal scope
REVIEWER → fix + comment each issue
OPTIMIZER → simplify
TESTER → validate ACs

## FLOW

ARCHITECT → DEVELOPER → REVIEWER → OPTIMIZER → TESTER

## OUTPUT

* concise
* code first
* no repetition
* ≤100 words outside code

## MODES

"ARCHITECT ONLY"
"REVIEWER ONLY"
"OPTIMIZER ONLY"
