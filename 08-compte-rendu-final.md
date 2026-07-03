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

Ce projet m'a fait comprendre l'idée centrale d'une chaîne CI/CD : automatiser tout ce qui se
passe entre "je modifie mon code" et "le site est mis à jour", pour ne plus jamais avoir à faire
ces étapes à la main.

Concrètement, ça se passe en trois temps. Je pousse mon code dans mon dépôt GitHub. GitHub
Actions construit alors une image Docker de mon site et vérifie automatiquement qu'elle
fonctionne (le site répond bien, la page s'affiche). Une fois validée, cette image est publiée
dans un registre (GHCR), avec une étiquette (un "digest") qui identifie précisément cette version
de l'image, comme un numéro de série unique. Ensuite, pour passer cette même image en
"production simulée", je ne la reconstruis pas : je réutilise exactement la même, identifiée par
ce digest. C'est ce qui garantit que ce qui a été testé est exactement ce qui est mis en ligne,
sans mauvaise surprise entre les deux.

J'ai aussi compris pourquoi j'ai séparé le projet en trois étapes distinctes (contrôle/test,
publication, promotion) plutôt que de tout mettre dans un seul fichier : chaque étape a un rôle
clair, et surtout, le passage en production reste une action volontaire que je déclenche
moi-même, jamais automatique. Ça évite qu'une mise en ligne se fasse par erreur.

Enfin, j'ai mieux compris ce qu'apporte réellement Docker Compose : il me permet de faire tourner
plusieurs petits services ensemble facilement sur ma machine, mais ce n'est pas un vrai outil de
production capable de répartir la charge entre plusieurs serveurs ou de gérer des pannes — ses
limites sont expliquées dans `05-orchestration-scaling.md`.

## Difficultés rencontrées

J'ai eu trois problèmes concrets pendant la réalisation.

Le premier : mon dépôt s'appelle `Pipeline-Cata-log`, avec des majuscules, mais Docker n'accepte
que des noms d'image en minuscules. Résultat, l'étape de promotion échouait avec une erreur assez
claire une fois que je l'ai lue attentivement. J'ai corrigé le workflow pour qu'il convertisse
automatiquement le nom en minuscules avant de l'utiliser.

Le deuxième : en local, mon site ne s'affichait pas alors que les conteneurs tournaient bien. Le
problème venait du port 8080 déjà utilisé par un autre projet sur ma machine, combiné à une
configuration de port que j'avais modifiée sans la remettre en place ensuite. Ça m'a appris à
toujours vérifier les ports affichés par `docker compose ps` avant de chercher plus loin.

Le troisième : la première fois que j'ai mis mon projet sur GitHub via l'interface web, le
dossier caché contenant mes workflows n'a pas été envoyé du tout, donc rien ne se déclenchait. Il
a fallu que je recrée ces fichiers directement sur GitHub au bon endroit. Depuis, je sais qu'il
vaut mieux utiliser `git` en ligne de commande pour ce genre de dossier.

## Limites assumées du rendu

Voir le détail dans `07-limites-et-tests.md`. En résumé : absence de scan de vulnérabilités
automatisé, environnements simulés au niveau GitHub plutôt que sur une infrastructure réelle
séparée, pas d'orchestrateur de production (volontairement hors périmètre du projet).

## Conclusion personnelle

Ce que je retiens surtout de ce module, c'est qu'une chaîne CI/CD fiable repose sur quelques
règles simples plutôt que sur des outils compliqués : ne jamais reconstruire ce qui a déjà été
testé, garder une trace claire de chaque version publiée, et ne jamais laisser une mise en
production se déclencher toute seule. Sur un vrai projet, je réutiliserais cette même logique
(publier une fois, promouvoir sans reconstruire), en l'accompagnant en plus d'un vrai
environnement de production séparé et d'un contrôle de sécurité automatique des images.
