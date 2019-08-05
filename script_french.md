# Lightweight containers and fast build times - a Java example

Google distroless: https://github.com/GoogleContainerTools/distroless
Google Jib: https://github.com/GoogleContainerTools/jib
https://www.youtube.com/watch?v=H6gR_Cv4yWI
Spring Boot Docker: https://spring.io/guides/topicals/spring-boot-docker/

## Goals

- For beginners: explain what's a container, and that there are different ways to build containers
- For intermediate devs: open your eyes on how layering works and how you can get better at it
- If you're an app developper, you shouldn't think too much about containers when you can
  - Similar to CF push
  - You can also deploy to your entreprise-deployed Kubernetes, without even docker installed !

## Talk notes

### Intro

Bonjour à tous !

Je m'appelle Daniel Garnier, et je suis Software Engineer chez Pivotal Labs. Ca fait quelques années que je travaille dans l'industrie logicielle, et j'ai pu voir différent niveaux de maturité d'entreprises, en termes de pratiques.

Chez Labs, on pousse nos clients à livrer en production aussi souvent que possible. Plusieurs fois par semaine, plusieurs fois par jour même ! Et pour faire ça, il y a un certain nombre de prérequis. Par exemple, il faut une grande confiance dans les changements que l'on shippe. C'est pour ça qu'on fait du TDD, Test-Driven-Development - entre autres raisons : on a plus confiance dans le fait qu'on ne casse rien quand on fait des changements.

Il faut également avoir une des pratiques et des outils qui nous permettent d'aller vite, et nous permettent d'avoir un certain ... déterminisme, dans nos déploiements. Par exemple, on fait de l'intégration et du déploiement continus, pour éviter d'avoir 15 étapes manuelles pour déployer. J'ai travaillé dans des entreprises où on déployait tout à la main. C'était long, une heure pour faire un déploiement complet (smoke tests compris) - donc on n'avait pas envie d'en faire un par jour. Et c'était sujet à erreur: "oh, oups, j'ai oublié de faire un backup de la base de données, et je viens de péter la prod."

Dans les outils qui nous permettent d'avoir un certain déterminisme dans nos process de déploiements, on a Cloud Foundry. Mais aujourd'hui, je ne suis pas là pour vous parler de PCF - j'ai plein de mereveilleux collègues à côté qui vous en parleront en long, en large, et en travers. Parfois, vous n'avez pas de PCF déployé chez vous. Ou alors vous avez des projets perso. Ou alors votre entreprise vous demande d'utiliser Kubernetes comme plateforme de déploiement.

Et dans ce cas là, vous allez utiliser des containers ! Vous, le développeur applicatif, pour déployer votre backend, vous allez devoir faire un container avec votre appli dedans...

Et comme on parle beaucoup de Spring ici, on va prendre comme exemple une appli Spring, qu'on ne présente plus: la Pet Clinic. Tout le monde connaît ?

Avant de commencer, rendons à Dave Syers ce qui est à César - tout ce talk se retrouve plus ou moins dans un article de blog qu'il a écrit, et qui a été décliné comme guide Spring.

---

C'est la Chevauchée Fantastique qui commence. Surtout pour ceux qui n'y connaissent rien. Qui n'a jamais utilisé des containers faits main en production, dans la salle ? Disons, est-ce que vous avez déjà écrit un Dockerfile, et vous avez déjà déployé le container produit quelque part en production ?

---

Pour ceux qui ne l'ont jamais fait, voilà à quoi ça ressemble. Pour ceux qui l'ont déjà fait - ils ont probablement fait ça au début. Je prends une image de base, que je connais - disons Ubuntu. J'installe toutes les dépendances nécessaires, je copie mon appli et BOUM, j'ai un container. Ce n'était pas si difficile.

Quelqu'un voit le plus gros problème ?

Certes, c'est gros / pas secure, mais ce n'est pas mon plus gros problème pour l'instant.

