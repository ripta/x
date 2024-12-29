import { Configuration } from '@rspack/cli';

const config: Configuration = {
    entry: {
        main: './src/sketch.ts',
    },
    resolve: {
        extensionAlias: {
            '.js': ['.ts', '.js'],
        },
    },
    module: {
        rules: [
            {
                test: /\.ts$/,
                exclude: [/node_modules/],
                loader: 'builtin:swc-loader',
                options: {
                    jsc: {
                        parser: {
                            syntax: 'typescript',
                        },
                    },
                },
                type: 'javascript/auto',
            },
        ],
    },
};

export = config;