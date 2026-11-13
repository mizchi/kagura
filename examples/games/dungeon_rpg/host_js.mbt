///|
fn install_platform() -> Unit {
  @hooks.install("#app")
}

///|
extern "js" fn install_host(
  read : () -> String,
  command : (String, Int32) -> String,
  save : () -> String,
  load : (String) -> String,
  paused : () -> Bool,
  pose : (Int32, Int32, Int32) -> String,
  read_agent : () -> String,
  step_agent : (Int32, String) -> String,
  reset_agent : (Int32, String, String) -> String,
  load_master : (String) -> String,
  read_master : () -> String,
  read_experience : (Int32) -> String,
) -> Unit =
  #| (read,command,save,load,paused,pose,readAgent,stepAgent,resetAgent,loadMaster,readMaster,readExperience) => {
  #| fetch('assets/host.mjs').then(r=>{if(!r.ok)throw Error(`FATHOM host: ${r.status}`);return r.text()})
  #| .then(async source=>{const url=URL.createObjectURL(new Blob([source],{type:'text/javascript'}));try{await (await import(url)).install({read:()=>JSON.parse(read()),command,save,load,paused,pose:(kind,count,index)=>JSON.parse(pose(kind,count,index)),readAgent,stepAgent,resetAgent,loadMaster,readMaster,readExperience})}finally{URL.revokeObjectURL(url)}})
  #| .catch(error=>{console.error(error);document.body.append(Object.assign(document.createElement('pre'),{textContent:String(error)}))});
  #| }

///|
fn App::platform_update(_self : App, _raw : @core.InputSnapshot) -> Unit {
  ()
}

///|
fn platform_overlay(_g : @sim.Game, _nodes : Array[@scene.SceneNode]) -> Unit {
  ()
}

///|
extern "js" fn surface_aspect() -> Double =
  #| () => innerWidth / Math.max(1, innerHeight)

///|
extern "js" fn surface_height() -> Double =
  #| () => Math.max(1,innerHeight)
