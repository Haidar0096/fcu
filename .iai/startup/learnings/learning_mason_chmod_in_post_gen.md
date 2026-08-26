### Mason does not preserve the executable bit — chmod required in `post_gen.dart`

Mason renders all files with default permissions (`-rw-r--r--`), regardless of the source file's mode. Any brick that ships a script that must be executable in the rendered project — `.sh` files, hooks, the IAI `cat.sh`, etc. — needs a `chmod +x` step in `post_gen.dart`, OR the consumer must invoke the script via `bash <path>` rather than `<path>` directly.

The IAI kernel walker checks `[ -x cat.sh ]` before sourcing project-level rules; without the chmod step, the walker silently skips the rendered project's rules, and generated apps boot without their project rules loaded. Verify with a render test (`mason make ... && ls -la <rendered_path>`) before declaring the brick correct.

**Origin:** session 1 (flutter_cli_utils legacy_rescue migration), 2026-05-10.
