// Transport/replay fixture uses the explicit tactical policy.
import {policyDecision} from './policies.mjs';
export const testPolicy=observation=>policyDecision(observation,'tactical');
