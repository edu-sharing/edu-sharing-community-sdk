# Startup

- Start an instance by calling:

    > If you run multiple instances, see [Common](../../common/README.md#multi-instance-support).

  ```
  ./deploy.sh start 
  ```  
    
    > **IMPORTANT:**   
      If you want to run multiple instances in parallel, 
      then you have to define unique identifier [(see)](../../common/README.md#multi-instance-support) and unique network ports for each instance [(see)](../../troubleshooting/README.md):  
    > ```
    > COMPOSE_PROJECT_NAME="instance-0" \
    > REPOSITORY_SERVICE_PORT_HTTP="8100" \
    > RENDERING_SERVICE_PORT_HTTP="9100" \
    > ./deploy.sh start 
    > 
    > COMPOSE_PROJECT_NAME="instance-1" \
    > REPOSITORY_SERVICE_PORT_HTTP="8101" \
    > RENDERING_SERVICE_PORT_HTTP="9101" \
    > ./deploy.sh start 
    > ```  
    > Please check your docker engine has enough total memory, because each instance needs a minimum of memory, 
      see: [Docker runtime](../../prerequisites/README.md#docker-runtime) 

- Request the HTTP-URL and credentials by calling:

    > If you run multiple instances, see [Common](../../common/README.md#multi-instance-support).

  ```
  ./deploy.sh info 
  ```  
     
    > **IMPORTANT:**     
      You can customize the bootstrap password by setting the environment variable `REPOSITORY_SERVICE_ROOT_PASS`. 
      This can _ONLY_ be done _BEFORE_ you start an instance the first time.

## Accessibility

- For safety reasons an instance is _ONLY_ accessible from your local host by default.    

  You can change this by setting the environment variable `COMMON_BIND_HOST` to `0.0.0.0`.
  If done, the instance is accessible from outside your local environment.     
   
    > Don't forget to change the public domains too by setting `RENDERING_SERVICE_HOST` and `REPOSITORY_SERVICE_HOST`,
      because they will be resolved to the loopback address `127.0.0.1` by default. 

    > **IMPORTANT:**     
      Please consult [Docker and iptables](https://docs.docker.com/network/iptables/) before you do this,
      because _ALL_ external source IPs are allowed to connect to a Docker host by default.

## Email support

- There is the option to send out invitation emails if someone wants to share content.

  Following environment variables should be customized:
  
  - `REPOSITORY_SERVICE_SMTP_FROM`: sender address, which will add in the 'From' header, default: `noreply@127.0.0.1.xip.io`  
  - `REPOSITORY_SERVICE_SMTP_REPL`: if `true` email address of invitor will add in the 'Reply-To' header, default: `false`  

  You can send out the invitation emails: 

  * directly to a mail server 
    by setting the environment variable `REPOSITORY_SERVICE_SMTP_HOST`
    with the host name of your favourite mail server (e.g. 'mail.example.com')  
    
    If so, you can customize this direct option over: 
        
    - `REPOSITORY_SERVICE_SMTP_PORT`: port number of your mail server, default: `25`  
    - `REPOSITORY_SERVICE_SMTP_AUTH`: if `tls` use TLS encryption, otherwise no encryption, default: ``    
    - `REPOSITORY_SERVICE_SMTP_USER`: username to authenticate, default: ``    
    - `REPOSITORY_SERVICE_SMTP_PASS`: password to authenticate, default: ``  
         
  * over a mail relay (if you leave the default value of `REPOSITORY_SERVICE_SMTP_HOST`):
  
    If so, you can customize this relay option over: 
  
    - `REPOSITORY_MAILRELAY_MAILNAME`: your mail domain, default: `127.0.0.1.xip.io`    
    - `REPOSITORY_MAILRELAY_RELAYHOST`: if specified then all emails will be forwarded to this mail server,
       otherwise all emails will send out directly, default: ``  
å
    This relay option works only with mail servers which do not require any authentication.  
  
- If you don't touch any mail settings, 
  then all invitation emails will send out directly over the relay option by default,
  but most of them will be bounced depending on the email server policies of the recipients.
  Please check the log messages for delivery failure notifications, see: [Monitoring](../monitoring/README.md).   
