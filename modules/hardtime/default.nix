# modules/hardtime/default.nix
{ lib, pkgs, config, ... }: # config refers to the full programs.nixvim config being built

let
  pluginPkg = pkgs.vimPlugins.hardtime-nvim;

  # You can still define user-configurable options for hardtime's Lua setup.
  # These options would be set in your main configuration like:
  # programs.nixvim.custom.hardtime.disabledFiletypes = [ ... ];
  # Let's assume you define these options elsewhere or decide to hardcode for now
  # for simplicity to match the "direct contribution" style.
  # For a more configurable approach, you'd define 'options.programs.nixvim.custom.hardtime = { ... };'
  # and then reference 'config.programs.nixvim.custom.hardtime' here.

  # For this example, let's make the Lua `enabled` state and `disabledFiletypes` directly configurable
  # via some agreed-upon paths in the main `programs.nixvim` config.
  # This is a common pattern: the module contributes to `programs.nixvim` AND
  # reads from other parts of `programs.nixvim` (or a dedicated section like `programs.nixvim.custom.hardtime`).

  # To make it truly configurable like treesitter.enable, we'd define options.
  # Let's use the options pattern from before, as it's more robust, and then this module
  # just returns the `config` block based on those options.
  # The key is that this module *itself* contributes the `options` and the `config`.

  hardtimeOpts = config.programs.nixvim.plugins.hardtime; # Referring to options defined below
in
{
  # 1. Define the Nix options for configuring hardtime.nvim
  # These will be available under `programs.nixvim.plugins.hardtime.*` in your main config.
  options.programs.nixvim.plugins.hardtime = {
    enable = lib.mkEnableOption "hardtime.nvim - Vim motion training plugin"; # Controls if this module's config is applied

    luaEnabled = lib.mkOption { # Controls the 'enabled' key in Lua setup
      type = lib.types.bool;
      default = true;
      description = "Whether hardtime.nvim functionality is enabled in its Lua setup.";
    };
    disabledFiletypes = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ "NvimTree" "neo-tree" "dashboard" "packer" "lazy" "TelescopePrompt" "mason" "Overseer" ];
      description = "Filetypes where hardtime.nvim should be disabled.";
    };
    # Add other hardtime.nvim Lua options you want to control via Nix here
    # Example:
    # scoreDecay = lib.mkOption { type = lib.types.nullOr lib.types.float; default = null; };
  };

  # 2. Conditionally apply the configuration for hardtime.nvim
  # This whole 'config' block gets merged into the final `programs.nixvim` if hardtimeOpts.enable is true.
  config = lib.mkIf hardtimeOpts.enable {
    extraPlugins = [ pluginPkg ];

    extraConfigLua = ''
      require('hardtime').setup({
        enabled = ${lib.generators.toLua hardtimeOpts.luaEnabled},
        disabled_filetypes = ${lib.generators.toLua hardtimeOpts.disabledFiletypes},
        -- Example for an option that might be null (not set by user)
        -- ${lib.optionalString (hardtimeOpts.scoreDecay != null) "score_decay = ${toString hardtimeOpts.scoreDecay},"}
      })
    '';

    commands = {
      HardtimeToggle = { command = "lua require('hardtime').toggle()"; description = "Toggle HardTime"; };
      HardtimeEnable = { command = "lua require('hardtime').enable()"; description = "Enable HardTime"; };
      HardtimeDisable = { command = "lua require('hardtime').disable()"; description = "Disable HardTime"; };
      HardtimeReport = { command = "lua require('hardtime').report()"; description = "HardTime Report"; };
    };

    keymaps = [{
      mode = "n";
      key = "<leader>ht"; # Example: <Leader>ht
      action = "<cmd>HardtimeToggle<cr>";
      options = {
        noremap = true;
        silent = true;
        desc = "Toggle HardTime";
      };
    }];
  };
}
