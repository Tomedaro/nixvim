# /home/daniil/NixOS/modules/hardtime/default.nix (MINIMAL TEST)
{ lib, pkgs, config, ... }: # config here should be the programs.nixvim scope

let
  # This refers to the 'enable' option defined below, which you'll set in your main config.
  cfg = config.programs.nixvim.plugins.hardtime;
in
{
  # 1. Define a simple enable option for this test module
  options.programs.nixvim.plugins.hardtime = {
    enable = lib.mkEnableOption "Enable minimal hardtime plugin test";
  };

  # 2. If enabled, try to do only two very basic things:
  #    - Add the plugin package.
  #    - Set a universal, core nixvim option.
  config = lib.mkIf cfg.enable {
    programs.nixvim.extraPlugins = [
      pkgs.vimPlugins.hardtime-nvim
    ];

    # Let's try to set one of the most basic nixvim options.
    # If this fails, then 'programs.nixvim.opts' itself is problematic in your setup.
    programs.nixvim.opts.number = true; # Display line numbers
  };
}
