# modules/hardtime/default.nix
{ lib, pkgs, config, ... }:

let
  # This refers to the 'enable' option defined in the 'options' block below
  cfg = config.programs.nixvim.plugins.hardtime;
  pluginPkg = pkgs.vimPlugins.hardtime-nvim;
in
{
  # 1. Define the Nix options for configuring this hardtime module
  options.programs.nixvim.plugins.hardtime = {
    enable = lib.mkEnableOption "hardtime.nvim - Vim motion training plugin";
    luaEnabled = lib.mkOption {
      type = lib.types.bool;
      default = true; # Default to functionally enabled if Nix module is enabled
      description = "Whether hardtime.nvim functionality is enabled in its Lua setup.";
    };
    disabledFiletypes = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ "NvimTree" "neo-tree" "dashboard" "packer" "lazy" "TelescopePrompt" "mason" "Overseer" ];
      description = "Filetypes where hardtime.nvim should be disabled.";
    };
    # You can add other options here to pass to the Lua setup if needed
  };

  # 2. Conditionally apply the configuration
  config = lib.mkIf cfg.enable {
    programs.nixvim.extraPlugins = [ pluginPkg ];

    programs.nixvim.extraConfigLua = ''
      -- Configure hardtime.nvim
      require('hardtime').setup({
        enabled = ${lib.generators.toLua cfg.luaEnabled},
        disabled_filetypes = ${lib.generators.toLua cfg.disabledFiletypes},
        -- Add any other hardtime.nvim specific Lua configurations here
      })

      -- Define user commands directly in Lua
      vim.api.nvim_create_user_command('HardtimeToggle', function()
        require('hardtime').toggle()
      end, { desc = 'Toggle HardTime' })

      vim.api.nvim_create_user_command('HardtimeEnable', function()
        require('hardtime').enable()
      end, { desc = 'Enable HardTime' })

      vim.api.nvim_create_user_command('HardtimeDisable', function()
        require('hardtime').disable()
      end, { desc = 'Disable HardTime' })

      vim.api.nvim_create_user_command('HardtimeReport', function()
        require('hardtime').report()
      end, { desc = 'HardTime Report' })
    '';

    programs.nixvim.keymaps = [
      {
        mode = "n";
        key = "<leader>ht"; # Example: <Leader>ht
        action = "<cmd>HardtimeToggle<cr>"; # This command is now defined via Lua
        options = {
          noremap = true;
          silent = true;
          desc = "Toggle HardTime";
        };
      }
      # Add other keymaps if needed
    ];
  };
}
