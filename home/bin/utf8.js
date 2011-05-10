#!/usr/bin/env node
// http://debuggable.com/posts/streaming-utf-8-with-node-js:4bf28e8b-a290-432f-a222-11c1cbdd56cb
var fs = require('fs');
var data = fs.readFileSync(process.argv[2]);
console.log(data.toString('utf-8'));
