# 02 - Architecture de la chaîne CI/CD

**Auteur :** Etudiant 7

## Vue d'ensemble

```
 Développeur (Etudiant 7)
        │  git push
        ▼
 ┌─────────────────────┐
 │  Dépôt GitHub        │
 │  (source de vérité)  │
 └─────────┬────────────┘
           │ déclenche
           ▼
 ┌─────────────────────────────┐
 │ GitHub Actions               │
 │                               │
 │ 01-ci.yml                    │  push / pull_request
 │  - checkout                  │
 │  - build image (local)       │
 │  - run conteneur              │
 │  - test HTTP automatisé      │
 │                               │
 │ 02-publish-ghcr.yml           │  push sur main
 │  - build image (1 seule fois)│
 │  - login GHCR (GITHUB_TOKEN) │
 │  - push + tag + digest       │
 │                               │
 │ 03-promote.yml                │  déclenchement manuel
 │  - imagetools inspect         │  (workflow_dispatch)
 │  - imagetools create (retag)  │
 │  - AUCUN rebuild               │
 └─────────┬─────────────────────┘
           │ push image
           ▼
 ┌─────────────────────┐        tag: recette
 │  GHCR                 │◄──── tag: production-simulee
 │  ghcr.io/.../site-    │        (même digest)
 │  catalog               │
 └─────────┬────────────┘
           │ pull par digest
           ▼
 ┌─────────────────────────────────────┐
 │ Environnements GitHub simulés        │
 │  - recette              (validation) │
 │  - production-simulee   (protection) │
 └───────────────────────────────────────┘
```

## Rôle de chaque composant

- **Dépôt GitHub** : source de vérité unique. Contient le code du site, le `Dockerfile`, le
  `compose.yml`, les workflows et la documentation. L'historique des commits sert de première
  preuve de traçabilité.
- **GitHub Actions** : moteur d'automatisation. Trois workflows distincts et responsabilités
  séparées (contrôle/test, publication, promotion) pour rester lisible et traçable.
- **GitHub-hosted runners** : machines temporaires fournies par GitHub (`ubuntu-latest`),
  détruites après chaque run. Aucun serveur à administrer, aucune dérive de configuration
  possible entre deux exécutions.
- **Dockerfile** : construit une image Nginx contenant uniquement le site statique nécessaire,
  à partir d'une image de base officielle et versionnée (`nginx:1.27-alpine`).
- **GHCR** : registre où l'image est publiée avec un tag lisible (`recette`, `sha-<commit>`) et
  un digest immuable (`sha256:...`) qui identifie de façon unique le contenu binaire de l'image.
- **compose.yml** : orchestration légère pour les tests locaux et la démonstration de
  coordination multi-conteneurs (service web + service de supervision). Voir
  `05-orchestration-scaling.md`.
- **Environnements GitHub (`recette`, `production-simulee`)** : permettent de simuler une
  séparation d'environnements et d'ajouter des règles de protection (validation manuelle
  obligatoire) sans avoir de serveur de production réel.

## Flux de promotion (sans rebuild)

1. `02-publish-ghcr.yml` construit l'image **une seule fois** et la publie dans GHCR. Le digest
   généré (`sha256:...`) est noté dans le résumé du run.
2. Ce digest est réutilisé tel quel en entrée de `03-promote.yml`.
3. `03-promote.yml` utilise `docker buildx imagetools create`, qui copie uniquement les
   métadonnées de manifeste dans le registre pour créer un nouveau tag (`production-simulee`)
   pointant vers le **même digest**. Aucune étape de build n'est ré-exécutée.
4. On peut vérifier, avant et après promotion, que le digest de l'image reste strictement
   identique : c'est la preuve que l'artefact promu en "production" est rigoureusement le même
   que celui validé en recette.

## Schéma enrichi : où se situerait une vraie production

```
                      ┌───────────────────────────┐
                      │   Registre d'images maîtrisé│
                      │   (GHCR + scan vulnérabilités)│
                      └─────────────┬───────────────┘
                                    │
                     ┌──────────────┴───────────────┐
                     ▼                               ▼
           ┌───────────────────┐           ┌───────────────────┐
           │ Cluster recette     │           │ Cluster production │
           │ (K8s / orchestrateur│           │ (K8s / orchestrateur│
           │  réel, plusieurs    │           │  réel, haute        │
           │  répliques)         │           │  disponibilité,     │
           └───────────────────┘           │  répartition de     │
                                             │  charge, supervision)│
                                             └───────────────────┘
```

Ce schéma cible n'est **pas** implémenté dans ce projet (voir `06-analyse-production-reelle.md`
et `07-limites-et-tests.md` pour l'analyse détaillée des écarts et de ce qu'il faudrait ajouter).
