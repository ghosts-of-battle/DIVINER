// TAC//PAC admin page - control ids. Local to this display; nothing else
// addresses them, so they start at 1.
#define PAC_IDC_BACKGROUND      1
#define PAC_IDC_TITLE           2
#define PAC_IDC_SUBTITLE        3
#define PAC_IDC_CLOSE           4

#define PAC_IDC_L_BACK          60
#define PAC_IDC_M_BACK          61
#define PAC_IDC_R_BACK          62

#define PAC_IDC_L_TITLE         10
#define PAC_IDC_L_FILTER        11
#define PAC_IDC_L_UNASSIGNED    12
#define PAC_IDC_L_LIST          13
#define PAC_IDC_L_COUNT         14

#define PAC_IDC_M_TITLE         20
#define PAC_IDC_M_NAME          21
#define PAC_IDC_RANK_LABEL      22
#define PAC_IDC_RANK_COMBO      23
#define PAC_IDC_ROLE_LABEL      24
#define PAC_IDC_ROLE_COMBO      25
#define PAC_IDC_STATUS_LABEL    26
#define PAC_IDC_STATUS_COMBO    27
#define PAC_IDC_GROUP_LABEL     28
#define PAC_IDC_SKILLS_TITLE    31
#define PAC_IDC_SKILLS_LIST     32
#define PAC_IDC_AWARDS_TITLE    33
#define PAC_IDC_AWARDS_LIST     34
#define PAC_IDC_AWARD_COMBO     35
#define PAC_IDC_AWARD_ADD       36
#define PAC_IDC_AWARD_REMOVE    37
#define PAC_IDC_NOTES_TITLE     38
#define PAC_IDC_NOTES_LIST      39
#define PAC_IDC_NOTE_EDIT       40
#define PAC_IDC_NOTE_ADD        41

#define PAC_IDC_R_TITLE         50
#define PAC_IDC_KICK            51
#define PAC_IDC_BAN             52
#define PAC_IDC_R_STATUS        53
#define PAC_IDC_ORPHANS_TITLE   54
#define PAC_IDC_ORPHANS_LIST    55
#define PAC_IDC_HINT            56
#define PAC_IDC_WINDOW_TITLE    57
#define PAC_IDC_WINDOW_NAME     58
#define PAC_IDC_WINDOW_START    59
#define PAC_IDC_WINDOW_STOP     63
#define PAC_IDC_REPORT          64
#define PAC_IDC_BACKUP_TITLE    65
#define PAC_IDC_EXPORT          66
#define PAC_IDC_IMPORT          67
#define PAC_IDC_RESTORE         68
#define PAC_IDC_STRUCTURE       69
#define PAC_IDC_SAMPLE_ADD      70
#define PAC_IDC_SAMPLE_REMOVE   71
#define PAC_IDC_GROUP_COMBO     42
#define PAC_IDC_ENLISTED_LABEL  43
#define PAC_IDC_ENLISTED        44
#define PAC_IDC_ENLISTED_SET    45
#define PAC_IDC_PROMOTED_LABEL  46
#define PAC_IDC_PROMOTED        47
#define PAC_IDC_PROMOTED_SET    48
#define PAC_IDC_SERVICE_LINE    49
#define PAC_IDC_STRUCT_OPEN     72
#define PAC_IDC_MANAGE_OPEN     73
#define PAC_IDC_STRUCT_IMPORT   74
#define PAC_IDC_LOG_TITLE       75
#define PAC_IDC_LOG_LIST        76
#define PAC_IDC_TOOLS_TITLE     77
#define PAC_IDC_M_SAVE          78
#define PAC_IDC_CSV_IMPORT      79
// the TRAINING block on the player page (2026-09-05)
#define PAC_IDC_TRAINING_TITLE  80
#define PAC_IDC_TRAINING_LIST   81
#define PAC_IDC_TRAIN_EDIT      82
#define PAC_IDC_TRAIN_ADD       83
#define PAC_IDC_TRAIN_REMOVE    84
#define PAC_IDC_TRAIN_COMBO     85

// ADD OPERATOR on the roster column (2026-09-09) - somebody who has never
// joined, put on the roster before they do.
#define PAC_IDC_L_ADD_UID       86
#define PAC_IDC_L_ADD_NAME      87
#define PAC_IDC_L_ADD           88

// EXPORT CLASSES (2026-09-09) - writes what this server has loaded to
// <unit>.classes, so the web manager's editors can offer real classnames.
#define PAC_IDC_EXPORT_CLASSES  89

// The boot screen (ui/bootscreen.hpp) - RscTitles, its own idc space
#define PAC_IDC_BS_LOGO         200
#define PAC_IDC_BS_TITLE        201
#define PAC_IDC_BS_BAR          202
#define PAC_IDC_BS_STEP         203

// The structure editor (ui/structure.inc.hpp)
#define PAC_IDC_ST_BACKGROUND   100
#define PAC_IDC_ST_TITLE        101
#define PAC_IDC_ST_SUBTITLE     102
#define PAC_IDC_ST_CLOSE        103
#define PAC_IDC_ST_L_BACK       104
#define PAC_IDC_ST_R_BACK       105
#define PAC_IDC_ST_SECTION      106
#define PAC_IDC_ST_LIST         107
#define PAC_IDC_ST_COUNT        108
#define PAC_IDC_ST_ID_LABEL     110
#define PAC_IDC_ST_ID           111
#define PAC_IDC_ST_NAME_LABEL   112
#define PAC_IDC_ST_NAME         113
#define PAC_IDC_ST_F1_LABEL     114
#define PAC_IDC_ST_F1           115
#define PAC_IDC_ST_F2_LABEL     116
#define PAC_IDC_ST_F2           117
#define PAC_IDC_ST_F3_LABEL     118
#define PAC_IDC_ST_F3           119
#define PAC_IDC_ST_HINT         120
#define PAC_IDC_ST_NEW          121
#define PAC_IDC_ST_SAVE         122
#define PAC_IDC_ST_REMOVE       123
#define PAC_IDC_ST_ME           124

// The management window (ui/manage.inc.hpp)
#define PAC_IDC_MG_BACKGROUND   130
#define PAC_IDC_MG_TITLE        131
#define PAC_IDC_MG_SUBTITLE     132
#define PAC_IDC_MG_CLOSE        133
#define PAC_IDC_MG_L_BACK       134
#define PAC_IDC_MG_R_BACK       135
#define PAC_IDC_MG_SECTION      136
#define PAC_IDC_MG_FILTER       137
#define PAC_IDC_MG_LIST         138
#define PAC_IDC_MG_COUNT        139
#define PAC_IDC_MG_ID_LABEL     140
#define PAC_IDC_MG_ID           141
#define PAC_IDC_MG_F1_LABEL     142
#define PAC_IDC_MG_F1           143
#define PAC_IDC_MG_F2_LABEL     144
#define PAC_IDC_MG_F2           145
#define PAC_IDC_MG_F3_LABEL     146
#define PAC_IDC_MG_F3           147
#define PAC_IDC_MG_F4_LABEL     148
#define PAC_IDC_MG_F4           149
#define PAC_IDC_MG_F5_LABEL     150
#define PAC_IDC_MG_F5           151
#define PAC_IDC_MG_F6_LABEL     152
#define PAC_IDC_MG_F6           153
#define PAC_IDC_MG_HINT         154
#define PAC_IDC_MG_NEW          155
#define PAC_IDC_MG_SAVE         156
#define PAC_IDC_MG_REMOVE       157
#define PAC_IDC_MG_EXPORT       158
