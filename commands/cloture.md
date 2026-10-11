---
description: "Clôture de session : synchronise les trois piliers, archive l'obsolète, tient le budget."
argument-hint: [note libre sur la session, optionnel]
---

Note de session : $ARGUMENTS

Mode **CLOTURE** du skill `clawd-stack`. Charge le skill et suis sa table des modes.
Après le commit, écris le témoin (vide hors Claude Code, le script sort sans rien écrire) :
`bash "$SKILL/scripts/ctx-demarrage.sh" --ecrire-temoin --donnees "${CLAUDE_PLUGIN_DATA}"`
