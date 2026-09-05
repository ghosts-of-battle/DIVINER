let old_build = HEMTT.project().version().build();
let new_build = old_build + 1;

let path = "addons/main/script_version.hpp";
let content = HEMTT_RFS.join(path).open_file().read();
content.replace(`#define BUILD ${old_build}`, `#define BUILD ${new_build}`);
HEMTT_RFS.join(path).create_file().write(content);

info(`BUILD bumped ${old_build} → ${new_build}`);
