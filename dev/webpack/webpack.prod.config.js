var webpack = require('webpack');
var path = require('path');
var _ = require('lodash');
var ExtractTextPlugin = require("extract-text-webpack-plugin");
var defaultConfig = require('./webpack.default.config');
var happyPackConfig = require('./happyPackConfig');

var env = 'production';

var prodConfig =  _.extend({}, defaultConfig, {
    name: 'Production Webpack',
    cache: true,
    devtool: 'cheap-module-source-map',
});

defaultConfig.entry['styles'] = path.join(__dirname, '..', 'styles', 'index.less');

defaultConfig.module.rules.push({
    test: /\.less$/,
    loader: ExtractTextPlugin.extract({
        fallback: 'style-loader',
        use: "css-loader!less-loader"
    }),
});

var prodPlugins = [
    new webpack.LoaderOptionsPlugin({
        debug: false
    }),
    new webpack.DefinePlugin({
        'process.env.NODE_ENV': '"production"'
    }),
    new webpack.optimize.UglifyJsPlugin({
        minimize : true,
        compress : {
            warnings : false
        }
    }),
    new ExtractTextPlugin('./../styles/index.css'),
    happyPackConfig(env),
];

prodConfig.plugins = defaultConfig.plugins.concat(prodPlugins);

module.exports = prodConfig;