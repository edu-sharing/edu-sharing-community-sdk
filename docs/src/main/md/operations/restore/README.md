# Restore 
 
- We only provide cold restores at the moment.  

    > **IMPORTANT:**     
      You have to [shut down](../shutdown/README.md) the instance and [cleanup](../cleanup/README.md) all data volumes before. 

- Restore a backup by calling: 

    > If you run multiple instances, see [Common](../../common/README.md#multi-instance-support).
      
    ```
    ./deploy.sh restore <backup_directory> 
    ```
