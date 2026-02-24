{ inputs, lib, ... }:
{
  imports = [
    inputs.nixvim.homeModules.nixvim
    ./autocommands.nix
    #./completion.nix
    ./cmp.nix
    ./keymappings.nix
    ./options.nix
    ./plugins
    ./git.nix
    ./todo.nix
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    plugins.web-devicons.enable = true;

    performance = {
      combinePlugins = {
        enable = true;
        standalonePlugins = [
          "hmts.nvim"
          "neorg"
          "nvim-treesitter"
          "bufferline.nvim"
        ];
      };
      byteCompileLua.enable = true;
    };

    viAlias = true;
    vimAlias = true;

    luaLoader.enable = true;
  };
}
