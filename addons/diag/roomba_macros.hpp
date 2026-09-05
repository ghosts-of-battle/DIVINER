// THE ROOMBA MISSION'S LOGGING MACROS, KEPT AS THEY WERE.
//
// The mission scripts call INFO("component", "message") - two arguments, the
// first naming the caller. Ghost's own INFO takes one. Twelve thousand lines
// came across from scripts\ and rewriting every log line would have been a
// mechanical change to hundreds of call sites for no gain, so the two-argument
// forms live here and the eleven addons that came out of scripts\ include this
// after ghost's macros.
//
// THE #undef IS REQUIRED, not decoration: redefining a macro that is already
// defined is a preprocessor warning in every file that includes this, and
// HEMTT treats the flood as noise that hides real ones.
//
// Everything routes to ghostD_diag_fnc_log / info / warning / error, which are
// Brostrom's originals - one place that decides whether a line goes to the RPT,
// to chat, or to both.

// EVERY ONE OF THEM, not just the four obvious ones. CBA defines the _SYS
// forms and the numbered variants up to _8 as well, and each redefinition is a
// preprocessor warning in every file that includes this - three and a half
// thousand of them, which is exactly the kind of noise that hides a real one.
#undef LOG_SYS

#undef LOG
#undef INFO
#undef WARNING
#undef ERROR

#undef LOG_1
#undef LOG_2
#undef LOG_3
#undef LOG_4
#undef LOG_5
#undef LOG_6
#undef LOG_7
#undef LOG_8

#undef INFO_1
#undef INFO_2
#undef INFO_3
#undef INFO_4
#undef INFO_5
#undef INFO_6
#undef INFO_7
#undef INFO_8

#undef WARNING_1
#undef WARNING_2
#undef WARNING_3
#undef WARNING_4
#undef WARNING_5
#undef WARNING_6
#undef WARNING_7
#undef WARNING_8

#undef ERROR_1
#undef ERROR_2
#undef ERROR_3
#undef ERROR_4
#undef ERROR_5
#undef ERROR_6
#undef ERROR_7
#undef ERROR_8

#define LOG_SYS(COMPONENT,MESSAGE,CHAT,SERVER) [ARR_4(MESSAGE,COMPONENT,CHAT,SERVER)] call EFUNC(diag,log)
#define INFO_SYS(COMPONENT,MESSAGE,CHAT,SERVER) [ARR_4(MESSAGE,COMPONENT,CHAT,SERVER)] call EFUNC(diag,info)
#define ERROR_SYS(COMPONENT,MESSAGE,CHAT,SERVER) [ARR_4(MESSAGE,COMPONENT,CHAT,SERVER)] call EFUNC(diag,error)
#define WARNING_SYS(COMPONENT,MESSAGE,CHAT,SERVER) [ARR_4(MESSAGE,COMPONENT,CHAT,SERVER)] call EFUNC(diag,warning)

#define LOG(COMPONENT,MESSAGE) LOG_SYS(COMPONENT,MESSAGE,false,false)
#define INFO(COMPONENT,MESSAGE) INFO_SYS(COMPONENT,MESSAGE,false,false)
#define WARNING(COMPONENT,MESSAGE) WARNING_SYS(COMPONENT,MESSAGE,false,false)
#define ERROR(COMPONENT,MESSAGE) ERROR_SYS(COMPONENT,MESSAGE,false,false)

#define LOG_1(C,M,A1) LOG(C,FORMAT_1(M,A1))
#define LOG_2(C,M,A1,A2) LOG(C,FORMAT_2(M,A1,A2))
#define LOG_3(C,M,A1,A2,A3) LOG(C,FORMAT_3(M,A1,A2,A3))
#define LOG_4(C,M,A1,A2,A3,A4) LOG(C,FORMAT_4(M,A1,A2,A3,A4))
#define LOG_5(C,M,A1,A2,A3,A4,A5) LOG(C,FORMAT_5(M,A1,A2,A3,A4,A5))

