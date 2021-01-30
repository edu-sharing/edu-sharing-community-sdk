#set( $symbol_pound = '#' )
#set( $symbol_dollar = '$' )
#set( $symbol_escape = '\' )

# edu-sharing extension ${rootArtifactId} - deploy installer repository

Prerequisites
-------------

- PostgreSQL Server 12+
- Alfresco Community Platform 5.2.g
- Java SE Development Kit 1.8+ (<9)
- Apache Maven 3.6.3+
- Git SCM

Download
--------

0. Log in to our [artifact repository](https://artifacts.edu-sharing.com).

1. Download the installer artifact:

   * [releases](https://artifacts.edu-sharing.com/#browse/browse:extension-${rootArtifactId}-releases:org%2Fedu_sharing%2Fedu_sharing-extension-${rootArtifactId}-deploy-installer-repository)
   * [snapshots](https://artifacts.edu-sharing.com/#browse/browse:extension-${rootArtifactId}-snapshots:org%2Fedu_sharing%2Fedu_sharing-extension-${rootArtifactId}-deploy-installer-repository)

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
   
1. Check out the [repository-project](https://scm.edu-sharing.com/Repository/edu-sharing) outside of this project.
 
2. If you have switched on additional plugins (see below), 
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

   Then setting following environment variables:
                          
   ```
   export PLUGIN_CLUSTER_ENABLED="true"
   export PLUGIN_LOGIN_IDM_ENABLED="true"
   export PLUGIN_REMOTE_ENABLED="true"
   ```
   
   and check this by calling:
   
   ```
   ./deploy.sh plugins
   ```                         
 
3. Build installer artifact by calling:
  
   ```
   ./deploy.sh build <repository-project>
   ```    

   After that you can find the installer artifact inside the `target` subdirectory.
   
Installation
------------

1. Open a bash shell and go to the home directory of your Alfresco installation.

2. Clean up outdated libraries by calling:

   ```
   rm -f tomcat/lib/postgresql*
   rm -f tomcat/webapps/alfresco/WEB-INF/lib/hazelcast*
   ```

3. Unpack the [downloaded](#download) or [builted](#build) installer artifact. 

4. Initialize a git repo for your configuration by calling:
 
   ```
   pushd tomcat/shared
   git init
   git add .
   git commit -m "Initial config"
   popd
   ```

5. Deploy the Alfresco Module Packages (AMP) by calling:

   ```
   java -jar $ALF_HOME/bin/alfresco-mmt.jar install $ALF_HOME/amps/alfresco/1 $CATALINA_HOME/webapps/alfresco -directory -force
   java -jar $ALF_HOME/bin/alfresco-mmt.jar install $ALF_HOME/amps/alfresco/2 $CATALINA_HOME/webapps/alfresco -directory -force
   java -jar $ALF_HOME/bin/alfresco-mmt.jar install $ALF_HOME/amps/alfresco/3 $CATALINA_HOME/webapps/alfresco -directory -force
   java -jar $ALF_HOME/bin/alfresco-mmt.jar install $ALF_HOME/amps/edu-sharing/1 $CATALINA_HOME/webapps/edu-sharing -directory -force
   ```

6. Change the environment variables `CATALINA_OPTS` by calling:

   ```
   CATALINA_OPTS="-Dfile.encoding=UTF-8 $CATALINA_OPTS"    
   CATALINA_OPTS="-Dorg.xml.sax.parser=com.sun.org.apache.xerces.internal.parsers.SAXParser $CATALINA_OPTS"
   CATALINA_OPTS="-Djavax.xml.parsers.DocumentBuilderFactory=com.sun.org.apache.xerces.internal.jaxp.DocumentBuilderFactoryImpl $CATALINA_OPTS"
   CATALINA_OPTS="-Djavax.xml.parsers.SAXParserFactory=com.sun.org.apache.xerces.internal.jaxp.SAXParserFactoryImpl $CATALINA_OPTS"

   # only for plugin-cluster

   CATALINA_OPTS="-Dcaches.backupCount=1 $CATALINA_OPTS"
   CATALINA_OPTS="-Dcaches.readBackupData=true $CATALINA_OPTS"
   # with multicast-join
   CATALINA_OPTS="-Dcaches.join=multicast $CATALINA_OPTS"
   CATALINA_OPTS="-Dcaches.join.multicast.group=[multicast-addr] $CATALINA_OPTS"
   CATALINA_OPTS="-Dcaches.join.multicast.port=[multicast-port] $CATALINA_OPTS"
   # with tcpip-join
   CATALINA_OPTS="-Dcaches.join=tcpip $CATALINA_OPTS"
   CATALINA_OPTS="-Dcaches.join.tcpip.members=[ipaddr,ipaddr,] $CATALINA_OPTS"
   # with kubernetes-join
   CATALINA_OPTS="-Dcaches.join=kubernetes $CATALINA_OPTS"
   CATALINA_OPTS="-Dcaches.join.kubernetes.dns=[headless-service] $CATALINA_OPTS"

   export CATALINA_OPTS
   ```

7. Start the server by calling:
   
   ```
   ./alfresco.sh start
   ```
   
Update
------

1. Open a bash shell and go to the home directory of your Alfresco installation.

2. Stop the server by calling:
   
   ```
   ./alfresco.sh stop
   ```

3. Save your configuration by calling:
 
   ```
   pushd tomcat/shared
   git checkout master
   git add .
   git commit -m "Current config"
   git checkout -b update
   popd
   ```

4. Unpack the [downloaded](#download) or [builted](#build) installer artifact 
   into the home directory of your Alfresco installation. 

5. Merge changes into your configuration by calling:
 
   ```
   pushd tomcat/shared
   git add .
   git commit -m "New config"
   git checkout master
   git merge update
   git add .
   git commit -m "Updated config"
   git branch -d update
   popd
   ```

6. Deploy the Alfresco Module Packages (AMP) by calling:

   ```
   ./bin/apply_amps.sh -force
   ```

7. Start the server again by calling:
   
   ```
   ./alfresco.sh start
   ```
      
---
If you need more information, please consult our [edu-sharing community sdk](https://scm.edu-sharing.com/edu-sharing-community/edu-sharing-community-sdk) project.
