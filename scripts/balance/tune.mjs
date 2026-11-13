import {AgentError, int32} from '../agents/errors.mjs';
import {aggregate,score,validateExperiment,parametersAt,checkGuards,fail} from './metrics.mjs';
import {createSearch} from './optimizer.mjs';

/** Game independent, asynchronous, bounded experiment. The validation cohort
 * is never supplied to the optimizer and is evaluated only after selection. */
export async function tune({experiment,runTrial,generations=8,maxTrials=2000,maxSeconds=120,seed=731,
  sigma=.3,onRecord=()=>{},signal}) {
  const e=structuredClone(validateExperiment(experiment));
  int32(seed,'optimizer seed');
  if (!Number.isInteger(generations)||generations<1||generations>1000 ||
      !Number.isInteger(maxTrials)||maxTrials<1||maxTrials>100000 ||
      !Number.isFinite(maxSeconds)||maxSeconds<=0||maxSeconds>3600) fail('invalid_experiment','invalid budget');
  const started=performance.now(), deadline=new AbortController();
  const timer=setTimeout(()=>deadline.abort(),maxSeconds*1000);
  const runSignal=signal?AbortSignal.any([signal,deadline.signal]):deadline.signal;
  const parameters=Object.fromEntries(e.parameters.map(p=>[p.name,p.initial]));
  const trainCost=e.trainSeeds.length*e.policies.length*e.seats.length;
  const validationCost=e.validationSeeds.length*e.policies.length*e.seats.length;
  let trials=0, evaluations=0, best, baseline, generation=0;
  const evaluate=async(params,split,candidate)=>{
    const seeds=split==='train'?e.trainSeeds:e.validationSeeds;
    const cost=seeds.length*e.policies.length*e.seats.length;
    if(trials+cost>maxTrials)fail('trial_limit');
    const results=[];
    for(const policy of e.policies)for(const seat of e.seats)for(const seed of seeds){
      if(runSignal.aborted)fail('interrupted');
      trials++;
      const trial=await runTrial({params:Object.freeze({...params}),seed,policy,seat,signal:runSignal});
      if(runSignal.aborted)fail('interrupted');
      const result={...trial,policy,seat,seed};
      // Validate before accepting data or writing it into an experiment.
      aggregate([result]); results.push(result);
      await onRecord({type:'trial',schemaVersion:1,split,candidate,params,...result});
    }
    const report=checkGuards(aggregate(results),e.guards), loss=score(report,e.goals);
    if(!Number.isFinite(loss)||loss>=1e90)fail('invalid_loss');
    const result={params:{...params},loss,report};evaluations++;
    await onRecord({type:'evaluation',schemaVersion:1,split,candidate,...result});
    return result;
  };
  const ending=extra=>({type:'run_end',schemaVersion:1,game:e.game,trials,evaluations,generations:generation,
    elapsedMs:Math.round(performance.now()-started),...extra});
  try{
    await onRecord({type:'run_start',schemaVersion:1,engine:'differentiable_ecs@0.2.2/CMA-ES',experiment:e,
      optimizer:{seed,sigma,generations},budget:{maxTrials,maxSeconds},startedAt:new Date().toISOString()});
    if(trainCost+2*validationCost>maxTrials)fail('trial_limit');
    baseline=await evaluate(parameters,'train','baseline');best=baseline;
    const search=createSearch(e.parameters.map(p=>(p.initial-p.min)/(p.max-p.min)),{seed,sigma});
    let stopped='generations';
    for(;generation<generations;generation++){
      const population=search.ask(),fitness=[];
      if(trials+population.length*trainCost+2*validationCost>maxTrials){stopped='trials';break;}
      for(let i=0;i<population.length;i++){
        const params=parametersAt(e.parameters,population[i]);
        const result=await evaluate(params,'train',`${generation+1}:${i}`);
        const loss=result.report.valid?result.loss:1e90;
        fitness.push(loss);
        if(result.report.valid&&(!best.report.valid||loss<best.loss-1e-12))best=result;
      }
      search.tell(fitness);
    }
    const validationBaseline=await evaluate(parameters,'validation','baseline');
    const validationBest=await evaluate(best.params,'validation','selected');
    const improved=best.loss<baseline.loss-1e-12;
    const valid=best.report.valid&&validationBest.report.valid&&validationBaseline.report.valid;
    const accepted=improved&&valid&&validationBest.loss<=validationBaseline.loss+1e-12;
    const result=ending({status:!valid?'incomplete':accepted?'accepted':improved?'rejected':'unchanged',accepted,
      meetsGoals:accepted&&validationBest.loss<1e-12,stopReason:stopped,
      reviewRequired:true,experienceReview:(e.review??[]).map(r=>({...r,status:'pending'})),
      profile:accepted?{schemaVersion:1,game:e.game,parameters:best.params,reviewRequired:true}:null,
      training:{baseline,best},validation:{baseline:validationBaseline,best:validationBest}});
    await onRecord(result);return result;
  }catch(error){
    const limited=error instanceof AgentError&&['trial_limit','interrupted','request_limit'].includes(error.code);
    const result=ending({status:limited?'limit':'error',accepted:false,profile:null,
      reason:deadline.signal.aborted?'time':error instanceof AgentError?error.code:'experiment_failed',
      training:baseline?{baseline,best}:null});
    await onRecord(result);if(limited)return result;throw error;
  }finally{clearTimeout(timer);}
}
