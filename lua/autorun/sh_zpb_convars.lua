-- Convars are created here so they can be used by either the vanilla or TTT2 versions of these items
-- Doubletap
CreateConVar("ttt_doubletap_detective", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Whether a detective can buy Doubletap", 0, 1)

CreateConVar("ttt_doubletap_traitor", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Whether a traitor can buy Doubletap", 0, 1)

CreateConVar("ttt_doubletap_firerate_multiplier", 1.5, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Firerate multiplier Doubletap gives", 0, 5)

-- Juggernog
CreateConVar("ttt_juggernog_detective", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Whether a detective can buy Juggernog", 0, 1)

CreateConVar("ttt_juggernog_traitor", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Whether a traitor can buy Juggernog", 0, 1)

CreateConVar("ttt_juggernog_health_multiplier", 1.5, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Health multiplier Juggernog gives", 0, 5)

-- PHD Flopper
CreateConVar("ttt_phd_detective", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Whether a detective can buy PHD Flopper", 0, 1)

CreateConVar("ttt_phd_traitor", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Whether a traitor can buy PHD Flopper", 0, 1)

CreateConVar("ttt_phd_explosion_radius", 256, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Explosion radius of PHD Flopper", 0, 1000)

CreateConVar("ttt_phd_only_immune_to_own_explosion", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Only make a PHD Flopper user immune to their PHD Flopper explosions, instead of any explosion", 0, 1)

-- Speed Cola
CreateConVar("ttt_speedcola_detective", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Whether a detective can buy Speed Cola", 0, 1)

CreateConVar("ttt_speedcola_traitor", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Whether a traitor can buy Speed Cola", 0, 1)

CreateConVar("ttt_speedcola_speed_multiplier", 2, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Reload speed multiplier Speed Cola gives", 0, 5)

-- Staminup
CreateConVar("ttt_staminup_detective", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Whether a detective can buy Staminup", 0, 1)

CreateConVar("ttt_staminup_traitor", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Whether a traitor can buy Staminup", 0, 1)

CreateConVar("ttt_staminup_speed_multiplier", 1.5, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Sprint speed multiplier Staminup gives", 0, 5)