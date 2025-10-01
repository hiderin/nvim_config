import type { Context, Item, SourceOptions } from "@shougo/ddu-vim/types";
import { BaseSource } from "@shougo/ddu-vim/source";
import { treePath2Filename } from "@shougo/ddu-vim/utils";

import { type ActionData } from "@shougo/ddu-kind-file";

import type { Denops } from "@denops/std";

import { join } from "@std/path/join";
import { resolve } from "@std/path/resolve";
import { relative } from "@std/path/relative";
import { abortable } from "@std/async/abortable";

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
  override kind = "file";

  override gather(
    { sourceOptions, sourceParams, context }: Args,
  ): ReadableStream<Item<ActionData>[]> {
    const abortController = new AbortController();

    return new ReadableStream({
      async start(controller) {
		  // ドライブ一覧取得
		  const drives: string[] = [];
		  for (const letter of "ABCDEFGHIJKLMNOPQRSTUVWXYZ") {
			  const drive = `${letter}:\\`;
			  try {
				  await Deno.stat(drive);
				  drives.push(drive);
			  } catch {
				  // 無視
			  }
		  }
		  // --- DduItem[] に変換 ---
		  const items: DduItem<ActionData>[] = drives.map((drive) => ({
			  word: drive,
			  action: { path: drive},
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


