# 08 - Compte rendu final

**Auteur :** Etudiant 7
**Évaluation :** EC06 — Mise en place d'un système d'automatisation d'intégration et de déploiement continu

## Ce qui a été mis en place

Dans le cadre de ce projet, j'ai construit une chaîne CI/CD complète pour la publication d'un
site statique conteneurisé avec Nginx :

- un dépôt GitHub individuel structuré, séparant clairement le code applicatif (`site/`), la
  construction de l'image (`Dockerfile`, `compose.yml`), l'automatisation
  (`.github/workflows/`) et la documentation (`docs/`) ;
- un premier workflow (`01-ci.yml`) qui contrôle automatiquement le projet à chaque
  modification : vérification de la structure, construction de l'image, puis test HTTP
  automatisé du conteneur démarré ;
- un second workflow (`02-publish-ghcr.yml`) qui construit l'image une seule fois et la publie
  dans GitHub Container Registry avec un tag lisible et un digest immuable ;
- un troisième workflow (`03-promote.yml`), déclenché manuellement, qui promeut ce même
  artefact (identifié par son digest) vers un environnement `production-simulee`, sans jamais
  reconstruire l'image, en s'appuyant sur `docker buildx imagetools create` ;
- un fichier `compose.yml` documentant une orchestration légère à deux services (le site et un
  service de supervision minimal), avec une explication de la simulation de mise à l'échelle et
  de ses limites par rapport à un vrai orchestrateur de production ;
- une documentation complète couvrant le cadrage, l'architecture, la sécurité, les preuves
  d'exécution, l'orchestration/scaling, et l'analyse obligatoire du passage vers une production
  réelle (secrets, rollback, sauvegarde/restauration).

## Ce que ce projet m'a permis de comprendre

`[À COMPLETER PAR L'ÉTUDIANT — réflexion personnelle attendue par le référentiel]`

Quelques pistes à développer avec vos propres mots :

- Ce que signifie concrètement "promouvoir un artefact sans rebuild", et pourquoi c'est une
  garantie importante de fiabilité (on teste et on déploie exactement la même chose).
- La différence entre un tag (mutable, pratique) et un digest (immuable, fiable pour la
  traçabilité).
- Pourquoi séparer les workflows par responsabilité (contrôle, publication, promotion) rend la
  chaîne plus lisible et plus sûre qu'un unique workflow monolithique.
- Ce que Docker Compose apporte réellement, et ce qu'il ne remplace pas (voir `05-` et `07-`).
- Les difficultés rencontrées concrètement pendant la réalisation (configuration des
  permissions GitHub Actions, syntaxe des workflows, tests locaux, etc.) et comment elles ont
  été résolues.

## Difficultés rencontrées

`[À COMPLETER PAR L'ÉTUDIANT]`

## Limites assumées du rendu

Voir le détail dans `07-limites-et-tests.md`. En résumé : absence de scan de vulnérabilités
automatisé, environnements simulés au niveau GitHub plutôt que sur une infrastructure réelle
séparée, pas d'orchestrateur de production (volontairement hors périmètre du projet).

## Conclusion personnelle

`[À COMPLETER PAR L'ÉTUDIANT — une conclusion courte et personnelle sur ce que vous retenez de
ce module et comment vous réutiliseriez cette approche sur un projet réel.]`
