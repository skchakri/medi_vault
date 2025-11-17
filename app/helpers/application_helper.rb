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
        .bg-purple-600 {
          background-color: var(--theme-primary-color) !important;
        }

        .bg-purple-700 {
          background-color: var(--theme-primary-color) !important;
          filter: brightness(0.9);
        }

        .text-purple-600 {
          color: var(--theme-primary-color) !important;
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
        .hover\\:bg-purple-700:hover {
          background-color: var(--theme-primary-color) !important;
          filter: brightness(0.9);
        }

        .hover\\:text-purple-700:hover {
          color: var(--theme-primary-color) !important;
          filter: brightness(0.9);
        }
      </style>
    CSS
  end
end
