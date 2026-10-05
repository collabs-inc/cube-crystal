import { mkdir, writeFile } from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import { runDesktop } from './desktop/start.mjs';

const dataDir = path.resolve(process.env.CUBE_CRYSTAL_DATA_DIR || path.join(process.env.XDG_DATA_HOME || path.join(os.homedir(), '.local/share'), 'cube-crystal'));
await mkdir(dataDir, {recursive:true,mode:0o700});
// Upstream merges this with defaults. Empty analytics key also disables its minimal client.
try {await writeFile(path.join(dataDir,'config.json'),JSON.stringify({analytics:{enabled:false,posthogApiKey:''}}),{flag:'wx',mode:0o600});}
catch(error){if(error.code!=='EEXIST')throw error;}
const executable = path.join(process.env.XDG_CACHE_HOME || path.join(os.homedir(), '.cache'), 'cube-crystal', '0.3.5-linux-x64', 'opt/Crystal/Crystal');
await runDesktop({name:'Crystal',executable,args:[`--user-data-dir=${path.join(dataDir,'profile')}`,'--ozone-platform=x11'],dataDir,env:{
  CRYSTAL_DIR:dataDir, APPIMAGE:undefined, APPDIR:undefined,
}});
