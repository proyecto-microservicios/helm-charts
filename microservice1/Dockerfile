# change the form to use the base image that best suit your needs
# use multi stage images to reduce final size
FROM alpine as initial

# these are variable that are being received to build the image
# use them as needed
# ARG github_user
# ARG github_token
# ARG newrelic_token
# ARG artifactory_username
# ARG artifactory_password

# # do specifics to your project
# # usually copy from local machine to the docker image
WORKDIR /microservice1
COPY ./README.md index.html
WORKDIR /microservice1/health
COPY ./README.md index.html

# by this point your service or app is ready to be sourced, prepare the final image
# use the (simplier) base image that best work for you (usually the smaller the better)
FROM nginx

# copy whatever you need from base image
# usually binnary and configuration and other static resources
COPY --from=initial /microservice1 /usr/share/nginx/html/
COPY --from=initial /microservice1 /usr/share/nginx/html/microservice1

# do other specific actions required by your project
WORKDIR /etc/nginx/conf.d
RUN rm default.conf
RUN echo 'server { \n\
 listen 8080; \n\
 server_name test; \n\
 location / { \n\
   root /usr/share/nginx/html; \n\
   index index.html; \n\
 } \n\
 \n\
 location /microservice1 { \n\
    root /usr/share/nginx/html; \n\
    index index.html; \n\
 } \n\
 \n\
 location /health { \n\
   root /usr/share/nginx/html; \n\
   index index.html; \n\
   try_files $uri $uri/index.html $uri/ =404; \n\
 } \n\
}' > default.conf

EXPOSE 8080