const criteria={
  challenge:[['flat','There is little resistance, tension or need to respond'],['varied','Tension and recovery create readable opportunities to respond'],['overwhelming','Repeated pressure leaves little room to understand or recover'],['unknown','The supplied evidence is insufficient']],
  agency:[['cosmetic','Different choices have little visible consequence'],['responsive','Defending, healing or target choices visibly change the situation'],['punishing','The consequences appear hard to anticipate or recover from'],['unknown','The supplied evidence is insufficient']],
};
export const reviewInstructions=`Evaluate PLAYER EXPERIENCE, not whether the agent found correct moves or won. A win can be flat or satisfying; a loss can be fair and interesting. Judge whether observed pressure, recovery and action consequences support readable, meaningful decisions. Use only the supplied mechanical trace. Do not infer animation, sound, reaction time, actual human enjoyment or psychological state. Use unknown when the evidence does not support a judgment. These judgments are hypotheses for a designer, not measurements of fun.`;

export async function reviewExperience(client,trial,{signal}={}){
  const judgments={};
  for(const [criterion,ratings] of Object.entries(criteria)){
    const observation={schemaVersion:2,game:'experience_review',phase:'review',revision:0,terminal:false,
      state:{criterion,metrics:trial.metrics,evidence:trial.experience},
      choices:ratings.map(([id,label])=>({id,label,action:{kind:'rate-experience'}}))};
    const decision=await client.choose(observation,{signal,instructions:reviewInstructions});
    judgments[criterion]={rating:decision.choiceId,confidence:decision.confidence,probabilities:decision.probabilities,model:decision.model,usage:decision.usage,elapsedMs:decision.elapsedMs,attempts:decision.attempts};
  }
  return {kind:'model-hypothesis',judgments,renderedFeedback:'not-observed',humanExperience:'not-observed'};
}
