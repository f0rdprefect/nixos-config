{
  programs.nixvim = {
    files."after/ftplugin/norg.lua" = {
      localOpts.conceallevel = 1;

      keymaps = [
        {
          mode = "n";
          key = "<C-g>";
          action = ":Neorg toc<CR>";
          options.silent = true;
        }
      ];
    };

    plugins.neorg = {
      enable = false;

      settings.load = {
        "core.defaults".__empty = null;

        "core.keybinds".config.hook.__raw = ''
          function(keybinds)
            keybinds.unmap('norg', 'n', '<C-s>')

            keybinds.map(
              'norg',
              'n',
              '<leader>c',
              ':Neorg toggle-concealer<CR>',
              {silent=true}
            )
          end
        '';

        "core.dirman".config.workspaces = {
          notes = "~/Documents/notes/general";
          nix = "~/Documents/notes/nix";
        };

        "core.concealer".__empty = null;
        "core.completion".config.engine = "nvim-cmp";
        "core.integrations.nvim-cmp".__empty = null;
        "core.qol.toc".config.close_after_use = true;
      };
    };
  };
}
