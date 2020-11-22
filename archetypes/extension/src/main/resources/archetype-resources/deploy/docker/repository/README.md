#set( $symbol_dollar = '$' )
# edu-sharing extension ${rootArtifactId} - deploy docker repository

Prerequisites
-------------

- Docker Engine 19.03.0+
- Docker Compose 1.27.4+ 
- Apache Maven 3.6.3+
- Java SE Development Kit 1.8+ (<9)

Installation
------------

0. Log in to our docker registry by calling:

   ```
   docker login ${rootArtifactId}.docker.edu-sharing.com
   ```

1. Start up an instance from remote docker images by calling:

   ```
   ./deploy.sh start
   ```

2. Stream out the log messages by calling:

   ```
   ./deploy.sh logs
   ```

3. Shut down the instance by calling:

   ```
   ./deploy.sh stop
   ```
  
4. Clean up all data volumes by calling:

   ```
   ./deploy.sh purge
   ```
    
Build
-----

0. Add your credentials for our artifact repository in `${symbol_dollar}HOME/.m2/settings.xml`:

   ```
   <settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                             https://maven.apache.org/xsd/settings-1.0.0.xsd">
     <servers>
   
       <server>  
         <id>edu-sharing.extension.${rootArtifactId}.releases</id>
         <username> ... </username>
         <password> ... </password>
       </server>
       <server>
         <id>edu-sharing.extension.${rootArtifactId}.snapshots</id>
         <username> ... </username>
         <password> ... </password>
       </server>  
   
     </servers>
   </settings>
   ```

   If you have switched on additional plugins (see below), 
   then you have to add your credentials for each plugin in `${symbol_dollar}HOME/.m2/settings.xml` too:
   
   ```
      <server>  
        <id>edu-sharing.plugin.cluster.releases</id>
        <username> ... </username>
        <password> ... </password>
      </server>
      <server>
        <id>edu-sharing.plugin.cluster.snapshots</id>
        <username> ... </username>
        <password> ... </password>
      </server>  
   
      <server>  
        <id>edu-sharing.plugin.logineo-idm.releases</id>
        <username> ... </username>
        <password> ... </password>
      </server>
      <server>
        <id>edu-sharing.plugin.logineo-idm.snapshots</id>
        <username> ... </username>
        <password> ... </password>
      </server>  
   
      <server>  
        <id>edu-sharing.plugin.remote.releases</id>
        <username> ... </username>
        <password> ... </password>
      </server>
      <server>
        <id>edu-sharing.plugin.remote.snapshots</id>
        <username> ... </username>
        <password> ... </password>
      </server>  
   ```      

1. Check out the [repository-project](https://scm.edu-sharing.com/Repository/edu-sharing) outside of this project.
 
2. If necessary, switch on additional plugins by setting following environment variables:
                          
   ```
   export PLUGIN_CLUSTER_ENABLED="true"
   export PLUGIN_LOGIN_IDM_ENABLED="true"
   export PLUGIN_REMOTE_ENABLED="true"
   ```
   
   and check this by calling:
   
   ```
   ./deploy.sh plugins
   ```                         
 
3. Build local docker images by calling:                        

   ```
   ./deploy.sh build <repository-project>
   ```
   
Test
----

1. [Build](#build) local docker images first.
      
2. Start up an instance from local docker images by calling: 

   ```
   ./deploy.sh test
   ```

3. Request all necessary information by calling:

   ```
   ./deploy.sh info
   ```
   
   and stream out the log messages by calling:
    
   ```
   ./deploy.sh logs
   ```
   
4. Shut down the instance by calling:

   ```
   ./deploy.sh stop
   ```
  
5. Clean up all data volumes by calling:

   ```
   ./deploy.sh purge
   ```
   
Debugging
---------

1. [Build](#build) local docker images first.
      
2. Start up an instance from local docker images that has mounted the local artifacts by calling: 

   ```
   ./deploy.sh debug 
   ```

3. Request all necessary information by calling:

   ```
   ./deploy.sh info
   ```
   
   and stream out the log messages by calling:
    
   ```
   ./deploy.sh logs
   ```
   
4. If you have made changes then you can rebuild and reload the local artifacts by calling:

   * for changes inside `<repository-project>/Backend/alfresco` or `repository/Backend/alfresco`: 
   
     ```
     ./deploy.sh rebuild-alfresco
     ```
     
     If you already built it, then you just have to trigger reloading by calling: 
      
     ```
     ./deploy.sh reload-alfresco
     ```
   
   * for changes inside `<repository-project>/Backend/services` or `repository/Backend/services`: 
   
     ```
     ./deploy.sh rebuild-services
     ```
     
     If you already built it, then you just have to trigger reloading by calling: 
      
     ```
     ./deploy.sh reload-services
     ```

   * for changes inside `<repository-project>/config/src/main/resources/org` or `repository/config/src/main/resources/org`:

     ```
     ./deploy.sh rebuild-config
     ```
      
   * for changes inside `<repository-project>/Frontend` or `repository/Frontend/src/main/ng`:

     ```
     ./deploy.sh rebuild-frontend
     ```     

     > You have to start the Angular dev server once at the beginning by calling:        
     > ```
     > pushd repository/Frontend/src/generated/ng
     > ./node/npm run start
     > popd
     > ```     
     > and use the special URL shown (instead of the usual one).  

5. Shut down the instance by calling:

   ```
   ./deploy.sh stop
   ```
  
6. Clean up all data volumes by calling:

   ```
   ./deploy.sh purge
   ```
---
If you need more information, please consult our [edu-sharing community sdk](https://scm.edu-sharing.com/edu-sharing-community/edu-sharing-community-sdk) project.
