#!/usr/bin/env node

const os = process.platform;

let platformLibs = "";
let audioLibs = "";

if (os === "darwin") {
  platformLibs = "-framework Metal -framework QuartzCore -framework IOKit -framework CoreFoundation -framework Cocoa -framework Foundation";
  audioLibs = `${platformLibs} -framework AudioToolbox -framework CoreAudio`;
} else if (os === "linux") {
  platformLibs = "-ldl -lpthread -lm -lX11 -lXrandr -lXi -lXcursor -lXinerama -lXxf86vm";
  audioLibs = `${platformLibs} -lasound`;
} else if (os === "win32") {
  platformLibs = "-lgdi32 -luser32 -lkernel32 -lshell32 -lole32 -luuid";
  audioLibs = `${platformLibs} -lwinmm`;
}

const payload = {
  vars: {
    KAGURA_NATIVE_PLATFORM_LIBS: platformLibs,
    KAGURA_NATIVE_AUDIO_LIBS: audioLibs,
  },
};

process.stdout.write(`${JSON.stringify(payload)}\n`);
