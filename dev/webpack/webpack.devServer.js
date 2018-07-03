var express = require('express');
var webpack = require('webpack');
var devMiddleware = require('webpack-dev-middleware');
var hotMiddleware = require('webpack-hot-middleware');
var config = require('./webpack.watch.config');
var devServerConfig = require('./webpack.devServer.config');

var host = devServerConfig.host;
var port = devServerConfig.port;
var path = devServerConfig.path;

var app = express();
var compiler = webpack(config);

var bundleStart = null;

compiler.plugin('compile', () => {
    console.info(`==> 💻  Webpack Dev Server listening on ${path}`);
    bundleStart = Date.now();
});

compiler.plugin('done', () => {
    console.log(`Bundled in ${Date.now() - bundleStart} ms!`);
});

var bundler = devMiddleware(compiler, {
    publicPath: config.output.publicPath,
    noInfo: true,
    headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, PATCH, OPTIONS',
        'Access-Control-Allow-Headers': 'X-Requested-With, content-type, Authorization'
    }
});

app.use(bundler);

app.use(hotMiddleware(compiler));

var listener = (err, result) => {
    var message = err ? err : '==> Bundling project please wait...';
    console.log(message);
};

app.listen(port, listener);