FROM ruby:3.0
WORKDIR /app
COPY . .
ENV DEFAULT_REPORT=all
ENV DEFAULT_LIMIT=10
RUN gem install terminal-table

ENTRYPOINT ["ruby", "main.rb"]
