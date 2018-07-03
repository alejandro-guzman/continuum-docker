var webpack = require('webpack');
var path = require('path');
var devBaseConfig = require('./webpack.dev.base.config');
var _ = require('lodash');
var devServerConfig = require('./webpack.devServer.config');

var watchConfig = _.extend({}, devBaseConfig);

watchConfig.module.rules = [
    {
        test: /.js$/,
        loaders: ['react-hot-loader/webpack', 'babel-loader'],
        exclude: [/node_modules/, /externalLibs/]
    },
    {
        test: /.less$/,
        loaders: ['style-loader', 'css-loader', 'less-loader']
    },
    {
        test:   /\.(gif|ttf|otf|eot|svg|woff2?)(\?.+)?$/,
        loader: 'url-loader',
        options:  {
            limit: 10000
        }
    }
];

var plugins = [
    new webpack.HotModuleReplacementPlugin(),
    new webpack.NoEmitOnErrorsPlugin(),
];

watchConfig.plugins = watchConfig.plugins.concat(plugins);

watchConfig.entry = _.reduce(watchConfig.entry, function(newEntry, entry, key) {
    var stylePath = path.join(__dirname, '..', 'styles', 'index.less');
    var shouldIncludeStyles = key === 'main';
    newEntry[key] = entry
        .concat([`webpack-hot-middleware/client?path=${devServerConfig.path}/__webpack_hmr`])
        .concat(!shouldIncludeStyles ? [] : [stylePath]);
    return newEntry;
}, devBaseConfig.entry);

watchConfig.output = _.extend({}, watchConfig.output, {
    publicPath: `${devServerConfig.path}/dist/scripts/`
});

module.exports = watchConfig;