Oui ! Je dois manager toutes cette folie de dépendance à la main... Vous vous rappelez votre premier serveur ? Où vous empiliez des trucs dans des répertoires bizarres, où il y avait 4 versions de la même appli, etc ? Ben c'est un peu le même esprit.

Retournons sur Google, et trouvons une meilleure solution.

---

Après 4 minutes de Googlisation frénétique, j'entends parler de ces images de base, openjdk. Et si je les utilise, c'est plus simple, et je n'ai pas ce management manuel à faire. Super, non ?

Quel est le problème avec cette image ?

Oui, c'est gros. Plus de 300MB... Donc si mon workflow c'est build+push, combien de temps ça prend ? C'est long.

On peut mieux faire ?

---

Oui ! Une Alpine. Bonne idée. C'est quoi une image Alpine ? C'est une base de Busybox - une distro minuscule, faire pour être déployée sur du hardware embarqué, donc optimisé pour être tout petit. Par dessus, ils ont mis un package manager pour facilement installer du soft, et c'est tout.

Une Alpine, toute nue, sans rien, ça fait moins de 5MB en terme de taille d'image. Donc on peut utiliser une openjdk:8-jre-alpine, qui fait moins de 100MB, qui suffit pour le runtime Java. Je package mon appli dedans, et j'ai une "petite" image à 130Mo. Je suis plutôt content.

On a beaucoup parlé de taille, mais on a assez peu parlé de sécurité... Si je veux avoir une surface d'attaque plus petite qu'une Alpine, je peux faire comment ?

---

Ahhh, je suis surpris que quelqu'un connaisse. Oui, il y a d'autres possibilités. En fait docker, c'est surtout un truc qui nous permet d'isoler des process. Certes il y a un espèce de système de fichiers, on en reparlera, mais l'important c'est qu'à la fin, ça run un ou des process. Dans le cadre d'une appli Java, on veut surtout faire tourner UN process, et c'est java, correct ? Donc embarquer un package manager, comme le fait Alpine, c'est peut-être un peu overkill, non ?

Jetons un oeil à ce qu'il y a dans une Alpine, juste pour se faire une idée. On peut utiliser un petit outil qui s'appelle **dive**.

Ca fait beaucoup d'éxécutables... Est-ce que je vais vraiment avoir besoin de ça quand je fais tourner mon appli java ? Probablement pas. Et si j'ai un package manager je vais être tenté d'installer des trucs, je vais me connecter en SSH, bref, pas une bonne idée.

Pour éviter ces vecteurs d'attaque supplémentaires, je vous propose une image qui n'a rien de tout ça. C'est une image faite par Google, qui s'appelle une Distroless ... Elle est créée from scratch, il n'y a QUE le minimum pour faire tourner java dedans. En regardant avec dive, on se fait une meilleure idée.

La sémantique est un peu différente mais l'esprit du dockerfile est le même.

---

Faisons une pause dans notre grande aventure de l'image parfaite, et parlons de ce qu'est un container. On envisage parfois les containers comme des machines virtuelles. Pourquoi ? Tout simplement parce que ça a un peu les mêmes buts, à savoir, reproducibilité, et isolation.

Reproducibilité, c'est à dire que je peux faire un gros package applicatif, vous l'envoyer, et quand vous le lancez, ça marche, sans avoir de problèmes de dépendances par exemple.

Isolation, pour que je puisse en faire tourner plusieurs en parallèle sur le même matériel, sans que les applis se voient ou interfèrent les unes avec les autres.

Les Machines Virtuelles, ça utiliser un hyperviseur, et ça fait semblant d'être une machine complète, avec de l'isolation au niveau de l'hyperviseur. Chacune a son propre "disque virtuel", et chacune vit dans son petit monde en pendant être déployé sur du hardware dédié. Elles intéragissent avec l'hyperviseur un peu comme elles interagiraient avec du hardware. Donc, techniquement, je peux faire tourner plusieurs OS en parallèle sans problème.

