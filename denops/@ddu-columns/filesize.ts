import type { DduItem, ItemHighlight } from "@shougo/ddu-vim/types";
import { BaseColumn, type GetTextResult } from "@shougo/ddu-vim/column";

import type { Denops } from "@denops/std";
import { basename } from "@std/path/basename";
import * as fn from "@denops/std/function";

type Params = {
};

export class Column extends BaseColumn<Params> {
  override kind = "filesize";
  override async getLength(args: {
    denops: Denops;
    columnParams: Params;
    items: DduItem[];
  }): Promise<number> {
	  return 7;
  }

  override async getBaseText(args: {
    denops: Denops;
    columnParams: Params;
    item: DduItem;
  }): Promise<string> {
    return createStrig(args.item);
  }

  override async getText(args: {
    denops: Denops;
    columnParams: Params;
    startCol: number;
    endCol: number;
    item: DduItem;
    baseText?: string;
  }): Promise<GetTextResult> {
	  const params = args.columnParams;
	  const highlights: ItemHighlight[] = [];
	  let sub_text: string = "";

	  sub_text = createStrig(args.item);

	  // ハイライト
	  const userHighlights = params.highlights;
	  highlights.push({
		  name: "column-filesize",
		  hl_group: "Title",
		  col: args.startCol + args.item.__level,
		  width: 8,
	  });

	  // パディング
	  const offset = 0;
	  const width = await fn.strwidth(args.denops, sub_text) as number;
	  const padding = " ".repeat(
		  Math.max(args.endCol - args.startCol - width + offset, 0),
	  );

	  return Promise.resolve({
		  text: padding + sub_text,
		  highlights: highlights,
	  });
  }

  override params(): Params {
    return {
    };
  }
}

function createStrig(item: DduItem): string {
	const status = item?.status;
	const isDirectory = item.isTree ?? false;
	const size = status.size as number | undefined;

	let sub_text: string = "";
	if ( isDirectory ) {
		sub_text = "";
	}else{
		if (size === undefined) {
			sub_text = "NG";
		}else{
			const units = ["B", "K", "M", "G", "T"];
			let i = 0;
			let s = size;
			while (s >= 1024 && i < units.length - 1) {
				s /= 1024;
				i++;
			}
			if(i){
				if(s < 100){
					sub_text = `${s.toFixed(2)}${units[i]}`;
				}else if(s < 1000){
					sub_text = `${s.toFixed(1)}${units[i]}`;
				}else{
					sub_text = `${s.toFixed(0)}${units[i]}`;
				}
			}else{
				sub_text = `${s.toFixed(0)}${units[i]}`;
			}
		}
	}
	return sub_text;
}
