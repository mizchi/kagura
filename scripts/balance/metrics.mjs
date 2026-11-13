import {AgentError, int32} from '../agents/errors.mjs';

const finite = Number.isFinite;
const unique = values => new Set(values).size === values.length;
const id = value => typeof value === 'string' && /^[a-zA-Z][\w-]*$/.test(value);
export const fail = (code, detail) => { throw new AgentError(code, detail); };

export function validateExperiment(e) {
  if (e?.schemaVersion !== 1 || !id(e.game) || !Array.isArray(e.parameters) || !e.parameters.length || e.parameters.length > 32) fail('invalid_experiment');
  if (!unique(e.parameters.map(p => p.name))) fail('invalid_parameter', 'duplicate names');
  for (const p of e.parameters) {
    if (!id(p.name) || ![p.min,p.max,p.initial,p.step].every(finite) || p.min >= p.max ||
        p.initial < p.min || p.initial > p.max || p.step <= 0 || p.step > p.max-p.min) fail('invalid_parameter');
  }
  for (const key of ['policies','seats']) {
    if (!Array.isArray(e[key]) || !e[key].length || !unique(e[key]) || !e[key].every(id)) fail('invalid_experiment', key);
  }
  for (const key of ['trainSeeds','validationSeeds']) {
    if (!Array.isArray(e[key]) || !e[key].length || !unique(e[key])) fail('invalid_experiment', key);
    e[key].forEach(seed => int32(seed, key));
  }
  if (e.trainSeeds.some(seed => e.validationSeeds.includes(seed))) fail('invalid_experiment','overlapping train/validation seeds');
  if (!Array.isArray(e.goals) || !e.goals.length) fail('invalid_experiment','goals required');
  const cohorts = new Set(e.policies.flatMap(p => [p, ...e.seats.map(s => `${p}@${s}`)]));
  for (const g of e.goals) {
    if (!cohorts.has(g.cohort) || typeof g.metric !== 'string' || !g.metric ||
        ![g.min,g.max,g.scale,g.weight].every(finite) || g.min > g.max || g.scale <= 0 || g.weight <= 0 ||
        g.subtract && (!cohorts.has(g.subtract.cohort) || !g.subtract.metric)) fail('invalid_experiment','invalid goal');
  }
  for(const g of e.guards??[]){
    if(!cohorts.has(g.cohort)||!g.metric||g.min===undefined&&g.max===undefined||
      g.min!==undefined&&!finite(g.min)||g.max!==undefined&&!finite(g.max)||
      (g.min??-Infinity)>(g.max??Infinity))fail('invalid_experiment','invalid guard');
  }
  return e;
}

export function checkGuards(report,guards=[]){
  const violations=[];
  for(const g of guards){
    const value=report.cohorts[g.cohort]?.[g.metric];
    if(!finite(value))fail('missing_metric',`${g.cohort}.${g.metric}`);
    if(value<(g.min??-Infinity)||value>(g.max??Infinity))violations.push({...g,value});
  }
  return {...report,valid:report.valid&&violations.length===0,violations};
}

export function parametersAt(specs, values) {
  if (values.length !== specs.length || !values.every(finite)) fail('invalid_parameter');
  return Object.fromEntries(specs.map((p,i) => {
    const raw = p.min + Math.min(1,Math.max(0,values[i])) * (p.max-p.min);
    const snapped = p.min + Math.round((raw-p.min)/p.step)*p.step;
    return [p.name, Number(Math.min(p.max,Math.max(p.min,snapped)).toPrecision(12))];
  }));
}

/** Wilson 95% interval; an estimate for this policy/seed population, not humans. */
export function wilson(wins, total) {
  if (!total) return [0,1];
  const z=1.959963984540054, p=wins/total, d=1+z*z/total;
  const center=(p+z*z/(2*total))/d, radius=z*Math.sqrt(p*(1-p)/total+z*z/(4*total*total))/d;
  return [Math.max(0,center-radius),Math.min(1,center+radius)];
}

export function aggregate(trials) {
  if (!trials.length) fail('invalid_trial','no trials');
  const groups = new Map();
  for (const t of trials) {
    if (!id(t.policy) || !id(t.seat) || !['victory','defeat','draw','returned','limit'].includes(t.status) ||
        !t.metrics || typeof t.metrics !== 'object' || Array.isArray(t.metrics) ||
        Object.entries(t.metrics).some(([k,v]) => !finite(v) || ['winRate','completionRate','drawRate','count','winInterval'].includes(k))) fail('invalid_trial');
    for (const key of [t.policy,`${t.policy}@${t.seat}`]) {
      if (!groups.has(key)) groups.set(key,[]);
      groups.get(key).push(t);
    }
  }
  const cohorts = Object.fromEntries([...groups].map(([key,group]) => {
    const keys=Object.keys(group[0].metrics).sort(), n=group.length;
    if (group.some(t => JSON.stringify(Object.keys(t.metrics).sort())!==JSON.stringify(keys))) fail('invalid_trial','inconsistent metrics');
    const wins=group.filter(t=>t.status==='victory').length;
    return [key,{
      ...Object.fromEntries(keys.map(k=>[k,group.reduce((sum,t)=>sum+t.metrics[k],0)/n])),
      count:n, winRate:wins/n, winInterval:wilson(wins,n),
      completionRate:group.filter(t=>t.status!=='limit').length/n,
      drawRate:group.filter(t=>t.status==='draw').length/n,
    }];
  }));
  return {valid:trials.every(t=>t.status!=='limit'), cohorts};
}

export function score(report, goals) {
  const get = selector => {
    const value = report.cohorts[selector.cohort]?.[selector.metric];
    if (!finite(value)) fail('missing_metric',`${selector.cohort}.${selector.metric}`);
    return value;
  };
  return goals.reduce((sum,g) => {
    const value=get(g)-(g.subtract?get(g.subtract):0);
    const distance=Math.max(g.min-value,0,value-g.max)/g.scale;
    return sum+g.weight*distance*distance;
  },0);
}