Les containers, à l'inverse, n'ont pas besoin de surcouche: ils accèdent directement au kernel du host. Petit apparté: c'est pour ça qu'on n'a pas de container Windows sur du Linux, alors qu'on peut avoir des VM windows sur du Linux.

Bref, on utilise le kernel du système hôte. Et l'isolation est réalisée grâce à des primitives d'isolation et de permissions Linux, comme les cgroups et les namespaces, qui régissent ce que le process a le droit de voir comme autre process, par exemple, ou à quelles ressources il a accès. On "trompe" un peu le process, en lui montrant une vue partielle de l'hôte.

Donc en fait, ce que je suis en train de dire, c'est que les "containers", ce ne sont que des process, isolés les uns des autres ?

---

Pas tout à fait ! Ces process ont des dépendances sur des fichiers. Par exemple, le binaire pour lancer le process. Les librairies linkées dynamiquement, utilisées par ce process - on peut penser à glibc. Les fichiers de configuration. Les certificats SSL auxquels le process va faire confiance. Et, en gros, tous les fichiers dont il va avoir besoin pour faire des syscalls au kernel. Globalement, si vous voulez un ubuntu, vous aurez ... presque tous les fichiers distribués avec Ubuntu, moins le kernel, les drivers, etc.

Et il faut un moyen de distribuer ces fichiers - ce n'est pas comme une VM, on n'a pas de disque virtuel à distribuer, par exemple. C'est là qu'un système assez malin a été pensé, le système d'image. Une image contient des tarballs, qui représentent différentes "couches" du système de fichier. Par exemple, j'ai un système de fichier de base avec le répertoire "fruits". Je peux ajouter une couche supplémentaire avec un truc modifié dans "fruits", et un nouveau répertoire veggies, qui contiennent les fichiers que vous voyez - et les couches vont se superposer. Chaque couche est ensuite compressée dans une tarball, et l'ensemble de ces couches, plus la configuration sur comment faire tourner l'image, plus des métadonnées - c'est ça, une image.

---

Un autre point important: à chaque fois que, dans un dockerfile par exmple, je fais "ADD", ou "COPY", ou "RUN", ça créée une layer.

Ensuite, les layers sont "empilées", ou plutôt fusionnées, pour faire ce qu'on a vu sur le slide précédent.

---

Pourquoi je vous ai parlé de tous ces détails ? On était juste en train de construire notre image, nous ! Revenons à nos moutons. Si on jette un oeil à l'image ci-dessus avec l'outil dive, on voit un petit problème subtil... Et ça a plus à voir avec mon process de build, voire ma connexion internet, qu'avec l'image en elle-même.

Une idée de ce que je veux dire ?

---

Là, le problème est plus "subtil"... Si je pousse cette image sur dockerhub, ça me prend 30 secondes la première fois. Dès que je fais un changement, ça vient me prendre un peu de temps, disons 30 secondes. Plus l'appli est grosse, plus ça va être long, et plus la bande passante utilisée va être importante. Ce n'est pas forcément crucial, mais ça peut dépendre de combien d'images vous faites par jour, de la qualité de votre réseau, etc.

Et ça nous donne une bonne excuse pour reparler des layers. Que se passe-t-il dans notre cas ? Tout d'abord, on empile les images de base, et ça, on aura du mal à faire mieux. Mais par dessus, on recrée une layer, qui fait, dans notre cas une quarantaine de méga octets. Et quand je change une ligne, je dois recréer toute la layer applicative.

Dans notre cas, ce n'est pas très intéressant - la seule chose qui change, c'est mon code, pas toute la machinerie Spring et Boot. Ça, ça reste, pas la peine de la mettre à jour. Donc on peut imaginer une stratégie plutôt du genre:

- Mes dépendances (changent peu fréquemment)
- Mon code applicatif (change plusieurs fois par jour)

