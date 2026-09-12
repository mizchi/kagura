// ASHEN HUNT supplies the reproducible scenario; Kagura owns the measurement.
import {parseArgs} from 'node:util';
import {profileWeb} from './profile-web.mjs';

const {values} = parseArgs({options:{
  url:{type:'string',default:'http://localhost:8080/'},
  'out-dir':{type:'string'}, moving:{type:'boolean',default:false},
}});
const url = new URL(values.url);
for (const [key,value] of Object.entries({snapshot:'playing',frames:'0',mute:'1',perf:'1',seed:'42'})) {
  url.searchParams.set(key,value);
}
await profileWeb({url:url.toString(), outDir:values['out-dir'],
  metadata:{game:'ashen-hunt',seed:42,mode:values.moving ? 'physical KeyD held' : 'paused scene; rendering active'},
  async prepare(page) {
    if (values.moving) await page.keyboard.down('KeyD');
    else await page.keyboard.press('KeyP');
  },
});
