# 07 - Limites, tests complémentaires et choix personnels

**Auteur :** Etudiant 7

## Test local avec Docker / Docker Compose

`[À COMPLETER PAR L'ÉTUDIANT selon votre environnement réel]`

Deux cas possibles, à choisir selon la situation réelle :

- **Si Docker est disponible en local** : documenter ici la commande utilisée
  (`docker compose up --build`), une capture d'écran du site accessible sur
  `http://localhost:8080`, et le résultat de `docker compose ps`.
- **Si l'environnement personnel ne permet pas de faire tourner Docker localement** (ex :
  poste sans droits administrateur, restrictions réseau, machine trop limitée) : documenter
  précisément la contrainte rencontrée, et s'appuyer sur les tests automatisés exécutés dans
  GitHub Actions (`01-ci.yml`) comme preuve de fonctionnement, en l'indiquant explicitement ici.

## Utilisation d'une VM personnelle

`[À COMPLETER PAR L'ÉTUDIANT]`

- **Si une VM personnelle est utilisée** (VirtualBox, VMware, Hyper-V, WSL2, etc.) : décrire
  brièvement sa configuration (OS, ressources) et ce qui y a été testé.
- **Si aucune VM personnelle n'est utilisée** : justifier ce choix (ex : les GitHub-hosted
  runners suffisent pour couvrir l'intégralité du besoin du projet, qui ne nécessite pas de
  serveur à administrer en continu).

## Amélioration graphique minimale du site

Le site (`site/index.html`) a été enrichi avec une mise en page en cartes, un dégradé de
couleurs et un badge d'environnement, afin qu'il soit visuellement identifiable et distinct
d'une page Nginx par défaut, sans complexifier inutilement la maintenance du projet.

## Tests complémentaires simples et documentés

En complément du test HTTP principal (code 200), le workflow `01-ci.yml` vérifie également :

- la présence des fichiers attendus dans le dépôt avant tout build (`Dockerfile`,
  `site/index.html`, `site/version.json`) ;
- la validité syntaxique du fichier `version.json` (chargement JSON réussi) ;
- la présence du texte `"Catal-Log"` dans la page HTML rendue par le conteneur ;
- l'accessibilité de `version.json` via HTTP et la présence de l'identifiant `"Etudiant 7"`
  dedans, ce qui garantit que le bon build (avec le bon contenu) a bien été déployé.

`[À COMPLETER PAR L'ÉTUDIANT] : ajouter ici tout test complémentaire personnel que vous auriez
mis en place (ex: test de l'en-tête `Content-Type`, test avec `docker scout` ou `trivy`, test de
temps de réponse, etc.), avec la preuve associée.`

## Amélioration de la traçabilité / automatisation documentaire

Piste d'amélioration envisagée : générer automatiquement un tableau récapitulatif (tag, digest,
date, environnement) dans un fichier `docs/historique-promotions.md`, mis à jour à chaque
exécution de `03-promote.yml`, via une étape supplémentaire qui committerait ce fichier dans le
dépôt. Cette amélioration n'a pas été implémentée dans la version rendue, pour rester dans le
périmètre du socle obligatoire, mais elle est identifiée comme une évolution naturelle du
projet.

## Réflexion approfondie sur les limites de l'approche globale

- **Limite d'échelle** : le projet démontre les principes d'une chaîne CI/CD sur un cas très
  simple (site statique, un seul conteneur applicatif). Un projet réel avec plusieurs services
  interdépendants demanderait une gestion de dépendances entre pipelines plus complexe.
- **Limite d'environnement** : les environnements `recette` et `production-simulee` sont des
  concepts GitHub (tags + règles de protection), pas des infrastructures isolées. Le risque
  qu'un même hôte serve les deux "environnements" existe si l'on déployait réellement les
  conteneurs quelque part, ce qui n'est pas le cas ici (le projet reste au niveau du registre
  d'images, sans déploiement effectif sur un serveur cible).
- **Limite de sécurité** : comme indiqué dans la fiche sécurité, aucun scan de vulnérabilités
  automatisé n'est en place ; c'est acceptable pour un site statique sans logique serveur, mais
  deviendrait indispensable dès qu'une application plus complexe serait conteneurisée.
- **Limite pédagogique assumée** : ce projet est un exercice individuel réalisé sur 5 jours ; il
  ne prétend pas remplacer une vraie infrastructure de production, mais vise à démontrer la
  compréhension des mécanismes fondamentaux d'une chaîne CI/CD conteneurisée (construction
  reproductible, tests automatisés, publication traçable, promotion contrôlée d'un artefact
  unique).
