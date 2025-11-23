module ApplicationHelper
  # Returns inline CSS with theme CSS variables
  def theme_css_variables
    theme = ThemeSetting.current

    # Font family mapping
    font_map = {
      'system' => '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif',
      'arial' => 'Arial, sans-serif',
      'helvetica' => 'Helvetica, sans-serif',
      'georgia' => 'Georgia, serif',
      'times' => '"Times New Roman", Times, serif',
      'courier' => '"Courier New", Courier, monospace',
      'verdana' => 'Verdana, sans-serif'
    }

    font_stack = font_map[theme.font_family] || font_map['system']

    <<~CSS.html_safe
      <style>
        :root {
          --theme-primary-color: #{theme.primary_color};
          --theme-secondary-color: #{theme.secondary_color};
          --theme-font-family: #{font_stack};
        }

        /* Apply theme font to body */
        body {
          font-family: var(--theme-font-family);
        }

        /* Override Tailwind's purple colors with theme colors */
        .bg-purple-500 {
          background-color: var(--theme-primary-color) !important;
        }

        .bg-purple-600 {
          background-color: var(--theme-primary-color) !important;
        }

        .bg-purple-700 {
          background-color: var(--theme-primary-color) !important;
          filter: brightness(0.9);
        }

        .bg-purple-100 {
          background-color: var(--theme-primary-color) !important;
          opacity: 0.1;
        }

        .bg-purple-50 {
          background-color: var(--theme-primary-color) !important;
          opacity: 0.05;
        }

        .text-purple-500 {
          color: var(--theme-primary-color) !important;
        }

        .text-purple-600 {
          color: var(--theme-primary-color) !important;
        }

        .text-purple-700 {
          color: var(--theme-primary-color) !important;
          filter: brightness(0.9);
        }

        .text-purple-800 {
          color: var(--theme-primary-color) !important;
          filter: brightness(0.8);
        }

        .text-purple-900 {
          color: var(--theme-primary-color) !important;
          filter: brightness(0.7);
        }

        .border-purple-600 {
          border-color: var(--theme-primary-color) !important;
        }

        .ring-purple-500,
        .focus\\:ring-purple-500:focus {
          --tw-ring-color: var(--theme-primary-color) !important;
        }

        .focus\\:border-purple-500:focus {
          border-color: var(--theme-primary-color) !important;
        }

        /* Hover states */
        .hover\\:bg-purple-50:hover {
          background-color: var(--theme-primary-color) !important;
          opacity: 0.05;
        }

        .hover\\:bg-purple-700:hover {
          background-color: var(--theme-primary-color) !important;
          filter: brightness(0.9);
        }

        .hover\\:text-purple-700:hover {
          color: var(--theme-primary-color) !important;
          filter: brightness(0.9);
        }

        .hover\\:text-purple-900:hover {
          color: var(--theme-primary-color) !important;
          filter: brightness(0.7);
        }

        /* Gradient overrides - using theme primary and blue */
        .bg-gradient-to-r.from-purple-600 {
          background: linear-gradient(to right, var(--theme-primary-color), #2563eb) !important;
        }

        .hover\\:from-purple-700:hover {
          background: linear-gradient(to right, var(--theme-primary-color), #1d4ed8) !important;
          filter: brightness(0.95);
        }

        /* Gradient text */
        .gradient-text {
          background: linear-gradient(135deg, var(--theme-primary-color) 0%, #2563eb 100%);
          -webkit-background-clip: text;
          -webkit-text-fill-color: transparent;
          background-clip: text;
        }
      </style>
    CSS
  end
end
