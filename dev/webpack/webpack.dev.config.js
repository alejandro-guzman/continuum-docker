var webpack = require('webpack');
var _ = require('lodash');
var path = require('path');
var ExtractTextPlugin = require("extract-text-webpack-plugin");

var devBaseConfig = require('./webpack.dev.base.config');
var happyPackConfig = require('./happyPackConfig');

var env = 'development';

var devConfig = _.extend({}, devBaseConfig);

devConfig.entry['styles'] = path.join(__dirname, '..', 'styles', 'index.less');

devConfig.module.rules.push({
    test: /\.less$/,
    loader: ExtractTextPlugin.extract({
        fallback: 'style-loader',
        use: "css-loader!less-loader"
    }),
});

var devPlugins = [
    new ExtractTextPlugin('./../styles/index.css'),
];

devConfig.plugins = devBaseConfig.plugins.concat(devPlugins);

module.exports = devConfig;