#define INFO_1(C,M,A1) INFO(C,FORMAT_1(M,A1))
#define INFO_2(C,M,A1,A2) INFO(C,FORMAT_2(M,A1,A2))
#define INFO_3(C,M,A1,A2,A3) INFO(C,FORMAT_3(M,A1,A2,A3))
#define INFO_4(C,M,A1,A2,A3,A4) INFO(C,FORMAT_4(M,A1,A2,A3,A4))
#define INFO_5(C,M,A1,A2,A3,A4,A5) INFO(C,FORMAT_5(M,A1,A2,A3,A4,A5))

// PER-ENTITY TRACE, DISARMED UNLESS THE ADDON ASKS FOR IT.
//
// An INFO on a path that runs once per unit or once per vehicle is not a log
// line, it is a cost paid on the frames a spawn is already expensive: the
// format runs, and diag_log writes a line to disk, for every entity the
// mission ever creates. The 2026-08-31 session put 2,236 of these in the RPT
// from the vehicle init path alone - seven lines per vehicle, four of them
// saying the same thing twice - so the ones on those paths say TRACE_INFO_N
// and compile to nothing.
//
// Uncomment DEBUG_MODE_FULL in an addon's script_component.hpp to get that
// addon's trace back. Anything that has to be readable in a normal RPT - a
// module coming up, a warning, a decision worth explaining - stays INFO.
#ifdef DEBUG_MODE_FULL
    #define TRACE_INFO_1(C,M,A1) INFO_1(C,M,A1)
    #define TRACE_INFO_2(C,M,A1,A2) INFO_2(C,M,A1,A2)
    #define TRACE_INFO_3(C,M,A1,A2,A3) INFO_3(C,M,A1,A2,A3)
    #define TRACE_INFO_4(C,M,A1,A2,A3,A4) INFO_4(C,M,A1,A2,A3,A4)
    #define TRACE_INFO_5(C,M,A1,A2,A3,A4,A5) INFO_5(C,M,A1,A2,A3,A4,A5)
#else
    #define TRACE_INFO_1(C,M,A1)
    #define TRACE_INFO_2(C,M,A1,A2)
    #define TRACE_INFO_3(C,M,A1,A2,A3)
    #define TRACE_INFO_4(C,M,A1,A2,A3,A4)
    #define TRACE_INFO_5(C,M,A1,A2,A3,A4,A5)
#endif

#define WARNING_1(C,M,A1) WARNING(C,FORMAT_1(M,A1))
#define WARNING_2(C,M,A1,A2) WARNING(C,FORMAT_2(M,A1,A2))
#define WARNING_3(C,M,A1,A2,A3) WARNING(C,FORMAT_3(M,A1,A2,A3))
#define WARNING_4(C,M,A1,A2,A3,A4) WARNING(C,FORMAT_4(M,A1,A2,A3,A4))
#define WARNING_5(C,M,A1,A2,A3,A4,A5) WARNING(C,FORMAT_5(M,A1,A2,A3,A4,A5))

#define ERROR_1(C,M,A1) ERROR(C,FORMAT_1(M,A1))
#define ERROR_2(C,M,A1,A2) ERROR(C,FORMAT_2(M,A1,A2))
#define ERROR_3(C,M,A1,A2,A3) ERROR(C,FORMAT_3(M,A1,A2,A3))
#define ERROR_4(C,M,A1,A2,A3,A4) ERROR(C,FORMAT_4(M,A1,A2,A3,A4))
#define ERROR_5(C,M,A1,A2,A3,A4,A5) ERROR(C,FORMAT_5(M,A1,A2,A3,A4,A5))

// The SHOW_ family differs only in where the line comes out - chat, the server
// log, or both. Same four functions underneath.
//
// THE NUMBERED VARIANTS ARE NOT OPTIONAL. In the mission these lines only
// existed inside #ifdef DEBUG_MODE, which was off - so SHOW_WARNING_1 and its
// relatives expanded to nothing and nobody noticed they were never defined for
// the SHOW_ family. Compiled for real they are twenty-seven parse errors, so
// each level is written out to the argument count the callers actually use.
#define SHOW_SYS_N(FN,C,M,CHAT,SERVER) [ARR_4(M,C,CHAT,SERVER)] call EFUNC(diag,FN)

