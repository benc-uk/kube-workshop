const themeToggle = document.querySelector(".theme-toggle");
const sidebarToggle = document.querySelector(".sidebar-toggle");
const sidebar = document.querySelector(".sidebar");
const mainContent = document.querySelector("main");
const html = document.documentElement;

// Check for saved theme preference or default to auto
const currentTheme = localStorage.getItem("theme") || "auto";

// Sidebar toggle functionality
sidebarToggle.addEventListener("click", () => sidebar.classList.toggle("collapsed"));
mainContent.addEventListener("click", () => sidebar.classList.add("collapsed"));

// Apply saved theme on page load
if (currentTheme === "dark") {
  html.setAttribute("data-theme", "dark");
} else if (currentTheme === "light") {
  html.setAttribute("data-theme", "light");
} else {
  // Remove data-theme to use system preference
  html.removeAttribute("data-theme");
}

// Theme toggle event listener
themeToggle.addEventListener("click", function () {
  const currentTheme = html.getAttribute("data-theme");

  // Add class to prevent transition flicker
  document.body.classList.add("theme-switching");

  if (currentTheme === "dark") {
    html.setAttribute("data-theme", "light");
    localStorage.setItem("theme", "light");
  } else if (currentTheme === "light") {
    html.removeAttribute("data-theme");
    localStorage.setItem("theme", "auto");
  } else {
    html.setAttribute("data-theme", "dark");
    localStorage.setItem("theme", "dark");
  }

  // Remove the class after a short delay
  setTimeout(() => {
    document.body.classList.remove("theme-switching");
  }, 50);

  // Update button text
  updateThemeButtonText();
});

// Update button text based on current theme
function updateThemeButtonText() {
  const currentTheme = html.getAttribute("data-theme");

  if (currentTheme === "dark") {
    themeToggle.textContent = "Light";
  } else if (currentTheme === "light") {
    themeToggle.textContent = "Auto";
  } else {
    themeToggle.textContent = "Dark";
  }
}

// Initial button text update
updateThemeButtonText();

// Listen for system theme changes when in auto mode
window.matchMedia("(prefers-color-scheme: dark)").addEventListener("change", updateThemeButtonText);
