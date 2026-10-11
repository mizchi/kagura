/**
 * JSON boundary for `kagura scene3d`. `request` is
 * {operation:'check', allow?:string[], tolerance?:number} | {operation:'distance', paths:[string,string]} |
 * {operation:'overlaps', tolerance?:number} | {operation:'raycast', from:[number,number,number], direction:[number,number,number]};
 * `snapshot` is the text of a kagura.scene3d-snapshot document.
 * Returns {ok:true,value:unknown,text:string,exitCode:0|1} or {ok:false,error:string}.
 */
export function analyzeScene3d(request: string, snapshot: string): string;
