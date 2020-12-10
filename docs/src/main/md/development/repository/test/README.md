## Test

- First of all you have to [build](../build/README.md) local docker images.

- Start up a test-instance using local docker images with build-in artifacts by calling:

  ```
  ./repository/deploy.sh test 
  ```       
  > If necessary, some [customization](../../../common/README.md#customization) can be made. 

- After that you can start additional services too, like:

  *  [rendering](../../rendering/startup)       
