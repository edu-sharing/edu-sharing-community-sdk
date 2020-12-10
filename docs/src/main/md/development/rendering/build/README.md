# Debug

- Start up a debug-instance with your [source code](../prerequisites/README.md#source-code) by calling:

  > **IMPORTANT**:  
    Don't forget to [start up](../../repository/startup/README.md) a repository instance before. 
    If you [clean up](../../repository/cleanup/README.md) the repository instance later, then you have to [clean up](../cleanup/README.md) this instance too. 

  ```
  ./rendering/deploy.sh debug <project-path> 
  ```       

  > If necessary, some [customization](../../../common/README.md#customization) can be made. 

- Following artifacts from your rendering project will be mounted directly  
  into this running debug-instance:
  
  ```
  <project-path>/target/php/* -> /var/www/html/esrender/*
  ``` 

  If you call `mvn compile` within your rendering project,  
  then the artifacts above will be updated inside the running debug-instance.   
  
  > If you are using JetBrains PhpStorm, you can configure a file watcher 
    under `Preferences > Tools > File Watchers`.    
  > This file watcher should: 
  >   * track all files within `src/main/php` recursively (all file types)   
  >   * trigger program: `mvn` with argument: `compile` under working directory: `$ProjectFileDir$`

  **IMPORTANT NOTES**:  
  
  * During your debugging session:
  
    - Don't run the `mvn clean` task within `<project-path>` 
      because all mounted artifacts inside the running debug-instance will be lost.
  
- Following endpoints are available for debugging purpose accessible from your local host:

  ```
  rendering-database (mysql)
  ```

- You can get all information for your debugging session by calling:

  ```
  ./rendering/deploy.sh info
  ```
