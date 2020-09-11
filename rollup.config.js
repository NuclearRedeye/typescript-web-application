import { default as copy } from 'rollup-plugin-copy';
import { terser } from 'rollup-plugin-terser';

export default [
  {
    input: 'dist/debug/index.js',
    output: [
      {
        file: 'dist/release/bundle.min.js',
        name: 'version',
        plugins: [terser()]
      }
    ],
    plugins: [
      copy({
        targets: [
          {
            src: 'src/index.html',
            dest: 'dist/debug',
            transform: (contents) => {
              return contents.toString().replace('__SCRIPT__', 'index.js');
            }
          },
          {
            src: 'src/index.html',
            dest: 'dist/release',
            transform: (contents) => {
              return contents.toString().replace('__SCRIPT__', 'bundle.min.js');
            }
          },
          { src: 'src/assets', dest: ['dist/debug', 'dist/release'] }
        ]
      })
    ]
  }
];
