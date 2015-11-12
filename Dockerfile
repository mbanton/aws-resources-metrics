FROM ruby:2.2

MAINTAINER <marceloanton@gmail.com>

ENV app /opt/aws-resources-metrics/
ADD . ${app}
WORKDIR ${app}

RUN bundle install
