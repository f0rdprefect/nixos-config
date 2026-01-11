{
  programs.nixvim.plugins = {
    treesitter = {
      enable = true;

      nixGrammars = true;
      nixvimInjections = true;

      settings = {
        highlight.enable = true;
        indent.enable = true;
      };
      folding.enable = true;
    };

    treesitter-refactor = {
      enable = false;
      settings = {
        highlight_definitions = {
          # enabled makes nvim choke on some flakes
          enable = false;
          # Set to false if you have an `updatetime` of ~100.
          clear_on_cursor_move = false;
        };
      };
    };
    treesitter-context = {
      enable = true;
      settings = {
        max_lines = 2;
      };
    };
    rainbow-delimiters.enable = true;

    hmts.enable = true;
  };
}
