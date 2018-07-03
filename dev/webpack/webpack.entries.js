var path = require('path');
var fs = require('fs');
var _ = require('lodash');
var scriptsDir = path.join(__dirname, '..', 'scripts');
var pagesDir = path.join(scriptsDir, 'pages');

const getPages = p => fs.readdirSync(p).filter(file => fs.statSync(path.join(p, file)));

const pagesChunck = getPages(pagesDir).reduce(function(entries, page) {
    const key = page.split('.js')[0];
    entries[key] = [path.join(pagesDir, key)]
        .concat(key === 'main' ? ['babel-polyfill'] : []);
    return entries;
}, {});

const entries = pagesChunck;

module.exports = entries;