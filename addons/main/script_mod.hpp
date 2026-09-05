#define MAINPREFIX z
#define PREFIX ghostD
#define QPREFIX "ghostD"

#define AUTHOR Ghost
#define QAUTHOR QUOTE(AUTHOR)
#define LOGO_PATH QUOTE(z\ghostD\addons\media\images\logo_256.paa)
#define URL "https://www.ghostsofbattle.com/"

#include "script_version.hpp"

#define VERSION     MAJOR.MINOR
#define VERSION_STR MAJOR.MINOR.PATCH
#define VERSION_AR  MAJOR,MINOR,PATCH

#define REQUIRED_VERSION 2.14

#ifdef COMPONENT_BEAUTIFIED
    #define COMPONENT_NAME QUOTE(DIVINER - COMPONENT_BEAUTIFIED)
#else
    #define COMPONENT_NAME QUOTE(DIVINER - COMPONENT)
#endif
