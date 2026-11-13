import "../../web/style.css";
import { installExperienceViewer } from "../../experience/viewer.mjs";
import { exampleRecording } from "./experience-data.mjs";
const viewer = installExperienceViewer();
viewer.open();
viewer.load(exampleRecording());
