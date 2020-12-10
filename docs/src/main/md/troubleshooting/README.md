# Troubleshooting

- `Bind for <...>:8100 failed: port is already allocated`  

  * Reason: The default network port 8100 used by repository-service is already in use.  
   
  * Solution: You have to switch to another free network port (e.g. 8101) 
    by setting the environment variables `REPOSITORY_SERVICE_PORT_HTTP`.   

- `Bind for <...>:9100 failed: port is already allocated`  

  * Reason: The default network port 9100 used by rendering-service is already in use.  
   
  * Solution: You have to switch to another free network port (e.g. 9101)
    by setting the environment variables `RENDERING_SERVICE_PORT_HTTP`.   

- `The POM for com.sun.xml.bind:jaxb-...:jar:2.2.11 is invalid`

  * Reason: Artifacts from group `com.sun.xml.bind` are not includes in Java 9 or higher anymore.  
   
  * Solution: Check your java version, we only support Java 8 at the moment.    
