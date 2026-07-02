# 04 - Preuves d'exécution

**Auteur :** Etudiant 7

> Ce document liste toutes les preuves demandées par le référentiel EC06. Les liens et captures
> ci-dessous doivent être complétés après avoir poussé ce dépôt sur un compte GitHub personnel et
> exécuté réellement les workflows : une preuve ne peut être produite que par une exécution
> effective, elle ne peut pas être pré-remplie à l'avance.

## 1. Dépôt GitHub individuel

- Lien du dépôt : `[À COMPLETER] https://github.com/<votre-utilisateur>/projet-cicd-ec06-etudiant7`

## 2. Exécutions GitHub Actions réussies

| Workflow | Lien du run | Statut |
|---|---|---|
| 01-ci.yml | `[À COMPLETER]` | `[À COMPLETER]` |
| 02-publish-ghcr.yml | `[À COMPLETER]` | `[À COMPLETER]` |
| 03-promote.yml (recette) | `[À COMPLETER]` | `[À COMPLETER]` |
| 03-promote.yml (production-simulee) | `[À COMPLETER]` | `[À COMPLETER]` |

Captures d'écran à ajouter dans `docs/screenshots/` (dossier à créer), par exemple :
`docs/screenshots/01-ci-success.png`, `docs/screenshots/02-publish-success.png`, etc.

## 3. Preuve du build Docker automatisé

- Étape "Build de l'image Docker" du run `01-ci.yml` : `[À COMPLETER lien direct vers l'étape]`

## 4. Preuve du test HTTP automatisé

- Étape "Test technique automatisé - code HTTP 200" du run `01-ci.yml` : `[À COMPLETER]`
- Code HTTP obtenu : `[À COMPLETER, attendu : 200]`

## 5. Preuve de publication GHCR

- Lien vers le package GHCR : `[À COMPLETER] https://github.com/users/<votre-utilisateur>/packages/container/package/site-catalog`
- Capture d'écran de la page du package : `[À COMPLETER]`

## 6. Tag et digest de l'image

- Tag(s) publié(s) : `[À COMPLETER, ex : sha-abc1234, recette]`
- Digest de l'image : `[À COMPLETER, ex : sha256:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx]`
- Commande utilisée pour vérifier : `docker buildx imagetools inspect ghcr.io/<utilisateur>/projet-cicd-ec06-etudiant7@<digest>`

## 7. Preuve de validation en recette simulée

- Run `03-promote.yml` avec `target_environment = recette` : `[À COMPLETER lien]`
- Résultat du job (résumé `GITHUB_STEP_SUMMARY`) : `[À COMPLETER, coller le contenu]`

## 8. Preuve de promotion vers production-simulee sans rebuild

- Run `03-promote.yml` avec `target_environment = production-simulee` : `[À COMPLETER lien]`
- Digest **avant** promotion : `[À COMPLETER]`
- Digest **après** promotion (tag `production-simulee`) : `[À COMPLETER]`
- Vérification : les deux digests doivent être strictement identiques → preuve qu'il n'y a pas
  eu de rebuild.

## 9. Extrait / lien vers compose.yml

- Fichier : [`compose.yml`](../compose.yml)
- Test local exécuté : `[À COMPLETER : docker compose up --build, capture ou logs]`

## 10. Explication de la simulation de scaling et de ses limites

- Voir [`05-orchestration-scaling.md`](05-orchestration-scaling.md).
- Résultat de `docker compose up --build --scale web=2` (si testé) : `[À COMPLETER]`

## 11. Preuve ou justification du test local avec Docker / Docker Compose

- `[À COMPLETER : capture de "docker compose up" en local, ou justification documentée si
  l'environnement personnel ne le permet pas (voir 07-limites-et-tests.md)]`

## 12. Preuve ou justification de l'utilisation d'une VM personnelle

- `[À COMPLETER : capture d'une VM locale utilisée pour tester le projet, ou justification
  documentée de non-utilisation, voir 07-limites-et-tests.md]`

## 13. Fiche sécurité minimale

- Voir [`03-securite.md`](03-securite.md) — complétée.

## 14. Analyse des trois points obligatoires (secrets, rollback, sauvegarde/restauration)

- Voir [`06-analyse-production-reelle.md`](06-analyse-production-reelle.md) — complétée.

## 15. Compte rendu final personnel

- Voir [`08-compte-rendu-final.md`](08-compte-rendu-final.md) — complété.
