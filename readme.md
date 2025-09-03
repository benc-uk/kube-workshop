# Kubernetes Developer Workshop

A comprehensive hands-on workshop for learning Kubernetes using Azure Kubernetes Service (AKS) as the platform. This workshop uses [Eleventy](https://www.11ty.dev/) as a static site generator to build and serve the workshop content.

## 🚀 Quick Start

### If you're just looking to view/run the workshop

Go here: [https://kube-workshop.benc.uk/](https://kube-workshop.benc.uk/)

### Prerequisites

- [Node.js](https://nodejs.org/) (version 20 or higher)
- [npm](https://www.npmjs.com/) (comes with Node.js)

### Installation & Development

1. **Clone the repository**

   ```bash
   git clone https://github.com/benc-uk/kube-workshop.git
   cd kube-workshop
   ```

2. **Install dependencies**

   ```bash
   npm install
   ```

3. **Start the development server**

   ```bash
   npm start
   ```

   This will start a local development server with hot reloading at `http://localhost:8080`

4. **Build for production**

   ```bash
   npm run build
   ```

   The built site will be generated in the `_site/` directory

## 📁 Project Structure

```
├── content/                # Workshop content (Markdown files)
│   ├── _includes/          # Eleventy templates and layouts
│   ├── 00-pre-reqs/        # Section 1: Prerequisites
│   ├── 01-cluster/         # Section 2: Cluster setup
│   └── ...                 # Additional workshop sections
├── _site/                  # Generated static site (ignored in git)
├── eleventy.config.js      # Eleventy configuration
├── package.json            # Node.js dependencies and scripts
└── README.md               # This file!
```

## 🛠️ Available Scripts

| Command              | Description                                 |
| -------------------- | ------------------------------------------- |
| `npm start`          | Start development server with hot reloading |
| `npm run build`      | Build static site for production            |
| `npm run clean`      | Remove the `_site/` directory               |
| `npm run lint`       | Format Markdown files with Prettier         |
| `npm run lint:check` | Check Markdown formatting                   |

## ✨ Contributing

### Content Guidelines

1. **All workshop content** is located in the [`content/`](content/) directory
2. **Use Markdown** with `.md` extension for all content files
3. **Follow the existing structure** - each section should be in its own directory with an `index.md` file
4. **Include navigation links** at the bottom of each section following the existing pattern
5. **Use relative links** for internal navigation and assets

### Adding New Sections

1. Create a new directory under [`content/`](content/) following the naming pattern: `##-section-name/`
2. Add an `index.md` file with the section content
3. Include any supporting files (YAML manifests, diagrams, etc.) in the same directory, they will be copied to the output
4. Update the main [`content/index.md`](content/index.md) to link to your new section

### Code Formatting

- Run `npm run lint` to format all Markdown files
- Use `npm run lint:check` to verify formatting without making changes
- The project uses [Prettier](https://prettier.io/) with a 120 character line width

### Local Testing

1. Make your changes in the [`content/`](content/) directory
2. Run `npm start` to serve the site locally
3. Verify your changes at `http://localhost:8080`
4. Test all navigation links and ensure assets load correctly
5. Run `npm run lint` to ensure consistent formatting

## 🌐 Deployment

The site is automatically built and deployed when changes are pushed to the main branch. The build process:

1. Runs `npm run build` to generate the static site
2. Deploys the contents of `_site/` directory
3. Makes the workshop available at the production URL

## 🐛 Troubleshooting

### Development Server Issues

- **Port already in use**: The default port is 8080. If it's occupied, Eleventy will try the next available port
- **Changes not reflecting**: Ensure you're editing files in the [`content/`](content/) directory, not the `_site/` directory
- **Build errors**: Check that all Markdown files are properly formatted and internal links are valid

### Content Issues

- **Broken links**: Use relative paths for internal links (e.g., `../01-cluster/index.md`)
- **Missing assets**: Ensure supporting files are in the same directory as the content that references them
- **Formatting problems**: Run `npm run lint` to fix common Markdown formatting issues

## 📚 Workshop Content

The workshop covers Kubernetes fundamentals check the `content/` directory for details.

For detailed content information, see the workshop itself at the deployed site or run locally with `npm start`.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
