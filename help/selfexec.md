# Selfexec plugin
This plugin is meant to make the plugin development process a little more convenient by bindig "reload" functionality to a key.

The default binding is to `Ctrl-r`, which conflicts with `ToggleRuler`.

The current implementation depends on being able to run a sh script and the exec syscall. No application state is saved, but thel list of currently open files is passed to the new session. You must save any files you've changed before executing the command. The behaviour is as if the program crashed, but backup restoration is set to manual mode.

For further information please review the plugin source.

# Development
Development is with the help of the Nix package manager.

See `nix/run.sh` for how things are invoked.

The plugin as of v2.0.8 requires a patch to micro to work. This patch is also located in the `nix` directory.

# Without Nix

The plugin can be used without Nix.

Compile micro with the patch in `nix` and then use the plugin as usual.
