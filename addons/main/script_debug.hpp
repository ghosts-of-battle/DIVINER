
/**
    Fast Recompiling via function
**/
// #define DISABLE_COMPILE_CACHE
// To Use: [] call GHOST_PREP_RECOMPILE;

#ifdef DISABLE_COMPILE_CACHE
    #define LINKFUNC(x) {_this call FUNC(x)}
    // No recompile button: ghost ships no debug console addon.
    #define PREP_RECOMPILE_ADD_BUTTON ;
    #define PREP_RECOMPILE_START    if (isNil 'PREFIX##_PREP_RECOMPILE') then {PREFIX##_RECOMPILES = []; PREFIX##_PREP_RECOMPILE = {{call _x} forEach PREFIX##_RECOMPILES; diag_frameNo}}; private _recomp = {INFO('Compiling');
    #define PREP_RECOMPILE_END      }; call _recomp; PREFIX##_RECOMPILES pushBack _recomp; PREP_RECOMPILE_ADD_BUTTON;
#else
    #define LINKFUNC(x) FUNC(x)
    #define PREP_RECOMPILE_START ;
    #define PREP_RECOMPILE_END ;
#endif
