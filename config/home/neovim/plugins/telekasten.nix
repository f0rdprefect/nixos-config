{
  programs.nixvim = {
    plugins.telekasten = {
      enable = true;
      settings = {
        #home = lib.nixvim.mkRaw "vim.fn.expand(\"~/zettelkasten\")";
        home.__raw = ''vim.fn.expand("~/zettelkasten")'';
      };
    };
    keymaps = [
      {
        mode = "n";
        key = "<leader>z";
        action = "<cmd>Telekasten panel<CR>";
      }

      {
        mode = "n";
        key = "<leader>zf";
        action = "<cmd>Telekasten find_notes<CR>";
      }

      {
        mode = "n";
        key = "<leader>zg";
        action = "<cmd>Telekasten search_notes<CR>";
      }

      {
        mode = "n";
        key = "<leader>zd";
        action = "<cmd>Telekasten goto_today<CR>";
      }

      {
        mode = "n";
        key = "<leader>zz";
        action = "<cmd>Telekasten follow_link<CR>";
      }

      {
        mode = "n";
        key = "<leader>zn";
        action = "<cmd>Telekasten new_note<CR>";
      }

      {
        mode = "n";
        key = "<leader>zc";
        action = "<cmd>Telekasten show_calendar<CR>";
      }

      {
        mode = "n";
        key = "<leader>zb";
        action = "<cmd>Telekasten show_backlinks<CR>";
      }

      {
        mode = "n";
        key = "<leader>zI";
        action = "<cmd>Telekasten insert_img_link<CR>";
      }

      {
        mode = "i";
        key = "[[";
        action = "<cmd>Telekasten insert_link<CR>";
      }
    ];
  };
}
