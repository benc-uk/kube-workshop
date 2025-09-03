import syntaxHighlight from "@11ty/eleventy-plugin-syntaxhighlight";
import markdownIt from "markdown-it";
import markdownItAttrs from "markdown-it-attrs";

export default function (eleventyConfig) {
  eleventyConfig.addPlugin(syntaxHighlight);

  eleventyConfig.addPassthroughCopy("./content/**/*.yaml");
  eleventyConfig.addPassthroughCopy("./content/**/*.sql");
  eleventyConfig.addPassthroughCopy("./content/**/*.png");
  eleventyConfig.addPassthroughCopy("./content/**/*.sh");
  eleventyConfig.addPassthroughCopy("./content/**/*.svg");

  eleventyConfig.addFilter("zeroPad", function (num, places = 2) {
    return String(num).padStart(places, "0");
  });

  let options = {
    html: true,
  };

  // Plugin to make external links open in new tab/window
  function externalLinksPlugin(md) {
    const defaultRender =
      md.renderer.rules.link_open ||
      function (tokens, idx, options, env, self) {
        return self.renderToken(tokens, idx, options);
      };

    md.renderer.rules.link_open = function (tokens, idx, options, env, self) {
      const token = tokens[idx];
      const hrefIndex = token.attrIndex("href");

      if (hrefIndex >= 0) {
        const href = token.attrs[hrefIndex][1];

        // Check if it's an external link (starts with http:// or https://)
        if (href.match(/^https?:\/\//)) {
          // Add target="_blank" and rel="noopener noreferrer" for security
          token.attrSet("target", "_blank");
          token.attrSet("rel", "noopener noreferrer");
        }
      }

      return defaultRender(tokens, idx, options, env, self);
    };
  }

  const markdownLib = markdownIt(options)
    .use(markdownItAttrs)
    .use(externalLinksPlugin);
  eleventyConfig.setLibrary("md", markdownLib);
}
