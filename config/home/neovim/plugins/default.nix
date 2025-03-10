{ inputs, lib, ... }:
{
  imports = [
    ./avante.nix
    ./barbar.nix
    ./blankline.nix
    ./bufferline.nix
    ./comment.nix
    ./floaterm.nix
    ./fidget.nix
    ./harpoon.nix
    ./lsp.nix
    ./lualine.nix
    ./markdown-preview.nix
    ./neorg.nix
    ./neo-tree.nix
    ./startify.nix
    ./tagbar.nix
    ./telescope.nix
    ./treesitter.nix
    #./vimtex.nix # inria
    ./which-key.nix
  ];

  programs.nixvim = {
    plugins = {
      web-devicons.enable = true;
      image = {
        enable = true;
        integrations.neorg.enabled = true;
        integrations.markdown.enabled = true;
        backend = "kitty";
      };
      lastplace.enable = true;
      gitsigns = {
        enable = true;
        settings.signs = {
          add.text = "+";
          change.text = "~";
        };
      };

      nvim-autopairs.enable = true;

      colorizer = {
        enable = true;
      };

      oil.enable = true;

      trim = {
        enable = true;
        settings = {
          highlight = true;
          ft_blocklist = [
            "checkhealth"
            "floaterm"
            "lspinfo"
            "neo-tree"
            "TelescopePrompt"
          ];
        };
      };
    };
  };
}
