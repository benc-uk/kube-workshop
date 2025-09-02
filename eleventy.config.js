export default function (eleventyConfig) {
  eleventyConfig.addPassthroughCopy("assets");
  eleventyConfig.addPassthroughCopy("**/*.yaml");
  eleventyConfig.addPassthroughCopy("**/*.sql");
}