#define SHOW_LOG(C,M) LOG_SYS(C,M,false,false)
#define SHOW_LOG_1(C,M,A1) SHOW_LOG(C,FORMAT_1(M,A1))
#define SHOW_LOG_2(C,M,A1,A2) SHOW_LOG(C,FORMAT_2(M,A1,A2))
#define SHOW_LOG_3(C,M,A1,A2,A3) SHOW_LOG(C,FORMAT_3(M,A1,A2,A3))
#define SHOW_LOG_4(C,M,A1,A2,A3,A4) SHOW_LOG(C,FORMAT_4(M,A1,A2,A3,A4))
#define SHOW_LOG_5(C,M,A1,A2,A3,A4,A5) SHOW_LOG(C,FORMAT_5(M,A1,A2,A3,A4,A5))

#define SHOW_INFO(C,M) INFO_SYS(C,M,false,false)
#define SHOW_INFO_1(C,M,A1) SHOW_INFO(C,FORMAT_1(M,A1))
#define SHOW_INFO_2(C,M,A1,A2) SHOW_INFO(C,FORMAT_2(M,A1,A2))
#define SHOW_INFO_3(C,M,A1,A2,A3) SHOW_INFO(C,FORMAT_3(M,A1,A2,A3))
#define SHOW_INFO_4(C,M,A1,A2,A3,A4) SHOW_INFO(C,FORMAT_4(M,A1,A2,A3,A4))
#define SHOW_INFO_5(C,M,A1,A2,A3,A4,A5) SHOW_INFO(C,FORMAT_5(M,A1,A2,A3,A4,A5))

#define SHOW_WARNING(C,M) WARNING_SYS(C,M,false,false)
#define SHOW_WARNING_1(C,M,A1) SHOW_WARNING(C,FORMAT_1(M,A1))
#define SHOW_WARNING_2(C,M,A1,A2) SHOW_WARNING(C,FORMAT_2(M,A1,A2))
#define SHOW_WARNING_3(C,M,A1,A2,A3) SHOW_WARNING(C,FORMAT_3(M,A1,A2,A3))
#define SHOW_WARNING_4(C,M,A1,A2,A3,A4) SHOW_WARNING(C,FORMAT_4(M,A1,A2,A3,A4))
#define SHOW_WARNING_5(C,M,A1,A2,A3,A4,A5) SHOW_WARNING(C,FORMAT_5(M,A1,A2,A3,A4,A5))

#define SHOW_ERROR(C,M) ERROR_SYS(C,M,true,false)
#define SHOW_ERROR_1(C,M,A1) SHOW_ERROR(C,FORMAT_1(M,A1))
#define SHOW_ERROR_2(C,M,A1,A2) SHOW_ERROR(C,FORMAT_2(M,A1,A2))
#define SHOW_ERROR_3(C,M,A1,A2,A3) SHOW_ERROR(C,FORMAT_3(M,A1,A2,A3))
#define SHOW_ERROR_4(C,M,A1,A2,A3,A4) SHOW_ERROR(C,FORMAT_4(M,A1,A2,A3,A4))
#define SHOW_ERROR_5(C,M,A1,A2,A3,A4,A5) SHOW_ERROR(C,FORMAT_5(M,A1,A2,A3,A4,A5))

#define SHOW_CHAT_LOG(C,M) LOG_SYS(C,M,true,false)
#define SHOW_CHAT_LOG_1(C,M,A1) SHOW_CHAT_LOG(C,FORMAT_1(M,A1))
#define SHOW_CHAT_LOG_2(C,M,A1,A2) SHOW_CHAT_LOG(C,FORMAT_2(M,A1,A2))
#define SHOW_CHAT_LOG_3(C,M,A1,A2,A3) SHOW_CHAT_LOG(C,FORMAT_3(M,A1,A2,A3))

