#!/usr/bin/env node
// Meme generation.
// https://imgflip.com/api

const Imgflipper = require("imgflipper");

cb = function (err, url) {
    if (err) {
        console.error('imgflip: err: ', err);
        process.exitCode = 1
    }
    if (url) {
        console.log(url);
    }
};

const [username, pw] = process.env.IMGFLIP_AUTH.split(':')
const imgflipper = new Imgflipper(username, pw);
id = 124822590 // Left-Exit-12-Off-Ramp (3 boxes, so this is lame)
id = 58470603 // Grandpa Simpson
imgflipper.generateMeme(id, process.argv[2], process.argv[3], cb);
