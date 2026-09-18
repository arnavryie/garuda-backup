# This is your fish shell configuration file! You can edit this file to customize your fish shell experience.
# IMPORTANT! The Garuda Linux defaults are set in /usr/share/garuda/garuda-fish-config/config.fish.
# IMPORTANT! Do not edit the defaults file directly, as it will be overwritten during system updates. (You can however read it to learn and get ideas!)
# Instead, you simply add your customizations to this file, and they will override the defaults.

source /usr/share/garuda/garuda-fish-config/config.fish # Do not edit this defaults file!

# -- Insert customizations below this line! --


# Keep this at the bottom of the file.
# This shows the "neofetch"/fastfetch output when you open a new terminal.
# If you don't want to see it, simply comment out the line below.
__garuda_fastfetch

# --- Android & Mobile Development Environment ---
set -gx JAVA_HOME "$HOME/.local/share/java/jdk-17"
set -gx ANDROID_HOME "$HOME/Android/Sdk"
set -gx ANDROID_SDK_ROOT "$HOME/Android/Sdk"
fish_add_path "$JAVA_HOME/bin"
fish_add_path "$ANDROID_HOME/cmdline-tools/latest/bin"
fish_add_path "$ANDROID_HOME/platform-tools"
fish_add_path "$ANDROID_HOME/emulator"
fish_add_path "$HOME/.nvm/versions/node/v22.23.2/bin"
fish_add_path "$HOME/.local/bin"
# ------------------------------------------------
