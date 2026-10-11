#!/usr/bin/env bash
#
# ctx-demarrage.sh : hook SessionStart du plugin clawd-stack, et ecriture du temoin de cloture.
#
# Usage :
#   bash ctx-demarrage.sh                    au demarrage : imprime quinze lignes au plus
#   bash ctx-demarrage.sh --ecrire-temoin    a la fin d'une cloture : ecrit le temoin
#   --racine <chemin>    projet a lire, sinon $CLAUDE_PROJECT_DIR, sinon le repertoire courant
#   --donnees <dossier>  dossier de donnees du plugin, sinon $CLAUDE_PLUGIN_DATA
#
# Il ne bloque jamais une session : code 0 dans tous les cas, lecture seule sur le projet.
# Ce que Claude Code fait de la sortie : le texte de stdout d'un hook SessionStart entre dans
# le contexte de Claude, qui le voit et peut le relayer. Rien n'est ecrit sur stderr.
#
# Silencieux quand tout va bien : une ligne par defaut coute du contexte a chaque demarrage,
# reprise et compactage. Seul le temoin de cloture parle toujours, c'est l'info de continuite.
# Sans bloc de convention : silence si aucun des trois piliers n'existe, une ligne qui propose
# /clawd-stack:migrer s'il en existe au moins un.
#
# Le temoin : <donnees>/temoins/<nom stable>, lignes `cle=valeur` (commit, arbre, date).
# Le nom stable est le nom du dossier du projet, assaini, plus une somme de son chemin absolu :
# ni `/` ni espace, et deux clones du meme nom ne se melangent pas.
# Les variables CLAUDE_PLUGIN_* n'existent pas dans l'outil Bash : le mode cloture passe
# --donnees avec la valeur que le skill a recue par substitution.
set -f
# Jamais de bruit sur stderr, meme si un outil manque dans le PATH.
exec 2>/dev/null

