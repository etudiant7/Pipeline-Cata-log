# =========================================================
# Projet CICD - EC06 - Etudiant 7
# Dockerfile - Image Nginx servant un site statique
# =========================================================
# Image de base officielle, figee sur une version stable et legere (alpine)
# pour limiter la surface d'attaque et accelerer le build/publication.
FROM nginx:1.27-alpine

# Metadonnees de tracabilite (bonne pratique de securite DevOps : identifier
# l'origine et le responsable de l'image publiee dans GHCR).
LABEL org.opencontainers.image.title="site-catalog" \
      org.opencontainers.image.description="Site statique Catal-Log - Projet CICD EC06" \
      org.opencontainers.image.authors="Etudiant 7" \
      org.opencontainers.image.source="https://github.com/etudiant7/projet-cicd-ec06-etudiant7"

# Nginx tourne par defaut avec un utilisateur non privilegie sur l'image alpine
# (utilisateur "nginx"). On le rend explicite pour la fiche securite.
# Suppression de la page d'accueil par defaut fournie par l'image officielle.
RUN rm -rf /usr/share/nginx/html/*

# Copie du site statique dans le repertoire servi par Nginx.
COPY site/ /usr/share/nginx/html/

# Port expose par le conteneur (documentation ; ne remplace pas -p au run).
EXPOSE 80

# Verification de sante du conteneur : utilisee localement et en test
# manuel. Le test automatise en CI reste un appel HTTP explicite (voir
# 01-ci.yml) qui est plus fiable dans le contexte des runners GitHub.
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget -q -O- http://localhost:80/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
