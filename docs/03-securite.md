# 03 - Fiche securite minimale

**Auteur :** Etudiant 7

## 1. Gestion des secrets

- Aucun secret (mot de passe, cle API, jeton personnel) n'est stocke en clair dans le depot,
  le `Dockerfile`, le `compose.yml` ou les workflows.
- L'authentification vers GHCR utilise exclusivement `secrets.GITHUB_TOKEN`, un jeton
  **genere automatiquement par GitHub**, valable uniquement pour la duree du run, et dont les
  droits sont limites par le bloc `permissions:` declare dans chaque workflow
  (`contents: read`, `packages: write`).
- Aucun jeton personnel d'acces (PAT) n'est utilise dans ce projet.

## 2. Image de base et surface d'attaque

- Utilisation de l'image officielle `nginx:1.27-alpine`, choisie pour sa taille reduite
  (moins de paquets = moins de vulnerabilites potentielles) et sa provenance officielle.
- Le contenu par defaut de l'image (`/usr/share/nginx/html/*`) est supprime avant copie du
  site, afin de ne publier que le contenu attendu.
- Le conteneur Nginx s'execute par defaut avec l'utilisateur non privilegie fourni par l'image
  Alpine officielle (pas d'execution explicite en `root` dans le `Dockerfile`).

## 3. Permissions GitHub Actions

- Chaque workflow declare explicitement le principe de moindre privilege via `permissions:` :
  - `01-ci.yml` : `contents: read` (aucune ecriture, aucune publication).
  - `02-publish-ghcr.yml` : `contents: read`, `packages: write` (uniquement le necessaire pour
    publier dans GHCR).
  - `03-promote.yml` : `contents: read`, `packages: write`.
- Le workflow de promotion (`03-promote.yml`) n'est declenche que manuellement
  (`workflow_dispatch`), jamais automatiquement, ce qui evite toute promotion accidentelle
  vers la production simulee.

## 4. Environnements et validation manuelle

- Les environnements GitHub `recette` et `production-simulee` permettent d'ajouter, dans les
  parametres du depot (Settings > Environments), une regle de protection de type
  "Required reviewers" pour l'environnement `production-simulee`. Cela simule une validation
  manuelle obligatoire avant toute mise en production, meme simulee.
- Configuration confirmee sur ce depot : dans *Settings > Environments*, l'environnement
  `production-simulee` affiche **"1 protection rule"** (verifie le jour du rendu), correspondant
  a la regle **"Required reviewers"** avec `etudiant7` comme reviewer autorise. Concretement,
  toute execution de `03-promote.yml` ciblant `production-simulee` reste desormais en attente
  ("Review deployments") tant qu'un reviewer declare n'a pas explicitement approuve le
  deploiement, ce qui materialise la validation manuelle avant mise en production, meme simulee.
  L'environnement `recette`, lui, ne porte aucune regle de protection (acces direct), ce qui
  differencie volontairement les deux niveaux de rigueur entre recette et production.

## 5. Tracabilite des artefacts

- Chaque image publiee est identifiee par :
  - un **tag** lisible (`recette`, `sha-<commit>`, `production-simulee`) ;
  - un **digest** immuable (`sha256:...`) qui ne change jamais tant que le contenu de l'image
    est identique.
- Cette double identification permet de savoir exactement quel code source a produit quelle
  image, et donc de tracer un incident jusqu'au commit d'origine.

## 6. Limites de securite assumees dans ce projet pedagogique

- Aucun scan automatise de vulnerabilites (type Trivy ou Docker Scout) n'est integre par
  defaut dans les workflows de ce depot (peut etre ajoute en amelioration, voir
  `07-limites-et-tests.md`).
- Aucun WAF, aucun pare-feu applicatif, aucune supervision de securite en temps reel : le
  perimetre du projet est volontairement limite a la chaine CI/CD elle-meme.
- Le site etant statique et sans base de donnees, la surface d'attaque applicative est tres
  reduite (pas d'injection SQL, pas de traitement de formulaire cote serveur).

## 7. Bonnes pratiques appliquees (resume)

| Bonne pratique | Statut dans ce projet |
|---|---|
| Pas de secret en clair dans le code | Respecte |
| Utilisation du `GITHUB_TOKEN` a duree de vie limitee | Respecte |
| Permissions minimales par workflow | Respecte |
| Image de base officielle et legere | Respecte |
| Promotion manuelle uniquement (pas d'auto-deploiement en prod) | Respecte |
| Tag + digest pour identifier chaque artefact | Respecte |
| Scan de vulnerabilites automatise | Non implemente (piste d'amelioration) |
| Separation stricte des environnements avec validation humaine | Respecte (Required reviewers actif sur `production-simulee`) |