On peut réaliser ça en deux étapes. L'idée est de builder notre jar, puis d'en extraire la substantifique moëlle - d'un côté, les briques de base de Spring, et de l'autre notre code à nous. On copie d'abord les dépendances, dans BOOT-INF/lib, puis on copie notre code applicatif. Si on y jette un oeil, on se rend compte que notre applicatif ne prend plus que quelques dizaines de kilo-octets - un peu plus parce qu'il y a des fonts.

---

Plusieurs choses très intéressantes avec ce procédé:

1. Je réutilise les layers de base entre plusieurs builds - comme rien ne change dans mes dépendances, docker est suffisamment malin pour réutiliser les couches déjà présentes quand je fais un petit changement. Gain de place en local, sur serveur, et gain de temps et de bande passante à l'upload de votre image.
2. Ce que je vous présente ici, c'est indépendant du langage. Imaginez vous avez une appli NodeJS - vos node_modules changent moins souvent que le code de l'app ; vous pouvez donc les mettre dans une layer "en-dessous".

---

Ok, là, ça commence à être difficile de faire mieux, au moins en terme d'image buildée. Quelqu'un a quelque chose à proposer ? Peut-être en terme de process ? D'outillage ?

On peut utiliser une feature récente de docker, les 'multi-stage builds'. C'est l'idée d'enchaîner plusieurs étapes, en utilisant des containers intermédiaires. En fait ça s'approche beaucoup de ce que des systèmes de CI/CD font aujourd'hui. Le Dockerfile ressemble à ça, avec une étape de build puis un Dockerfile qui utilise les outputs de la première étape.

Alors ça c'est un peu plus robuste et indépendant du système sur lequel vous fonctionnez. Une mini CI-CD sur votre machine, si vous voulez ... attention par contre, plusieurs caveat.
Ce n'est pas un vraie système de CI, donc ne le considérez pas comme tel.

Ensuite, si votre but c'est d'avoir du temps de build rapide, là, il y a zéro cache - pas de cache de build maven/gradle, et même pas de cache d'artefacts - donc faut tout télécharger à chaque fois...

On peut également, ajouter du cache, mais il faut un peu changer le dockerfile, et en plus c'est une feature expérimentale chez docker, donc il faut un flag spécial quand vous lancez le client... Bref, ca devient un peu compliqué. En plus là vous avez plusieurs images à maintenir en fait ...

---

Bon. C'est pas mal, comme overview, on a exploré un peu tout ce qu'on pouvait faire comme containerisation explicite. Comme la mode semble être plutôt à Docker, j'ai basé mes exemples sur des dockerfiles, mais on pourrait imaginer bundler nos images avec rkt par exemple.

Qu'est-ce qui nous reste à explorer ? Là, il faut commencer à sérieusement penser en dehors de la boîte si on souhaite aller plus loin. Et dans notre cas, la boîte, c'est le dockerfile - après tout nous, ce qu'on veut vraiment c'est produire une image, un container. Peu importe comment c'est produit. Et on a déjà un système de build sous la main, que ce soit maven ou gradle.

C'est exactement ce que des ingénieurs chez google se sont dit, en inventant un plugin maven/gradle qui s'appelle Jib.

---

Jib, c'est un plugin de vos systèmes de build classiques, maven ou Gradle. Pas de Dockerfile, il suffit d'intégrer le plugin, d'être loggué sur Dockerhub ou sur le registry de votre de choix, et boum, vous avez un goal supplémentaire pour builder votre projet et le pusher sur Dockerhub.

Ca ressemble à ça dans mon `pom.xml`, et je n'ai plus qu'à faire `mvn jib:dockerBuild`, si je veux builder avec mon daemon docker local. Sinon, si je n'ai même pas docker installé en local, je peux utiliser la deuxième option `mvn jib:build`, qui est très intéressante: ça builde l'image sans utiliser docker, et ça push l'image directement sur Dockerhub, ou sur le registry de votre choix.

---

Enfin, peut-ête un petit mot sur les Cloud-Native buildpacks, je ne sais pas si vous en avez entendu parler. A la base c'est une initiative soutenue par Heroku et Pivotal.

