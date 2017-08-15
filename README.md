[![Build Status](https://travis-ci.org/IUBLibTech/phydo.svg?branch=master)](https://travis-ci.org/IUBLibTech/phydo)
[![Coverage Status](https://coveralls.io/repos/github/IUBLibTech/phydo/badge.svg?branch=master)](https://coveralls.io/github/IUBLibTech/phydo?branch=master)

# Phydo

A Hydra app that focuses on Digital Asset Management functions.


## Dependencies

Phydo has the following dependencies that you must install yourself.

1. Ruby >= 2.3.0
1. Java 1.8
1. Redis server

## Development Setup

> NOTE: All commands after Step 1 should be run from where ever your code is located.

1. Clone the repository
   ```bash
   cd path/to/wherever/you/want/your/code/to/live
   git clone https://github.com/IUBLibTech/phydo.git
   ```

1. Install gems
   ```bash
   bundle install
   ```

1. Migrate the database
   ```bash
   rake db:migrate
   ```

1. From a new terminal window, start the development Solr instance using the `solr_wrapper` gem
   ```bash
   bundle exec solr_wrapper --config .solr_wrapper.development.yml
   ```

   > NOTE: Solr will continue to run as long as the process in the terminal
   > window is running. Closing the terminal window will stop Solr, unless
   > you've explicitly told it to run in the background. Ctrl+C will stop Solr
   > without closing the terminal window. Press Ctrl+C only once, and allow
   > SolrWrapper to exit.

1. From a new terminal window, start the development Fedora instance using the `fcrepo_wrapper` gem
   ```bash
   bundle exec fcrepo_wrapper --config .fcrepo_wrapper.development.yml
   ```

   > NOTE: Fedora will continue to run as long as the process in the terminal
   > window is running. Closing the terminal window will stop Fedora, unless
   > you've explicitly told it to run in the background. Ctrl+C will stop Fedora
   > without closing the terminal window.

1. Start Redis server from a separate terminal window.
   ```bash
   # From a dedicated terminal window...
   redis-server
   ```

   > NOTE: Redis server will continue to run as long as the process in the
   > terminal window is running. Closing the terminal window will stop Redis
   > server, unless you've explicitly told it to run in the background. Ctrl+C
   > will stop Redis server without closing the terminal window.


1. From a new terminal window, start the Rails server.
   ```bash
   rake rails s
   ```

   > NOTE: The Rails server will continue to run as long as the process in the
   > terminal window is running. Closing the terminal window will stop the
   > Rails server, unless you've explicitly told it to run in the background.
   > Ctrl+C will stop Rails server without closing the terminal window.

1. Verify Rails is working by opening http://localhost:3000 in your browser.
