# Déléguer à des profils d'agents

La session principale orchestre. Elle garde le cadrage, l'arbitrage, la décision irréversible et
la validation. Le reste part en profil, lecture comprise. Valable pour tout projet et tout langage.

## Les profils

| Profil | Modèle | Effort | Outils | Pour |
|---|---|---|---|---|
| `explorateur` | `haiku` | low | lecture et Bash | trouver, lire, inventorier, compter, résumer un fichier borné |
| `controleur` | `haiku` | low | lecture et Bash | lancer tests, linters et scripts de contrôle, rendre la sortie brute |
| `executant` | `sonnet` | low | tous | geste mécanique déjà décidé : renommage, patch fourni, régénération |
| `developpeur` | `sonnet` | medium | tous | implémenter un changement cadré, avec ses tests et sa doc |
| `chercheur` | `sonnet` | medium | web, lecture et outils MCP de recherche de la session | information externe, sourcée et datée |
| `expert` | `sonnet` | high | tous | cause racine inconnue, migration, sécurité, code délicat |
| `relecteur` | `sonnet` | high | sans écriture, Bash pour lancer des contrôles seulement | relecture adversariale d'un diff contre ses critères, toujours neuf |

Ils s'appellent `clawd-stack:<profil>`. Le modèle est un alias, il ne fige aucune version.

## Choisir

Le profil le plus bas qui tient le critère de fin. Un échec repart une fois au cran du dessus, puis
l'orchestrateur reprend la main. Un modèle plus lourd en sous-agent se demande explicitement, il
n'est jamais le défaut.

Une sortie de `explorateur` ou de `controleur` se recoupe avant d'agir : on exige des chemins et des
chiffres, on relance un `grep` ou un `wc` sur ce qui engage la suite.

## Le brief

Quatre éléments, dans cet ordre :

1. La spec : ce qu'on veut, en quelques lignes.
2. Les chemins exacts : fichiers à lire, fichiers à écrire.
3. Le critère de fin : une commande qui passe, ou un fait observable.
4. La consigne « vise court ».

Le rapport revient en trois lignes, puis le détail demandé :

```
Fait : <ce qui est terminé>
Reste : <ce qui n'est pas fait>
Surpris : <ce que le brief ne prévoyait pas>
```

## Les limites

- Jamais deux agents sur les mêmes fichiers.
- Cinq agents en parallèle au plus.
- Un agent ne lance pas d'agent. `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH=1` le garantit, il est recommandé.
- Un profil ne commite pas et ne pousse pas.
- Au-delà d'environ 200 appels d'outils, un profil s'arrête avec un point d'étape.

## Régler la session principale

L'effort élevé se pose de l'une de ces deux façons :

```bash
/effort high                       # sauvegardé par modèle
```

```json
{ "effortLevel": "high" }
```

Le second va dans le `.claude/settings.json` du projet. Jamais `CLAUDE_CODE_EFFORT_LEVEL` : cette
variable passe aussi devant l'`effort` de chaque profil et écrase toute la graduation.

## Les alias selon la plateforme

Sur l'API Anthropic, `haiku` et `sonnet` suivent la dernière version de leur famille. Sur Bedrock,
Vertex et Foundry, ils pointent encore sur une version 4.x. Pour y retrouver la version voulue, on
épingle par variable d'environnement : `ANTHROPIC_DEFAULT_SONNET_MODEL`,
`ANTHROPIC_DEFAULT_HAIKU_MODEL` et leurs voisines.

## Sans sous-agents

Codex, Hermes et OpenClaw n'ont pas tous les sous-agents. La doctrine devient alors un découpage en
étapes, chacune avec son critère de fin vérifié avant de passer à la suivante, et la relecture se
fait dans une session neuve.
