#set( $symbol_pound = '#' )
#set( $symbol_dollar = '$' )
#set( $symbol_escape = '\' )

# edu-sharing extension ${rootArtifactId} - deploy docker rendering

Prerequisites
-------------

- Docker Engine 19.03.0+
- Docker Compose 1.27.4+ 
- Apache Maven 3.6.3+

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

1. Check out the [rendering-project](https://scm.edu-sharing.com/edu-sharing/rendering-service) outside of this project.
    
2. Build local docker images by calling: 
                                                    
   ```
   ./deploy.sh build <rendering-project>
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
      
2. Start up an instance from local docker images that has mounted local artifacts by calling: 

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

   * for changes inside `<rendering-project>/src/main/php`: 

     ```
     ./deploy.sh rebuild
     ```
   
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
