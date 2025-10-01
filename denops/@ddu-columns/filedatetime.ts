import type { DduItem, ItemHighlight } from "@shougo/ddu-vim/types";
import { BaseColumn, type GetTextResult } from "@shougo/ddu-vim/column";

import type { Denops } from "@denops/std";
import { basename } from "@std/path/basename";
import * as fn from "@denops/std/function";

type Params = {
};

export class Column extends BaseColumn<Params> {
  override kind = "filedatetime";
  override async getLength(args: {
    denops: Denops;
    columnParams: Params;
    items: DduItem[];
  }): Promise<number> {
    return 15;
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
	  const time = args.item?.status.time as number | undefined;
	  const now = new Date();
	  const delta_time = now - time;
	  let color_name: string;
	  if (!(time === undefined)) {
		  if(delta_time < 86400000){
			  color_name = "Number";
		  }else if(delta_time < 604800000){
			  color_name = "MoreMsg";
		  }else{
			  color_name = "Directory";
		  }
	  }
	  const userHighlights = params.highlights;
	  highlights.push({
		  name: "column-filedatetime",
		  hl_group: color_name,
		  col: args.startCol + args.item.__level,
		  width: 16,
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
	const time = status.time as number | undefined;

	let sub_text: string = "";
	if (time === undefined) {
		sub_text = "NG";
	}else{
		sub_text = formatTimestamp(time);
	}
	return sub_text;
}
function formatTimestamp(timestamp: number): string {
  const date = new Date(timestamp); // ms単位のタイムスタンプを想定

  const yy = String(date.getFullYear()).slice(-2);
  const mm = String(date.getMonth() + 1).padStart(2, "0");
  const dd = String(date.getDate()).padStart(2, "0");

  const hh = String(date.getHours()).padStart(2, "0");
  const min = String(date.getMinutes()).padStart(2, "0");

  return ` ${yy}/${mm}/${dd} ${hh}:${min}`;
}
