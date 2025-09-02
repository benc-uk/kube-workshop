import syntaxHighlight from "@11ty/eleventy-plugin-syntaxhighlight";
import markdownIt from "markdown-it";
import markdownItAttrs from "markdown-it-attrs";

export default function (eleventyConfig) {
  eleventyConfig.addPlugin(syntaxHighlight);

  eleventyConfig.addPassthroughCopy("assets");
  eleventyConfig.addPassthroughCopy("**/*.yaml");
  eleventyConfig.addPassthroughCopy("**/*.sql");
  eleventyConfig.addPassthroughCopy("**/*.png");
  eleventyConfig.addPassthroughCopy("**/*.sh");
  eleventyConfig.addPassthroughCopy("**/*.svg");

  eleventyConfig.addFilter("zeroPad", function (num, places = 2) {
    return String(num).padStart(places, "0");
  });

  let options = {
    html: true,
  };

  const markdownLib = markdownIt(options).use(markdownItAttrs);
  eleventyConfig.setLibrary("md", markdownLib);
}
