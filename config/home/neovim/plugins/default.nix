{
  inputs,
  lib,
  pkgs,
  ...
}:
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
    # WIP
    extraPlugins = with pkgs.vimPlugins; [
      outline-nvim
      img-clip-nvim
    ];
    extraConfigLua = ''
      require("outline").setup({})
    '';
    keymaps = [
      {
        mode = "n";
        key = "<leader>oo";
        options.silent = true;
        action = ":OutlineOpen<CR>";
      }
      {
        mode = "n";
        key = "<leader>oc";
        options.silent = true;
        action = ":OutlineClose<CR>";
      }
      {
        # new markdown note creation
        mode = "n";
        key = "<c-n><c-n>";
        action = ":e <c-r><c-w>.md<CR>";
        options.silent = true;
      }
    ];
    # END WIP
  };
}
