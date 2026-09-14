import {spawn} from 'node:child_process';
import {constants} from 'node:os';

/** Run without a shell; own the whole build/watch tree on POSIX. */
export function runProcess(command, args, options = {}) {
  return new Promise((resolve, reject) => {
    const grouped = process.platform !== 'win32';
    const child = spawn(command, args, {...options, stdio: 'inherit', detached: grouped, shell: false});
    let interrupted;
    function kill(signal) {
      try {
        if (grouped && child.pid) process.kill(-child.pid, signal);
        else child.kill(signal);
      } catch (error) { if (error.code !== 'ESRCH') throw error; }
    }
    function interrupt(signal) {
      interrupted = 128 + constants.signals[signal];
      kill(signal);
    }
    const onInt = () => interrupt('SIGINT');
    const onTerm = () => interrupt('SIGTERM');
    process.on('SIGINT', onInt);
    process.on('SIGTERM', onTerm);
    function cleanup() {
      process.off('SIGINT', onInt);
      process.off('SIGTERM', onTerm);
      kill('SIGTERM');
    }
    child.once('error', error => { cleanup(); reject(error); });
    child.once('close', (code, signal) => {
      cleanup();
      resolve(interrupted ?? code ?? (128 + (constants.signals[signal] ?? 1)));
    });
  });
}
