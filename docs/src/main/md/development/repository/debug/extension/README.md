# Debug extension

## Backend side 
  
- First of all you have to [build](../../build/README.md) local docker images.

- Start up a debug-instance using local images with local artifacts by calling:

  ```
  ./repository/deploy.sh debug <community-path> <extension-path>
  ```       

  > If necessary, some [customization](../../../../common/README.md#customization) can be made. 
  
- If there are changes:

  * within `<community-path>/Backend/alfresco` or `<extension-path>/Backend/alfresco`  
    then you have to rebuild the alfresco services by calling:
  
    ```
    ./repository/deploy.sh rebuild-alfresco <community-path> <extension-path>
    ```       

    > If you've already built the artifacts,
      then all you have to do is reloading the alfresco services by calling: 
    > ```
    > ./repository/deploy.sh reload-alfresco 
    > ```       

  * within `<community-path>/Backend/services` or `<extension-path>/Backend/services`  
    then you have to rebuild the backend services by calling:
  
    ```
    ./repository/deploy.sh rebuild-services <community-path> <extension-path>
    ```       

    > If you've already built the artifacts,
      then all you have to do is reloading the backend services by calling: 
    > ```
    > ./repository/deploy.sh reload-services 
    > ```       

  * within `<extension-path>/config/target/classes`
    then you have to reload the services by calling:
  
    ```
    ./repository/deploy.sh reload-alfresco
    ./repository/deploy.sh reload-services
    ```       
           
  **IMPORTANT NOTES**:  
  
  * During your debugging session:
  
    - Don't run the `mvn clean` task,  
      because all mounted artifacts inside the running debug-instance will be unmounted.  

    - Don't run any `mvn` task within `<extension-path>/config`,  
      because current configurations can be overwritten with default settings.       
  
- Following endpoints are available for debugging purpose accessible from your local host:

  ```
  repository-database       (psql)
  repository-search-elastic (http)
  repository-search-solr4   (http, jpda)
  repository-service        (http, jpda)
  ```

- You can get all information for your debugging session by calling:

  ```
  ./repository/deploy.sh info
  ```

- After that you can start additional services too, like:

  *  [rendering](../../../rendering/startup)       

## Frontend side

- Jump to your [source code](../../prerequisites/README.md#source-code) and start the "Angular dev server" by calling:  

  ```
  pushd <extension-path>/Frontend/src/generated/ng
  npm run start
  popd
  ```       

  Now you can debug the frontend side over `http://localhost:4200` [(see)](https://code.visualstudio.com/docs/nodejs/angular-tutorial#_debugging-angular).  
   
- All request to the backend side will be forwarded by the Angular dev server
  based on `<extension-path>/Frontend/src/generated/ng/proxy.docker.json` ([see](https://angular.io/guide/build#proxying-to-a-backend-server)).  
  
  > Don't forget to start up an [backend-instance](../../startup) before.
