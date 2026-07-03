# 07 - Limites, tests complémentaires et choix personnels

**Auteur :** Etudiant 7

## Test local avec Docker / Docker Compose

Docker était disponible en local (Docker Desktop sous Windows, backend WSL2), donc le test a été
fait réellement plutôt que justifié en théorie. Commande utilisée : `docker compose up --build`.

Ce test a permis de vérifier concrètement plusieurs choses avant même de pousser sur GitHub :

- l'image se construit sans erreur à partir du `Dockerfile` (résolution de l'image de base
  `nginx:1.27-alpine`, copie du site) ;
- les deux services démarrent et restent up (`site-catalog-web` marqué `healthy`,
  `site-catalog-monitor` en cours d'exécution) ;
- le site est bien accessible et affiche la page attendue (voir capture
  `docs/screenshots/site-fonctionnel-en-local.png`) ;
- les logs confirment que le service `monitor` interroge bien `web` toutes les 30 secondes et
  reçoit une réponse HTTP 200, preuve que les deux conteneurs communiquent correctement via le
  réseau interne.

Un souci a été rencontré une fois en cours de route : le site n'était plus accessible sur
`http://localhost:8080` alors que les conteneurs tournaient. La cause était double : le port 8080
était déjà utilisé par un autre projet Docker présent sur la machine, et le mapping de port dans
`compose.yml` avait été retiré entre deux tests (probablement en manipulant le fichier pour
essayer le scaling). Le correctif a été de remettre le mapping de port et de choisir un port
libre. Ce test a donc aussi servi à vérifier que `docker compose ps` (colonne PORTS) est le bon
réflexe de diagnostic avant de chercher plus loin.

## Utilisation d'une VM personnelle

Aucune VM personnelle dédiée (VirtualBox, VMware, Hyper-V) n'a été utilisée en plus de Docker
Desktop. Justification : Docker Desktop sur Windows s'appuie déjà sur WSL2, qui fournit
l'isolation nécessaire pour faire tourner les conteneurs localement, sans avoir besoin de monter
et d'administrer une machine virtuelle séparée. Le projet ne nécessite pas non plus de serveur à
administrer en continu : les tests automatisés s'exécutent sur les GitHub-hosted runners, qui
couvrent l'intégralité du besoin de validation continue sans infrastructure supplémentaire à
maintenir de mon côté.

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

Aucun test complémentaire supplémentaire (scan de vulnérabilités, test d'en-tête HTTP, test de
temps de réponse) n'a été ajouté au-delà de ceux listés ci-dessus : ce choix a été fait pour
rester concentré sur le socle obligatoire dans le temps imparti. C'est identifié comme une piste
d'amélioration possible plutôt qu'un test réalisé (voir aussi la fiche sécurité,
`03-securite.md`, qui liste l'absence de scan automatisé comme limite assumée).

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
