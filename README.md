# Install

    $ git clone git://github.com/~~~~
    $ cd listwiki

RVM

    $ rvm install 1.9.2
    $ rvm 1.9.2
    $ rvm gemset create padrino
    $ rvm 1.9.2@padrino

Bundler

    $ gem install bundler
    $ bundle install

# Usage

    $ padrino start

Specify Daemonizing, Port, Environment and Adapter

    $ padrino start -d -p 3000 -e development -a thin
    $ padrino stop

See also [Padrino Terminal Commands](http://www.padrinorb.com/guides/development-commands#terminal-commands)
