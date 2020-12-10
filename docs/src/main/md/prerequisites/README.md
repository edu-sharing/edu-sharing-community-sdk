# Prerequisites

## Docker Runtime

- Install Docker Desktop for Windows / MacOS [(see)](https://www.docker.com/get-started) 
  or if already happened check for updates.    

  For linux platforms you have to install:   

    * Docker Engine [(see)](https://docs.docker.com/engine/install)   

      >  Check your docker version by calling: `docker version` which has to be 19.03.12 or later.  

    * Docker Compose [(see)](https://docs.docker.com/compose/install)    
  
      >  Check your docker-compose version by calling: `docker-compose version` which has to be 1.27.4 or later.     

- To start an instance on your local environment
  your docker engine should have a minimum of 4 GB Total Memory.
    
    > Check "Total Memory" by calling: `docker info`. 
      If necessary, you should increase the total memory size of your docker engine. 
      For Docker Desktop, go to `Preferences > Resources > Advanced > Memory`.

## Bash shell

- We provide only bash scripts at the moment.  
  
  That's way you need a bash shell on your local environment 
  which is included in MacOS and many other linux distributions.

    > For Windows: Install [Windows-Subsystem for Linux](https://docs.microsoft.com/windows/wsl/)
      or [Git for Windows](https://git-scm.com/download/win).