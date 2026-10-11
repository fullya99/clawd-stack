# Deep plan

> **Le contrat** : un plan ancré dans le terrain réel, sourcé sur du récent, validé par
> l'opérateur avant d'être écrit, suivi d'un prompt d'exécution qui pilote une équipe de
> sous-agents.

**Avant d'écrire quoi que ce soit**, charge le skill **`style-redaction`**. S'il n'est pas
installé, le minimum tient en une ligne : français, ton direct, aucun tiret cadratin, aucun
point-virgule, aucune tournure qui sent le texte généré.

---

## Quand ce skill s'applique

| Situation | Ce que tu fais |
|---|---|
| Idée à transformer en plan d'implémentation, sujet avec une vraie surface (code, infra, doc, migration, investigation) | Les six phases ci-dessous, dans l'ordre |
| Tâche qui tient en deux étapes et trois fichiers | Tu le dis, tu proposes d'ajouter les étapes à `TODOS.md` ou au suivi existant, pas de plan |
| Modification simple, question qui se répond en lisant un fichier | Tu réponds directement, ce skill n'apporte rien ici |
| Fin de session, mise au propre du dépôt | C'est le mode CLÔTURE, pas ce mode |

Si la demande n'entre dans aucune ligne, dis-le plutôt que de forcer un plan là où il n'en faut
pas.

---

## Les six phases

### Phase 0. Triage

Deux minutes, sans lire de code.

- **Le type**, parmi fonctionnalité, correctif, migration, refonte, infrastructure,
  documentation, investigation, hors code. Un plan peut relever de deux types, prends le plus
  contraignant. Détail des sections et des pièges dans `references/plan/TYPES-DE-PLAN.md`.
- **L'environnement.** Dépôt git ou pas, monorepo ou dépôt simple, stack par les manifestes
  (`package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `pom.xml`, `*.csproj`, `Gemfile`,
  `composer.json`, `mix.exs`, `pubspec.yaml`), commandes de test, de lint et de build réellement
  présentes, convention de contexte déjà en place (`CLAUDE.md`, `AGENTS.md`, `CODEMAP.md`,
  `TODOS.md`, `docs/`). Sur terrain vierge, note-le et avance quand même.
- **La surface externe.** La tâche touche-t-elle une lib, une API, un fournisseur, un
  comportement qui a pu bouger ? Si non, la phase 1 se saute et le plan l'écrit noir sur blanc.

### Phase 1. Recherche

Seulement si la surface externe est réelle. Lance un éventail de sous-agents chercheurs, un axe
par sous-agent, tous dans le même tour. Trois à cinq axes suffisent, jamais un sous-agent qui
cherche tout.

Pour l'outil, Context7 sert la doc de lib versionnée, ms-learn et cf-docs les docs Microsoft et
Cloudflare, Firecrawl un fait daté ou une page à lire en entier, Exa l'état de l'art par le sens,
Brave la recherche généraliste. Ces connecteurs arrivent souvent en différé, charge-les avec
`ToolSearch` avant de les appeler. Aucun n'est un prérequis : absent, la recherche web native
prend le relais et le plan le note. Cascade complète, contrat de sortie et découpage par axe dans
`references/plan/RECHERCHE.md`.

Chaque affirmation repart avec son lien et sa date. Une source de plus de six mois se signale
comme peut-être périmée. Un sous-agent qui ne trouve rien écrit « non trouvé », jamais une
supposition.

### Phase 2. Exploration

Sous-agents lecteurs sur les zones que le triage et la recherche ont désignées. Ils reviennent
avec des chemins, des symboles et des faits, pas des impressions. Un plan qui ne nomme aucun
symbole réel est un plan écrit à l'aveugle. Sur terrain vierge, cette phase lit seulement les
conventions du langage choisi.

### Phase 3. Questions

La phase que l'opérateur vit, elle doit rester légère.

- Cinq questions au maximum, en une seule passe.
- Chaque question porte sa réponse par défaut, annoncée comme telle. « ok pour tout » suffit à
  répondre.
- Langage normal, aucun jargon d'implémentation dans l'énoncé.
- Une question ne se pose que si la réponse change le plan. Sinon tranche, écris l'hypothèse
  dans le plan, avance.
- Deux natures de questions : réduire le flou, et ouvrir le potentiel que l'idée n'avait pas
  encore montré. Tu proposes, l'opérateur décide, tu n'élargis jamais tout seul le périmètre.
- Termine par une validation explicite : cinq lignes qui disent ce que tu as compris, l'opérateur
  confirme ou corrige. **Rien ne s'écrit avant ce oui.**

### Phase 4. Le plan

Emplacement, dans l'ordre : l'endroit que le projet utilise déjà pour ses plans s'il en a un,
sinon `plans/<slug>.md` à la racine, slug en minuscules et tirets. Sur une tâche petite, propose
d'ajouter les étapes au suivi existant plutôt que de créer un fichier.

Rédige depuis `templates/plan.md`. L'ossature complète, le format d'une tâche et ce qui est
interdit dans un plan (« TBD », un chemin inventé, une étape sans vérification) sont dans
`references/plan/PLAN.md`. Le type retenu en phase 0 ajoute ses sections propres, voir
`references/plan/TYPES-DE-PLAN.md`. Le plan garde sa propre section Reprise, il se relit sans le
prompt de la phase 5.

### Phase 5. Le prompt

Un seul bloc de texte copiable dans le chat, jamais dans un fichier. L'opérateur le colle dans une
session neuve, sans résidu de l'exploration qui précède, `/clear` chez Claude Code. Ordre des
morceaux, contexte long d'abord : le plan à lire en entier, les décisions
verrouillées restatées en clair, ce qu'on ne touche pas, les invariants, l'équipe et son rôle, les
étapes avec leur porte de vérification, et le démarrage en tout dernier. Balises `<plan>`,
`<decisions>`, `<invariants>`, `<equipe>`, `<etapes>`, `<demarrage>`.

Équipe de trois à cinq : un pilote qui séquence sans coder les gros lots, des implémenteurs un
par lot indépendant, un relecteur en contexte frais qui ne voit que le diff et les critères de la
tâche. Deux lots qui touchent les mêmes fichiers ne partent jamais en parallèle. Anatomie
complète, formulation et exemple dans `references/plan/PROMPT.md`.

---

## Invariants, jamais négociables

- ❌ **Rien ne s'écrit avant le oui de l'opérateur** en fin de phase 3.
- ❌ **Aucun chemin ni symbole qui n'a pas été vérifié** dans le vrai dépôt.
- ❌ **Aucune étape sans critère de vérification.**
- ❌ **Aucun outil MCP en prérequis.** Absent, on dégrade et on le dit dans le plan.
- ❌ **Aucun commit, aucun push.** Ce skill planifie, il n'exécute pas.
- ❌ **Aucune modification de fichier hors du plan lui-même.**
- ❌ **Aucun texte qui sent le généré.** Voir le skill `style-redaction`.

---

## Références, à charger seulement au besoin

| Fichier | Quand le lire |
|---|---|
| skill `style-redaction` | Avant toute rédaction |
| `references/plan/RECHERCHE.md` | Cascade des serveurs, dégradation, découpage en axes, contrat de sortie d'un chercheur |
| `references/plan/TYPES-DE-PLAN.md` | Les huit types, leurs sections en plus, leur piège typique |
| `references/plan/PLAN.md` | Ossature complète d'un plan, format d'une tâche, ce qui est interdit |
| `references/plan/PROMPT.md` | Anatomie du prompt d'exécution, formulation, équipe, exemple complet |
| `templates/plan.md` | Gabarit à remplir pour la phase 4 |
