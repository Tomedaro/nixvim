# modules/hardtime/default.nix
{
  lib,
  pkgs,
  config,
  ...
}: # Standard module arguments

let
  # Define a configuration path for hardtime options within nixvim structure
  cfg = config.programs.nixvim.plugins.hardtime;
  pluginPkg = pkgs.vimPlugins.hardtime-nvim;
in
{
  # Define options for this module, making it easily configurable
  options.programs.nixvim.plugins.hardtime = {
    enable = lib.mkEnableOption "hardtime.nvim - Vim motion training plugin";

    # Expose some common hardtime.nvim settings as Nix options
    disabledFiletypes = lib.mkOption {
      type = with lib.types; listOf str;
      default = [
        "NvimTree"
        "neo-tree"
        "dashboard"
        "packer"
        "lazy"
        "TelescopePrompt"
        "mason"
        "Overseer"
      ];
      description = "Filetypes where hardtime.nvim should be disabled by default.";
    };

    # You could expose more options like 'score_decay', 'hint_show_threshold' etc.
    # For example:
    # scoreDecay = lib.mkOption {
    #   type = lib.types.float;
    #   default = 0.5; # Default from hardtime.nvim docs
    #   description = "Score decay rate.";
    # };
  };

  # Apply the configuration if this module is enabled
  config = lib.mkIf cfg.enable {
    # Add hardtime.nvim to the list of plugins
    programs.nixvim.extraPlugins = [ pluginPkg ];

    # Configure hardtime.nvim using Lua
    programs.nixvim.extraConfigLua = ''
      require('hardtime').setup({
        -- If cfg.enable is true, we enable it here.
        -- Alternatively, you can set this to false and use commands to toggle.
        enabled = true,
        disabled_filetypes = ${lib.generators.toLua cfg.disabledFiletypes},
        -- Example of using another Nix option if you defined it:
        -- score_decay = ${toString cfg.scoreDecay}, -- Ensure type matches Lua expectation
        -- Add any other specific hardtime.nvim configurations here:
        -- See :help hardtime.txt for all available options
        -- notification_progress_bar = "", -- Example: if you have nerd fonts
      })
    '';

    # Optional: Add user commands to easily toggle/control hardtime
    programs.nixvim.extraCommands = {
      HardtimeToggle = "lua require('hardtime').toggle()";
      HardtimeEnable = "lua require('hardtime').enable()";
      HardtimeDisable = "lua require('hardtime').disable()";
      HardtimeReport = "lua require('hardtime').report()";
    };

    # Optional: Keymap for toggling
    programs.nixvim.keymaps = [
      {
        mode = "n"; # Normal mode
        key = "<leader>ht"; # Example: <Leader>ht
        action = "<cmd>HardtimeToggle<cr>";
        options = {
          noremap = true;
          silent = true;
          desc = "Toggle HardTime";
        };
      }
    ];
  };
}
