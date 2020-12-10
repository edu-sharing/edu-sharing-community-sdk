# Debug

- First of all you have to [build](../build/README.md) local docker images.

- Start up a debug-instance using local images with local artifacts by calling:

  ```
  ./rendering/deploy.sh debug <project-path> 
  ```       

  > If necessary, some [customization](../../../common/README.md#customization) can be made. 

- If there are changes:

  * within `<community-path>/src/main/php`  
    then you have to rebuild the local artifacts by calling:
  
    ```
    ./rendering/deploy.sh rebuild <community-path>
    ```       

  **IMPORTANT NOTES**:  
  
  * During your debugging session:
  
    - Don't run the `mvn clean` task within `<project-path>` 
      because all mounted artifacts inside the running debug-instance will be unmounted.
  
- Following endpoints are available for debugging purpose accessible from your local host:

  ```
  rendering-database (mysql)
  ```

- You can get all information for your debugging session by calling:

  ```
  ./rendering/deploy.sh info
  ```
