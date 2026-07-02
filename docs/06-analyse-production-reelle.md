# 06 - Analyse : passage vers une production réelle

**Auteur :** Etudiant 7

Ce projet ne met pas en place une vraie production. Cette section explique ce qu'il faudrait
ajouter pour transformer la simulation actuelle (recette / production-simulee dans GitHub) en un
véritable environnement de production.

## 1. Gestion des secrets

Dans ce projet, **aucun secret n'est stocké dans le code** :

- L'authentification vers GHCR repose uniquement sur `secrets.GITHUB_TOKEN`, un jeton
  généré automatiquement par GitHub pour chaque exécution de workflow, avec une durée de vie
  limitée au run et des droits restreints par le bloc `permissions:` (`packages: write`
  uniquement quand nécessaire).
- Stocker un secret directement dans un fichier versionné est risqué car il reste accessible
  indéfiniment dans l'historique Git, même après suppression du fichier, et peut être exposé si
  le dépôt devient public ou est compromis.

En production réelle, il faudrait en plus :

- Utiliser **GitHub Secrets** (au niveau dépôt ou environnement) pour tout identifiant
  supplémentaire (ex : clé d'API d'un service tiers, identifiants de déploiement vers un cloud
  provider, jeton d'un registre externe).
- Pour une infrastructure plus large, s'appuyer sur un **coffre de secrets dédié** (HashiCorp
  Vault, AWS Secrets Manager, Azure Key Vault, GCP Secret Manager) avec rotation automatique des
  secrets et accès audité.
- Ne jamais journaliser un secret dans les logs de CI (attention aux `echo` de variables
  sensibles).

## 2. Rollback

La stratégie de rollback de ce projet s'appuie sur l'identification stricte des artefacts :

- Chaque image publiée possède un **tag** (ex : `sha-abc1234`) et un **digest** immuable
  (`sha256:...`). Le digest ne change jamais tant que le contenu binaire de l'image est
  identique.
- Pour revenir à une version antérieure, il suffit de ré-exécuter `03-promote.yml` en fournissant
  le digest de l'ancienne version connue (conservé dans l'historique des runs
  `02-publish-ghcr.yml` ou dans les résumés de run), et de recréer le tag
  `production-simulee` pointant vers cet ancien digest, **sans reconstruire l'image**.
- Cette approche est possible car GHCR conserve toutes les images publiées avec leur digest tant
  qu'elles ne sont pas explicitement supprimées.

En production réelle, il faudrait en plus :

- Une politique de rétention claire dans GHCR (ne pas supprimer les images encore utilisées ou
  potentiellement nécessaires à un rollback).
- Un mécanisme de déploiement qui permette de rebasculer rapidement le trafic vers l'ancienne
  version (ex : changement de tag suivi d'un redéploiement orchestré, ou bascule bleu/vert).
- Un enregistrement clair de "quelle version tourne actuellement en production" (ex : fichier de
  configuration versionné indiquant le digest actif), pour savoir précisément vers quoi revenir.

## 3. Sauvegarde / restauration

Éléments qu'il faudrait sauvegarder pour pouvoir restaurer intégralement ce projet :

- **Le dépôt GitHub** lui-même (code source, `Dockerfile`, `compose.yml`) : sauvegarde native
  via Git (clones distribués) et, pour une garantie supplémentaire, export périodique
  (mirroring vers un autre hébergeur ou stockage).
- **Les workflows GitHub Actions** (`.github/workflows/*.yml`) : versionnés avec le code, donc
  déjà couverts par la sauvegarde du dépôt.
- **La documentation** (`docs/*.md`) : également versionnée dans le dépôt.
- **Les images publiées dans GHCR** : nécessitent une sauvegarde spécifique (le registre n'est
  pas sauvegardé par Git). Il faudrait soit répliquer les images vers un second registre, soit
  exporter périodiquement les images critiques (`docker save`), soit s'appuyer sur les garanties
  de durabilité du fournisseur du registre.
- **La configuration des environnements GitHub** (règles de protection, secrets associés) :
  à documenter manuellement (elle n'est pas versionnée automatiquement avec le code).
- **Les preuves d'exécution** (logs de runs, résumés `GITHUB_STEP_SUMMARY`, captures d'écran) :
  utiles pour l'audit et la conformité, à archiver en dehors de GitHub Actions si une rétention
  longue est nécessaire (les logs de run ont une durée de rétention limitée sur GitHub).
- **Éléments nécessaires à la restauration complète** : accès au compte GitHub (ou à
  l'organisation), droits sur le registre GHCR, et la documentation elle-même qui explique
  comment reconstruire la chaîne depuis zéro.

## Éléments complémentaires (au moins deux au choix, référentiel section 8)

1. **Contrôle des vulnérabilités** : en production, il faudrait intégrer un scanner d'image
   (Trivy, Docker Scout, Grype) directement dans le workflow `02-publish-ghcr.yml`, avec un seuil
   de sévérité qui bloque la publication en cas de vulnérabilité critique non corrigée.
2. **Séparation stricte des environnements** : en production réelle, `recette` et
   `production-simulee` seraient deux environnements physiquement ou logiquement séparés
   (clusters, comptes cloud, ou au minimum des réseaux isolés), avec des accès et des
   identifiants distincts, plutôt que deux simples tags GitHub Environments comme dans cette
   simulation pédagogique.
3. **Journalisation et supervision** *(élément additionnel, non obligatoire mais pertinent ici)* :
   le service `monitor` du `compose.yml` est une amorce très simplifiée de ce qui deviendrait, en
   production, une stack de supervision complète (Prometheus/Grafana, alerting, dashboards de
   disponibilité).
