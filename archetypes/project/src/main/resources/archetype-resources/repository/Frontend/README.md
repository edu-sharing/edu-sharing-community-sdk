# Frontend Customization

## Simple Customizations

Use this method if you only want to override or insert images, fonts or other static assets.
Create a "webapp" folder inside src/main. This represents the root folder of the webapp.

To insert/override: 
- images: put your images under assets/images inside the webapp folder.
- fonts: put your fonts under assets/fonts inside the webapp folder.

## To Customize Typescript, HTML or SCSS

You have to add your angular code under src/main/ng/src.
Also place the assets into src/main/ng/src/assets folder.

## Delivery

The UI is delivered by the frontend server, not by Tomcat. The war built here is its
`dist`: `repository/deploy/docker/frontend-server` replaces `/app/dist` of the community
frontend server image with the content of this war (the server itself stays the community
one). `repository/webapp` only takes `assets/i18n` and `assets/images` of it (mails,
translations served by the backend).

For local development (`./deploy.sh ldev`) the dev compose mounts the `Frontend/dist` of the
community checkout into the frontend server container, see `scripts/apply-frontend-customizations.sh`.