#define SHOW_CHAT_INFO(C,M) INFO_SYS(C,M,true,false)
#define SHOW_CHAT_INFO_1(C,M,A1) SHOW_CHAT_INFO(C,FORMAT_1(M,A1))
#define SHOW_CHAT_INFO_2(C,M,A1,A2) SHOW_CHAT_INFO(C,FORMAT_2(M,A1,A2))
#define SHOW_CHAT_INFO_3(C,M,A1,A2,A3) SHOW_CHAT_INFO(C,FORMAT_3(M,A1,A2,A3))

#define SHOW_CHAT_WARNING(C,M) WARNING_SYS(C,M,true,false)
#define SHOW_CHAT_WARNING_1(C,M,A1) SHOW_CHAT_WARNING(C,FORMAT_1(M,A1))
#define SHOW_CHAT_WARNING_2(C,M,A1,A2) SHOW_CHAT_WARNING(C,FORMAT_2(M,A1,A2))
#define SHOW_CHAT_WARNING_3(C,M,A1,A2,A3) SHOW_CHAT_WARNING(C,FORMAT_3(M,A1,A2,A3))
#define SHOW_CHAT_WARNING_4(C,M,A1,A2,A3,A4) SHOW_CHAT_WARNING(C,FORMAT_4(M,A1,A2,A3,A4))
#define SHOW_CHAT_WARNING_5(C,M,A1,A2,A3,A4,A5) SHOW_CHAT_WARNING(C,FORMAT_5(M,A1,A2,A3,A4,A5))

#define SHOW_CHAT_ERROR(C,M) ERROR_SYS(C,M,true,false)
#define SHOW_CHAT_ERROR_1(C,M,A1) SHOW_CHAT_ERROR(C,FORMAT_1(M,A1))
#define SHOW_CHAT_ERROR_2(C,M,A1,A2) SHOW_CHAT_ERROR(C,FORMAT_2(M,A1,A2))
#define SHOW_CHAT_ERROR_3(C,M,A1,A2,A3) SHOW_CHAT_ERROR(C,FORMAT_3(M,A1,A2,A3))
#define SHOW_CHAT_ERROR_4(C,M,A1,A2,A3,A4) SHOW_CHAT_ERROR(C,FORMAT_4(M,A1,A2,A3,A4))
#define SHOW_CHAT_ERROR_5(C,M,A1,A2,A3,A4,A5) SHOW_CHAT_ERROR(C,FORMAT_5(M,A1,A2,A3,A4,A5))

#define SHOW_SERVER_LOG(C,M) LOG_SYS(C,M,false,true)
#define SHOW_SERVER_LOG_1(C,M,A1) SHOW_SERVER_LOG(C,FORMAT_1(M,A1))
#define SHOW_SERVER_LOG_2(C,M,A1,A2) SHOW_SERVER_LOG(C,FORMAT_2(M,A1,A2))
#define SHOW_SERVER_LOG_3(C,M,A1,A2,A3) SHOW_SERVER_LOG(C,FORMAT_3(M,A1,A2,A3))
#define SHOW_SERVER_INFO(C,M) INFO_SYS(C,M,false,true)
#define SHOW_SERVER_INFO_1(C,M,A1) SHOW_SERVER_INFO(C,FORMAT_1(M,A1))
#define SHOW_SERVER_INFO_2(C,M,A1,A2) SHOW_SERVER_INFO(C,FORMAT_2(M,A1,A2))
#define SHOW_SERVER_INFO_3(C,M,A1,A2,A3) SHOW_SERVER_INFO(C,FORMAT_3(M,A1,A2,A3))
#define SHOW_SERVER_WARNING(C,M) WARNING_SYS(C,M,false,true)
#define SHOW_SERVER_WARNING_1(C,M,A1) SHOW_SERVER_WARNING(C,FORMAT_1(M,A1))
#define SHOW_SERVER_WARNING_2(C,M,A1,A2) SHOW_SERVER_WARNING(C,FORMAT_2(M,A1,A2))
#define SHOW_SERVER_WARNING_3(C,M,A1,A2,A3) SHOW_SERVER_WARNING(C,FORMAT_3(M,A1,A2,A3))
#define SHOW_SERVER_ERROR(C,M) ERROR_SYS(C,M,false,true)
#define SHOW_SERVER_ERROR_1(C,M,A1) SHOW_SERVER_ERROR(C,FORMAT_1(M,A1))
#define SHOW_SERVER_ERROR_2(C,M,A1,A2) SHOW_SERVER_ERROR(C,FORMAT_2(M,A1,A2))
#define SHOW_SERVER_ERROR_3(C,M,A1,A2,A3) SHOW_SERVER_ERROR(C,FORMAT_3(M,A1,A2,A3))

