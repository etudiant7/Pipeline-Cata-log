# 05 - Orchestration légère et simulation de scaling (compétence C13)

**Auteur :** Etudiant 7

## Rôle de Docker Compose comme orchestration légère

Ce projet n'utilise pas Kubernetes et ne met pas en place d'orchestration de production réelle.
`compose.yml` joue ici le rôle d'une **orchestration légère** : il décrit de façon déclarative
les conteneurs nécessaires, leurs dépendances, leur réseau et leur configuration, afin de pouvoir
les démarrer et les arrêter de manière reproductible avec une seule commande
(`docker compose up`). C'est un premier niveau de coordination de plusieurs conteneurs, bien
plus simple qu'un orchestrateur de production, mais qui en illustre certains principes
(déclaratif, réseau partagé, dépendances entre services).

## Description du fichier compose.yml

Le fichier définit deux services :

- **`web`** : le service principal, construit à partir du `Dockerfile` du projet, expose le
  port 8080 en local et sert le site statique. Un `healthcheck` HTTP est configuré.
- **`monitor`** : un second service, basé sur l'image légère `curlimages/curl`, qui interroge
  périodiquement (toutes les 30 secondes) le service `web` via le réseau interne Docint
  (`catalog-net`) et journalise le code HTTP obtenu. Il illustre la coordination de plusieurs
  conteneurs (compétence C13) et amorce une logique de supervision minimale.

Les deux services communiquent via un réseau Docker dédié (`catalog-net`), ce qui montre que
Docker Compose gère automatiquement la résolution de nom entre conteneurs (`http://web:80/`
est résolu sans configuration manuelle).

## Simulation de mise à l'échelle (scaling)

Commande utilisée pour simuler un passage à plusieurs instances du service `web` :

```bash
docker compose up --build --scale web=2
```

Remarque technique : le mapping de port fixe (`8080:80`) et le `container_name` fixe doivent
être retirés du service `web` avant d'utiliser `--scale`, car un nom de conteneur figé et un
port hôte fixe empêchent tous les deux Docker Compose de créer plusieurs instances (un premier
essai sans cette modification a d'ailleurs échoué avec l'erreur `Docker requires each container
to have a unique name`).

Note honnête : ce test de scaling n'a pas été mené à son terme dans le temps imparti au projet.
La commande a été essayée une première fois et a révélé le problème de `container_name` ci-dessus
; la correction (suppression de `container_name` et du port fixe) est documentée mais n'a pas
encore été revalidée par une exécution réussie montrant deux instances `web` actives
simultanément. C'est assumé comme limite du rendu plutôt que comme preuve fournie.

## Pourquoi cette simulation ne remplace pas une orchestration de production

- Il n'y a **aucun mécanisme de répartition de charge** devant les deux instances : sans un
  reverse proxy ou un load balancer (ex: Traefik, Nginx en frontal, ou un service cloud dédié),
  rien ne redirige automatiquement le trafic entre `web-1` et `web-2`.
- Il n'y a **pas de redémarrage automatique intelligent en cas de panne d'un noeud** au sens
  d'un cluster : Docker Compose ne fait tourner les conteneurs que sur une seule machine hôte,
  il n'y a donc pas de haute disponibilité réelle (si la machine hôte tombe, tout tombe).
- Il n'y a **pas de planification automatique des ressources** (CPU/mémoire) entre plusieurs
  machines, contrairement à un orchestrateur comme Kubernetes qui répartit les pods sur un
  cluster de noeuds.
- Il n'y a **pas de mise à l'échelle automatique** en fonction de la charge réelle (autoscaling) :
  le nombre de répliques est fixé manuellement via `--scale`.

## Limites de Docker Compose dans ce contexte pédagogique

Docker Compose est un excellent outil pour le développement local et les démonstrations
pédagogiques de coordination de conteneurs, mais il n'est pas conçu pour piloter un
environnement de production multi-machines. Il ne gère ni la découverte de service à travers
plusieurs hôtes, ni la tolérance de panne au niveau infrastructure, ni les déploiements
progressifs (rolling updates, canary), fonctionnalités que l'on retrouverait dans Kubernetes ou
un service managé (ECS, Cloud Run, etc.).

## Lien avec la robustesse de la chaîne CI/CD

Même sans orchestrateur de production, la chaîne CI/CD mise en place ici reste robuste sur trois
points essentiels, qui sont justement ceux qui comptent le plus lors d'une montée en charge
réelle :

1. **Reproductibilité** : l'image est construite une seule fois à partir d'un `Dockerfile`
   versionné, ce qui garantit que chaque instance démarrée (2, 10 ou 100 répliques) exécute
   strictement le même code.
2. **Promotion d'un artefact identifié** : le digest immuable de l'image garantit qu'on ne
   déploie jamais une version incertaine ; que ce soit avec Docker Compose ou un vrai
   orchestrateur, la bonne pratique de promotion par digest reste identique.
3. **Traçabilité** : chaque publication et chaque promotion sont journalisées dans GitHub
   Actions, indépendamment du nombre d'instances qui consomment ensuite cette image.
