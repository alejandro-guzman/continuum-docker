var path = require('path');
var webpack = require('webpack');

var rootDir = path.join(__dirname);
var entries = require('./webpack.entries.js');

module.exports = {
    target: 'web',
    entry: entries,
    output: {
        path: path.join(rootDir, '..', 'dist', 'scripts'),
        filename: '[name].js',
        library: ["CTM", "[name]"],
        libraryTarget: 'umd'
    },
    resolve: {
        alias: {
            handlebars: 'handlebars/dist/handlebars.min.js'
        }
    },
    module: {
        rules: [
            {
                test: /\.js$/,
                loaders: ['happypack/loader'],
                exclude: [/node_modules/, /externalLibs/]
            },
            {
                test:   /\.(gif|ttf|otf|eot|svg|woff2?)(\?.+)?$/,
                loader: 'url-loader',
                options:  {
                    limit: 10000,
                    name: './../fonts/[name].[ext]'
                }
            }
        ]
    },
    plugins: [
        new webpack.IgnorePlugin(/regenerator|nodent|js\-beautify/, /ajv/)
    ]
};