// Edit scene literals here or in Kagura Studio. Keep behavior outside the managed region.
// kagura-scene:begin
///|
pub fn training() -> @scene_document.Document {
  {
    version: 1,
    name: "Flappy Bird",
    units: "meters",
    up: "Y",
    forward: "+Z",
    nodes: [],
    action: {
      target: "",
      duration: 1,
      flashDuration: 0.08,
      recoilDuration: 0.3,
      recoilStrength: 0.4,
    },
    resources: [{
        id: "kagura.example",
        kind: "kagura.example",
        version: 1,
        data: {
          "example": "flappy_bird",
          "query": Json::empty_object(),
        },
      }, {
        id: "kagura.scene2d",
        kind: "kagura.scene2d",
        version: 1,
        data: {
          "coordinates": "pixels-y-down",
          "width": 320,
          "height": 240,
          "background": 8900331,
          "objects": [{
              "id": "ground",
              "name": "Ground",
              "kind": "ground",
              "x": 0,
              "y": 220,
              "width": 320,
              "height": 20,
              "color": 9127187,
            }, {
              "id": "bird",
              "name": "Bird",
              "kind": "bird",
              "x": 60,
              "y": 120,
              "width": 12,
              "height": 12,
              "color": 16766720,
            }],
        },
      }],
  }
}
// kagura-scene:end
