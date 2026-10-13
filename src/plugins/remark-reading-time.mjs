import getReadingTime from "reading-time";

const skippedNodes = new Set([
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
function getReadableText(node) {
	if (["text", "inlineCode", "code", "math", "inlineMath"].includes(node.type)) {
		return node.value;
	}
	if (node.type === "break" || node.type === "html") return " ";
	if (skippedNodes.has(node.type) || !Array.isArray(node.children)) return "";

	const parts = node.children.map(getReadableText).filter(Boolean);
	return parts.join(blockNodes.has(node.type) ? " " : "");
}

function countCharacters(text) {
	return Array.from(text.replace(/\s/gu, "")).length;
}

export function remarkReadingTime() {
	return (tree, { data }) => {
		const textOnPage = getReadableText(tree);
		const readingTime = getReadingTime(textOnPage);
		data.astro.frontmatter.minutes = Math.max(
			1,
			Math.ceil(readingTime.minutes),
		);
		data.astro.frontmatter.words = countCharacters(textOnPage);
	};
}
