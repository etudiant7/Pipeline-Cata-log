# Projet CICD — EC06 (RNCP39611 BC02)

**Auteur du rendu : Etudiant 7**

Chaîne CI/CD conteneurisée pour la publication d'un site statique via Nginx, GitHub Actions et
GitHub Container Registry (GHCR), avec simulation des environnements recette et
production-simulee.

## Démarrage rapide en local

```bash
docker compose up --build
# Site accessible sur http://localhost:8080
```

Simulation de scaling (voir docs/05-orchestration-scaling.md) :

```bash
docker compose up --build --scale web=2
```

## Structure du dépôt

```
site/                          Site statique (index.html, version.json)
Dockerfile                      Image Nginx reproductible
compose.yml                     Orchestration légère (2 services)
.github/workflows/01-ci.yml              Contrôle + build + test automatisé
.github/workflows/02-publish-ghcr.yml    Publication GHCR (tag + digest)
.github/workflows/03-promote.yml         Promotion manuelle sans rebuild
docs/                            Documentation complète (cadrage, sécurité,
                                  preuves, orchestration, analyse production,
                                  limites, compte rendu final)
```

## Documentation

| Fichier | Contenu |
|---|---|
| [docs/01-cadrage.md](docs/01-cadrage.md) | Contexte, mission, périmètre |
| [docs/02-architecture.md](docs/02-architecture.md) | Schéma d'architecture de la chaîne CI/CD |
| [docs/03-securite.md](docs/03-securite.md) | Fiche sécurité minimale |
| [docs/04-preuves.md](docs/04-preuves.md) | Toutes les preuves demandées par le référentiel |
| [docs/05-orchestration-scaling.md](docs/05-orchestration-scaling.md) | C13 : orchestration légère et scaling |
| [docs/06-analyse-production-reelle.md](docs/06-analyse-production-reelle.md) | Secrets, rollback, sauvegarde/restauration |
| [docs/07-limites-et-tests.md](docs/07-limites-et-tests.md) | Limites, tests complémentaires, choix personnels |
| [docs/08-compte-rendu-final.md](docs/08-compte-rendu-final.md) | Compte rendu final personnel |

## Important — avant le rendu

Ce dépôt fournit la structure complète, le code et les workflows du projet. Les preuves
d'exécution réelles (liens vers les runs GitHub Actions, captures d'écran GHCR, tag et digest
effectifs, etc.) doivent être complétées **après avoir poussé ce dépôt sur votre propre compte
GitHub et exécuté réellement les workflows**. Les emplacements à compléter sont marqués
`[À COMPLETER PAR L'ÉTUDIANT]` dans les fichiers de `docs/`.

Pensez également à :

1. Remplacer `etudiant7` par votre nom d'utilisateur GitHub réel dans `compose.yml` si vous
   souhaitez que l'image locale pointe vers votre propre espace GHCR.
2. Créer les deux environnements GitHub (`recette` et `production-simulee`) dans
   *Settings > Environments*, et configurer une règle de validation manuelle sur
   `production-simulee`.
3. Vérifier que le package GHCR créé est visible (public ou privé selon votre choix) et lié au
   dépôt.
