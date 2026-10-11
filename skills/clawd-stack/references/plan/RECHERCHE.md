# Recherche, quand et comment

## Quand chercher, quand ne pas chercher

La surface externe décide. Une refonte interne pure, un correctif dans du code qu'on possède, un
renommage : pas de recherche, le plan l'écrit noir sur blanc plutôt que de se remplir de notes
hors sujet.

Une lib externe, l'API d'un fournisseur, une version récente, un comportement susceptible d'avoir
bougé, un choix technologique à trancher : recherche.

## La cascade des serveurs

| Besoin | Où chercher | Pourquoi |
|---|---|---|
| Version de lib, API précise | Context7, `resolve-library-id` puis `query-docs` | doc versionnée, évite l'API hallucinée |
| Doc Microsoft ou Azure | ms-learn, `microsoft_docs_search` puis `microsoft_docs_fetch` | source de vérité, ne pas chercher ailleurs |
| Doc Cloudflare | cf-docs | n'indexe que ça, mais bien |
| Fait daté, actualité, pages à lire en entier | Firecrawl, `firecrawl_search`, `firecrawl_map` pour explorer un site inconnu | rend le contenu propre, pas juste des extraits |
| État de l'art, similarité, papiers | Exa, `web_search_exa` puis `web_fetch_exa` | cherche par le sens, pas par mots-clés |
| Recherche généraliste, fraîcheur | Brave | index propre, filtres pays langue fraîcheur |

Ces outils arrivent via un connecteur MCP, souvent différé au démarrage de la session. Il faut le
charger avec `ToolSearch` avant de tenter un appel, sinon l'outil paraît absent alors qu'il ne fait
qu'attendre son chargement. Le nom exact d'un connecteur change d'une machine à l'autre, donc pars
de la forme `mcp__<connecteur>__<serveur>_<outil>` et retrouve le nom réel avec `ToolSearch`, ne le
code jamais en dur.

## La dégradation

Aucun de ces outils n'est un prérequis. S'ils sont absents ou que `ToolSearch` ne remonte rien, la
recherche web native fait le travail, moins bien mais elle le fait, et le plan note la
dégradation. Un skill qui exige un connecteur ne s'installe nulle part ailleurs que sur la machine
où il a été conçu.

## Le découpage en axes

Un sous-agent par axe, tous lancés dans le même tour. Trois à cinq axes suffisent, rarement plus.
Axes types :

- l'outil ou la lib visée et sa version courante
- l'état de l'art de la pratique
- les pièges et retours de terrain
- la contrainte réglementaire ou de plateforme, quand il y en a une

Ne donne jamais deux axes au même sous-agent. Un chercheur qui doit couvrir deux sujets en couvre
un bien et l'autre mal, et rien ne dit lequel.

## Le contrat de sortie d'un chercheur

Des notes brutes, pas un rapport mis en forme. Chaque affirmation part avec son lien et sa date.
Une source de plus de six mois se marque comme peut-être périmée. Ce qui est contesté entre deux
sources se signale comme tel plutôt que d'être tranché à la place de l'opérateur. Rien de trouvé
sur un point s'écrit « non trouvé », jamais une supposition habillée en fait.

Pas d'introduction, pas de conclusion. Le sous-agent qui synthétise avant de rendre perd la
traçabilité que ces notes existent pour donner.

## Ce qui entre dans le plan

Seulement ce qui a façonné une décision. Une note de recherche que le plan n'utilise pas ne s'y
recopie pas, elle reste dans les notes du sous-agent. Un plan encombré de recherche non exploitée
est plus dur à relire qu'un plan qui va droit aux décisions qu'elle a produites.
