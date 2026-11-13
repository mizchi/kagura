export interface Choice {id:string;label:string;action:{kind:string;[key:string]:unknown}}
export interface Observation {schemaVersion:2;revision:number;phase:string;terminal:boolean;choices:Choice[];[key:string]:unknown}
export interface Decision {choiceId:string;confidence:number;probabilities:Record<string,number>;model:string;usage:{inputTokens:number;outputTokens:number};elapsedMs:number;attempts:number}
