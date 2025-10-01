import type { DduItem, ItemHighlight } from "@shougo/ddu-vim/types";
import { BaseColumn, type GetTextResult } from "@shougo/ddu-vim/column";

import type { Denops } from "@denops/std";
import { basename } from "@std/path/basename";
import * as fn from "@denops/std/function";

type Params = {
  collapsedIcon: string;
  expandedIcon: string;
  iconWidth: number;
  indentationWidth: number;
  linkIcon: string;
  highlights: HighlightGroup;
};

type HighlightGroup = {
  directoryIcon?: string;
  directoryName?: string;
  linkIcon?: string;
  linkName?: string;
};

type ActionData = {
  isDirectory?: boolean;
  isLink?: boolean;
  path?: string;
  parent?: string;
};

export class Column extends BaseColumn<Params> {
  override kind = "customfilename";
  override async getLength(args: {
    denops: Denops;
    columnParams: Params;
    items: DduItem[];
  }): Promise<number> {
	  // 現在のWindowの幅を取得
	  const winwidth = await args.denops.call("winwidth", 0) as number;
	  // window幅から決まるcustomfilenameの最大幅 size = 7文字 datetime = 15文字
	  const max_width = winwidth - 7 - 15;
	  // ファイル名を省略する場合に最小幅
	  const min_width = 16;
	  return Math.max(min_width, max_width);
  }

  override async getBaseText(args: {
    denops: Denops;
    columnParams: Params;
    item: DduItem;
  }): Promise<string> {
    const action = args.item?.action as ActionData;
    const isDirectory = args.item.isTree ?? false;
    let path = basename(action.path ?? args.item.word) +
      (isDirectory ? "/" : "");
    const isLink = action.isLink ?? false;

    if (args.item.__groupedPath) {
      path = `${args.item.__groupedPath}${path}`;
    }
    if (isLink && action.path) {
      let realPath = "?";
      try {
        realPath = await Deno.realPath(action.path);
      } catch (_e: unknown) {
        // Ignore link error
      }
      path += ` -> ${realPath}`;
    }

    return path;
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
    const action = args.item?.action as ActionData;
    const highlights: ItemHighlight[] = [];
    const isDirectory = args.item.isTree ?? false;
    const isLink = action.isLink ?? false;

    if (isDirectory) {
      const userHighlights = params.highlights;
      highlights.push({
        name: "column-filename-directory-icon",
        hl_group: userHighlights.directoryIcon ?? "Special",
        col: args.startCol + args.item.__level,
        width: params.iconWidth,
      });

      if (args.baseText) {
        highlights.push({
          name: "column-filename-directory-name",
          hl_group: userHighlights.directoryName ?? "Directory",
          col: args.startCol + args.item.__level + params.iconWidth + 1,
          width: getByteLength(args.baseText),
        });
      }
    } else if (isLink) {
      const userHighlights = params.highlights;
      highlights.push({
        name: "column-filename-link-icon",
        hl_group: userHighlights.linkIcon ?? "Comment",
        col: args.startCol + args.item.__level,
        width: params.iconWidth,
      });

      if (args.baseText) {
        highlights.push({
          name: "column-filename-link-name",
          hl_group: userHighlights.linkName ?? "Comment",
          col: args.startCol + args.item.__level + params.iconWidth + 1,
          width: getByteLength(args.baseText),
        });
      }
    }

    const directoryIcon = args.item.__expanded
      ? params.expandedIcon
      : params.collapsedIcon;
    const icon = isDirectory ? directoryIcon : isLink ? params.linkIcon : " ";

	// ファイル名を取得
    let text =
      " ".repeat(Math.max(params.indentationWidth * args.item.__level, 0)) +
      icon + " " + args.baseText;
    // const width = await fn.strwidth(args.denops, text) as number;
	// ファイル名が列幅を越える場合は間を省略
    let width = getByteLength(text) as number;
    const col_length = (args.endCol - args.startCol) as number;
	if(width > col_length){
		// 切り取り長さ
		const clip_len = Math.floor((col_length -2) / 2) as number;
		// ファイル名の切り取り
		const first_str = substringByBytes(text, clip_len) as string;
		const end_str = substringByBytes(text, -clip_len) as string;
		text = first_str + ".." + end_str;
		width = getByteLength(text);
	}
    const padding = " ".repeat(
      Math.max(args.endCol - args.startCol - width, 0),
    );

    return Promise.resolve({
      text: text + padding,
      highlights: highlights,
    });
  }

  override params(): Params {
    return {
      collapsedIcon: "+",
      expandedIcon: "-",
      iconWidth: 1,
      indentationWidth: 1,
      linkIcon: "@",
      highlights: {},
    };
  }
}
function getByteLength(str: string): number {
  return new TextEncoder().encode(str).length;
}

function substringByBytes(str: string, maxBytes: number): string {
  const encoder = new TextEncoder();
  const decoder = new TextDecoder();

  const bytes = encoder.encode(str);

  if (maxBytes === 0) {
    return "";
  }

  if (maxBytes > 0) {
    // 先頭から maxBytes バイト分
    const slice = bytes.slice(0, maxBytes);
    return decoder.decode(slice, { fatal: false });
  } else {
    // 末尾から |maxBytes| バイト分
    const absBytes = Math.abs(maxBytes);
    const slice = bytes.slice(Math.max(0, bytes.length - absBytes));
    return decoder.decode(slice, { fatal: false });
  }
}