case "$0" in */*) DIR="${0%/*}" ;; *) DIR=. ;; esac
DIR="$(cd "$DIR" && pwd)"
SORTIE=""

ligne() { # <texte> : ajoute une ligne a la sortie
  SORTIE="${SORTIE}[clawd-stack] $1
"
  return 0
}

# Nom stable du projet pour le temoin.
nom_projet() { # <racine>
  local base somme
  base="$(basename "$1" | tr -c 'A-Za-z0-9._-' '-')"
  somme="$(printf '%s' "$1" | cksum | cut -d' ' -f1)"
  printf '%s-%s\n' "$base" "$somme"
  return 0
}

# Empreinte de l'arbre de travail : sort differemment si un fichier a bouge depuis.
empreinte_arbre() { # <racine>
  git -C "$1" status --porcelain 2>/dev/null | cksum | cut -d' ' -f1
  return 0
}

ecrire_temoin() { # <racine> <donnees>
  local racine="$1" donnees="$2" dest commit
  if [ -z "$donnees" ]; then
    ligne "Temoin de cloture non ecrit : CLAUDE_PLUGIN_DATA absent. Le mode cloture le passe avec --donnees."
    return 0
  fi
  commit="$(git -C "$racine" rev-parse HEAD 2>/dev/null || true)"
  if [ -z "$commit" ]; then
    ligne "Temoin de cloture non ecrit : pas de commit dans ce depot."
    return 0
  fi
  dest="$donnees/temoins/$(nom_projet "$racine")"
  if mkdir -p "$donnees/temoins" 2>/dev/null \
     && printf 'commit=%s\narbre=%s\ndate=%s\n' "$commit" "$(empreinte_arbre "$racine")" "$(ctx_aujourdhui)" > "$dest" 2>/dev/null; then
    ligne "Temoin de cloture ecrit : commit $(printf '%s' "$commit" | cut -c1-7)."
  else
    ligne "Temoin de cloture non ecrit : $donnees/temoins n'est pas accessible en ecriture."
  fi
  return 0
}

lire_temoin() { # <racine> <donnees>
  local racine="$1" donnees="$2" f tc ta td head n c7
  [ -n "$donnees" ] || return 0
  f="$donnees/temoins/$(nom_projet "$racine")"
  [ -f "$f" ] || return 0
  tc="$(sed -n 's/^commit=//p' "$f" | head -n 1)"
  ta="$(sed -n 's/^arbre=//p' "$f" | head -n 1)"
  td="$(sed -n 's/^date=//p' "$f" | head -n 1)"
  [ -n "$tc" ] || return 0
  c7="$(printf '%s' "$tc" | cut -c1-7)"
  head="$(git -C "$racine" rev-parse HEAD 2>/dev/null || true)"
  [ -n "$head" ] || return 0
  if [ "$head" = "$tc" ]; then
    if [ -n "$ta" ] && [ "$ta" != "$(empreinte_arbre "$racine")" ]; then
      ligne "Derniere cloture le $td au commit $c7, le meme commit, mais des fichiers ont change depuis."
    else
      ligne "La session repart bien de la derniere cloture (le $td, commit $c7)."
    fi
  elif git -C "$racine" cat-file -e "$tc^{commit}" 2>/dev/null \
       && git -C "$racine" merge-base --is-ancestor "$tc" "$head" 2>/dev/null; then
    n="$(git -C "$racine" rev-list --count "$tc..$head" 2>/dev/null || true)"
    ligne "Derniere cloture le $td au commit $c7, ${n:-plusieurs} commit(s) ajoute(s) depuis."
  else
    ligne "Derniere cloture le $td au commit $c7, absent de cette branche (rebase ou autre branche)."
  fi
  return 0
}

main() {
  local mode=lire racine="" donnees="${CLAUDE_PLUGIN_DATA:-}" base top v ligne_version
  local out rc nb na reprise d date_r msgs c

  while [ $# -gt 0 ]; do
    case "$1" in
      --ecrire-temoin) mode=ecrire; shift ;;
      --racine)        racine="${2:-}"; if [ $# -ge 2 ]; then shift 2; else shift; fi ;;
      --donnees)       donnees="${2:-}"; if [ $# -ge 2 ]; then shift 2; else shift; fi ;;
      *) shift ;;
    esac
  done

  # Pas de depot git (ou pas de git) : ce n'est pas un projet, on ne dit rien.
  base="${racine:-${CLAUDE_PROJECT_DIR:-$PWD}}"
  [ -d "$base" ] || return 0
  top="$(git -C "$base" rev-parse --show-toplevel 2>/dev/null || true)"
  [ -n "$top" ] || return 0
  racine="$(cd "$top" && pwd -P)" || return 0

  CTX_RACINE="$racine"
  export CTX_RACINE
  # shellcheck source=ctx-commun.sh
  . "$DIR/ctx-commun.sh" || return 0

  if [ "$mode" = ecrire ]; then
    ecrire_temoin "$racine" "$donnees"
    return 0
  fi

  v="$(conv_version)"
  if [ "$v" = 0 ]; then
    # Le plugin est installe pour tous les depots, forks compris : sans bloc et sans aucun
    # pilier, ce n'est pas un projet de la convention, silence complet. Avec au moins un
    # pilier, quelqu'un a commence, une ligne propose de poser le bloc.
    if [ -f "$racine/CODEMAP.md" ] || [ -f "$racine/TODOS.md" ] || [ -f "$racine/CHANGELOG.md" ]; then
      ligne "Piliers de contexte presents mais pas de bloc de convention. /clawd-stack:migrer pour le poser."
    fi
    return 0
  fi

  # Version du bloc.
  case "$v" in
    ''|*[!0-9]*)
      ligne "Version du bloc contexte:convention illisible ($v). /clawd-stack:migrer pour la remettre d'aplomb."
      ;;
    *)
      if [ "$v" -lt "$CTX_VERSION" ]; then
        ligne_version=""
        [ -n "$(conv_lire version)" ] || ligne_version=", sans ligne version:"
        ligne "Bloc de convention en version $v${ligne_version}, la courante est la $CTX_VERSION. /clawd-stack:migrer"
      elif [ "$v" -gt "$CTX_VERSION" ]; then
        ligne "Bloc de convention en version $v, plus recent que les scripts du plugin (version $CTX_VERSION). Mets le plugin a jour."
      fi
      ;;
  esac

  # Bloc de reprise de TODOS.md : la date de son titre.
  if [ -f "$racine/TODOS.md" ]; then
    reprise="$(grep -iE '^#+ .*(reprise|resume state)' "$racine/TODOS.md" 2>/dev/null | head -n 1 || true)"
    if [ -n "$reprise" ]; then
      date_r="$(printf '%s' "$reprise" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -n 1 || true)"
      d="$(ctx_jours_depuis "$date_r")"
      if [ -n "$d" ] && [ "$d" -gt 14 ]; then
        ligne "Le bloc de reprise de TODOS.md date du $date_r, soit $d jours. Il est peut-etre perime."
      fi
    fi
  fi

  # Audit du budget, sauf si le bloc est plus recent que les scripts : il refuserait de tourner.
  if [ "$v" -le "$CTX_VERSION" ] 2>/dev/null; then
    rc=0
    if command -v timeout >/dev/null 2>&1; then
      out="$(timeout 8 bash "$DIR/ctx-audit.sh" --root "$racine" --budget --json 2>/dev/null)" || rc=$?
    else
      out="$(bash "$DIR/ctx-audit.sh" --root "$racine" --budget --json 2>/dev/null)" || rc=$?
    fi
    case "$out" in
      "["*)
        if [ "$rc" -eq 0 ]; then
          nb="$(printf '%s\n' "$out" | grep -o '"niveau":"blocage"' | wc -l | tr -d ' ')"
          na="$(printf '%s\n' "$out" | grep -o '"niveau":"alerte"' | wc -l | tr -d ' ')"
          if [ "${nb:-0}" -gt 0 ] || [ "${na:-0}" -gt 0 ]; then
            ligne "${nb:-0} blocage(s) et ${na:-0} alerte(s) sur le budget de contexte. /clawd-stack:cloture pour les ranger."
            msgs="$(printf '%s\n' "$out" | grep '"niveau":"blocage"' | sed -e 's/.*"message":"//' -e 's/"}*,*$//' -e 's/\\"/"/g' | head -n 3 | cut -c1-200 || true)"
            if [ -n "$msgs" ]; then
              while IFS= read -r c; do
                [ -n "$c" ] && ligne "  blocage : $c"
              done <<FIN
$msgs
FIN
            fi
          fi
        else
          ligne "L'audit du budget a rendu le code $rc. /clawd-stack:audit pour le lire en clair."
        fi
        ;;
      *)
        ligne "L'audit du budget n'a rien rendu (code $rc). /clawd-stack:audit pour le lire en clair."
        ;;
    esac
  fi

  lire_temoin "$racine" "$donnees"
  return 0
}

# main ne parle que par SORTIE, qu'on imprime ici tronquee a quinze lignes.
main "$@" >/dev/null 2>&1 </dev/null || true
printf '%s' "$SORTIE" | head -n 15 | cut -c1-240
exit 0
