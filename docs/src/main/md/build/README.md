# Build

## Prerequisites

- Please check the [prerequisites](../prerequisites/README.md) first.
 
### Java SE 8

- Install Java SE 8 Development Kit [(see)](https://www.oracle.com/java/technologies/javase/javase-jdk8-downloads.html).  

  > Check your java version by calling: `java -version` which has to be `1.8` or higher.

  > **IMPORTANT:**  
    We only support Java 8 at the moment. Please _DON'T_ install Java 9 or higher.
 
### Apache Maven

- Install Apache Maven [(see)](http://maven.apache.org/install.html). 

  > Check your java version by calling: `mvn -version` which has to be `3.6.3` or higher.

  > **IMPORTANT:**  
    Please check the java version used by maven too. It will also be displayed below the maven version.  
     
  > The java version must be `Java 8` and _NOT_ any higher version. 
    If necessary, define a global environment variable `JAVA_HOME` 
    with the path to the home directory of the [Java SE 8 Development Kit](#java-se-8).     

## Build artifacts

  * Run `mvn clean package` to build the docker artifacts.
