# Chat App Demo

Chat Application Demo with Node.js, Express, CoffeeScript, Bootstrap and MongoDB.
( based on https://github.com/suin/chat-nodejs )

## How to build and run

Install modules and compile coffee-script files.

    $ npm install
    $ node_modules/coffee-script/bin/cake build

If mongod is not running, start it like below:

    $ mongod --nojournal --noprealloc --dbpath mongodb --logpath mongodb/mongodb.log

Run app

    $ node app.js
