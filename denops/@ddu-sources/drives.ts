import type { Context, Item, SourceOptions } from "@shougo/ddu-vim/types";
import { BaseSource } from "@shougo/ddu-vim/source";

import { type ActionData } from "@shougo/ddu-kind-file";

import type { Denops } from "@denops/std";

type Params = {
  chunkSize: 1000;
  ignoredDirectories: string[];
  expandSymbolicLink: boolean;
};

type Args = {
  denops: Denops;
  context: Context;
  sourceOptions: SourceOptions;
  sourceParams: Params;
};

export class Source extends BaseSource<Params> {
  override kind = "drives";

  override gather(
    { sourceOptions, sourceParams, context }: Args,
  ): ReadableStream<Item<ActionData>[]> {
    const abortController = new AbortController();

    return new ReadableStream({
      async start(controller) {
		  // ドライブ一覧取得
		  const command = new Deno.Command("powershell", {
			  args: [
				  "-Command",
				  "Get-Volume | Where-Object DriveLetter | ForEach-Object {\"$($_.DriveLetter): $($_.FileSystemLabel)\"}",
			  ],
			  stdout: "piped",
		  });

		  const output = await command.output();
		  const text = new TextDecoder().decode(output.stdout);

		  // --- 出力例 ---
		  // Caption  VolumeName
		  // C:       Windows
		  // D:       Data
		  // E:       

		  // --- パース処理 ---
		  const lines = text
		  .split("\n")
		  .map((l) => l.trim())
		  .filter((l) => /^[A-Z]:/.test(l)); // A: で始まる行だけ

		  // まず、ドライブ名とボリューム名の配列を作成
		  const driveVolumes = lines.map((line) => {
			  const parts = line.trim().split(/\s+/);
			  const drive = parts[0].replace(":", "");
			  const volume = parts.slice(1).join(" ") || "No Label";
			  return { drive, volume };
		  });

		  // --- DduItem[] に変換 ---
		  const items: DduItem<ActionData>[] = driveVolumes.map(({drive, volume}) => ({

			  //word: drive + ":\\ (" + volume + ")",
			  word: drive + ":\\",
			  action: { path: drive + ":\\"},
			  isTree: true,
		  }));

		  // enqueueしてclose
		  controller.enqueue(items);
		  controller.close();
      },

      cancel(reason): void {
        abortController.abort(reason);
      },
    });
  }

  override params(): Params {
    return {
      chunkSize: 1000,
      ignoredDirectories: [".git"],
      expandSymbolicLink: false,
    };
  }
}


