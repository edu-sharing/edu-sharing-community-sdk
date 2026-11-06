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
one).

`repository/webapp` does not use this war: it assembles `assets/i18n` and `assets/images`
(mails, translations served by the backend) from the sources - the community frontend
`sources` plus the overrides of this module (`src/main/ng/src/assets`,
`src/edu-sharing-override/assets`, `src/main/webapp/assets`), in the same precedence as this
war. So the backend does not wait for the angular build; `mvn -T 1C` builds both in
parallel. Put project translations and mail images into one of these override folders.

For local development (`./deploy.sh ldev`) the dev compose mounts the `Frontend/dist` of the
community checkout into the frontend server container, see `scripts/apply-frontend-customizations.sh`.

## Storybook (`storybook.build`)

The file `storybook.build` in this module adds a storybook build, published under
`storybook/` in the war (and so by the frontend server at `/edu-sharing/storybook/`).

* **Without overrides** (no `src/edu-sharing-override`): only the libraries and storybook
  are built. The app and the web components come unchanged from the community frontend
  war - rebuilding them would only reproduce the community build.
* **With overrides** (`src/edu-sharing-override` present): the app and the web components
  are built as well, so the customizations reach them.

Which case applies is logged at the start of the build (`frontend.storybook: ...`).

