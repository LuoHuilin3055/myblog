import getReadingTime from "reading-time";

const skippedNodes = new Set([
	"code",
	"math",
	"inlineMath",
	"image",
	"imageReference",
]);
const blockNodes = new Set([
	"root",
	"blockquote",
	"list",
	"listItem",
	"table",
	"tableRow",
]);
const cjkPattern =
	/[\p{Script=Han}\p{Script=Hiragana}\p{Script=Katakana}\p{Script=Hangul}]/gu;
const wordPattern = /[\p{L}\p{N}]+(?:['’][\p{L}\p{N}]+)*/gu;

function getReadableText(node) {
	if (node.type === "text" || node.type === "inlineCode") return node.value;
	if (node.type === "break" || node.type === "html") return " ";
	if (skippedNodes.has(node.type) || !Array.isArray(node.children)) return "";

	const parts = node.children.map(getReadableText).filter(Boolean);
	return parts.join(blockNodes.has(node.type) ? " " : "");
}

function countWords(text) {
	const cjkCount = text.match(cjkPattern)?.length ?? 0;
	const otherText = text.replace(cjkPattern, " ");
	const otherWords = otherText.match(wordPattern)?.length ?? 0;
	return cjkCount + otherWords;
}

export function remarkReadingTime() {
	return (tree, { data }) => {
		const textOnPage = getReadableText(tree);
		const readingTime = getReadingTime(textOnPage);
		data.astro.frontmatter.minutes = Math.max(
			1,
			Math.round(readingTime.minutes),
		);
		data.astro.frontmatter.words = countWords(textOnPage);
	};
}
