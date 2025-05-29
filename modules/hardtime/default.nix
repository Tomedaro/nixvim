# In your nixvim configuration (e.g., ~/.config/nixvim/plugins.nix or similar)
{ pkgs, ... }:

{
    plugins = {
      # ... your other plugins
      hardtime = {
        enable = true;
        # Optional: specify the package if needed, though often NixVim can infer it
        # package = pkgs.vimPlugins.hardtime-nvim; # Or the correct attribute name
      };
    };
}
