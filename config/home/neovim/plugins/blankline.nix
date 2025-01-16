{
  # draws a vertical line to indicate scope
  programs.nixvim.plugins.indent-blankline = {
    enable = true;
    settings = {
      indent = {
        smart_indent_cap = true;
        char = " ";
      };
      scope = {
        enabled = true;
        char = "│";
      };
    };
  };
}
