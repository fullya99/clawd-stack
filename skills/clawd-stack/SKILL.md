---
name: clawd-stack
description: "Tient la documentation de contexte d'un projet vraie et courte d'une session à l'autre, quel que soit son type ou sa taille. Six modes : init installe la convention, planifier écrit un plan sourcé et son prompt d'exécution, cloture range la session avant un redémarrage de contexte, relance dit où on en était, audit vérifie CLAUDE.md et AGENTS.md contre le code, migrer remet une ancienne convention à jour. Trois piliers CODEMAP.md, TODOS.md et CHANGELOG.md, plus docs/ et archives/, réglés par le bloc contexte:convention. Se déclenche sur : clôture, fin de session, avant de clear, reprends, où on en était, fais un plan, planifie, audite le CLAUDE.md, la doc gonfle, TODOS est trop long, archive ce qui est obsolète, doc vivante, migrer la convention, /clawd-stack. Pas pour rédiger ou corriger un texte, c'est style-redaction."
license: MIT
metadata:
  version: 1.0.0-rc.1
  hermes:
    tags: [documentation, session, housekeeping, changelog, codemap, context-budget, planning, audit]
---

# clawd-stack

> Le dépôt seul doit suffire à reprendre le travail. Ce qui ne vit que dans la conversation n'existe pas.

Charge d'abord le skill `style-redaction` avant d'écrire. S'il manque : ton direct, aucun tiret
cadratin, aucun point-virgule, langue de la prose du projet.

## Le socle

- Trois piliers à la racine : `CODEMAP.md` (où), `TODOS.md` (maintenant), `CHANGELOG.md` (ce qui a changé).
- `CLAUDE.md` porte ce qui est vrai tout le temps, court, sans état ni récit.
- `docs/` ne contient que du vrai. `archives/` absorbe le reste, avec un en-tête, et ne se lit jamais comme source de vérité.
- Chaque surface tient dans son budget, ce qui déborde descend d'un étage.
- Le bloc `contexte:convention`, dans `CODEMAP.md`, déclare les chemins réels et le profil du projet.
- Une phrase a un seul propriétaire. Devant chaque ligne, demande : qui est propriétaire de cette phrase ?

## Choisir le mode

La commande décide. Sans commande, l'intention décide.

| Mode | Commande | Intention | Suivre |
|---|---|---|---|
| init | `/clawd-stack:init` | installer la convention, le kit manque | `references/MODE-CLOTURE.md`, section Mode INIT |
| cloture | `/clawd-stack:cloture` | fin de session, avant de clear, la doc gonfle | `references/MODE-CLOTURE.md`, section Mode CLÔTURE |
| relance | `/clawd-stack:relance` | début de session, où on en était | `references/MODE-CLOTURE.md`, section Mode REPRISE |
| planifier | `/clawd-stack:planifier` | faire un plan, cadrer une idée | `references/MODE-PLANIFIER.md` |
| audit | `/clawd-stack:audit` | CLAUDE.md ou AGENTS.md trop long ou faux | `references/MODE-AUDIT.md` |
| migrer | `/clawd-stack:migrer` | remettre une ancienne convention à jour | `references/MODE-MIGRER.md` |

Ce skill ne sert pas à rédiger ou corriger un texte, c'est `style-redaction`.

## Résoudre `$SKILL`, une fois par session

Les scripts vivent dans le skill, pas dans le projet. Résous le chemin avant le premier appel :

```bash
ANCETRES="$(d="$PWD"; while [ "$d" != "/" ]; do echo "$d/.agents/skills/clawd-stack"; d="$(dirname "$d")"; done)"

SKILL="$(for d in "$CLAUDE_PLUGIN_ROOT/skills/clawd-stack" \
  ".claude/skills/clawd-stack" $ANCETRES \
  "$HOME/.claude/skills/clawd-stack" \
  "$HOME/.codex/skills/clawd-stack" "$HOME/.agents/skills/clawd-stack" \
  $(find "$HOME/.claude/plugins/cache" -maxdepth 5 -type d -path '*/skills/clawd-stack' 2>/dev/null | sort -r) \
  $(find "$HOME/.claude/plugins/marketplaces" -maxdepth 5 -type d -path '*/skills/clawd-stack' 2>/dev/null); do
  [ -f "$d/scripts/ctx-audit.sh" ] && echo "$d" && break
done)"
[ -n "$SKILL" ] || echo "skill introuvable, fais les etapes a la main sans le script"
```

L'ordre est voulu, le pourquoi est dans `references/RESOLUTION.md`.

## Invariants

- Aucune suppression silencieuse, l'obsolète part dans `archives/` avec sa raison.
- Aucune affirmation connue fausse laissée pour plus tard, aucune doc écrite depuis une supposition.
- Aucun `archives/` lu en reprise, toute fouille passe par `ctx-archeo.sh`.
- Aucun travail en cours sans tâche écrite avant un redémarrage à froid.
- Aucun fichier au-dessus de son seuil de blocage à la fin d'une clôture.
- Aucun commit ni push non demandé, aucun secret dans un fichier tracké.
- Rien ne s'écrit avant le oui de l'opérateur en planification et en audit.
- Aucun texte qui sent le généré.

## Références

| Fichier | Quand le lire |
|---|---|
| `references/MODE-CLOTURE.md` | modes init, cloture et relance |
| `references/MODE-PLANIFIER.md` | mode planifier |
| `references/MODE-AUDIT.md` | mode audit |
| `references/MODE-MIGRER.md` | mode migrer, projet qui a déjà une convention |
| `references/CONVENTION.md` | spécification des trois piliers et propriétaire de chaque savoir |
| `references/CONFIG-PROJET.md` | chaque clé du bloc `contexte:convention`, défaut et exemple |
| `references/BUDGET.md` | seuils, geste par fichier qui déborde, `CLAUDE.md` sans audit |
| `references/ZONES.md` | un répertoire mérite sa carte |
| `references/DOCS-SYSTEM.md` | organisation de `docs/`, ADR, index |
| `references/ARCHIVAGE.md` | archiver, corriger ou supprimer, rotation des journaux |
| `references/PROFILS-PROJETS.md` | adapter la convention au type de projet |
| `references/HANDOFF.md` | test « prêt pour un contexte neuf » |
| `references/RESOLUTION.md` | la boucle `$SKILL` rend vide ou la mauvaise version |
| `references/plan/PLAN.md` | rédiger un plan, ossature et format d'une tâche |
| `references/plan/PROMPT.md` | rédiger le prompt d'exécution |
| `references/plan/RECHERCHE.md` | phase de recherche d'un plan |
| `references/plan/TYPES-DE-PLAN.md` | triage, sections propres à chaque type |
| `references/audit-md/les-quatre-etages.md` | choisir où sort un bloc de `CLAUDE.md` |
| `references/audit-md/criteres-classement.md` | trancher un cas limite de classement |
| `references/audit-md/anti-patterns.md` | justifier une suppression |
| `references/audit-md/modeles.md` | gabarit de fichier racine et de fiche |
| `references/audit-md/fichiers-agents.md` | le dépôt déclare des sous-agents |
| `templates/` | gabarits des piliers, zones, fiches, ADR et du plan |
| `scripts/ctx-*.sh` | init, audit, rotation, archivage, archéologie des archives |
| `scripts/verif-refs.sh`, `scripts/verif-agents.sh` | mode audit, phase 2 |
