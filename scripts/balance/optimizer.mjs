import * as core from '../../game/balance/_build/js/release/build/host/host.js';
import {int32} from '../agents/errors.mjs';
import {fail} from './metrics.mjs';

/** All numerical search is delegated to the published differentiable_ecs. */
export function createSearch(initial, {seed=731,sigma=.3}={}) {
  int32(seed,'optimizer seed');
  if (!Array.isArray(initial) || !initial.length || initial.length>32 || initial.some(v=>!Number.isFinite(v)||v<0||v>1) ||
      !Number.isFinite(sigma) || sigma<=0 || sigma>1) fail('invalid_search');
  const search=core.create(JSON.stringify(initial),sigma,seed);
  return Object.freeze({
    ask(){const values=JSON.parse(core.ask(search));if(!Array.isArray(values))fail('invalid_search');return values;},
    tell(losses){
      if (!Array.isArray(losses)||losses.some(v=>!Number.isFinite(v)||v<0||v>=1e100)) fail('invalid_fitness');
      if(core.tell(search,JSON.stringify(losses))!=='applied')fail('invalid_fitness');
    },
  });
}
