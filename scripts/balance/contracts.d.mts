export interface Parameter {name:string; min:number; max:number; step:number; initial:number}
export interface Selector {cohort:string; metric:string}
export interface Goal extends Selector {axis?:'challenge'|'pacing'|'agency'|'feedback'|'guardrail'; subtract?:Selector; min:number; max:number; scale:number; weight:number}
export interface Experiment {
  schemaVersion:1; game:string; parameters:Parameter[]; policies:string[]; seats:string[];
  trainSeeds:number[]; validationSeeds:number[]; goals:Goal[];
  guards?:Array<Selector & {min?:number;max?:number}>;
  review?:Array<{id:string;question:string;evidence:'trace'|'rendered'|'human'}>;
}
export interface TrialInput {
  params:Readonly<Record<string,number>>; seed:number; policy:string; seat:string; signal:AbortSignal;
}
export interface Trial {
  status:'victory'|'defeat'|'draw'|'returned'|'limit'; metrics:Record<string,number>;
}
export interface GameAdapter {
  experiment:Experiment;
  runTrial(input:TrialInput):Promise<Trial>|Trial;
}
