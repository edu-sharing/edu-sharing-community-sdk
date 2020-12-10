# Common

## Command line interface

- We provide a _Command Line Interface_ (CLI) in form of a bash shell-script 
  inside the root directory of this project 
  (and for [development](../development/README.md) purposes inside each subdirectory too).   
  
  Open a bash shell in the root directory of this project and 
  call this shell script without any parameter to list all possible options.   
  
  ```
  ./deploy.sh  
  ```  

## Customization

- You can start an instance without any customization. 
  If you have some troubles, see: [Troubleshooting](../troubleshooting/README.md).
  
  If necessary you can customize the deployment over environment variables.    
  You can specify these environment variables: 
    * explicit in your bash shell or
    * inside the config file `.env` which has to be located inside the directory
      where the [CLI](#command-line-interface) is located.     

        > We provide a sample file `.env.sample` as customization template too. 
          Feel free to copying it and uncomment specific environment variables.
          Inside the template can you find more details about all environment variables too. 

## Multi-instance support

- We provide the possibility to run multiple instances with _dedicated_ data volumes. 
  If you want to use this option, then you have to define a unique identifier for each instance
  by setting the environment variable `COMPOSE_PROJECT_NAME` first, like:

  ```
  COMPOSE_PROJECT_NAME="<instance-id>" ./deploy.sh [option] 
  ```  
    > **IMPORTANT:**   
      The environment variable `COMPOSE_PROJECT_NAME` can _ONLY_ be set explicitly in your bash shell.

## Show information
    
- You can show the current configuration by calling: 
  
  ```
  ./deploy.sh info 
  ```  

  or if you run multiple instances:

  ```
  COMPOSE_PROJECT_NAME="<instance-id>" ./deploy.sh info 
  ```  
