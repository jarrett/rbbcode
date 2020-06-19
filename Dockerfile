FROM ruby:2.7.1

RUN mkdir /app
WORKDIR /app
COPY . /app/
RUN bundle install

CMD ["/bin/bash"]