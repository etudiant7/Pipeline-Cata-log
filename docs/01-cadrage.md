# 01 - Cadrage du projet

**Auteur :** Etudiant 7
**Formation :** Administrateur Systèmes, Réseaux et Cybersécurité — RNCP39611
**Bloc :** RNCP39611BC02 — Configurer et administrer l'infrastructure réseau et les solutions cloud
**Évaluation :** EC06 — Mise en place d'un système d'automatisation d'intégration et de déploiement continu

## Contexte professionnel

L'entreprise fictive **Catal-Log** souhaite industrialiser la publication d'un petit site web statique.
Elle veut éviter les opérations manuelles répétitives, rendre les livraisons plus fiables et conserver
des preuves d'exécution de chaque étape de mise en production.

## Mission

Mettre en place une chaîne CI/CD simple, lisible et traçable, permettant de construire, tester,
publier et promouvoir une image Docker Nginx contenant un site web statique, via GitHub Actions
et GitHub Container Registry (GHCR), avec simulation des environnements **recette** et
**production-simulee** au sein de GitHub.

## Objectifs opérationnels retenus

1. Versionner chaque modification dans un dépôt GitHub individuel.
2. Contrôler automatiquement le projet à chaque push / pull request.
3. Construire une image Docker reproductible à partir d'un `Dockerfile`.
4. Tester automatiquement le conteneur (test HTTP) dans GitHub Actions.
5. Publier l'image dans GHCR avec un tag et un digest identifiables.
6. Valider l'image en recette simulée.
7. Promouvoir manuellement le même artefact vers une production simulée, **sans rebuild**.
8. Documenter les choix techniques, les limites de l'approche et fournir des preuves vérifiables.

## Environnement technique retenu

| Composant | Rôle dans ce projet |
|---|---|
| GitHub | Dépôt individuel `projet-cicd-ec06-etudiant7`, historique de commits, documentation, preuves. |
| GitHub Actions | Contrôles automatiques, build Docker, tests, publication GHCR, promotion manuelle. |
| GitHub-hosted runners | Exécution des workflows sans serveur à administrer (`ubuntu-latest`). |
| Dockerfile | Construction reproductible de l'image Nginx contenant le site statique. |
| GHCR (`ghcr.io`) | Registre de publication et de conservation des tags / digests de l'image. |
| compose.yml | Orchestration légère locale, documentation du service et simulation de scaling (C13). |
| Environnements GitHub | `recette` et `production-simulee`, utilisés comme environnements simulés avec règles de protection configurables. |

## Découpage du dépôt

```
projet-cicd-ec06-etudiant7/
├── site/
│   ├── index.html
│   └── version.json
├── Dockerfile
├── compose.yml
├── .github/workflows/
│   ├── 01-ci.yml
│   ├── 02-publish-ghcr.yml
│   └── 03-promote.yml
└── docs/
    ├── 01-cadrage.md
    ├── 02-architecture.md
    ├── 03-securite.md
    ├── 04-preuves.md
    ├── 05-orchestration-scaling.md
    ├── 06-analyse-production-reelle.md
    ├── 07-limites-et-tests.md
    └── 08-compte-rendu-final.md
```

## Anonymisation du rendu

Conformément aux exigences de correction anonymisée, tous les documents de ce dépôt utilisent
l'identifiant **Etudiant 7** à la place de tout nom réel. Aucune information personnelle
(nom, prénom, adresse e-mail personnelle, identifiant d'établissement) n'apparaît dans le code,
les workflows ou la documentation.
