/** Serialized ParseReply. Keeps MoonBit enums private to the implementation. */
export function parseCli(argv: string[]): string;
export function helpText(): string;
export function scaffoldFiles(name: string): string;
export function projectName(directory: string, currentDirectory: string): string;

export interface BrowserOptions {
  url: string;
  output: string | null;
  viewport: {width: number; height: number};
  headed: boolean;
  timeout: number;
  samples: number;
  profileMs: number;
  warmupMs: number;
}

export type ParseReply =
  | {ok: false; error: string}
  | {ok: true; command: 'new'; directory: string}
  | {ok: true; command: 'help'; topic: string | null}
  | {ok: true; command: 'dev'; project: string | null; port: number | null; host: string}
  | {ok: true; command: 'build'; project: string | null; outDir: string | null}
  | {ok: true; command: 'studio'; port: number | null; host: string}
  | ({ok: true; command: 'capture' | 'profile'} & BrowserOptions);