#define SHOW_CHAT_SERVER_LOG(C,M) LOG_SYS(C,M,true,true)
#define SHOW_CHAT_SERVER_LOG_1(C,M,A1) SHOW_CHAT_SERVER_LOG(C,FORMAT_1(M,A1))
#define SHOW_CHAT_SERVER_LOG_2(C,M,A1,A2) SHOW_CHAT_SERVER_LOG(C,FORMAT_2(M,A1,A2))
#define SHOW_CHAT_SERVER_INFO(C,M) INFO_SYS(C,M,true,true)
#define SHOW_CHAT_SERVER_INFO_1(C,M,A1) SHOW_CHAT_SERVER_INFO(C,FORMAT_1(M,A1))
#define SHOW_CHAT_SERVER_INFO_2(C,M,A1,A2) SHOW_CHAT_SERVER_INFO(C,FORMAT_2(M,A1,A2))
#define SHOW_CHAT_SERVER_WARNING(C,M) WARNING_SYS(C,M,true,true)
#define SHOW_CHAT_SERVER_WARNING_1(C,M,A1) SHOW_CHAT_SERVER_WARNING(C,FORMAT_1(M,A1))
#define SHOW_CHAT_SERVER_WARNING_2(C,M,A1,A2) SHOW_CHAT_SERVER_WARNING(C,FORMAT_2(M,A1,A2))
#define SHOW_CHAT_SERVER_ERROR(C,M) ERROR_SYS(C,M,true,true)
#define SHOW_CHAT_SERVER_ERROR_1(C,M,A1) SHOW_CHAT_SERVER_ERROR(C,FORMAT_1(M,A1))
#define SHOW_CHAT_SERVER_ERROR_2(C,M,A1,A2) SHOW_CHAT_SERVER_ERROR(C,FORMAT_2(M,A1,A2))

// Notifications. The mission already routed these to ghost_notify; with the
// code inside ghost the GHOST* indirection is gone and EFUNC does the job.
#define NOTE_INFO [ARR_4(0.871,0.361,0.188,1)]
#define NOTE_GOOD [ARR_4(0.400,0.702,0.400,1)]
#define NOTE_WARN [ARR_4(1,0.776,0.102,1)]
#define NOTE_BAD  [ARR_4(0.831,0.267,0.267,1)]

#define GHOSTFUNC(var1,var2) TRIPLES(DOUBLES(ghost,var1),fnc,var2)
#define GHOSTGVAR(var1,var2) TRIPLES(ghost,var1,var2)
#define QGHOSTGVAR(var1,var2) QUOTE(GHOSTGVAR(var1,var2))

// Logistics shorthand, used across several of the eleven addons.
#define GET_CONTAINER(BOX) [BOX] call EFUNC(logistics,getContainer)
#define GET_CONTAINER_KEYS(BOX) [ARR_2(BOX,true)] call EFUNC(logistics,getContainer)

#define GETCFGVALUE(VAR) [missionConfigFile >> "PDT_CfgSimulator" >> VAR] call BIS_fnc_getCfgData
