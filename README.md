# ListWiki

## Install

    $ git clone git@github.com:kambara/listwiki.git
    $ cd listwiki

RVM (ruby 1.9.2)

    $ rvm install 1.9.2
    $ rvm 1.9.2
    $ rvm gemset create padrino
    $ rvm 1.9.2@padrino

Bundler

    $ gem install bundler
    $ bundle install


## Start the server

    $ padrino start

Specify Daemonizing, Port, Environment and Adapter

    $ padrino start -d -p 3000 -e development -a thin
    $ padrino stop

See also [Padrino Terminal Commands](http://www.padrinorb.com/guides/development-commands#terminal-commands)


## Wiki Syntax

Formatting rules are similar to [PukiWiki style](http://pukiwiki.sourceforge.jp/?FormatRule).

### Link

    [[Page Name]]

### External link

    http://example.com/
    [[Example: http://example.com/]]

### Image

URL for png, jpeg or gif

    http://example.com/hoge.png

### YouTube video

URL for a YouTube video page

    http://www.youtube.com/watch?v=sV75QjBrso0
    http://youtu.be/sV75QjBrso0

### Pre-formatted text

Indent every line of a block by one space character

    ~~~
     function hello() {
       alert('hello');
     }
    ~~~
