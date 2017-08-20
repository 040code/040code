FROM jekyll/jekyll:3.4.3 AS build
MAINTAINER Niek Palm <dev.npalm@gmail.com>

WORKDIR /build
ADD . /build
RUN jekyll build

FROM nginx:1.13.3-alpine
RUN rm -rf /usr/share/nginx/html
COPY --from=build /build/_site /usr/share/nginx/html
