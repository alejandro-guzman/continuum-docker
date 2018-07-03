var webpack = require('webpack');
var _ = require('lodash');
var defaultConfig = require('./webpack.default.config');
var happyPackConfig = require('./happyPackConfig');

var env = 'development';

var devBaseConfig = _.extend({}, defaultConfig, {
    name: 'Development Webpack',
    cache: true,
    devtool: 'eval-source-map',
});

var devPlugins = [
    new webpack.LoaderOptionsPlugin({
        debug: true
    }),
    new webpack.DefinePlugin({
        'process.env.NODE_ENV': JSON.stringify(env)
    }),
    happyPackConfig(env)
];



devBaseConfig.plugins = defaultConfig.plugins.concat(devPlugins);

module.exports = devBaseConfig;

