var os = require('os');
var HappyPack = require('happypack');

function threadCount() {
    return Math.max(1, os.cpus().length);
}

module.exports = function(env) {
    return new HappyPack({
        loaders: ['babel-loader'],
        threads: threadCount(),
        cacheContext: {
            env: env
        }
    })
};