Un buildpack, c'est quoi ? Pour un PaaS, c'est un ... truc ..., imaginez c'est une espèce de fonction, qui prend votre code source, et le transforme suffisamment, notamment en le compilant, pour qu'il tourne sur le PaaS.

Ainsi, l'expérience d'un dev sur Heroku, c'est juste de pusher du code source sur une branche sur un repo Git hosté par Heroku. Et quand Heroku détecte le push, il applique le buildpack et déploie l'artéfact. Sur Cloud Foundry, quand je fais "cf push", j'ai juste besoin de pusher mon code, pas nécessairement les artefacts compilés. Puis CF détecte le langage utilisé, compile les resources, reconfigure mon appli si nécessaire, et la déploie.

Les Cloud-Native buildpack c'est la même chose, mais en utilisant des containers natifs, compatibles runC, et l'output c'est un container !

Alors attention c'est un gros container, avec plein de trucs dedans ... Disons que l'état d'esprit, c'est plutôt: Comment on va abstraire l'étape de build pour les devs. Disons que la vision, c'est que demain, pour déployer sur l'orchestrateur de votre choix, vous n'ayiez plus à vous soucier de TOUT ce que je viens de dire ; c'est quelqu'un d'autre qui en aura la responsabilité, et qui pourra faire les opérations nécessaires - par exemple, elle pourra maîtriser les updates de sécurité de TOUTES les images déployées sur les orchestrateurs qu'il fournit.

---

Demo time ! Enfin, ça suffit les slides.

**TODO**

- Demo jib, avec un petit changement dans la banner par exemple
- Demo pack-build

---

## Rough outline

- Who am I
- What do I do about containers

? What's a container
? How layers work
? Showing dive

- Different steps

  - Ubuntu or debian, install open jdk, add your spring app
    - Seems like a lot of work, doesn't it ?
  - Openjdk, same as stretch, but the heavy lifting of installing the jdk has been done for you
    - Okay, simpler but quite fat
  - Openjdk-alpine, same as openjdk, but much more lightweight
    - Better ! However the build and push can be a bit slow, right ?
  - HIATUS: the layers !
  - Put dependencies first, they change less often then your app code
    - The push becomes faster

- So now we have a thinner image, that updates faster when you push it

- You can get even thinner and have a smaller attack surface with distroless images

- Also, you shouldn't be thinking about containers too much

## Distroless notes

- Slower to upload / download
- Larger scope for CVE / Provenance
- Google deploys this way
- Docker -> lightweight VM, isolated environment to run you app
  - "statically linking your app at the kernel level", using the VM file system
  - Alpine: busybox + package manager
  - Busybox: small distro for poking around an embedded system
- Henry Ford's "faster horses" ~= smaller distros
- App needs
  - Compiled source code
  - Dependencies: libs, assets
  - The app's language runtime libc, JRE, node
- docker_build -> bazel build tool rules to build and publish images
- cross-compilation of docker images
- look github.com/google-cloud-platform/distroless

## Jib notes

- Containers are kind of jars, "write once, run anywhere"
- Pet clinic

- Image journey

  - Ubuntu
    - complicated
  - Openjdk:8
    - fat
  - Openjdk:8-alpine
    - still slow
  - Add .dockerignore
    - not send everything to the docker daemon
  - Layers !
    - One for dependencies
    - One for classes
  - Pom xml

- Image "containerizing with docker"

- Pet clinic demo

- Goals

  - Pure Java
  - Fast
  - Reproducible

- Container is :

  - Layers, tarballs that compose the container's file system
  - Configuration
  - Manifest

- Remove metadata to have reproducible builds

- Hot swap on Kubernetes with Kubernetes dev ... O_O

## Notes / todo

- What's Alpine, really ?
  - Lightweight linux on MUSL c (not glibc)
- Multi-stage builds ?
  - bof
- Cloud native builpacks
- Performance benchmarks
- Try rkt ?
