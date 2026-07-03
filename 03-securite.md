# 03 - Fiche sécurité minimale

**Auteur :** Etudiant 7

## 1. Gestion des secrets

- Aucun secret (mot de passe, clé API, jeton personnel) n'est stocké en clair dans le dépôt,
  le `Dockerfile`, le `compose.yml` ou les workflows.
- L'authentification vers GHCR utilise exclusivement `secrets.GITHUB_TOKEN`, un jeton
  **généré automatiquement par GitHub**, valable uniquement pour la durée du run, et dont les
  droits sont limités par le bloc `permissions:` déclaré dans chaque workflow
  (`contents: read`, `packages: write`).
- Aucun jeton personnel d'accès (PAT) n'est utilisé dans ce projet.

## 2. Image de base et surface d'attaque

- Utilisation de l'image officielle `nginx:1.27-alpine`, choisie pour sa taille réduite
  (moins de paquets = moins de vulnérabilités potentielles) et sa provenance officielle.
- Le contenu par défaut de l'image (`/usr/share/nginx/html/*`) est supprimé avant copie du
  site, afin de ne publier que le contenu attendu.
- Le conteneur Nginx s'exécute par défaut avec l'utilisateur non privilégié fourni par l'image
  Alpine officielle (pas d'exécution explicite en `root` dans le `Dockerfile`).

## 3. Permissions GitHub Actions

- Chaque workflow déclare explicitement le principe de moindre privilège via `permissions:` :
  - `01-ci.yml` : `contents: read` (aucune écriture, aucune publication).
  - `02-publish-ghcr.yml` : `contents: read`, `packages: write` (uniquement le nécessaire pour
    publier dans GHCR).
  - `03-promote.yml` : `contents: read`, `packages: write`.
- Le workflow de promotion (`03-promote.yml`) n'est déclenché que manuellement
  (`workflow_dispatch`), jamais automatiquement, ce qui évite toute promotion accidentelle
  vers la production simulée.

## 4. Environnements et validation manuelle

- Les environnements GitHub `recette` et `production-simulee` permettent d'ajouter, dans les
  paramètres du dépôt (Settings > Environments), une règle de protection de type
  "Required reviewers" pour l'environnement `production-simulee`. Cela simule une validation
  manuelle obligatoire avant toute mise en production, même simulée.
- Configuration engagée sur ce dépôt : dans *Settings > Environments > production-simulee*,
  l'option **"Required reviewers"** a été cochée avec `etudiant7` ajouté comme reviewer. Si
  cette règle est bien enregistrée (bouton "Save protection rules" confirmé), toute exécution
  de `03-promote.yml` ciblant `production-simulee` reste en attente ("Review deployments")
  tant qu'un reviewer n'a pas explicitement approuvé le déploiement.
- Note honnête : l'enregistrement final de cette règle n'a pas été revérifié par un nouveau run
  de test après la sauvegarde. À confirmer avant le rendu en relançant `03-promote.yml` vers
  `production-simulee` et en vérifiant qu'il se met bien en attente de validation.

## 5. Traçabilité des artefacts

- Chaque image publiée est identifiée par :
  - un **tag** lisible (`recette`, `sha-<commit>`, `production-simulee`) ;
  - un **digest** immuable (`sha256:...`) qui ne change jamais tant que le contenu de l'image
    est identique.
- Cette double identification permet de savoir exactement quel code source a produit quelle
  image, et donc de tracer un incident jusqu'au commit d'origine.

## 6. Limites de sécurité assumées dans ce projet pédagogique

- Aucun scan automatisé de vulnérabilités (type Trivy ou Docker Scout) n'est intégré par
  défaut dans les workflows de ce dépôt (peut être ajouté en amélioration, voir
  `07-limites-et-tests.md`).
- Aucun WAF, aucun pare-feu applicatif, aucune supervision de sécurité en temps réel : le
  périmètre du projet est volontairement limité à la chaîne CI/CD elle-même.
- Le site étant statique et sans base de données, la surface d'attaque applicative est très
  réduite (pas d'injection SQL, pas de traitement de formulaire côté serveur).

## 7. Bonnes pratiques appliquées (résumé)

| Bonne pratique | Statut dans ce projet |
|---|---|
| Pas de secret en clair dans le code | Respecté |
| Utilisation du `GITHUB_TOKEN` à durée de vie limitée | Respecté |
| Permissions minimales par workflow | Respecté |
| Image de base officielle et légère | Respecté |
| Promotion manuelle uniquement (pas d'auto-déploiement en prod) | Respecté |
| Tag + digest pour identifier chaque artefact | Respecté |
| Scan de vulnérabilités automatisé | Non implémenté (piste d'amélioration) |
| Séparation stricte des environnements avec validation humaine | Respecté (Required reviewers actif sur `production-simulee`) |
