# Build community

- Build local docker images for [sources](../../prerequisites/README.md#source-code) by calling:

  ```
  ./repository/deploy.sh build <community-path> 
  ```       
  
  Optionally you can specify a relative path to a submodule by calling:
  
  ```
  ./repository/deploy.sh build <community-path> [<submodule-path>] 
  ```       
   
  For instance, you can build backend services only by calling:   
 
  ```
  ./repository/deploy.sh build <community-path> Backend 
  ```       
