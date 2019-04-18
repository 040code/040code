FROM jekyll/jekyll:3.8.3 AS build
MAINTAINER Niek Palm <dev.npalm@gmail.com>

WORKDIR /build
ADD . /build
RUN chown -R jekyll:jekyll /build
RUN jekyll build

FROM nginx:1.15.3
RUN rm -rf /usr/share/nginx/html
COPY --from=build /build/_site /usr/share/nginx/html

COPY nginx/default.conf /etc/nginx/conf.d/mysite.template
COPY nginx/start.sh /usr/bin

CMD ["start.sh"]
