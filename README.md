# Custom source-to-image builder for static nginx containers

## Overview
This repo is source code to `docker build` an S2I build image for an Nginx server 
on CentOS7.  

Most people will just need the Basic Usage if you just want NGinx to serve 
HTML/CSS/JS/whatever from it and/or use it as a reverse or forward proxy.

For people who want to change the builder image see Advanced Usage.  Building a 
new S2I is for people who want to do more than simply change NGinx config and
serve static files.

## Basic Usage

### Step 1: Building the S2I Image

Long term, we should have this s2i image available in the global registry 
but until then, you'll have to build this custom s2i image.  Here's how:

Required tools install:

1. [Docker Toolbox](https://www.docker.com/products/docker-toolbox)

Open Docker QuickStart Terminal (need Docker engine started and env variables set) and
build the S2I image:

`$ docker build -t s2i-nginx git://github.com/BCDevOps/s2i-nginx`

Tag and push this image to the OpenShift Docker Registry for your OpenShift Project:

`$ docker tag s2i-nginx docker-registry.pathfinder.gov.bc.ca/<yourprojectname>/s2i-nginx`
`$ docker login docker-registry.pathfinder.gov.bc.ca -u <username> -p <token>`
`$ docker push docker-registry.pathfinder.gov.bc.ca/<yourprojectname>/s2i-nginx`

[Forgot how to get a token?](https://console.pathfinder.gov.bc.ca:8443/console/command-line)

### Step 2: Customizing your Nginx Config and Static Files

Create a separate Git repo or [fork/clone our example](https://github.com/BCDevOps/s2i-nginx-example) repo.

The directory structure should look like this:

`/html/    <- your static files here or just empty`

`/conf.d/  <- your custom NGinx config files`

`/aux/     <- your custom auxiliary files`

All `*.conf` files in the `/conf.d/` will be copied and read by NGinx.  

All `*.conf.tmpl` files in the `/conf.d/` will be copied and `envsubst` will run replacing $ENVVAR with the run-time environment variable.

You can put auxiliary files in a directory `aux` (or `NGINX_AUX_DIR`) to copy
them to the resulting image, e.g. htpasswd files.  These will be copied to `/opt/app-root/etc/aux`.

Optionally can supply a `/nginx.conf-snippet` that will be used by the as built container.

### Step 3: Using the S2I-Nginx in OpenShift
The builder image should've built and been pushed to OpenShift.  You should have your own custom nginx conf and/or static files.  Now you can spin it up in your OpenShift Project.

1. [Login to OpenShift](https://console.pathfinder.gov.bc.ca:8443/console/)
2. Choose the project where you want this
3. Click `Add to Project`
4. Click `Don't see the image you are looking for?`
5. Scroll to find your `s2i-nginx` S2I image and click it
6. Give it a name, e.g., `rproxy`, and the Git URL to the repo you made in Step 2
7. The defaults are generally fine for basic usage
8. Watch it deploy automatically!

## Best Practices

1. Generally you want a minimum of 2 pods for high availability purposes, e.g., rolling deployments.
2. Branch, e.g, `master and development` your configuration repo to avoid deploying untested config to production.  
3. If reverse proxying to a OpenShift Service, remove the `route' from the service to avoid proxy by-pass.  This is especially important if the reverse proxy is providing a layer of security.
4. Harden your nginx configuration.   

TODO: Avoid environment specific configuration in your custom configuration repo, should be generic nginx config for ALL environments.

## Integrating with SiteMinder Web SSO

TODO

## Advanced Usage

Don't like the static HTML folder?  Want to remove or add Nginx plugins?  A certbot would be handy? Just want to tinker? 

Required tools install:

1. [Docker Toolbox](https://www.docker.com/products/docker-toolbox)
2. [Make](http://gnuwin32.sourceforge.net/packages/make.htm) (Windows users only)

Steps:

1. Fork this repo (FYI we accept pull requests if the change is done in a way that could be reuseable for others)
2. Clone it
3. `make` it


### Build behavior
There are some environment variables you can set to influence **build** behavior.

`NGINX_STATIC_DIR` sets the repo subdir to use for static files, default
`html`.

Either `NGINX_CONF_FILE` sets a config snippet to use or `NGINX_CONF_DIR`
will copy config from this dir (defaults to `conf.d`).

`NGINX_AUX_DIR` sets the aux directory for auxiliary files.

