;====================================================================================================;
;
;   DeepFish BETA
;   Copyright (c) 2026 Yato. All rights reserved.
;
;   YOU MAY:
;     - Use this macro for your own personal use.
;     - Read the source and reuse PARTS of it in your own projects, provided that "Yato" is
;       credited visibly somewhere in that project's user interface.
;
;   YOU MAY NOT:
;     - Redistribute this macro, modified or unmodified, in whole or in substantial part.
;     - Publish a modified build of it, or present it as your own work.
;     - Remove, hide or alter the credits shown in the About tab.
;     - Sell it, or put it behind payment, subscription or paid access of any kind.
;
;   PORTIONS FROM OTHER PROJECTS
;     Precision/Lines mode's control method (PD steering with velocity tracking and stopping
;     distance) is adapted from IRUS IDIOTPROOF, IRUS COMET by AsphaltCake.
;       Source:  https://www.youtube.com/@AsphaltCake
;     Those portions remain subject to AsphaltCake's own terms, which permit sharing
;     modifications with attribution. The restrictions above apply to Yato's original work
;     and cannot and do not override AsphaltCake's terms for their part.
;
;     Changes made to that method in this macro: reimplemented in AutoHotkey v1; driven by
;     this macro's own GDI capture and color-calibration code; extended with an arrow-based
;     fallback for when the bar itself is not visible.
;
;   NO WARRANTY
;     Provided "as is", without warranty of any kind. Automating a game may breach its rules.
;     You use this at your own risk, and the author accepts no responsibility for any
;     consequence to your account.
;
;====================================================================================================;

#SingleInstance Force
#MaxThreadsPerHotkey 2

DFBetaVersion := "1.0.1"

setkeydelay, -1
setmousedelay, -1
setbatchlines, -1
SetTitleMatchMode 2

CoordMode, Tooltip, Relative
CoordMode, Pixel, Client
CoordMode, Mouse, Client


DllCall("QueryPerformanceFrequency", "Int64*", QpcFreq)
if (!QpcFreq)
	QpcFreq := 10000000
LineHitsFn()


ProfilesDir := A_ScriptDir . "\Profiles"
SettingsFile := A_ScriptDir . "\Settings.ini"
DefaultProfileFile := ProfilesDir . "\Default.ini"

ProfileFields := []
ProfileFields.Push( ["General","AutoLowerGraphics","true","bool"]
                  , ["General","AutoGraphicsDelay","50","num"]
                  , ["General","AutoZoomInCamera","true","bool"]
                  , ["General","AutoZoomDelay","50","num"]
                  , ["General","AutoEnableCameraMode","true","bool"]
                  , ["General","AutoCameraDelay","5","num"]
                  , ["General","AutoLookDownCamera","true","bool"]
                  , ["General","AutoLookDelay","200","num"]
                  , ["General","AutoBlurCamera","false","bool"]
                  , ["General","AutoBlurDelay","50","num"]
                  , ["General","RestartDelay","1000","num"]
                  , ["General","HoldRodCastDuration","1000","num"]
                  , ["General","WaitForBobberDelay","1000","num"]
                  , ["General","NavigationKey","\","str"]
                  , ["General","RodSlotKey","1","str"]
                  , ["General","BagSlotKey","2","str"]
                  , ["General","UnstickAfter","2","num"] )
ProfileFields.Push( ["Cast","CastMode","Normal","castmode"]
                  , ["Cast","PerfectGreenColor","0x60AA4A","str"]
                  , ["Cast","PerfectWhiteColor","0xFFFEF3","str"]
                  , ["Cast","PerfectGreenTolerance","20","num"]
                  , ["Cast","PerfectWhiteTolerance","25","num"]
                  , ["Cast","PerfectFailTimeout","20","num"]
                  , ["Cast","PerfectReleaseTiming","0","num"] )
ProfileFields.Push( ["Shake","ShakeMode","Navigation","shakemode"]
                  , ["Shake","FishBarColorTolerance","3","num"]
                  , ["Shake","ClickShakeFailsafe","20","num"]
                  , ["Shake","ClickShakeColorTolerance","1","num"]
                  , ["Shake","ClickScanDelay","100","num"]
                  , ["Shake","RepeatBypassCounter","10","num"]
                  , ["Shake","ShakeAreaLeftPct","21","num"]
                  , ["Shake","ShakeAreaRightPct","79","num"]
                  , ["Shake","ShakeAreaTopPct","7","num"]
                  , ["Shake","ShakeAreaBottomPct","88","num"]
                  , ["Shake","NavigationShakeFailsafe","30","num"]
                  , ["Shake","NavigationSpamDelay","10","num"] )
ProfileFields.Push( ["Minigame","ControlMode","Precision","controlmode"]
                  , ["Minigame","BarCalculationFailsafe","60","num"]
                  , ["Minigame","FishColor","0x434B5B","str"]
                  , ["Minigame","BarLeftColor","0xF1F1F1","str"]
                  , ["Minigame","BarRightColor","0xF1F1F1","str"]
                  , ["Minigame","BarColorTolerance","3","num"]
                  , ["Minigame","ArrowColor","0x848587","str"]
                  , ["Minigame","ArrowColorTolerance","3","num"]
                  , ["Minigame","StabilizerLoop","10","num"]
                  , ["Minigame","SideBarRatio","0.8","num"]
                  , ["Minigame","SideBarWaitMultiplier","4.5","num"]
                  , ["Minigame","SpecialRod","None","specialrod"]
                  , ["Minigame","RemembranceMode","Living","remembrancemode"]
                  , ["Minigame","NoteColor","0xB2CFFF","str"]
                  , ["Minigame","NoteColorTolerance","15","num"]
                  , ["Minigame","NoteBias","100","num"]
                  , ["Minigame","NoteRegionHeight","1000","num"]
                  , ["Minigame","NoteHandoff","50","num"]
                  , ["Minigame","LullRadiusPct","16","num"]
                  , ["Minigame","LullPivotUp","26","num"]
                  , ["Minigame","LullLightLum","90","num"]
                  , ["Minigame","LullArmDelta","45","num"]
                  , ["Minigame","LullTrigPct","10","num"]
                  , ["Minigame","LullClearMs","100","num"]
                  , ["Minigame","LullMinDeg","4","num"]
                  , ["Minigame","ReelMinHold","200","num"]
                  , ["Minigame","ReelMinRelease","200","num"]
                  , ["Minigame","ManiaLead","45","num"] )
ProfileFields.Push( ["Tuning","StableRightMultiplier","2.1","num"]
                  , ["Tuning","StableRightDivision","1.4","num"]
                  , ["Tuning","StableLeftMultiplier","1.1","num"]
                  , ["Tuning","StableLeftDivision","1.0","num"]
                  , ["Tuning","UnstableRightMultiplier","2.4","num"]
                  , ["Tuning","UnstableRightDivision","1.5","num"]
                  , ["Tuning","UnstableLeftMultiplier","1.3","num"]
                  , ["Tuning","UnstableLeftDivision","1.1","num"]
                  , ["Tuning","RightAnkleBreakMultiplier","1","num"]
                  , ["Tuning","LeftAnkleBreakMultiplier","0.9","num"]
                  , ["Tuning","Kp","0.5","num"]
                  , ["Tuning","Kd","0.3","num"]
                  , ["Tuning","VelocitySmoothing","0.2","num"]
                  , ["Tuning","StoppingDistanceMultiplier","3.0","num"] )
ProfileFields.Push( ["Keeper","KeeperAuto","false","bool"]
                  , ["Keeper","KeeperEveryCatches","20","num"]
                  , ["Keeper","KeeperRecharges","1","num"]
                  , ["Keeper","KeeperRelicKey","","str"]
                  , ["Keeper","KeeperInvKey","g","str"]
                  , ["Keeper","KeeperEnchantX","0","num"]
                  , ["Keeper","KeeperEnchantY","0","num"]
                  , ["Keeper","KeeperConfirmX","0","num"]
                  , ["Keeper","KeeperConfirmY","0","num"]
                  , ["Keeper","KeeperBetweenDelay","2000","num"]
                  , ["Keeper","KeeperStepDelay","100","num"]
                  , ["Keeper","KeeperOpenDelay","100","num"] )
ProfileFields.Push( ["Aquarium","AquariumAuto","false","bool"]
                  , ["Aquarium","AquariumEveryMin","63","num"]
                  , ["Aquarium","AquariumFoodCount","12","num"]
                  , ["Aquarium","AquariumMaxBuys","8","num"]
                  , ["Aquarium","AquariumStepDelay","320","num"]
                  , ["Aquarium","AquariumOpenDelay","1500","num"]
                  , ["Aquarium","AquariumScrollSteps","14","num"] )
ProfileFields.Push( ["Totem","TotemAuto","false","bool"]
                  , ["Totem","TotemPollSec","20","num"]
                  , ["Totem","TotemActDelay","2500","num"]
                  , ["Totem","TotemKeySundial","","str"]
                  , ["Totem","TotemKeyClearcast","","str"]
                  , ["Totem","TotemKeyTempest","","str"]
                  , ["Totem","TotemKeyWindset","","str"]
                  , ["Totem","TotemKeySmokescreen","","str"]
                  , ["Totem","TotemKeyEclipse","","str"]
                  , ["Totem","TotemKeyAurora","","str"]
                  , ["Totem","TotemKeyStarfall","","str"]
                  , ["Totem","TotemKeyShiny","","str"]
                  , ["Totem","TotemKeySparkling","","str"]
                  , ["Totem","TotemKeyMutation","","str"]
                  , ["Totem","TotemSel1","Aurora","str"]
                  , ["Totem","TotemSel2","None","str"] )

gosub, EnsureConfigFiles
gosub, LoadSettingsFile
gosub, LoadActiveProfile
gosub, FirstRunGate

MacroRunning := false
MacroPaused := false
NoteHoldAt := 0
NoteNeeded := false
NoteFresh := true
NoteBlitAt := 0
NoteRefreshMs := 55
NoteMissAt := 0
NoteMissN := 0
TargetIsNote := false
NoteAcc := 0
CastHolding := false
MgInPlay := false
MacroPreview := false
RunKeysArmed := false
BarLostAt := 0
BarWOutFirst := 0
BarWCal := 0
SectionBuilt := {}
ControlModeDdl := 0
NoteIndep := false
NoteOriginX := 0
NoteOriginY := 0
MgScore := 0
MgConf := 0
MgSawBar := false
MgSawFish := false
MgSawArrow := false
MgLastSig := -1
MgStaticN := 0
MgStaticAt := 0
BarSizeBadN := 0
BarSizePend := 0
BarSizePendN := 0
HudBuilt := false
HudGpOk := false
HudGdipToken := 0
hHudDC := 0
hHudBM := 0
hHudOldBM := 0
pHudBits := 0
pHudGfx := 0
pHudBmp := 0
HudSurfW := 0
HudSurfH := 0
HudH := 34
HudNoteX := -1
HudNote2X := -1
HudDirty := true
HudLastKey := ""
HudPrevT := 0
BarWTrust := 0
HudWRing := []
HudWMed := 0
; ==============================================================================================
TargetSection := ""
MgBlocks := {}
MgVisible := {}
MgAllCtrls := []
AllManaged := []
VisibleCtrls := []
CtrlBaseX := {}
CtrlBaseY := {}
CtrlW := {}
CtrlH := {}
CtrlRgnR := {}
CtrlClip := {}
SbTrack := 0
SbThumb := 0
SbTrackH := 0
SbThumbH := 0
SbShown := -1
ContentTopEdge := 120
SecTopEdge := 120
DpiF := (A_ScreenDPI > 0) ? (A_ScreenDPI / 96) : 1
SecScroll := {}
SecMaxScroll := 0
DetTesting := false
CardRects := []
hRunStatus := 0
ColorListCache := {}
ColorListCacheN := 0

CMTargetKeys := ["FishColor","BarLeftColor","BarRightColor","ArrowColor","NoteColor","PerfectGreenColor","PerfectWhiteColor"]
CMTargetLabel := {FishColor: "Fish line", BarLeftColor: "Bar - left end", BarRightColor: "Bar - right end"
	, ArrowColor: "Bar arrow", NoteColor: "Falling note", PerfectGreenColor: "Cast bar - green", PerfectWhiteColor: "Cast bar - white"}
CMTargetSection := {FishColor: "Minigame", BarLeftColor: "Minigame", BarRightColor: "Minigame"
	, ArrowColor: "Minigame", NoteColor: "Minigame", PerfectGreenColor: "Cast", PerfectWhiteColor: "Cast"}
CMTargetHint := {FishColor: "The thin marker that slides along the bar —`nthe fish you are chasing."
	, BarLeftColor: "The LEFT end of the reeling bar.`nAdd every shade it takes if the bar`nchanges color as it fills."
	, BarRightColor: "The RIGHT end of the reeling bar.`nAdd every shade it takes if the bar`nchanges color as it fills."
	, ArrowColor: "The small arrow drawn inside the`nreeling bar."
	, NoteColor: "A falling note.`nPinions Aria only."
	, PerfectGreenColor: "The green perfect-cast marker on`nthe cast power bar."
	, PerfectWhiteColor: "The white fill of the cast power bar."}
CMShortLabel := {FishColor: "Fish line", BarLeftColor: "Bar left", BarRightColor: "Bar right"
	, ArrowColor: "Arrow", NoteColor: "Note", PerfectGreenColor: "Cast green", PerfectWhiteColor: "Cast white"}
CMSel := "FishColor"
CMRowMax := 9
MiniTab := "Setup"
MiniTop := 162
MiniTabSetupH := 0
MiniTabColorsH := 0
FreezeActive := false
FreezeTarget := ""
FreezeMode := "add"
FreezePicked := ""

HudZoneShown := false
NoteNextX := -1
NoteNextY := -1
NoteLockY := -1
BarLiveL := -1
BarLiveR := -1
BarLiveMiss := 0
BarWLive := -1
BarLiveOnlyAt := 0
BarWidthTrusted := true
BarWOutN := 0
CastBarL := -1
CastBarW := 0
CastFishX := -1
CastScanned := false
CastBlindN := 0
CastPrevL := -1
CastPrevW := -1
CastPrevF := -1
CastSameN := 0
CastSameT := 0
CastStatic := false
RemWhiteX := -1
RemBlackX := -1
RemTargetX := -1
CtrAcc := 0
CtrBias := 0
RemScanned := false
RemFound := false
RemBarScanned := false
RemBarFound := false
RemBarL := -1
RemBarW := 0
RemBarRing := []
MiguFishX := -1
MiguLastX := -1
MiguScanned := false
MiguFound := false
MiguBarScanned := false
MiguBarFound := false
MiguBarL := -1
MiguBarW := 0
if (RemembranceMode = "")
	RemembranceMode := "Living"
CastFound := false
NoteHoldX := -1
LullFrames := 0
LullCalN := 0
LullR := 0
LullSecN := 0
LullCalLt := []
LullCalDk := []
LullCalLs := []
LullBg := []
LullSecA := []
LullSecB := []
LullArmA := []
LullClrT := []
LullActive := false
LullSeen := false
LullGoneN := 0
LullClicks := 0
LullHitSec := 0
NoteAllX := []
NoteAllY := []
NoteAllN := 0
TotemTpl := []
TotemTime := ""
TotemWeather := ""
AqNextTick := 0
KbCatches := 0
KbBusy := false
KbStatus := "idle"
KbLastResult := ""
AqBusy := false
AqHoverOk := false
AqStatus := "idle"
AqLastResult := ""
AqBtnN := 0
AqBtnCX := []
AqBtnCY := []
AqBtnKind := []
AqBuys := 0
AqUses := 0
AqCardPitch := 0
TotemEvents := ""
TotemDbg := ""
TotemLastCheck := 0
TotemWantTime := ""
WhStartTick := 0
WhCatches := 0
WhLastCatchTick := 0
WhLastSummary := 0
WhStalled := false
PausedMs := 0
AutoRefocus := true
LastAutoStop := 0
PCLastGoodY := -1
HotkeysArmed := false
CastFailCount := 0
DarkHoldN := 0
DarkFlashing := false
ManiaPrevY := [-1,-1,-1,-1]
ManiaHitY := -1
ManiaPrevT := [0,0,0,0]
ManiaSpeed := [0,0,0,0]
ManiaFired := [false,false,false,false]
ManiaSeen := false
BelPrevF := [0,0]
BelPrevB := [0,0]
BelPrevT := [0,0]
BelVel := [0,0]
BelBVel := [0,0]
BelDown := [false,false]
BelA := [0,0]
BelB := [0,0]
BelF := [-1,-1]
BelOK := [false,false]
DutyAvg := 0.5
DarkAcc := 0
settimer, HotkeyWatch, 500

Hotkey, % "$" . StartStopKey, HotkeyToggle, Off
Hotkey, % "$" . ReloadKey, HotkeyReload, Off
Hotkey, % "$" . ExitKey, HotkeyExit, Off
ForceReEquip := false
RodEquippedOnce := false
Hotkey, $F9, FreezePickHotkey, On

Menu, Tray, Tip, DeepFish BETA
Menu, Tray, Add, Show DeepFish, ShowGuiFromTray
Menu, Tray, Default, Show DeepFish
Menu, Tray, Click, 1

gosub, BuildGui

return

;====================================================================================================;

ResolveRoblox:
RobloxHwnd := 0
WinGet, RobloxHwnd, ID, ahk_exe RobloxPlayerBeta.exe
if (!RobloxHwnd)
	{
	SetTitleMatchMode, 3
	WinGet, RobloxHwnd, ID, Roblox
	SetTitleMatchMode, 2
	}
return

;====================================================================================================;

Calculations:
if (!RobloxHwnd)
	gosub, ResolveRoblox
RobloxClientRect(RobloxHwnd, WindowLeft, WindowTop, WindowWidth, WindowHeight)

AqNavX := (WindowWidth // 2) + 101
AqNavY := 29

CameraCheckLeft := WindowWidth/2.8444
CameraCheckRight := WindowWidth/1.5421
CameraCheckTop := WindowHeight/1.28
CameraCheckBottom := WindowHeight

ClickShakeLeft := WindowWidth * ClampPct(ShakeAreaLeftPct, 0, 99) / 100
ClickShakeRight := WindowWidth * ClampPct(ShakeAreaRightPct, 1, 100) / 100
ClickShakeTop := WindowHeight * ClampPct(ShakeAreaTopPct, 0, 99) / 100
ClickShakeBottom := WindowHeight * ClampPct(ShakeAreaBottomPct, 1, 100) / 100
if (ClickShakeRight <= ClickShakeLeft)
	ClickShakeRight := ClickShakeLeft + 1
if (ClickShakeBottom <= ClickShakeTop)
	ClickShakeBottom := ClickShakeTop + 1

if (SpecialRod = "Bellona's Waraxe")
	{
	FishBarLeft := WindowWidth * 0.05
	FishBarRight := WindowWidth * 0.95
	}
else
	{
	FishBarLeft := WindowWidth/3.3160
	FishBarRight := WindowWidth/1.4317
	}
FishBarTop := WindowHeight/1.1871
FishBarBottom := WindowHeight/1.1512

if (SpecialRod = "Remembrance")
	{
	FishBarTop := WindowHeight/1.2318
	FishBarBottom := WindowHeight/1.1862
	}

FishBarTooltipHeight := WindowHeight/1.0626

gosub, SetupCapture

ResolutionScaling := 2560/WindowWidth

LookDownX := WindowWidth/2
LookDownY := WindowHeight/4

runtimeS := 0
runtimeM := 0
runtimeH := 0

TooltipX := WindowWidth/20
Tooltip1 := (WindowHeight/2)-(20*9)
Tooltip2 := (WindowHeight/2)-(20*8)
Tooltip3 := (WindowHeight/2)-(20*7)
Tooltip4 := (WindowHeight/2)-(20*6)
Tooltip5 := (WindowHeight/2)-(20*5)
Tooltip6 := (WindowHeight/2)-(20*4)
Tooltip7 := (WindowHeight/2)-(20*3)
Tooltip8 := (WindowHeight/2)-(20*2)
Tooltip9 := (WindowHeight/2)-(20*1)
Tooltip10 := (WindowHeight/2)
Tooltip11 := (WindowHeight/2)+(20*1)
Tooltip12 := (WindowHeight/2)+(20*2)
Tooltip13 := (WindowHeight/2)+(20*3)
Tooltip14 := (WindowHeight/2)+(20*4)
Tooltip15 := (WindowHeight/2)+(20*5)
Tooltip16 := (WindowHeight/2)+(20*6)
Tooltip17 := (WindowHeight/2)+(20*7)
Tooltip18 := (WindowHeight/2)+(20*8)
Tooltip19 := (WindowHeight/2)+(20*9)
Tooltip20 := (WindowHeight/2)+(20*10)

if (DetTesting)
	goto CalcTipsDone

tooltip, Made By Yato, %TooltipX%, %Tooltip1%, 1
tooltip, Runtime: 0h 0m 0s, %TooltipX%, %Tooltip2%, 2


if (DetTesting)
	goto CalcTipsDone
gosub, RefreshHints

if (AutoLowerGraphics == true)
	{
	tooltip, AutoLowerGraphics: true, %TooltipX%, %Tooltip8%, 8
	}
else
	{
	tooltip, AutoLowerGraphics: false, %TooltipX%, %Tooltip8%, 8
	}
	
if (AutoEnableCameraMode == true)
	{
	tooltip, AutoEnableCameraMode: true, %TooltipX%, %Tooltip9%, 9
	}
else
	{
	tooltip, AutoEnableCameraMode: false, %TooltipX%, %Tooltip9%, 9
	}
	
if (AutoZoomInCamera == true)
	{
	tooltip, AutoZoomInCamera: true, %TooltipX%, %Tooltip10%, 10
	}
else
	{
	tooltip, AutoZoomInCamera: false, %TooltipX%, %Tooltip10%, 10
	}
	
if (AutoLookDownCamera == true)
	{
	tooltip, AutoLookDownCamera: true, %TooltipX%, %Tooltip11%, 11
	}
else
	{
	tooltip, AutoLookDownCamera: false, %TooltipX%, %Tooltip11%, 11
	}
	
if (AutoBlurCamera == true)
	{
	tooltip, AutoBlurCamera: true, %TooltipX%, %Tooltip12%, 12
	}
else
	{
	tooltip, AutoBlurCamera: false, %TooltipX%, %Tooltip12%, 12
	}

tooltip, Navigation Key: "%NavigationKey%", %TooltipX%, %Tooltip14%, 14

if (ShakeMode == "Click")
	{
	tooltip, Shake Mode: "Click", %TooltipX%, %Tooltip16%, 16
	}
else if (ShakeMode == "Disabled")
	{
	tooltip, Shake Mode: "Disabled", %TooltipX%, %Tooltip16%, 16
	}
else
	{
	tooltip, Shake Mode: "Navigation", %TooltipX%, %Tooltip16%, 16
	}
CalcTipsDone:
return

;====================================================================================================;

runtime:
runtimeS++
if (runtimeS >= 60)
	{
	runtimeS := 0
	runtimeM++
	}
if (runtimeM >= 60)
	{
	runtimeM := 0
	runtimeH++
	}


if WinActive("ahk_id " . RobloxHwnd)
	{
	RunDbg := MacroRunning ? "Y" : "N"
	KeyDbg := HotkeysArmed ? "armed" : "OFF"
	tooltip, Runtime: %runtimeH%h %runtimeM%m %runtimeS%s | Running:%RunDbg% Keys:%KeyDbg%, %TooltipX%, %Tooltip2%, 2
	gosub, RefreshHints
	}
else
	{
	if (!CastHolding)
		send {lbutton up}
	send {rbutton up}
	send {shift up}
	PrecisionDown := false
	MacroPaused := true
	PausedMs := 0
	while (MacroRunning and !WinActive("ahk_id " . RobloxHwnd))
		{
		if (!WinExist("ahk_id " . RobloxHwnd))
			{
			gosub, ResolveRoblox
			if (!RobloxHwnd)
				{
				tooltip, Waiting for the Roblox window to come back..., %TooltipX%, %Tooltip2%, 2
				sleep 1000
				continue
				}
			}
		WinActivate, ahk_id %RobloxHwnd%
		WinWaitActive, ahk_id %RobloxHwnd%, , 1
		PausedMs := PausedMs + 100
		tooltip, Reclaiming focus - Roblox was not in front, %TooltipX%, %Tooltip2%, 2
		if (!WinActive("ahk_id " . RobloxHwnd))
			sleep 100
		}
	MacroPaused := false
	if (!MacroRunning)
		goto Idle
	}
return

;====================================================================================================;

HotkeyToggle:

if (MacroRunning)
	goto ToggleMacro
if WinActive("DeepFish BETA")
	return
goto ToggleMacro

HotkeyReload:
if (MacroRunning)
	goto DoReload
if WinActive("DeepFish BETA")
	return
goto DoReload

HotkeyExit:
if (MacroRunning)
	goto DoExit
if WinActive("DeepFish BETA")
	return
goto DoExit

ToggleMacro:
if (MacroRunning)
	{
	MacroRunning := false
	MacroPreview := false
	GuiControl, 1:, StartStopDisplay, ▶ Start
	gosub, RefreshRunChip
	settimer, runtime, off
	settimer, ClickShakeFailsafe, off
	settimer, NavigationShakeFailsafe, off
	settimer, BarCalculationFailsafe, off
	send {lbutton up}
	send {rbutton up}
	send {shift up}
	StopSweepTicks := 0
	settimer, StopSweep, 25
	gosub, StopSweep
	return
	}
MacroRunning := true
LastAutoStop := 0
RodEquippedOnce := false
KbCatches := 0
KbBusy := false
AqNextTick := 0
AqBusy := false
WhStartTick := A_TickCount
WhLastSummary := A_TickCount
GuiControl, 1:, StartStopDisplay, ⏹ Stop
gosub, RefreshRunChip
goto StartMacroFlow

PreviewOrToggle:
if (MacroRunning)
	{
	gosub, ToggleMacro
	return
	}

if (LastAutoStop and (A_TickCount - LastAutoStop) < 2500)
	{
	LastAutoStop := 0
	gosub, Idle
	return
	}
LastAutoStop := 0

gosub, ResolveRoblox
if (!RobloxHwnd)
	{
	msgbox, 4144, DeepFish, Could not find the Roblox game window. Make sure Roblox is running, then try again.
	return
	}
WinActivate, ahk_id %RobloxHwnd%
WinWaitActive, ahk_id %RobloxHwnd%, , 2
WinMaximize, ahk_id %RobloxHwnd%

gosub, Calculations
MacroPreview := true
gosub, ArmHotkeys
if (!GuiKeepOpen)
	Gui, Hide

return

HotkeyWatch:
if (FreezeActive)
	return
if (!WinExist("DeepFish BETA"))
	gosub, ArmHotkeys
gosub, SyncRunKeys
return

ArmHotkeys:
if (!HotkeysArmed)
	{
	Hotkey, % "$" . StartStopKey, On
	HotkeysArmed := true
	}
gosub, SyncRunKeys
return

SyncRunKeys:
MacroLive := (HotkeysArmed or MacroRunning)
if (MacroLive and !RunKeysArmed)
	{
	Hotkey, % "$" . ReloadKey, On
	Hotkey, % "$" . ExitKey, On
	RunKeysArmed := true
	}
else if (!MacroLive and RunKeysArmed)
	{
	Hotkey, % "$" . ReloadKey, Off
	Hotkey, % "$" . ExitKey, Off
	RunKeysArmed := false
	}
return

DisarmHotkeys:
if (HotkeysArmed)
	{
	Hotkey, % "$" . StartStopKey, Off
	HotkeysArmed := false
	}
gosub, SyncRunKeys
return

DoReload:
MacroRunning := false
send {lbutton up}
send {rbutton up}
send {shift up}
reload

DoExit:
MacroRunning := false
send {lbutton up}
send {rbutton up}
send {shift up}
exitapp

;====================================================================================================;

StartMacroFlow:

TotemLastCheck := 0
WhStartTick := A_TickCount
WhCatches := 0
WhLastCatchTick := 0
WhLastSummary := A_TickCount
WhStalled := false
WhEvent("start")
settimer, WhTick, 30000
send {lbutton up}
send {rbutton up}
send {shift up}

gosub, ResolveRoblox
if (!RobloxHwnd)
	{
	MacroRunning := false
	msgbox, 4144, DeepFish, Could not find the Roblox game window. Make sure Roblox is running, then try again.
	return
	}
WinActivate, ahk_id %RobloxHwnd%
WinWaitActive, ahk_id %RobloxHwnd%, , 2
WinMaximize, ahk_id %RobloxHwnd%

gosub, Calculations
settimer, runtime, 1000

gosub, RefreshHints

tooltip, , , , 6
tooltip, , , , 10
tooltip, , , , 11
tooltip, , , , 12
tooltip, , , , 14
tooltip, , , , 16

tooltip, Current Task: AutoLowerGraphics, %TooltipX%, %Tooltip7%, 7
tooltip, F10 Count: 0/20, %TooltipX%, %Tooltip9%, 9
f10counter := 0
if (AutoLowerGraphics == true)
	{
	send {shift}
	tooltip, Action: Press Shift, %TooltipX%, %Tooltip8%, 8
	sleep %AutoGraphicsDelay%
	send {shift down}
	tooltip, Action: Hold Shift, %TooltipX%, %Tooltip8%, 8
	sleep %AutoGraphicsDelay%
	loop, 20
		{
		f10counter++
		tooltip, F10 Count: %f10counter%/20, %TooltipX%, %Tooltip9%, 9
		send {f10}
		tooltip, Action: Press F10, %TooltipX%, %Tooltip8%, 8
		sleep %AutoGraphicsDelay%
		}
	send {shift up}
	tooltip, Action: Release Shift, %TooltipX%, %Tooltip8%, 8
	sleep %AutoGraphicsDelay%
	}

tooltip, Current Task: AutoZoomInCamera, %TooltipX%, %Tooltip7%, 7
tooltip, Scroll In: 0/20, %TooltipX%, %Tooltip9%, 9
tooltip, Scroll Out: 0/1, %TooltipX%, %Tooltip10%, 10
scrollcounter := 0
if (AutoZoomInCamera == true and CastMode != "Perfect")
	{
	sleep %AutoZoomDelay%
	loop, 20
		{
		scrollcounter++
		tooltip, Scroll In: %scrollcounter%/20, %TooltipX%, %Tooltip9%, 9
		send {wheelup}
		tooltip, Action: Scroll In, %TooltipX%, %Tooltip8%, 8
		sleep %AutoZoomDelay%
		}
	send {wheeldown}
	tooltip, Scroll Out: 1/1, %TooltipX%, %Tooltip10%, 10
	tooltip, Action: Scroll Out, %TooltipX%, %Tooltip8%, 8
	ZoomSettleDelay := AutoZoomDelay*5
	sleep %ZoomSettleDelay%
	}
	
tooltip, , , , 10

tooltip, Current Task: AutoEnableCameraMode, %TooltipX%, %Tooltip7%, 7
tooltip, Right Count: 0/10, %TooltipX%, %Tooltip9%, 9
rightcounter := 0
CamModeOn := (AutoEnableCameraMode and !(TotemAuto or AquariumAuto or KeeperAuto))
if (CamModeOn == true)
	{
	PixelSearch, , , CameraCheckLeft, CameraCheckTop, CameraCheckRight, CameraCheckBottom, 0xFFFFFF, 0, Fast
	if (ErrorLevel == 0)
		{
		sleep %AutoCameraDelay%
		send {2}
		tooltip, Action: Presss 2, %TooltipX%, %Tooltip8%, 8
		sleep %AutoCameraDelay%
		send {1}
		tooltip, Action: Press 1, %TooltipX%, %Tooltip8%, 8
		sleep %AutoCameraDelay%
		send {%NavigationKey%}
		tooltip, Action: Press %NavigationKey%, %TooltipX%, %Tooltip8%, 8
		sleep %AutoCameraDelay%
		loop, 10
			{
			rightcounter++
			tooltip, Right Count: %rightcounter%/10, %TooltipX%, %Tooltip9%, 9
			send {right}
			tooltip, Action: Press Right, %TooltipX%, %Tooltip8%, 8
			sleep %AutoCameraDelay%
			}
		send {enter}
		tooltip, Action: Press Enter, %TooltipX%, %Tooltip8%, 8
		sleep %AutoCameraDelay%
		}
	}

RestartMacro:

if (!MacroRunning)
	goto Idle

send {lbutton up}
send {rbutton up}

if (KeeperAuto and !KbBusy and KbCatches >= Round(KeeperEveryCatches))
	gosub, KeeperRun

if (!MacroRunning)
	goto Idle

if (AquariumAuto and !AqBusy and (AqNextTick = 0 or A_TickCount >= AqNextTick))
	gosub, AquariumRun

if (!MacroRunning)
	goto Idle

tooltip, , , , 9

tooltip, Current Task: AutoLookDownCamera, %TooltipX%, %Tooltip7%, 7
if (AutoLookDownCamera == true)
	{
	send {rbutton up}
	sleep %AutoLookDelay%
	mousemove, LookDownX, LookDownY
	tooltip, Action: Position Mouse, %TooltipX%, %Tooltip8%, 8
	sleep %AutoLookDelay%
	send {rbutton down}
	tooltip, Action: Hold Right Click, %TooltipX%, %Tooltip8%, 8
	sleep %AutoLookDelay%
	DllCall("mouse_event", "UInt", 0x01, "UInt", 0, "UInt", 10000)
	tooltip, Action: Move Mouse Down, %TooltipX%, %Tooltip8%, 8
	sleep %AutoLookDelay%
	send {rbutton up}
	tooltip, Action: Release Right Click, %TooltipX%, %Tooltip8%, 8
	sleep %AutoLookDelay%
	mousemove, LookDownX, LookDownY
	tooltip, Action: Position Mouse, %TooltipX%, %Tooltip8%, 8
	sleep %AutoLookDelay%
	}
	
if (!MacroRunning)
	goto Idle

tooltip, Current Task: AutoBlurCamera, %TooltipX%, %Tooltip7%, 7
if (AutoBlurCamera == true)
	{
	sleep %AutoBlurDelay%
	send {m}
	tooltip, Action: Press M, %TooltipX%, %Tooltip8%, 8
	sleep %AutoBlurDelay%
	}

if (!MacroRunning)
	goto Idle

if (!CamModeOn and RodSlotKey != "" and !RodEquippedOnce)
	ForceReEquip := true

if (RodSlotKey != "" and (ForceReEquip or (UnstickAfter > 0 and CastFailCount >= UnstickAfter)))
	{
	tooltip, Current Task: Re-equipping Rod (stuck bobber), %TooltipX%, %Tooltip7%, 7
	send {lbutton up}
	send {rbutton up}
	sleep 120
	if (BagSlotKey != "")
		send {%BagSlotKey%}
	else
		send {%RodSlotKey%}
	sleep 400
	send {%RodSlotKey%}
	sleep 600
	CastFailCount := 0
	ForceReEquip := false
	RodEquippedOnce := true
	if (!MacroRunning)
		goto Idle
	}

gosub, TotemMaybeRun
if (!MacroRunning)
	goto Idle
tooltip, Current Task: Casting Rod, %TooltipX%, %Tooltip7%, 7
CastHolding := true
if (CastMode = "Perfect")
	{
	send {lbutton down}
	gosub, PerfectCastRelease
	if (!PCReleased)
		send {lbutton up}
	}
else
	{
	send {lbutton down}
	tooltip, Action: Casting For %HoldRodCastDuration%ms, %TooltipX%, %Tooltip8%, 8
	sleep %HoldRodCastDuration%
	send {lbutton up}
	}
CastHolding := false
if (!MacroRunning)
	goto Idle
tooltip, Action: Waiting For Bobber (%WaitForBobberDelay%ms), %TooltipX%, %Tooltip8%, 8
sleep %WaitForBobberDelay%
if (!MacroRunning)
	goto Idle

if (ShakeMode == "Disabled")
goto BarMinigame
else if (ShakeMode == "Click")
goto ClickShakeMode
else if (ShakeMode == "Navigation")
goto NavigationShakeMode

;====================================================================================================;

ClickShakeFailsafe:
ClickFailsafeCount++
tooltip, Failsafe: %ClickFailsafeCount%/%ClickShakeFailsafe%, %TooltipX%, %Tooltip14%, 14
if (ClickFailsafeCount >= ClickShakeFailsafe)
	{
	settimer, ClickShakeFailsafe, off
	CastFailCount++
	ForceReset := true
	}
return

ClickShakeMode:

tooltip, Current Task: Shaking, %TooltipX%, %Tooltip7%, 7
tooltip, Click X: None, %TooltipX%, %Tooltip8%, 8
tooltip, Click Y: None, %TooltipX%, %Tooltip9%, 9

tooltip, Click Count: 0, %TooltipX%, %Tooltip11%, 11
tooltip, Bypass Count: 0/%RepeatBypassCounter%, %TooltipX%, %Tooltip12%, 12

tooltip, Failsafe: 0/%ClickShakeFailsafe%, %TooltipX%, %Tooltip14%, 14

MgInPlay := false
ClickFailsafeCount := 0
ClickCount := 0
ClickShakeRepeatBypassCounter := 0
MemoryX := 0
MemoryY := 0
ForceReset := false
MinigameSeen := 0
MgScore := 0
MgConf := 0

settimer, ClickShakeFailsafe, 1000

ClickShakeModeRedo:
if (!MacroRunning)
	goto Idle
if (ForceReset == true)
	{
	tooltip, , , , 11
	tooltip, , , , 12
	tooltip, , , , 14
	goto RestartMacro
	}
sleep %ClickScanDelay%
gosub, CaptureFishBar
if (SpecialRod = "Tranquility")
	{
	MinigameSeen := ManiaVisible() ? MinigameSeen + 1 : 0
	MinigameHit := (MinigameSeen >= 2)
	}
else
	{
	MinigameHit := FishLineVisible()
	if (MinigameHit)
		MinigameSeen := 0
	else
		{
		MinigameSeen := MinigameVisible(6) ? MinigameSeen + 1 : 0
		if (MinigameSeen >= 2)
			MinigameHit := true
		}
	}
if (MinigameHit)
	{
	settimer, ClickShakeFailsafe, off
	tooltip, , , , 9
	tooltip, , , , 11
	tooltip, , , , 12
	tooltip, , , , 14
	goto BarMinigame
	}
else
	{
	PixelSearch, ClickX, ClickY, ClickShakeLeft, ClickShakeTop, ClickShakeRight, ClickShakeBottom, 0xFFFFFF, %ClickShakeColorTolerance%, Fast
	if (ErrorLevel == 0)
		{
		tooltip, Click X: %ClickX%, %TooltipX%, %Tooltip8%, 8
		tooltip, Click Y: %ClickY%, %TooltipX%, %Tooltip9%, 9
		if (ClickX != MemoryX or ClickY != MemoryY)
			{
			ClickShakeRepeatBypassCounter := 0
			tooltip, Bypass Count: %ClickShakeRepeatBypassCounter%/%RepeatBypassCounter%, %TooltipX%, %Tooltip12%, 12
			ClickFailsafeCount := 0
			ClickCount++
			click, %ClickX%, %ClickY%
			tooltip, Click Count: %ClickCount%, %TooltipX%, %Tooltip11%, 11
			MemoryX := ClickX
			MemoryY := ClickY
			goto ClickShakeModeRedo
			}
		else
			{
			ClickShakeRepeatBypassCounter++
			tooltip, Bypass Count: %ClickShakeRepeatBypassCounter%/%RepeatBypassCounter%, %TooltipX%, %Tooltip12%, 12
			if (ClickShakeRepeatBypassCounter >= RepeatBypassCounter)
				{
				MemoryX := 0
				MemoryY := 0
				}
			goto ClickShakeModeRedo
			}
		}
	else
		{
		goto ClickShakeModeRedo
		}
	}

;====================================================================================================;

NavigationShakeFailsafe:
NavigationFailsafeCount++
tooltip, Failsafe: %NavigationFailsafeCount%/%NavigationShakeFailsafe%, %TooltipX%, %Tooltip10%, 10
if (NavigationFailsafeCount >= NavigationShakeFailsafe)
	{
	settimer, NavigationShakeFailsafe, off
	CastFailCount++
	ForceReset := true
	}
return

NavigationShakeMode:

tooltip, Current Task: Shaking, %TooltipX%, %Tooltip7%, 7
tooltip, Attempt Count: 0, %TooltipX%, %Tooltip8%, 8

tooltip, Failsafe: 0/%NavigationShakeFailsafe%, %TooltipX%, %Tooltip10%, 10

MgInPlay := false
NavigationFailsafeCount := 0
NavigationCounter := 0
ForceReset := false
MinigameSeen := 0
MgScore := 0
MgConf := 0
settimer, NavigationShakeFailsafe, 1000
NavigationShakeModeRedo:
if (!MacroRunning)
	goto Idle
if (ForceReset == true)
	{
	tooltip, , , , 10
	goto RestartMacro
	}
sleep %NavigationSpamDelay%
gosub, CaptureFishBar
if (SpecialRod = "Tranquility")
	{
	MinigameSeen := ManiaVisible() ? MinigameSeen + 1 : 0
	MinigameHit := (MinigameSeen >= 2)
	}
else
	{
	MinigameHit := FishLineVisible()
	if (MinigameHit)
		MinigameSeen := 0
	else
		{
		MinigameSeen := MinigameVisible(6) ? MinigameSeen + 1 : 0
		if (MinigameSeen >= 2)
			MinigameHit := true
		}
	}
if (MinigameHit)
	{
	settimer, NavigationShakeFailsafe, off
	goto BarMinigame
	}
else
	{
	NavigationCounter++
	tooltip, Attempt Count: %NavigationCounter%, %TooltipX%, %Tooltip8%, 8
	sleep 1
	send {enter}
	goto NavigationShakeModeRedo
	}

;====================================================================================================;

BarCalculationFailsafe:
BarCalcFailsafeCounter++
tooltip, Failsafe: %BarCalcFailsafeCounter%/%BarCalculationFailsafe%, %TooltipX%, %Tooltip10%, 10
if (BarCalcFailsafeCounter >= BarCalculationFailsafe)
	{
	settimer, BarCalculationFailsafe, off
	CastFailCount++
	ForceReEquip := true
	ForceReset := true
	}
return

BarMinigame:
MgInPlay := true
BarColRing := []
BarColT := 0
RemBarRing := []
HudWRing := []
HudWMed := 0

CastFailCount := 0
if (SpecialRod = "Tranquility")
	{
	tooltip, Current Task: Playing Notes, %TooltipX%, %Tooltip7%, 7
	tooltip, , , , 8
	tooltip, , , , 10
	ForceReset := false
	MinigameLost := 0
	ManiaPrevY := [-1, -1, -1, -1]
	ManiaHitY := -1
	ManiaPrevT := [0, 0, 0, 0]
	ManiaSpeed := [0, 0, 0, 0]
	ManiaFired := [false, false, false, false]
	goto BarMinigame2
	}

tooltip, Current Task: Calculating Bar Size, %TooltipX%, %Tooltip7%, 7
tooltip, Bar Size: Not Found, %TooltipX%, %Tooltip8%, 8
tooltip, Failsafe: 0/%BarCalculationFailsafe%, %TooltipX%, %Tooltip10%, 10

ForceReset := false
BarCalcFailsafeCounter := 0
MgOverWhy := ""
settimer, BarCalculationFailsafe, 1000

if (SpecialRod = "Noiseform")
	{
	NoiseWCal := 0
	NoiseWCnt := {}
	NoiseWVote := 0
	NoisePrevC := -1
	NoisePrevT := 0
	NoiseVelC := 0
	NoiseCoastN := 0
	NoiseStillX := -1
	NoiseStillC := 0
	NoiseLostN := 0
	NoiseEHist := []
	NoiseFishPrev := -1
	NoiseFishT := 0
	NoiseFoundStreak := 0
	NoiseJumpHold := 0
	NoiseStuckN := 0
	NoiseStuckRel := 0
	NoiseStaleN := 0
	NoiseStaleBlk := 0
	NoiseOnZoneN := 0
	NoiseLastBarX := -1
	NoiseAltW := 0
	NoiseAltN := 0
	NoiseZSeenT := 0
	NoiseRate := 1
	NoiseRateT := 0
	NoiseN6 := 6
	NoiseN8 := 8
	NoiseN15 := 15
	NoiseN45 := 45
	HudZoneShown := false
	HudDirty := true
	}

BarMinigameRedo:
if (!MacroRunning)
	goto Idle
if (ForceReset == true)
	{
	tooltip, , , , 10
	goto RestartMacro
	}
gosub, CaptureFishBar
if (BarPresent())
	{
	BarWidthSamples := []
	BarWidthSamples.Push(RunWidth)
	NoiseEntryFish := NoiseFishFresh ? 1 : 0
	Loop, 8
		{
		if (!MacroRunning)
			goto Idle
		sleep 12
		gosub, CaptureFishBar
		if (BarPresent())
			BarWidthSamples.Push(RunWidth)
		if (NoiseFishFresh)
			NoiseEntryFish := NoiseEntryFish + 1
		}
	if (BarWidthSamples.MaxIndex() >= 3 and (SpecialRod != "Noiseform" or NoiseEntryFish >= 2))
		{
		WhiteBarSize := MedianOf(BarWidthSamples)
		BarWCal := WhiteBarSize
		BarWTrust := WhiteBarSize
		goto BarMinigameSingle
		}
	}
sleep 1
goto BarMinigameRedo

;====================================================================================================;

BarMinigameSingle:

tooltip, Current Task: Playing Bar Minigame, %TooltipX%, %Tooltip7%, 7
tooltip, Bar Size: %WhiteBarSize%, %TooltipX%, %Tooltip8%, 8


HalfBarSize := WhiteBarSize/2
MgLastSig := -1
MgStaticN := 0
BarSizeBadN := 0
BarSizePend := 0
BarSizePendN := 0
DllCall("QueryPerformanceCounter", "Int64*", MgStaticAt)
SideDelay := 0
AnkleBreakDelay := 0
DirectionalToggle := "Disabled"
AtLeastFindWhiteBar := false
LastFishX := -1
LastBarL := -1
LastBarR := -1
MinigameLost := 0
BelNoStrong := 0
NoisePrevC := -1
NoisePrevT := 0
NoiseFishPrev := -1
NoiseFishT := 0
NoiseStillX := -1
NoiseStillC := 0
NoiseWCal := 0
NoiseJumpN := 0
NoiseJumpHold := 0
NoiseStuckN := 0
NoiseStuckRel := 0
NoiseStaleN := 0
NoiseStaleBlk := 0
NoiseOnZoneN := 0
NoiseLastBarX := -1
NoiseRate := 1
NoiseRateT := 0
NoiseN6 := 6
NoiseN8 := 8
NoiseN15 := 15
NoiseN45 := 45
NoiseAltW := 0
NoiseAltN := 0
NoiseZSeenT := 0
NoiseWCnt := {}
NoiseWVote := 0
NoiseLastD := 0
NoiseOscN := 0
NoiseVelC := 0
NoiseLostN := 0
NoiseRowOff := 0
NoiseCoastN := 0
NoiseWBase := 0
NoiseWBaseML := 0
NoiseWDthr := 6
NoiseZoneTgt := -1
NoiseZoneT := 0
NoiseZoneKind := ""
NoiseZScanT := 0
NoiseZFreshT := 0
NoisePendKind := ""
NoisePendT := 0
NoiseWNow := ""
NoiseWBlk := 0
NoiseDkRing := []
NoiseMlRing := []
NoiseD6Ring := []
NoiseDkIdx := 0
NoiseDkN := 0
NoiseWGT := 0
DkI := 0
while (DkI < 32)
	{
	NoiseDkRing[DkI] := -1
	NoiseMlRing[DkI] := -1
	NoiseD6Ring[DkI] := -1
	DkI := DkI + 1
	}
NoiseZBD := 0
NoiseZBB := 0
NoiseZBL := 0
NoiseZBG := 0
NoiseMissN := 0
NoiseMissT := 0
WMissN := 0
WMissT := 0
WRW := 0
WRH := 0
WRN := 0
WRIdx := 0
WRSkip := 0
NoiseZWx := -1
NoiseZGx := -1
NoiseZKx := -1
NoiseZOK := false
NoiseEHist := []
RelLock := 0
DutyAvg := 0.5
DarkAcc := 0
NoteAcc := 0
DarkHoldN := 0
DarkFlashing := false
NoteLockX := -1
NoteLockN := 0
NoteNextX := -1
NoteNextY := -1
NoteLockY := -1
NoteHoldX := -1
LullFrames := 0
LullCalN := 0
LullR := 0
LullSecN := 0
LullCalLt := []
LullCalDk := []
LullCalLs := []
LullBg := []
LullSecA := []
LullSecB := []
LullArmA := []
LullClrT := []
LullActive := false
LullSeen := false
LullGoneN := 0
LullClicks := 0
NoteAllN := 0
LineBarW := -1
LineBarAge := 99

MaxLeftToggle := false
MaxRightToggle := false

PrevBarX := -1
PrevFishX := -1
PrevSampleT := 0
BarVel := 0.0
FishVel := 0.0
PrevPosAbs := -1
PrecisionDown := false
BarLostAt := 0
NoFishAt := 0
BlindAcc := 0
BarWOutFirst := 0
BarWCal := WhiteBarSize
BarWRing := []
BarWMed := 0
BarWOutN := 0
HudWRing := []
HudWMed := 0
BarWidthTrusted := true
BarLiveL := -1
BarLiveR := -1
BarLiveMiss := 0
BarWLive := -1
BarLiveOnlyAt := 0
CastBlindN := 0
CastPrevL := -1
CastPrevW := -1
CastPrevF := -1
CastSameN := 0
CastSameT := 0
CastStatic := false
RemWhiteX := -1
RemBlackX := -1
RemTargetX := -1
CtrAcc := 0
CtrBias := 0
MiguLastX := -1
NoiseFoundStreak := 0
ZoneInset := WhiteBarSize*SideBarRatio
ZoneInsetMax := (FishBarRight-FishBarLeft)*0.4
if (ZoneInset > ZoneInsetMax)
	ZoneInset := ZoneInsetMax
MaxLeftBar := FishBarLeft+ZoneInset
MaxRightBar := FishBarRight-ZoneInset

gosub, ShowHud
gosub, UpdateHud

BarMinigame2:
if (!MacroRunning)
	goto Idle
if (ForceReset == true)
	{
	MgOverWhy := "forcereset"
	goto BarMinigameOver
	}
DllCall("QueryPerformanceCounter", "Int64*", PfA)
PfDt := PfPrev ? Round((PfA - PfPrev) * 1000.0 / QpcFreq, 1) : 0
PfPrev := PfA
sleep 0
DllCall("QueryPerformanceCounter", "Int64*", PfB)
gosub, CaptureFishBar
DllCall("QueryPerformanceCounter", "Int64*", PfC)
PfSleep := Round((PfB - PfA) * 1000.0 / QpcFreq, 1)
PfCap := Round((PfC - PfB) * 1000.0 / QpcFreq, 1)
if (SpecialRod = "Lullaby")
	{
	if (LullScan())
		{
		send {lbutton down}
		sleep 20
		send {lbutton up}
		LullClicks := LullClicks + 1
		tooltip, Lullaby: %LullSecN% light sector(s)`, hits %LullClicks% (last #%LullHitSec%), %TooltipX%, %Tooltip9%, 9
		}
	if (LullActive)
		{
		LullSeen := true
		LullGoneN := 0
		}
	else if (LullSeen)
		{
		LullGoneN := LullGoneN + 1
		if (LullGoneN >= 25)
			{
			MgOverWhy := "lullaby-done"
			goto BarMinigameOver
			}
		}
	goto BarMinigame2
	}

if (SpecialRod = "Tranquility")
	{
	if (ManiaVisible())
		{
		MinigameLost := 0
		ManiaStep()
		}
	else
		{
		MinigameLost++
		if (MinigameLost >= 10)
			goto BarMinigameOver
		}
	goto BarMinigame2
	}

if (SpecialRod = "Bellona's Waraxe")
	{
	BelRes := BellonaScan()
	if (BelRes = 2)
		BelNoStrong := 0
	else
		BelNoStrong++
	if (BelRes = 0)
		{
		MinigameLost++
		if (MinigameLost = 1)
			BellonaRelease()
		if (MinigameLost >= 8)
			goto BarMinigameOver
		goto BarMinigame2
		}
	MinigameLost := 0
	if (BelNoStrong >= 150)
		{
		BellonaRelease()
		goto BarMinigameOver
		}
	BellonaDrive(1)
	BellonaDrive(2)
	if (BelOK[1])
		{
		if (BelF[1] >= 0)
			MoveHudFish(FishBarLeft + BelF[1])
		MoveHudBarSpan(FishBarLeft + BelA[1], BelB[1] - BelA[1])
		}
	if (BelOK[2] and BelF[2] >= 0)
		MoveHudNote(FishBarLeft + BelF[2])
	else
		MoveHudNote(-1)
	goto BarMinigame2
	}

FoundBar := BarPresent()
if (FoundBar and SpecialRod = "None" and BarWCal > 0 and RunWidth < BarWCal * 0.2)
	{
	FoundBar := false
	}
LineSeen := FishLineVisible()
if (!FoundBar and !LineSeen and SpecialRod != "Remembrance" and SpecialRod != "MiguRod" and SpecialRod != "Halibut Harpoon")
	LineSeen := (FindArrowX() >= 0)
if (!FoundBar and !LineSeen)
	{
	NoiseFoundStreak := 0
	MinigameLost++
	if (MinigameLost = 1)
		{
		send {lbutton up}
		PrecisionDown := false
		DllCall("QueryPerformanceCounter", "Int64*", BarLostAt)
		gosub, HideHud
		}
	DllCall("QueryPerformanceCounter", "Int64*", BarLostNow)
	if (BarLostAt and ((BarLostNow - BarLostAt) * 1000.0 / QpcFreq) > 750)
		{
		MgOverWhy := "barlost"
		goto BarMinigameOver
		}
	goto BarMinigame2
	}
if (MinigameLost and HudBuilt)
	gosub, ShowHud
MinigameLost := 0
BarLostAt := 0
NoiseFoundStreak := NoiseFoundStreak + 1

if (FoundBar and RunWidth > 0)
	{
	if (BarWidthTrusted and !(BarWCal > 0 and RunWidth > BarWCal * 1.3))
		{
		if (BarWMed <= 0 or Abs(RunWidth - BarWMed) <= (BarWMed * 0.25))
			{
			BarWPush(RunWidth)
			BarWOutN := 0
			BarWOutFirst := 0
			}
		else
			{
			if (BarWOutN > 0 and BarWOutFirst > 0 and Abs(RunWidth - BarWOutFirst) <= (BarWOutFirst * 0.15))
				BarWOutN := BarWOutN + 1
			else
				{
				BarWOutFirst := RunWidth
				BarWOutN := 1
				}
			if (BarWOutN >= 4)
				{
				BarWRing := []
				BarWMed := 0
				BarWOutN := 0
				BarWOutFirst := 0
				BarWPush(RunWidth)
				}
			}
		}
	NewBarSize := (BarWMed > 0) ? BarWMed : RunWidth
	if (SpecialRod = "Noiseform" and NoiseWCal >= 40)
		NewBarSize := NoiseWCal
	if (!HudZoneShown and HudBuilt and (SpecialRod != "Noiseform" or NoiseWCal >= 40))
		{
		HudZoneShown := true
		HudDirty := true
		}
	BarWTrust := (BarWMed > 0 and Abs(RunWidth - BarWMed) <= (BarWMed * 0.25)) ? RunWidth : NewBarSize
	if (BarWidthTrusted and Abs(NewBarSize - WhiteBarSize) > (WhiteBarSize * 0.2))
		{
		WhiteBarSize := NewBarSize
		HalfBarSize := WhiteBarSize/2
		ZoneInset := WhiteBarSize*SideBarRatio
		ZoneInsetMax := (FishBarRight-FishBarLeft)*0.4
		if (ZoneInset > ZoneInsetMax)
			ZoneInset := ZoneInsetMax
		MaxLeftBar := FishBarLeft+ZoneInset
		MaxRightBar := FishBarRight-ZoneInset
		gosub, UpdateHud
		}
	}

DllCall("QueryPerformanceCounter", "Int64*", PfD)
FishX := GetFishPos()
DllCall("QueryPerformanceCounter", "Int64*", PfE)

if (SpecialRod != "Tranquility" and SpecialRod != "Lullaby" and SpecialRod != "Noiseform")
	{
	if (FishX >= 0)
		NoFishAt := 0
	else if (!NoFishAt)
		NoFishAt := A_TickCount
	else if ((A_TickCount - NoFishAt) > 8000)
		{
		MgOverWhy := "nofishline"
		goto BarMinigameOver
		}
	}

NoteAt := NoteTarget()
TargetIsNote := false
DllCall("QueryPerformanceCounter", "Int64*", PfF)
PfFish := Round((PfE - PfD) * 1000.0 / QpcFreq, 1)
PfNote := Round((PfF - PfE) * 1000.0 / QpcFreq, 1)
MoveHudNote(DarkFlashing ? FishX : ((SpecialRod = "Pinions Aria" and NoteAt < 0 and NoteBias >= 100) ? NoteHoldX : NoteAt))
if (SpecialRod = "Remembrance")
	MoveHudNote(RemBlackX)
MoveHudNote2((SpecialRod = "Pinions Aria" and !DarkFlashing) ? NoteNextX : -1)
if (FishX >= 0)
	MoveHudFish(FishX)
if (NoteAt >= 0)
	{
	NoteW2 := NoteBias
	if (SpecialRod = "Noiseform" or SpecialRod = "Halibut Harpoon")
		NoteW2 := 100
	if (NoteW2 < 0)
		NoteW2 := 0
	if (NoteW2 > 100)
		NoteW2 := 100
	if (FishX >= 0)
		FishX := ((NoteAt * NoteW2) + (FishX * (100 - NoteW2))) / 100
	else if (SpecialRod != "Noiseform")
		FishX := NoteAt
	if (SpecialRod = "Pinions Aria")
		{
		NoteHoldX := NoteAt
		DllCall("QueryPerformanceCounter", "Int64*", NoteHoldAt)
		}
	TargetIsNote := (NoteW2 >= 60)
	}
else if (SpecialRod = "Pinions Aria" and NoteBias >= 100 and NoteHoldX >= 0)
	{
	DllCall("QueryPerformanceCounter", "Int64*", NoteHoldNow)
	if (NoteHoldAt and ((NoteHoldNow - NoteHoldAt) * 1000.0 / QpcFreq) < 220)
		{
		FishX := NoteHoldX
		TargetIsNote := true
		}
	else
		NoteHoldX := -1
	}
if (DarkFlashing)
	{
	DarkAcc := DarkAcc + DutyAvg
	if (DarkAcc >= 1)
		{
		DarkAcc := DarkAcc - 1
		gosub, PrecisionHold
		}
	else
		gosub, PrecisionRelease
	goto BarMinigame2
	}
if (FishX >= 0 and RunWidth > 0)
	{
	DutyErr := Abs(FishX - (RunLeft + RunWidth / 2))
	DutyNear := TargetIsNote ? NoteHoldZone(RunWidth) : 30
	if (DutyNear < 30)
		DutyNear := 30
	if (DutyErr < DutyNear)
		DutyAvg := DutyAvg * 0.9 + (PrecisionDown ? 0.1 : 0)
	}
if (FishX < 0 and SpecialRod = "Noiseform")
	{
	NoiseLostN := NoiseLostN + 1

	gosub, PrecisionRelease
	if (NoiseLostN >= 60)
		{
		MgOverWhy := "nofish60"
		goto BarMinigameOver
		}
	goto BarMinigame2
	}
if (SpecialRod = "Noiseform")
	NoiseLostN := 0
if (FishX >= 0)
	{
	if (ControlMode = "Precision" or ControlMode = "Lines" or SpecialRod = "Requiem")
		goto BarPrecisionControl
	if (FishX < MaxLeftBar)
		{
		if (MaxLeftToggle == false)
			{
			MoveHudBarSpan(RunLeft, RunWidth)
			DirectionalToggle := "Right"
			MaxLeftToggle := true
			send {lbutton up}
			sleep 1
			send {lbutton up}
			sleep %SideDelay%
			AnkleBreakDelay := 0
			SideDelay := 0
			}
		goto BarMinigame2
		}
	else if (FishX > MaxRightBar)
		{
		if (MaxRightToggle == false)
			{
			MoveHudBarSpan(RunLeft, RunWidth)
			DirectionalToggle := "Left"
			MaxRightToggle := true
			send {lbutton down}
			sleep 1
			send {lbutton down}
			sleep %SideDelay%
			AnkleBreakDelay := 0
			SideDelay := 0
			}
		goto BarMinigame2
		}
	MaxLeftToggle := false
	MaxRightToggle := false
	if (FoundBar)
		{
		AtLeastFindWhiteBar := true
		BarX := RunLeft+(RunWidth/2)
		if (BarX > FishX)
			{
			MoveHudBarSpan(RunLeft, RunWidth)
			Difference := (BarX-FishX)*ResolutionScaling*StableLeftMultiplier
			CounterDifference := Difference/StableLeftDivision
			send {lbutton up}
			if (DirectionalToggle == "Right")
				{
				sleep %AnkleBreakDelay%
				AnkleBreakDelay := 0
				}
			else
				{
				AnkleBreakDelay := AnkleBreakDelay+(Difference-CounterDifference)*LeftAnkleBreakMultiplier
				SideDelay := AnkleBreakDelay/LeftAnkleBreakMultiplier*SideBarWaitMultiplier
				}
			SleepTrack(Difference, "Left", false)
			CounterDifference := CounterDifference*HeldFraction
			gosub, CaptureFishBar
			FishX := GetFishPos()
			if (FishX < MaxLeftBar)
				goto BarMinigame2
			send {lbutton down}
			sleep %CounterDifference%
			gosub, StabilizeBurst
			DirectionalToggle := "Left"
			}
		else
			{
			MoveHudBarSpan(RunLeft, RunWidth)
			Difference := (FishX-BarX)*ResolutionScaling*StableRightMultiplier
			CounterDifference := Difference/StableRightDivision
			send {lbutton down}
			if (DirectionalToggle == "Left")
				{
				sleep %AnkleBreakDelay%
				AnkleBreakDelay := 0
				}
			else
				{
				AnkleBreakDelay := AnkleBreakDelay+(Difference-CounterDifference)*RightAnkleBreakMultiplier
				SideDelay := AnkleBreakDelay/RightAnkleBreakMultiplier*SideBarWaitMultiplier
				}
			SleepTrack(Difference, "Right", false)
			CounterDifference := CounterDifference*HeldFraction
			gosub, CaptureFishBar
			FishX := GetFishPos()
			if (FishX > MaxRightBar)
				goto BarMinigame2
			send {lbutton up}
			sleep %CounterDifference%
			gosub, StabilizeBurst
			DirectionalToggle := "Right"
			}
		}
	else
		{
		tooltip, Bar NOT FOUND, %TooltipX%, %Tooltip9%, 9
		if (AtLeastFindWhiteBar == false)
			{
			if (FishLineVisible() or FindArrowX() >= 0)
				{
				send {lbutton down}
				send {lbutton up}
				}
			goto BarMinigame2
			}

		ArrowX := FindArrowX()
		if (ArrowX < 0)
			ArrowX := FindColorX(0x878584, ArrowColorTolerance)
		if (ArrowX < 0)
			goto BarMinigame2
		if (ArrowX > FishX)
			{
			MoveHudBarC(ArrowX)
			Difference := HalfBarSize*UnstableLeftMultiplier
			CounterDifference := Difference/UnstableLeftDivision
			send {lbutton up}
			if (DirectionalToggle == "Right")
				{
				sleep %AnkleBreakDelay%
				AnkleBreakDelay := 0
				}
			else
				{
				AnkleBreakDelay := AnkleBreakDelay+(Difference-CounterDifference)*LeftAnkleBreakMultiplier
				SideDelay := AnkleBreakDelay/LeftAnkleBreakMultiplier*SideBarWaitMultiplier
				}
			SleepTrack(Difference, "Left", true)
			CounterDifference := CounterDifference*HeldFraction
			gosub, CaptureFishBar
			FishX := GetFishPos()
			if (FishX < MaxLeftBar)
				goto BarMinigame2
			send {lbutton down}
			sleep %CounterDifference%
			gosub, StabilizeBurst
			DirectionalToggle := "Left"
			}
		else
			{
			MoveHudBarC(ArrowX)
			Difference := HalfBarSize*UnstableRightMultiplier
			CounterDifference := Difference/UnstableRightDivision
			send {lbutton down}
			if (DirectionalToggle == "Left")
				{
				sleep %AnkleBreakDelay%
				AnkleBreakDelay := 0
				}
			else
				{
				AnkleBreakDelay := AnkleBreakDelay+(Difference-CounterDifference)*RightAnkleBreakMultiplier
				SideDelay := AnkleBreakDelay/RightAnkleBreakMultiplier*SideBarWaitMultiplier
				}
			SleepTrack(Difference, "Right", true)
			CounterDifference := CounterDifference*HeldFraction
			gosub, CaptureFishBar
			FishX := GetFishPos()
			if (FishX > MaxRightBar)
				goto BarMinigame2
			send {lbutton up}
			sleep %CounterDifference%
			gosub, StabilizeBurst
			DirectionalToggle := "Right"
			}
		}
	goto BarMinigame2
	}

BlindAcc := BlindAcc + DutyAvg
if (BlindAcc >= 1)
	{
	BlindAcc := BlindAcc - 1
	gosub, PrecisionHold
	}
else
	gosub, PrecisionRelease
goto BarMinigame2

BarPrecisionControl:

if (!FoundBar)
	{
	if (SpecialRod = "Castbound" and CastBlindN < 40)
		{
		CastBlindN := CastBlindN + 1
		NoteAcc := NoteAcc + DutyAvg
		if (NoteAcc >= 1)
			{
			NoteAcc := NoteAcc - 1
			WantDown := true
			}
		else
			WantDown := false
		goto PrecisionApply
		}
	if (SpecialRod = "Remembrance" or SpecialRod = "MiguRod" or SpecialRod = "Halibut Harpoon")
		{
		gosub, PrecisionRelease
		goto BarMinigame2
		}
	ArrowX := FindArrowX()
	if (ArrowX < 0)
		{
		gosub, PrecisionRelease
		goto BarMinigame2
		}
	MoveHudBarC(ArrowX)
	WantDown := (ArrowX > FishX) ? false : true
	goto PrecisionApply
	}

BarX := RunLeft + (RunWidth/2)
CastBlindN := 0
MoveHudBarSpan(RunLeft, RunWidth)

; --- velocities -------------------------------------------------------------------------------
DllCall("QueryPerformanceCounter", "Int64*", tNowP)
if (PrevSampleT > 0)
	{
	dtP := (tNowP - PrevSampleT) / QpcFreq
	if (dtP > 0.0005)
		{
		rawBarVel := (BarX - PrevBarX) / dtP
		rawFishVel := (FishX - PrevFishX) / dtP
		if (Abs(FishX - PrevFishX) > 100)
			{
			rawFishVel := 0
			FishVel := 0
			}
		if (TargetIsNote)
			{
			rawFishVel := 0
			FishVel := 0
			}
		VsA := VelocitySmoothing
		if (SpecialRod = "Noiseform" and NoiseRate > 1 and VsA > 0 and VsA < 1)
			VsA := 1 - ((1 - VsA) ** NoiseRate)
		if (TargetIsNote and SpecialRod != "Noiseform" and VsA < 0.6)
			VsA := 0.6
		BarVel := VsA*rawBarVel + (1-VsA)*BarVel
		FishVel := VsA*rawFishVel + (1-VsA)*FishVel
		PrevBarX := BarX
		PrevFishX := FishX
		PrevSampleT := tNowP
		}
	}
else
	{
	PrevBarX := BarX
	PrevFishX := FishX
	PrevSampleT := tNowP
	}

PosError := BarX - FishX             
RelVel := BarVel - FishVel

SteadyTarget := (TargetIsNote and SpecialRod != "Halibut Harpoon")

if (SpecialRod = "Noiseform")
	{
	StopDist := Abs(RelVel) * StoppingDistanceMultiplier * 0.04
	if (StopDist < CaptureW * 0.01)
		StopDist := CaptureW * 0.01
	if (StopDist > RunWidth * 0.5)
		StopDist := RunWidth * 0.5
	}
else
	StopDist := Abs(RelVel) * StoppingDistanceMultiplier
if (SteadyTarget and SpecialRod != "Noiseform")
	StopDist := StopDist * 1.6

; --- reachable span ---------------------------------------------------------------------------
HalfW := RunWidth/2
MinReach := FishBarLeft + HalfW
MaxReach := FishBarRight - HalfW
CtrRs := (ResolutionScaling > 0) ? ResolutionScaling : 1
CtrZoneE := 36 / CtrRs
if (CtrZoneE > RunWidth * 0.35)
	CtrZoneE := RunWidth * 0.35
CtrZoneV := 120 / CtrRs
CtrHold := (SpecialRod != "Requiem" and !SteadyTarget
	and Abs(PosError) <= CtrZoneE and Abs(RelVel) <= CtrZoneV)


if (SpecialRod = "Castbound" and CastStatic
	and RunLeft > FishBarLeft + 2 and (RunLeft + RunWidth) < FishBarRight - 2
	and Abs(PosError) <= RunWidth * 0.5)
	{
	NoteAcc := NoteAcc + 0.5
	if (NoteAcc >= 1)
		{
		NoteAcc := NoteAcc - 1
		WantDown := true
		}
	else
		WantDown := false
	}
else if (FishX < MinReach)
	{
	WantDown := false
	}
else if (FishX > MaxReach)
	{
	WantDown := true
	}
else if (CtrHold)
	{
	CtrKp := 0.0122 * CtrRs
	CtrKd := 0.00488 * CtrRs
	if (dtP > 0 and dtP < 0.1)
		{
		CtrBias := CtrBias - (0.25 * CtrKp * PosError * dtP)
		if (CtrBias > 0.2)
			CtrBias := 0.2
		if (CtrBias < -0.2)
			CtrBias := -0.2
		}
	CtrDuty := 0.463 + CtrBias - (CtrKp * PosError) - (CtrKd * RelVel)
	if (CtrDuty < 0)
		CtrDuty := 0
	if (CtrDuty > 1)
		CtrDuty := 1
	CtrAcc := CtrAcc + CtrDuty
	if (CtrAcc >= 1)
		{
		CtrAcc := CtrAcc - 1
		WantDown := true
		}
	else
		WantDown := false
	}
else if (SpecialRod = "Castbound")
	{
	CastSdm := StoppingDistanceMultiplier
	if (CastSdm <= 0)
		CastSdm := 3.0
	CastStopA := 1000.0 * (3.0 / CastSdm)
	CastSigma := PosError + ((RelVel * Abs(RelVel)) / (2 * CastStopA))
	CastDead := RunWidth * 0.02
	if (CastDead < 2)
		CastDead := 2
	if (CastSigma > CastDead)
		WantDown := false
	else if (CastSigma < -CastDead)
		WantDown := true
	else
		WantDown := PrecisionDown
	}
else if (FishX >= RunLeft and FishX <= (RunLeft + RunWidth))
	{
	if (SpecialRod = "Noiseform")
		{
		if (NoiseFishFresh)
			NoiseStaleN := 0
		else
			NoiseStaleN := NoiseStaleN + 1
		if (PrecisionDown and Abs(Round(BarX) - NoiseLastBarX) <= 2 and Abs(PosError) > 100)
			NoiseStuckN := NoiseStuckN + 1
		else if (Abs(Round(BarX) - NoiseLastBarX) > 2)
			{
			NoiseStuckN := 0
			NoiseLastBarX := Round(BarX)
			}
		if (NoiseStuckN >= NoiseN6 and !PrecisionDown)
			{
			NoiseStuckRel := NoiseStuckRel + 1
			if (NoiseStuckRel >= 12)
				{
				NoiseStuckN := 0
				NoiseStuckRel := 0
				NoiseLastBarX := Round(BarX)
				}
			}
		else
			NoiseStuckRel := 0
		ZoneSlack := 0
		if (NoiseZoneTgt >= 0)
			ZoneSlack := Round(CaptureW * 0.030)
		if (NoiseZoneTgt >= 0 and ZoneSlack > 0 and Abs(PosError) <= ZoneSlack)
			NoiseOnZoneN := NoiseOnZoneN + 1
		else
			NoiseOnZoneN := 0
		if (ZoneSlack > 0 and Abs(PosError) <= ZoneSlack)
			WantDown := ((PosError + (RelVel * 0.12)) > 0) ? false : true
		else
			{
			ControlOut := Kp*PosError + Kd*RelVel*0.60
			WantDown := (ControlOut > 0) ? false : true
			}
		}
	else if (SteadyTarget and Abs(PosError) <= NoteHoldZone(RunWidth))
		{
		NoteDuty := DutyAvg - (PosError / (NoteHoldZone(RunWidth) * 5.4)) - (BarVel * 0.0016)
		if (NoteDuty < 0)
			NoteDuty := 0
		if (NoteDuty > 1)
			NoteDuty := 1
		NoteAcc := NoteAcc + NoteDuty
		if (NoteAcc >= 1)
			{
			NoteAcc := NoteAcc - 1
			WantDown := true
			}
		else
			WantDown := false
		}
	else if (PosError < -StopDist)
		WantDown := true
	else if (PosError > StopDist)
		WantDown := false
	else
		{
		NoteAcc := 0
		CtrLook := (Kp > 0) ? (Kd / Kp) : 0.12
		if (CtrLook < 0.02)
			CtrLook := 0.02
		CtrMax := SteadyTarget ? 0.25 : 1.50
		if (CtrLook > CtrMax)
			CtrLook := CtrMax
		WantDown := ((PosError + (RelVel * CtrLook)) > 0) ? false : true
		}
	}
else
	{
	if (SpecialRod = "Noiseform")
		ControlOut := Kp*PosError + Kd*RelVel*0.60
	else if (SteadyTarget)
		{
		OutLook := (Kp > 0) ? (Kd / Kp) : 0.12
		if (OutLook < 0.02)
			OutLook := 0.02
		if (OutLook > 0.25)
			OutLook := 0.25
		ControlOut := Kp * (PosError + (RelVel * OutLook))
		}
	else
		ControlOut := Kp*PosError + Kd*RelVel
	WantDown := (ControlOut > 0) ? false : true
	}

PrecisionApply:
if (SpecialRod = "Noiseform" and WantDown and !PrecisionDown and NoiseFoundStreak < NoiseN6)
	WantDown := false
if (SpecialRod = "Noiseform" and NoiseStuckN >= NoiseN6)
	WantDown := false
if (SpecialRod = "Noiseform" and WantDown and !PrecisionDown and NoiseStaleN >= NoiseN6
	and !(NoiseZoneTgt >= 0 and NoiseZOK))
	{
	NoiseStaleBlk := NoiseStaleBlk + 1
	if (NoiseStaleBlk < NoiseN15)
		WantDown := false
	else
		NoiseStaleBlk := 0
	}
else
	NoiseStaleBlk := 0
if (SpecialRod = "Dreambreaker")
	WantDown := !WantDown
if (WantDown)
	gosub, PrecisionHold
else
	gosub, PrecisionRelease
goto BarMinigame2

PrecisionHold:
if (!PrecisionDown)
	{
	if (SpecialRod = "Requiem" and ReelMinRelease > 0 and PrecisionUpAt)
		{
		DllCall("QueryPerformanceCounter", "Int64*", ReelNow)
		if (((ReelNow - PrecisionUpAt) * 1000.0 / QpcFreq) < ReelMinRelease)
			return
		}
	send {lbutton down}
	PrecisionDown := true
	DllCall("QueryPerformanceCounter", "Int64*", PrecisionDownAt)
	}
return

PrecisionRelease:
if (PrecisionDown)
	{
	if (SpecialRod = "Requiem" and ReelMinHold > 0 and PrecisionDownAt)
		{
		DllCall("QueryPerformanceCounter", "Int64*", ReelNow)
		if (((ReelNow - PrecisionDownAt) * 1000.0 / QpcFreq) < ReelMinHold)
			return
		}
	send {lbutton up}
	PrecisionDown := false
	DllCall("QueryPerformanceCounter", "Int64*", PrecisionUpAt)
	}
return

StabilizeBurst:
if (SpecialRod = "Requiem")
	return
gosub, CaptureFishBar
if (!BarPresent() and !FishLineVisible() and FindArrowX() < 0)
	return
loop, %StabilizerLoop%
	{
	send {lbutton down}
	send {lbutton up}
	}
return

;====================================================================================================;

BarMinigameOver:
NoFishAt := 0
BarLiveL := -1
BarLiveR := -1
BarLiveMiss := 0
BarWLive := -1
BarLiveOnlyAt := 0
NoFishAt := 0
send {lbutton up}
send {rbutton up}
PrecisionDown := false
MgInPlay := false
WhCatches := WhCatches + 1
KbCatches := KbCatches + 1
WhLastCatchTick := A_TickCount
WhStalled := false
if (WebhookOnCatch)
	WhEvent("catch")
settimer, BarCalculationFailsafe, off
send {lbutton up}
send {rbutton up}

tooltip, , , , 10
tooltip, , , , 11
tooltip, , , , 12
tooltip, , , , 13
tooltip, , , , 15
gosub, HideHud
sleep %RestartDelay%
goto RestartMacro

;====================================================================================================;

KeeperRun:

KbBusy := true
SetBatchLines, -1
KbLastResult := ""
KbStatus := "opening"
KbRecharged := 0
MouseGetPos, KbSaveX, KbSaveY
send {lbutton up}
send {rbutton up}
tooltip, Current Task: Keeperbound Recharge, %TooltipX%, %Tooltip7%, 7

if (KeeperRelicKey = "")
	{
	KbLastResult := "no relic key set"
	goto KeeperBail
	}
if (RobloxHwnd)
	{
	WinActivate, ahk_id %RobloxHwnd%
	WinWaitActive, ahk_id %RobloxHwnd%, , 3
	sleep 300
	}

gosub, KeeperClearDialog

KbWant := Round(KeeperRecharges)
if (KbWant < 1)
	KbWant := 1
if (KbWant > 20)
	KbWant := 20

KbManual := (KbSpot("enchant", KbEx, KbEy) and KbSpot("confirm", KbCx, KbCy))
KbStatus := "recharging"

if (KbManual)
	{
	tooltip, Action: Open Inventory, %TooltipX%, %Tooltip8%, 8
	KbKey(KeeperInvKey)
	sleep %KeeperOpenDelay%

	tooltip, Action: Equip Relic, %TooltipX%, %Tooltip8%, 8
	KbKey(KeeperRelicKey)
	sleep %KeeperStepDelay%

	KbI := 0
	while (KbI < KbWant and MacroRunning)
		{
		KbI++
		tooltip, Action: Enchant Rod, %TooltipX%, %Tooltip8%, 8
		KbTapSaved(KbEx, KbEy)
		sleep %KeeperStepDelay%
		tooltip, Action: Confirm, %TooltipX%, %Tooltip8%, 8
		KbTapSaved(KbCx, KbCy)
		sleep %KeeperStepDelay%
		KbRecharged++
		if (KbI < KbWant)
			sleep %KeeperBetweenDelay%
		}
	KbLastResult := "pressed " . KbRecharged . " of " . KbWant
	goto KeeperBail
	}

; ---- no saved positions: find the buttons instead ------------------------------------------
tooltip, Action: Open Inventory, %TooltipX%, %Tooltip8%, 8
if (!KbWaitFor("enchant", KbEx, KbEy, 700))
	{
	KbKey(KeeperInvKey)
	if (!KbWaitFor("enchant", KbEx, KbEy, KeeperOpenDelay + 3000))
		{
		KbKey(KeeperInvKey)
		if (!KbWaitFor("enchant", KbEx, KbEy, KeeperOpenDelay + 3000))
			{
			KbLastResult := "could not open the inventory"
			goto KeeperBail
			}
		}
	}

tooltip, Action: Equip Relic, %TooltipX%, %Tooltip8%, 8
KbKey(KeeperRelicKey)
sleep %KeeperStepDelay%

KbGuard := 0
Loop
	{
	KbGuard++
	if (KbGuard > 24 or !MacroRunning or KbRecharged >= KbWant)
		break
	tooltip, Action: Enchant Rod, %TooltipX%, %Tooltip8%, 8
	KbTap(KbEx, KbEy)
	if (!KbWaitFor("confirm", KbCx, KbCy, 3500))
		{
		KbLastResult := "Enchant Rod did nothing - try setting the button positions"
		break
		}
	sleep 300
	tooltip, Action: Confirm, %TooltipX%, %Tooltip8%, 8
	KbTap(KbCx, KbCy)
	sleep %KeeperStepDelay%
	if (!KbGone("confirm", 3000))
		gosub, KeeperClearDialog
	KbRecharged++
	KbLastResult := ""
	if (KbRecharged < KbWant)
		sleep %KeeperBetweenDelay%
	}
if (KbLastResult != "")
	KbLastResult := "recharged " . KbRecharged . " of " . KbWant . " - " . KbLastResult
else
	KbLastResult := "recharged " . KbRecharged . " of " . KbWant

KeeperBail:
gosub, KeeperClearDialog
tooltip, Action: Close Inventory, %TooltipX%, %Tooltip8%, 8
KbGuard := 0
while (KbGuard < 4)
	{
	KbGuard++
	if (KbGone("enchant", 1200))
		break
	KbKey(KeeperInvKey)
	sleep %KeeperOpenDelay%
	}
if (!KbGone("enchant", 1200))
	KbLastResult .= " (inventory still open)"

tooltip, Action: Select Rod, %TooltipX%, %Tooltip8%, 8
sleep 300
ForceReEquip := true
MouseMove, KbSaveX, KbSaveY
tooltip, , , , 8
KbStatus := (KbRecharged > 0) ? "done" : "failed"
WhEvent("keeper", ((KbStatus = "done") ? "Done: " : "Failed: ") . KbLastResult)
KbCatches := 0
KbBusy := false
SetBatchLines, 10ms
return

;====================================================================================================;

KeeperClearDialog:
KbClr := 0
while (KbClr < 4 and KbFind("confirm", KbCx, KbCy))
	{
	KbClr++
	if (KbFind("confirm", KbRx, KbRy, "red"))
		KbTap(KbRx, KbRy)
	else
		break
	sleep 900
	}
return

;====================================================================================================;

AquariumRun:

AqBusy := true
SetBatchLines, -1
AqBuys := 0
AqUses := 0
AqUseOnly := false
AqHoverOk := false
AqLastResult := ""
AqStatus := "opening"
MouseGetPos, AqSaveX, AqSaveY
send {lbutton up}
send {rbutton up}
tooltip, Current Task: Auto Aquarium, %TooltipX%, %Tooltip7%, 7
tooltip, Action: Open Aquariums, %TooltipX%, %Tooltip8%, 8

if (RobloxHwnd)
	{
	WinActivate, ahk_id %RobloxHwnd%
	WinWaitActive, ahk_id %RobloxHwnd%, , 3
	sleep 350
	}

if (!AqPanelSure())
	{
	AqTap(AqNavX, AqNavY)
	AqWaitPanel(1)
	}
if (!AqPanelSure())
	AqRecoverRow()
if (!AqPanelSure())
	{
	AqLastResult := "could not find the fish food panel"
	AqStatus := "failed"
	WhEvent("aquarium", "Failed: " . AqLastResult)
	MouseMove, AqSaveX, AqSaveY
	tooltip, , , , 8
	AqNextTick := A_TickCount + (Round(AquariumEveryMin) * 60000)
	AqBusy := false
	SetBatchLines, 10ms
	return
	}

AqStatus := "feeding"
AqCap := Round(AquariumFoodCount)
if (AqCap < 10)
	AqCap := 10

tooltip, Action: Scroll To Start, %TooltipX%, %Tooltip8%, 8
AqMeasurePitch()

AqUseOnly := false
gosub, AquariumSweep

if (AqBuys > 0 and MacroRunning)
	{
	tooltip, Action: Use New Fish Food, %TooltipX%, %Tooltip8%, 8
	AqUseOnly := true
	gosub, AquariumSweep
	}

tooltip, Action: Back To Start, %TooltipX%, %Tooltip8%, 8
AqScrollHome()

AqLastResult := "bought " . AqBuys . ", used " . AqUses
AqStatus := "done"

AquariumClose:
tooltip, Action: Close Aquariums, %TooltipX%, %Tooltip8%, 8
if (AqPanelSure())
	{
	AqTap(AqNavX, AqNavY)
	AqWaitPanel(0)
	}
MouseMove, AqSaveX, AqSaveY
tooltip, , , , 8
AqNextTick := A_TickCount + (Round(AquariumEveryMin) * 60000)
if (AqStatus = "done")
	WhEvent("aquarium", "Done: " . AqLastResult)
else
	WhEvent("aquarium", "Stopped: " . ((AqLastResult != "") ? AqLastResult : AqStatus))
AqBusy := false
SetBatchLines, 10ms
return

;====================================================================================================;

;====================================================================================================;

AquariumSweep:
AqDone := 0
AqHitShop := false
AqScrollHome()

AqShiftAcc := 0
AqSeenMax := -999999
AqHalf := AqCardPitch // 2
if (AqHalf < 20)
	AqHalf := 20
AqStep := 1
AqStall := 0
AqGuard := 0
AqScan()
Loop
	{
	AqGuard++
	if (AqGuard > 60 or !MacroRunning or AqDone >= AqCap)
		break
	gosub, AquariumHandleNew
	if (AqHitShop)
		break
	AqPrevLeft := AqLeftX()
	AqOldX := []
	AqOldN := AqBtnN
	AqI := 1
	while (AqI <= AqOldN)
		{
		AqOldX.Push(AqBtnCX[AqI])
		AqI++
		}
	tooltip, Action: Next Fish Food, %TooltipX%, %Tooltip8%, 8
	if (!AqWheel(AqStep, 1))
		break
	if (AqScan() < 1)
		{
		AqBack := 0
		while (AqBack < AqStep + 3)
			{
			AqBack++
			if (!AqWheel(1, -1))
				break
			if (AqScan() >= 1)
				break
			}
		if (AqBtnN >= 1)
			{
			AqShiftAcc := AqShiftAcc + AqShiftBetween(AqOldX, AqOldN, AqBtnCX, AqBtnN, AqCardPitch)
			gosub, AquariumHandleNew
			}
		break
		}
	if (AqLeftX() = AqPrevLeft)
		{
		AqStall++
		if (AqStall >= 5)
			break
		}
	else
		AqStall := 0
	AqMoved := AqShiftBetween(AqOldX, AqOldN, AqBtnCX, AqBtnN, AqCardPitch)
	AqShiftAcc := AqShiftAcc + AqMoved
	}
return

;====================================================================================================;

AquariumHandleNew:
AqLstN := AqBtnN
AqLstX := []
AqLstY := []
AqLstK := []
AqI := 1
while (AqI <= AqLstN)
	{
	AqLstX.Push(AqBtnCX[AqI])
	AqLstY.Push(AqBtnCY[AqI])
	AqLstK.Push(AqBtnKind[AqI])
	AqI++
	}

AqI := 1
while (AqI <= AqLstN)
	{
	if (!MacroRunning or AqDone >= AqCap)
		break
	AqCx := AqLstX[AqI]
	AqCy := AqLstY[AqI]
	AqKind := AqLstK[AqI]
	AqContentX := AqCx + AqShiftAcc
	if (AqContentX <= AqSeenMax + AqHalf)
		{
		AqI++
		continue
		}
	AqSeenMax := AqContentX
	if (AqKind = "buy" and AqUseOnly)
		{
		AqHitShop := true
		break
		}
	if (AqKind = "buy" and AqBuys >= AquariumMaxBuys)
		{
		AqI++
		continue
		}
	AqDone++
	if (AqKind = "buy")
		{
		tooltip, Action: Buy Fish Food, %TooltipX%, %Tooltip8%, 8
		AqBuys++
		}
	else
		{
		tooltip, Action: Use Fish Food, %TooltipX%, %Tooltip8%, 8
		AqUses++
		}
	AqTap(AqCx, AqCy)
	sleep %AquariumStepDelay%
	AqScan()
	AqI++
	}
AqScan()
return

;====================================================================================================;

StopSweep:
StopSweepTicks++
Loop, 10
	tooltip, , , , % A_Index + 6
gosub, HideHud
if (StopSweepTicks >= 60)
	{
	settimer, StopSweep, off
	gosub, RefreshHints
	}
return

;====================================================================================================;

Idle:

send {lbutton up}
send {rbutton up}
PrecisionDown := false
AqBusy := false
KbBusy := false
MacroPreview := false
MgInPlay := false
settimer, WhTick, off
if (WhStartTick)
	WhEvent("stop")
WhStartTick := 0
settimer, runtime, off
settimer, ClickShakeFailsafe, off
settimer, NavigationShakeFailsafe, off
settimer, BarCalculationFailsafe, off

GuiControl, 1:, StartStopDisplay, ▶ Start
gosub, RefreshRunChip

send {lbutton up}
send {rbutton up}
send {shift up}

tooltip, , , , 6
tooltip, , , , 7
tooltip, , , , 8
tooltip, , , , 9
tooltip, , , , 10
tooltip, , , , 11
tooltip, , , , 12
tooltip, , , , 13
tooltip, , , , 14
tooltip, , , , 15
tooltip, , , , 16
gosub, HideHud
gosub, RefreshHints

return

;====================================================================================================;

RefreshHints:
if (DetTesting)
	return
if (MacroRunning)
	{
	tooltip, Press "%StartStopKey%" to Stop, %TooltipX%, %Tooltip4%, 4
	tooltip, Press "%ReloadKey%" to Reload, %TooltipX%, %Tooltip5%, 5
	tooltip, , , , 6
	}
else
	{
	tooltip, Press "%StartStopKey%" to Start, %TooltipX%, %Tooltip4%, 4
	tooltip, Press "%ReloadKey%" to Reload, %TooltipX%, %Tooltip5%, 5
	tooltip, Press "%ExitKey%" to Exit, %TooltipX%, %Tooltip6%, 6
	}
return

;====================================================================================================;

EnsureConfigFiles:

if !InStr(FileExist(ProfilesDir), "D")
	FileCreateDir, %ProfilesDir%

if !FileExist(DefaultProfileFile)
	gosub, BuildDefaultProfile

if !FileExist(SettingsFile)
	{
	IniWrite, Default, %SettingsFile%, Profiles, ActiveProfile
	IniWrite, p, %SettingsFile%, Hotkeys, StartStop
	IniWrite, o, %SettingsFile%, Hotkeys, Reload
	IniWrite, m, %SettingsFile%, Hotkeys, Exit
	IniWrite, 0, %SettingsFile%, GUI, AlwaysOnTop
	IniWrite, 0, %SettingsFile%, GUI, KeepOpen
	IniWrite, 0, %SettingsFile%, GUI, AutoSave
	IniWrite, 0, %SettingsFile%, Meta, FirstRunDone
	}

return

;====================================================================================================;

DFCheckForUpdate:
DFLatest := ""
try
	{
	whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	whr.SetTimeouts(2000, 2000, 1500, 1500)
	whr.Open("GET", "https://raw.githubusercontent.com/yatonomacro/DeepFish/main/version.txt", false)
	whr.Send()
	if (whr.Status = 200)
		DFLatest := Trim(whr.ResponseText)
	}
catch e
	return
if (DFLatest = "" or DFLatest = DFBetaVersion)
	return
if (!DFVersionNewer(DFLatest, DFBetaVersion))
	return
MsgBox, 0x24, DeepFish Update Available, % "A new version of DeepFish is available.`n`nYou have: " . DFBetaVersion . "`nLatest: " . DFLatest . "`n`nOpen the download page now?"
IfMsgBox, Yes
	Run, https://github.com/yatonomacro/DeepFish
return

DFVersionNewer(a, b) {
	StringSplit, aP, a, .
	StringSplit, bP, b, .
	Loop, 4
		{
		av := aP%A_Index%
		bv := bP%A_Index%
		if (av = "")
			av := 0
		if (bv = "")
			bv := 0
		if (av + 0 > bv + 0)
			return true
		if (av + 0 < bv + 0)
			return false
		}
	return false
}

FirstRunGate:

IniRead, FirstRunDone, %SettingsFile%, Meta, FirstRunDone, 0
if (FirstRunDone = 1)
	return

GateMsg := "IMPORTANT DISCLAIMER`n`n"
GateMsg .= "This will Auto-Subscribe you to the channel.`n`n"
GateMsg .= "OK  =  I understand, continue`n"
GateMsg .= "Cancel  =  Exit"

MsgBox, 0x2021, DeepFish BETA — First Time Setup, %GateMsg%
IfMsgBox, Cancel
	ExitApp

Run, https://www.youtube.com/@yatoark?sub_confirmation=1

Sleep, 3000

WinGetPos,,, W, H, A

CenterX := W // 2
CenterY := H // 2

Click, %CenterX%, %CenterY%

Sleep, 100
Send, {Tab}
Sleep, 100
Send, {Tab}
Sleep, 300
Send, {Enter}
Sleep, 500
Send, {Enter}

IniWrite, 1, %SettingsFile%, Meta, FirstRunDone
FirstRunDone := 1
return

;====================================================================================================;

LoadSettingsFile:

IniRead, ActiveProfile, %SettingsFile%, Profiles, ActiveProfile, Default
IniRead, TotemGlobal, %SettingsFile%, Totem, Global, 0
IniRead, StartStopKey, %SettingsFile%, Hotkeys, StartStop, p
IniRead, ReloadKey, %SettingsFile%, Hotkeys, Reload, o
IniRead, ExitKey, %SettingsFile%, Hotkeys, Exit, m
IniRead, GuiAlwaysOnTop, %SettingsFile%, GUI, AlwaysOnTop, 0
if (GuiAlwaysOnTop != 1)
	GuiAlwaysOnTop := 0
IniRead, GuiKeepOpen, %SettingsFile%, GUI, KeepOpen, 0
if (GuiKeepOpen != 1)
	GuiKeepOpen := 0
IniRead, GuiAutoSave, %SettingsFile%, GUI, AutoSave, 0
if (GuiAutoSave != 1)
	GuiAutoSave := 0
IniRead, WebhookURL, %SettingsFile%, Webhook, URL, %A_Space%
if (WebhookURL = "ERROR")
	WebhookURL := ""
IniRead, WebhookOn, %SettingsFile%, Webhook, Enabled, 0
IniRead, WebhookShot, %SettingsFile%, Webhook, Screenshot, 0
IniRead, WebhookSummaryMin, %SettingsFile%, Webhook, SummaryMinutes, 10
IniRead, WebhookStallMin, %SettingsFile%, Webhook, StallMinutes, 10
IniRead, WebhookOnCatch, %SettingsFile%, Webhook, OnCatch, 0
IniRead, WebhookOnAlert, %SettingsFile%, Webhook, OnAlert, 0
if (WebhookOn != 1)
	WebhookOn := 0
if (WebhookShot != 1)
	WebhookShot := 0
if (WebhookOnCatch != 1)
	WebhookOnCatch := 0
if (WebhookOnAlert != 1)
	WebhookOnAlert := 0
if (WebhookSummaryMin < 1)
	WebhookSummaryMin := 10
if (WebhookStallMin < 1)
	WebhookStallMin := 10

ActiveProfileFile := ProfilesDir . "\" . ActiveProfile . ".ini"
if !FileExist(ActiveProfileFile)
	{
	ActiveProfile := "Default"
	ActiveProfileFile := DefaultProfileFile
	IniWrite, Default, %SettingsFile%, Profiles, ActiveProfile
	}

return

;====================================================================================================;

LoadActiveProfile:

ConfigWarnings := ""

for i, f in ProfileFields
	{
	sec := f[1]
	key := f[2]
	def := f[3]
	type := f[4]
	SrcFile := (sec = "Aquarium" or sec = "Keeper" or (TotemGlobal and sec = "Totem")) ? SettingsFile : ActiveProfileFile
	IniRead, val, %SrcFile%, %sec%, %key%, %def%
	if (val = "ERROR" and def = "")
		val := ""
	if (val = "" and def != "")
		val := def
	if (!ProfFieldOk(type, val))
		{
		ConfigWarnings .= key . "`n"
		val := def
		}
	if (type = "bool")
		val := (val = "true") ? true : false
	%key% := val
	}

if (ConfigWarnings != "")
	msgbox, 4144, DeepFish - Config Notice, One or more settings in "%ActiveProfile%.ini" were invalid and have been reset to defaults:`n`n%ConfigWarnings%

if (SpecialRod = "None")
	{
	NoRodQuiet := true
	gosub, ApplyNoRodPreset
	NoRodQuiet := false
	}

return

;====================================================================================================;

ProfFieldOk(type, ByRef val) {
	if (type = "bool")
		return (val = "true" or val = "false")
	if (type = "shakemode")
		return (val = "Click" or val = "Navigation" or val = "Disabled")
	if (type = "specialrod")
		{
		if (val = "Pinion Aria")
			val := "Pinions Aria"
		return (val = "None" or val = "Pinions Aria" or val = "Requiem" or val = "Darkheart" or val = "Bellona's Waraxe" or val = "Dreambreaker" or val = "Tranquility" or val = "Noiseform" or val = "Verdant Oath" or val = "Lullaby" or val = "Castbound" or val = "Remembrance" or val = "MiguRod" or val = "Halibut Harpoon")
		}
	if (type = "remembrancemode")
		return (val = "Living" or val = "Departed")
	if (type = "controlmode")
		{
		if (val = "Classic")
			val := "Manual"
		return (val = "Manual" or val = "Precision" or val = "Lines")
		}
	if (type = "castmode")
		return (val = "Normal" or val = "Perfect")
	if (type = "num")
		{
		if val is number
			return true
		return false
		}
	return true
}

MgShareFields() {
	global ProfileFields
	static Cached := ""
	if (IsObject(Cached))
		return Cached
	Cached := []
	for i, f in ProfileFields
		{
		if (f[1] = "Minigame" or f[1] = "Tuning" or f[2] = "FishBarColorTolerance")
			Cached.Push(f)
		}
	return Cached
}

MgShareHash(txt) {
	h := 2166136261
	Loop, Parse, txt
		{
		h := h ^ Asc(A_LoopField)
		h := (h * 16777619) & 0xFFFFFFFF
		}
	return Format("{:04X}", (h ^ (h >> 16)) & 0xFFFF)
}

MgShareSig() {
	sig := ""
	for i, f in MgShareFields()
		sig .= f[2] . ","
	return MgShareHash(sig)
}

BuildDefaultProfile:

for i, f in ProfileFields
	{
	sec := f[1]
	key := f[2]
	val := f[3]
	IniWrite, %val%, %DefaultProfileFile%, %sec%, %key%
	}

return


BuildCastHud:
CastHudIds := []
for idx, spec in [["CkA","F04747"], ["CkB","F04747"], ["CkC","FFD400"], ["CkD","FFD400"], ["CkE","22D3EE"], ["CkF","22D3EE"]]
	{
	nm := spec[1]
	cl := spec[2]
	Gui, %nm%:New, -Caption +AlwaysOnTop +ToolWindow +E0x20 +HwndhMk
	Gui, %nm%:Color, %cl%
	Gui, %nm%:Margin, 0, 0
	Gui, %nm%:Show, NoActivate Hide x0 y0 w22 h7
	CastHudIds.Push(hMk)
	}
CastHudBuilt := true
CH_LastG := -9999
CH_LastT := -9999
CH_LastB := -9999
return

ShowCastHud:
if (!CastHudBuilt)
	gosub, BuildCastHud
CH_LX := WindowLeft + PCGreenL - 28
CH_RX := WindowLeft + PCGreenR + 8
CH_LastG := -9999
CH_LastT := -9999
CH_LastB := -9999
for idx, id in CastHudIds
	DllCall("ShowWindow", "Ptr", id, "Int", 8)
return

HideCastHud:
if (!CastHudBuilt)
	return
for idx, id in CastHudIds
	DllCall("ShowWindow", "Ptr", id, "Int", 0)
return

CastHudMark(gy, wt, wb) {
	global CastHudBuilt, CastHudIds, WindowTop, CH_LX, CH_RX, CH_LastG, CH_LastT, CH_LastB
	if (!CastHudBuilt)
		return
	if (gy != CH_LastG)
		{
		CH_LastG := gy
		ay := WindowTop + gy - 3
		DllCall("SetWindowPos", "Ptr", CastHudIds[1], "Ptr", -1, "Int", CH_LX, "Int", ay, "Int", 22, "Int", 7, "UInt", 0x0010)
		DllCall("SetWindowPos", "Ptr", CastHudIds[2], "Ptr", -1, "Int", CH_RX, "Int", ay, "Int", 22, "Int", 7, "UInt", 0x0010)
		}
	if (wt != CH_LastT)
		{
		CH_LastT := wt
		ay := WindowTop + wt - 3
		DllCall("SetWindowPos", "Ptr", CastHudIds[3], "Ptr", -1, "Int", CH_LX, "Int", ay, "Int", 22, "Int", 7, "UInt", 0x0010)
		DllCall("SetWindowPos", "Ptr", CastHudIds[4], "Ptr", -1, "Int", CH_RX, "Int", ay, "Int", 22, "Int", 7, "UInt", 0x0010)
		}
	if (wb != CH_LastB)
		{
		CH_LastB := wb
		ay := WindowTop + wb - 3
		DllCall("SetWindowPos", "Ptr", CastHudIds[5], "Ptr", -1, "Int", CH_LX, "Int", ay, "Int", 22, "Int", 7, "UInt", 0x0010)
		DllCall("SetWindowPos", "Ptr", CastHudIds[6], "Ptr", -1, "Int", CH_RX, "Int", ay, "Int", 22, "Int", 7, "UInt", 0x0010)
		}
}


PerfectCastRelease:

PCGreenRGB := ColMain(PerfectGreenColor)
PCWhiteBGR := ToBGR(ColMain(PerfectWhiteColor))
PCSearchTop := Round(WindowHeight * 0.13)
PCSearchBottom := Round(WindowHeight * 0.90)
PCGreenY := -1
PCGreenL := -1
PCGreenR := -1
PCReachedBottom := false
PCLastFill := -1
PCSpeedSum := 0.0
PCSpeedCount := 0
PCReleased := false
PCLostCount := 0
PCValidFrames := 0
PCFrameDt := 0
PCTipT := 0

DllCall("QueryPerformanceCounter", "Int64*", PCStart)
PCLastT := PCStart
PCCapT := PCStart

PerfectCastLoop:
if (!MacroRunning)
	{
	tooltip, , , , 8
	gosub, HideCastHud
	return
	}
DllCall("QueryPerformanceCounter", "Int64*", PCNow)
PCElapsed := (PCNow - PCStart) / QpcFreq
if (PCElapsed > PerfectFailTimeout)
	{
	tooltip, Action: Perfect cast timed out - released, %TooltipX%, %Tooltip8%, 8
	gosub, HideCastHud
	return
	}

if (PCGreenY < 0)
	{
	if (!PerfectAcquireGreen())
		{
		tooltip, Action: Looking for cast bar, %TooltipX%, %Tooltip8%, 8
		goto PerfectCastLoop
		}
	PCLostCount := 0
	gosub, ShowCastHud
	}

PCState := PerfectTrackFrame()
if (PCState = 0)
	{
	PCLostCount++
	if (PCLostCount >= 6)
		{
		PCGreenY := -1
		PCLostCount := 0
		}
	goto PerfectCastLoop
	}
PCLostCount := 0
if (PCState = 1)
	{
	tooltip, Action: Perfect cast - bar empty`, waiting, %TooltipX%, %Tooltip8%, 8
	goto PerfectCastLoop
	}

PCTotal := PCWhiteBottom - PCGreenY
if (PCTotal <= 0)
	goto PerfectCastLoop

PCFill := (1 - ((PCWhiteTop - PCGreenY) / PCTotal)) * 100

PCOffset := 0.0
if (PCLastFill >= 0)
	{
	PCdt := (PCCapT - PCLastT) / QpcFreq
	if (PCdt > 0.0005)
		{
		PCFrameDt := PCdt
		PCChange := PCFill - PCLastFill
		if (PCChange < -50)
			{
			PCSpeedSum := 0.0
			PCSpeedCount := 0
			PCReachedBottom := false
			PCValidFrames := 0
			PCLastFill := -1
			}
		else
			{
			if (PCChange > 0)
				{
				PCSpeedSum += PCChange / PCdt
				PCSpeedCount++
				if (PCSpeedCount > 20)
					{
					PCSpeedSum := PCSpeedSum * 20 / PCSpeedCount
					PCSpeedCount := 20
					}
				}
			if (PCSpeedCount > 0)
				{
				PCAvgSpeed := PCSpeedSum / PCSpeedCount
				PCOffset := 1.5 * Ln(1 + PCAvgSpeed / 25.0)
				if (PerfectReleaseTiming < 0)
					{
					PCBaseMult := 1.0 - (PerfectReleaseTiming / 5.0)
					PCScale := (PCAvgSpeed / 100.0) ** 2
					if (PCScale > 6.0)
						PCScale := 6.0
					PCOffset := PCOffset * (PCBaseMult + (PCBaseMult - 1.0) * PCScale)
					}
				if (PCOffset > 50.0)
					PCOffset := 50.0
				}
			}
		}
	}

PCPredicted := PCFill + PCOffset

if (!PCReachedBottom)
	{
	PCValidFrames++
	if (PCPredicted <= (5.0 + PCOffset) or PCValidFrames >= 3)
		{
		PCReachedBottom := true
		PCLastFill := -1
		PCSpeedSum := 0.0
		PCSpeedCount := 0
		}
	}

if (PerfectReleaseTiming <= 0)
	PCThreshold := 95.5
else
	{
	PCThreshold := 95.5 + (PerfectReleaseTiming / 50.0) * 4.5
	if (PCThreshold > 100)
		PCThreshold := 100
	}

if (PCReachedBottom and PCPredicted >= PCThreshold)
	{
	send {lbutton up}
	PCReleased := true
	gosub, HideCastHud
	return
	}

if (PCReachedBottom and PCSpeedCount >= 3 and PCAvgSpeed > 1 and PCFrameDt > 0)
	{
	PCLead := ((PCThreshold - PCPredicted) / PCAvgSpeed) + 0.010
	DllCall("QueryPerformanceCounter", "Int64*", PCNowR)
	PCLatency := (PCNowR - PCCapT) / QpcFreq
	if (PCLead < PCFrameDt + PCLatency)
		{
		PCWaitMs := (PCLead - PCLatency) * 1000
		if (PCWaitMs > 250)
			PCWaitMs := 250
		if (PCWaitMs > 0)
			PreciseSleep(PCWaitMs)
		send {lbutton up}
		PCReleased := true
		gosub, HideCastHud
		return
		}
	}

CastHudMark(PCGreenY, PCWhiteTop, PCWhiteBottom)
if ((PCCapT - PCTipT) / QpcFreq >= 0.12)
	{
	PCTipT := PCCapT
	PCFillDbg := Round(PCPredicted)
	PCGateDbg := PCReachedBottom ? "armed" : "arming"
	tooltip, Action: Perfect %PCFillDbg%`% / %PCThreshold%`% (%PCGateDbg%), %TooltipX%, %Tooltip8%, 8
	}

PCLastFill := PCFill
PCLastT := PCCapT
goto PerfectCastLoop

;====================================================================================================;

PerfectAcquireGreen() {
	global PCGreenY, PCGreenL, PCGreenR, PerfectGreenColor, PerfectGreenTolerance
	global PerfectWhiteColor, PerfectWhiteTolerance
	global PCSearchTop, PCSearchBottom, WindowLeft, WindowTop, WindowWidth
	global hPCFullDC, hPCFullBM, pPCFullBits, PCFullW, PCFullH, hPCFullOld
	global PCLastGoodY

	w := WindowWidth
	h := PCSearchBottom - PCSearchTop
	if (w < 8 or h < 8)
		return false

	if (PCFullW != w or PCFullH != h or !hPCFullDC)
		{
		if (hPCFullDC)
			{
			DllCall("SelectObject", "Ptr", hPCFullDC, "Ptr", hPCFullOld)
			DllCall("DeleteObject", "Ptr", hPCFullBM)
			DllCall("DeleteDC", "Ptr", hPCFullDC)
			}
		hSD := DllCall("GetDC", "Ptr", 0, "Ptr")
		hPCFullDC := DllCall("CreateCompatibleDC", "Ptr", hSD, "Ptr")
		VarSetCapacity(bi, 40, 0)
		NumPut(40, bi, 0, "UInt")
		NumPut(w, bi, 4, "Int")
		NumPut(-h, bi, 8, "Int")
		NumPut(1, bi, 12, "UShort")
		NumPut(32, bi, 14, "UShort")
		NumPut(0, bi, 16, "UInt")
		hPCFullBM := DllCall("CreateDIBSection", "Ptr", hPCFullDC, "Ptr", &bi, "UInt", 0, "Ptr*", pPCFullBits, "Ptr", 0, "UInt", 0, "Ptr")
		hPCFullOld := DllCall("SelectObject", "Ptr", hPCFullDC, "Ptr", hPCFullBM, "Ptr")
		DllCall("ReleaseDC", "Ptr", 0, "Ptr", hSD)
		PCFullW := w
		PCFullH := h
		}

	hSD2 := DllCall("GetDC", "Ptr", 0, "Ptr")
	DllCall("BitBlt", "Ptr", hPCFullDC, "Int", 0, "Int", 0, "Int", w, "Int", h
		, "Ptr", hSD2, "Int", WindowLeft, "Int", WindowTop + PCSearchTop, "UInt", 0x00CC0020)
	DllCall("ReleaseDC", "Ptr", 0, "Ptr", hSD2)

	bgr := ToBGR(ColMain(PerfectGreenColor))
	tB := (bgr >> 16) & 0xFF
	tG := (bgr >> 8) & 0xFF
	tR := bgr & 0xFF
	tol := PerfectGreenTolerance

	wbgr := ToBGR(ColMain(PerfectWhiteColor))
	wB := (wbgr >> 16) & 0xFF
	wG := (wbgr >> 8) & 0xFF
	wR := wbgr & 0xFF
	wtol := PerfectWhiteTolerance

	gRow := -1
	gl := -1
	gr := -1
	Loop, 2
		{
		narrow := (A_Index = 1 and PCLastGoodY >= 0)
		if (narrow)
			{
			y0 := PCLastGoodY - PCSearchTop - 70
			if (y0 < 0)
				y0 := 0
			y1 := PCLastGoodY - PCSearchTop + 70
			if (y1 > h)
				y1 := h
			}
		else
			{
			y0 := 0
			y1 := h
			}
		y := y0
		while (y < y1 and gRow < 0)
		{
		rowOff := y * w * 4
		lo := -1
		hi := -1
		runStart := -1
		runEnd := -1
		miss := 0
		x := 0
		while (x < w)
			{
			px := NumGet(pPCFullBits + 0, rowOff + (x*4), "UInt")
			b := px & 0xFF
			g := (px >> 8) & 0xFF
			r := (px >> 16) & 0xFF
			if ((g > 80 and g > r + 22 and g > b + 22)
				or (Abs(b - tB) <= tol and Abs(g - tG) <= tol and Abs(r - tR) <= tol))
				{
				if (runStart < 0)
					runStart := x
				runEnd := x
				miss := 0
				}
			else if (runStart >= 0)
				{
				miss++
				if (miss > 1)
					{
					if (runEnd - runStart + 1 > hi - lo + 1)
						{
						lo := runStart
						hi := runEnd
						}
					runStart := -1
					miss := 0
					}
				}
			x += 2
			}
		if (runStart >= 0 and runEnd - runStart + 1 > hi - lo + 1)
			{
			lo := runStart
			hi := runEnd
			}
		if (lo >= 0 and (hi - lo + 1) >= 6 and (hi - lo + 1) < 60)
			{
			gRow := y
			gl := lo
			gr := hi
			}
		else if (lo >= 0)
			{
			skip := y
			while (skip < h)
				{
				rOff := skip * w * 4
				any := false
				x2 := 0
				while (x2 < w)
					{
					p2 := NumGet(pPCFullBits + 0, rOff + (x2*4), "UInt")
					b2 := p2 & 0xFF
					g2 := (p2 >> 8) & 0xFF
					r2 := (p2 >> 16) & 0xFF
					if ((g2 > 80 and g2 > r2 + 22 and g2 > b2 + 22)
						or (Abs(b2 - tB) <= tol and Abs(g2 - tG) <= tol and Abs(r2 - tR) <= tol))
						{
						any := true
						break
						}
					x2 += 2
					}
				if (!any)
					break
				skip++
				}
			y := skip
			continue
			}
		y++
		}
		if (gRow >= 0 or !narrow)
			break
		}
	if (gRow < 0)
		return false

	PCGreenY := PCSearchTop + gRow
	PCGreenL := gl
	PCGreenR := gr
	PCLastGoodY := PCGreenY
	return true
}


PerfectTrackFrame() {
	global PCGreenY, PCGreenL, PCGreenR, PCWhiteTop, PCWhiteBottom, PCSearchBottom, PCCapT
	global PerfectGreenColor, PerfectWhiteColor, PerfectGreenTolerance, PerfectWhiteTolerance
	global WindowLeft, WindowTop, WindowWidth
	global hPCColDC, hPCColBM, pPCColBits, PCColW, PCColH, hPCColOld

	w := 160
	mid := Round((PCGreenL + PCGreenR) / 2)
	sx := mid - 80
	if (sx < 0)
		sx := 0
	if (sx + w > WindowWidth)
		sx := WindowWidth - w
	if (sx < 0)
		return 0

	sy := PCGreenY - 50
	if (sy < 0)
		sy := 0
	h := PCSearchBottom - sy
	if (h < 8)
		return 0

	if (PCColW != w or PCColH != h or !hPCColDC)
		{
		if (hPCColDC)
			{
			DllCall("SelectObject", "Ptr", hPCColDC, "Ptr", hPCColOld)
			DllCall("DeleteObject", "Ptr", hPCColBM)
			DllCall("DeleteDC", "Ptr", hPCColDC)
			}
		hSD := DllCall("GetDC", "Ptr", 0, "Ptr")
		hPCColDC := DllCall("CreateCompatibleDC", "Ptr", hSD, "Ptr")
		VarSetCapacity(bi, 40, 0)
		NumPut(40, bi, 0, "UInt")
		NumPut(w, bi, 4, "Int")
		NumPut(-h, bi, 8, "Int")
		NumPut(1, bi, 12, "UShort")
		NumPut(32, bi, 14, "UShort")
		NumPut(0, bi, 16, "UInt")
		hPCColBM := DllCall("CreateDIBSection", "Ptr", hPCColDC, "Ptr", &bi, "UInt", 0, "Ptr*", pPCColBits, "Ptr", 0, "UInt", 0, "Ptr")
		hPCColOld := DllCall("SelectObject", "Ptr", hPCColDC, "Ptr", hPCColBM, "Ptr")
		DllCall("ReleaseDC", "Ptr", 0, "Ptr", hSD)
		PCColW := w
		PCColH := h
		}

	hSD2 := DllCall("GetDC", "Ptr", 0, "Ptr")
	DllCall("QueryPerformanceCounter", "Int64*", PCCapT)
	DllCall("BitBlt", "Ptr", hPCColDC, "Int", 0, "Int", 0, "Int", w, "Int", h
		, "Ptr", hSD2, "Int", WindowLeft + sx, "Int", WindowTop + sy, "UInt", 0x00CC0020)
	DllCall("ReleaseDC", "Ptr", 0, "Ptr", hSD2)

	gbgr := ToBGR(ColMain(PerfectGreenColor))
	gB := (gbgr >> 16) & 0xFF
	gG := (gbgr >> 8) & 0xFF
	gR := gbgr & 0xFF
	gtol := PerfectGreenTolerance

	gRow := -1
	gl := -1
	gr := -1
	scanTo := (h < 110) ? h : 110
	y := 0
	while (y < scanTo and gRow < 0)
		{
		p := pPCColBits + (y * w * 4)
		lo := -1
		hi := -1
		runStart := -1
		runEnd := -1
		miss := 0
		x := 0
		while (x < w)
			{
			px := NumGet(p + 0, 0, "UInt"), bb := px & 0xFF, gg := (px >> 8) & 0xFF, rr := (px >> 16) & 0xFF, p += 4
			if ((gg > 80 and gg > rr + 22 and gg > bb + 22) or (Abs(bb - gB) <= gtol and Abs(gg - gG) <= gtol and Abs(rr - gR) <= gtol))
				runStart := (runStart < 0) ? x : runStart, runEnd := x, miss := 0
			else if (runStart >= 0 and ++miss > 2)
				{
				if (runEnd - runStart + 1 > hi - lo + 1)
					lo := runStart, hi := runEnd
				runStart := -1, miss := 0
				}
			x++
			}
		if (runStart >= 0 and runEnd - runStart + 1 > hi - lo + 1)
			{
			lo := runStart
			hi := runEnd
			}
		if (lo >= 0)
			{
			gRow := y
			gl := lo
			gr := hi
			}
		y++
		}
	if (gRow < 0)
		return 0

	if ((gr - gl + 1) < 6 or (gr - gl + 1) >= 60)
		return 0

	PCGreenY := sy + gRow
	PCGreenL := sx + gl
	PCGreenR := sx + gr

	wbgr := ToBGR(ColMain(PerfectWhiteColor))
	wB := (wbgr >> 16) & 0xFF
	wG := (wbgr >> 8) & 0xFF
	wR := wbgr & 0xFF
	wtol := PerfectWhiteTolerance

	top := -1
	bot := -1
	y := gRow
	while (y < h and (top < 0 or y - bot <= 16))
		{
		p := pPCColBits + ((y * w + 74) * 4)
		pe := p + 48
		while (p < pe)
			{
			px := NumGet(p + 0, 0, "UInt"), bb := px & 0xFF, gg := (px >> 8) & 0xFF, rr := (px >> 16) & 0xFF, p += 4
			if ((rr > 200 and gg > 200 and bb > 200 and ((rr > gg) ? ((rr > bb) ? rr : bb) : ((gg > bb) ? gg : bb)) - ((rr < gg) ? ((rr < bb) ? rr : bb) : ((gg < bb) ? gg : bb)) < 32) or (Abs(bb - wB) <= wtol and Abs(gg - wG) <= wtol and Abs(rr - wR) <= wtol))
				{
				if (top < 0)
					top := y
				bot := y
				break
				}
			}
		y++
		}

	if (top < 0)
		return 1
	PCWhiteTop := sy + top
	PCWhiteBottom := sy + bot
	return 2
}

;====================================================================================================;


SetupCapture:

if (hCaptureMemDC)
	{
	DllCall("SelectObject", "Ptr", hCaptureMemDC, "Ptr", hCaptureOldBitmap)
	DllCall("DeleteObject", "Ptr", hCaptureBitmap)
	DllCall("DeleteDC", "Ptr", hCaptureMemDC)
	DllCall("ReleaseDC", "Ptr", 0, "Ptr", hCaptureScreenDC)
	}

CaptureW := Round(FishBarRight - FishBarLeft)
if (CaptureW < 1)
	CaptureW := 1
CaptureH := Round(FishBarBottom - FishBarTop) + 1
if (CaptureH < 1)
	CaptureH := 1

hCaptureScreenDC := DllCall("GetDC", "Ptr", 0, "Ptr")
hCaptureMemDC := DllCall("CreateCompatibleDC", "Ptr", hCaptureScreenDC, "Ptr")

VarSetCapacity(CaptureBMI, 40, 0)
NumPut(40, CaptureBMI, 0, "UInt")
NumPut(CaptureW, CaptureBMI, 4, "Int")
NumPut(-CaptureH, CaptureBMI, 8, "Int")
NumPut(1, CaptureBMI, 12, "UShort")
NumPut(32, CaptureBMI, 14, "UShort")
NumPut(0, CaptureBMI, 16, "UInt")

hCaptureBitmap := DllCall("CreateDIBSection", "Ptr", hCaptureScreenDC, "Ptr", &CaptureBMI, "UInt", 0, "Ptr*", pCaptureBits, "Ptr", 0, "UInt", 0, "Ptr")
hCaptureOldBitmap := DllCall("SelectObject", "Ptr", hCaptureMemDC, "Ptr", hCaptureBitmap, "Ptr")
pCaptureOwn := pCaptureBits

if (hNoteMemDC)
	{
	DllCall("SelectObject", "Ptr", hNoteMemDC, "Ptr", hNoteOldBitmap)
	DllCall("DeleteObject", "Ptr", hNoteBitmap)
	DllCall("DeleteDC", "Ptr", hNoteMemDC)
	DllCall("ReleaseDC", "Ptr", 0, "Ptr", hNoteScreenDC)
	}

NoteW := CaptureW
NoteH := Round(NoteRegionHeight)
if (SpecialRod = "Tranquility" and NoteH < Round(WindowHeight * 0.55))
	NoteH := Round(WindowHeight * 0.55)
if (SpecialRod = "Noiseform" and NoteH < Round(WindowHeight * 0.50))
	NoteH := Round(WindowHeight * 0.50)
if (SpecialRod = "Halibut Harpoon")
	NoteH := Round(WindowHeight * 0.075)
if (NoteH < 20)
	NoteH := 20
if (NoteH > 1400)
	NoteH := 1400
NoteTop := Round(FishBarTop) - NoteH
if (NoteTop < 0)
	{
	NoteTop := 0
	NoteH := Round(FishBarTop)
	if (NoteH < 20)
		NoteH := 20
	}
if (SpecialRod = "Noiseform")
	{
	nfTop := Round(WindowHeight * 0.5194) - Round(WindowHeight * 0.118) - 2
	if (nfTop > NoteTop and nfTop < Round(FishBarTop) - 80)
		{
		NoteTop := nfTop
		NoteH := Round(FishBarTop) - NoteTop
		}
	}

NoteIndep := false
NoteNeeded := (SpecialRod = "Pinions Aria" or SpecialRod = "Noiseform"
	or SpecialRod = "Tranquility" or SpecialRod = "Lullaby" or SpecialRod = "Halibut Harpoon")
NoteOriginX := Round(FishBarLeft)
NoteOriginY := NoteTop
if (SpecialRod = "Pinions Aria")
	{
	nrx := Round(ClickShakeLeft)
	nrw := Round(ClickShakeRight - ClickShakeLeft)
	nry := Round(ClickShakeTop)
	nrh := Round(ClickShakeBottom - ClickShakeTop)
	if (nry + nrh > Round(FishBarTop))
		nrh := Round(FishBarTop) - nry
	if (nrw >= 20 and nrh >= 40)
		{
		NoteIndep := true
		NoteOriginX := nrx
		NoteOriginY := nry
		NoteW := nrw
		NoteH := nrh
		}
	}

hNoteScreenDC := DllCall("GetDC", "Ptr", 0, "Ptr")
hNoteMemDC := DllCall("CreateCompatibleDC", "Ptr", hNoteScreenDC, "Ptr")

VarSetCapacity(NoteBMI, 40, 0)
NumPut(40, NoteBMI, 0, "UInt")
NoteFullH := NoteIndep ? NoteH : (NoteH + CaptureH)
NumPut(NoteW, NoteBMI, 4, "Int")
NumPut(-NoteFullH, NoteBMI, 8, "Int")
NumPut(1, NoteBMI, 12, "UShort")
NumPut(32, NoteBMI, 14, "UShort")
NumPut(0, NoteBMI, 16, "UInt")

hNoteBitmap := DllCall("CreateDIBSection", "Ptr", hNoteScreenDC, "Ptr", &NoteBMI, "UInt", 0, "Ptr*", pNoteBits, "Ptr", 0, "UInt", 0, "Ptr")
hNoteOldBitmap := DllCall("SelectObject", "Ptr", hNoteMemDC, "Ptr", hNoteBitmap, "Ptr")

return

;====================================================================================================;

CaptureFishBar:
CaptureStrip()
LineScanned := false
NoiseScanned := false
CastScanned := false
RemScanned := false
RemBarScanned := false
MiguScanned := false
MiguBarScanned := false
HaliBarScanned := false
return

;====================================================================================================;

BuildHud:
gosub, HudDestroySurface
if (HudBuilt)
	Gui, Hud:Destroy
HudW := Round(FishBarRight - FishBarLeft)
if (HudW < 40)
	HudW := 40
HudH := 34
Gui, Hud:New, +AlwaysOnTop -Caption +ToolWindow +E0x80020 +HwndhHudGui
Gui, Hud:Color, 010101
Gui, Hud:Margin, 0, 0
Gui, Hud:Show, NoActivate Hide, DeepFishHud
HudBuilt := true
HudGpOk := HudSurfaceMake(HudW, HudH)
HudFishTgt := -1
HudBarTgt := -1
HudFishCur := -1
HudBarCur := -1
HudNoteX := -1
HudNote2X := -1
HudZoneShown := false
BarWTrust := 0
HudWRing := []
HudWMed := 0
HudDirty := true
HudLastKey := ""
HudPrevT := 0
return

;====================================================================================================;
;====================================================================================================;

HudGdipStart() {
	global HudGdipToken
	if (HudGdipToken)
		return true
	if (!DllCall("GetModuleHandle", "Str", "gdiplus", "Ptr"))
		{
		if (!DllCall("LoadLibrary", "Str", "gdiplus", "Ptr"))
			return false
		}
	VarSetCapacity(gsi, A_PtrSize = 8 ? 24 : 16, 0)
	NumPut(1, gsi, 0, "UInt")
	if (DllCall("gdiplus\GdiplusStartup", "Ptr*", gtk, "Ptr", &gsi, "Ptr", 0, "UInt") != 0)
		return false
	HudGdipToken := gtk
	return true
}

HudSurfaceMake(w, h) {
	global hHudDC, hHudBM, hHudOldBM, pHudBits, pHudGfx, pHudBmp, HudSurfW, HudSurfH
	gosub, HudDestroySurface
	if (!HudGdipStart())
		return false
	hdcS := DllCall("GetDC", "Ptr", 0, "Ptr")
	hHudDC := DllCall("CreateCompatibleDC", "Ptr", hdcS, "Ptr")
	DllCall("ReleaseDC", "Ptr", 0, "Ptr", hdcS)
	if (!hHudDC)
		return false
	VarSetCapacity(hbi, 40, 0)
	NumPut(40, hbi, 0, "UInt")
	NumPut(w, hbi, 4, "Int")
	NumPut(-h, hbi, 8, "Int")
	NumPut(1, hbi, 12, "UShort")
	NumPut(32, hbi, 14, "UShort")
	NumPut(0, hbi, 16, "UInt")
	hHudBM := DllCall("CreateDIBSection", "Ptr", hHudDC, "Ptr", &hbi, "UInt", 0, "Ptr*", pHudBits, "Ptr", 0, "UInt", 0, "Ptr")
	if (!hHudBM)
		return false
	hHudOldBM := DllCall("SelectObject", "Ptr", hHudDC, "Ptr", hHudBM, "Ptr")

	if (DllCall("gdiplus\GdipCreateBitmapFromScan0", "Int", w, "Int", h, "Int", w*4
		, "Int", 0xE200B, "Ptr", pHudBits, "Ptr*", pbm) != 0)
		return false
	pHudBmp := pbm
	if (DllCall("gdiplus\GdipGetImageGraphicsContext", "Ptr", pHudBmp, "Ptr*", pg) != 0)
		return false
	pHudGfx := pg
	DllCall("gdiplus\GdipSetSmoothingMode", "Ptr", pHudGfx, "Int", 4)
	DllCall("gdiplus\GdipSetPixelOffsetMode", "Ptr", pHudGfx, "Int", 2)
	HudSurfW := w
	HudSurfH := h
	return true
}

HudWPush(w) {
	global HudWRing, HudWMed
	if (w <= 0)
		return
	if (!IsObject(HudWRing))
		HudWRing := []
	HudWRing.Push(w)
	if (HudWRing.MaxIndex() > 5)
		HudWRing.RemoveAt(1)
	n := HudWRing.MaxIndex()
	srt := []
	Loop, %n%
		srt.Push(HudWRing[A_Index])
	i := 2
	while (i <= n)
		{
		v := srt[i]
		j := i - 1
		while (j >= 1 and srt[j] > v)
			{
			srt[j+1] := srt[j]
			j--
			}
		srt[j+1] := v
		i++
		}
	HudWMed := srt[(n // 2) + 1]
}

HudBarW() {
	global BarWTrust, WhiteBarSize, RunWidth, HudWMed, HudWRing
	if (HudWMed > 8 and IsObject(HudWRing) and HudWRing.MaxIndex() >= 3)
		return HudWMed
	if (WhiteBarSize > 8)
		return WhiteBarSize
	if (BarWTrust > 8)
		return BarWTrust
	return (RunWidth > 8) ? RunWidth : 8
}

HudRoundRect(x, y, w, h, r, argb) {
	global pHudGfx
	if (w <= 0 or h <= 0)
		return
	if (r*2 > h)
		r := h/2
	if (r*2 > w)
		r := w/2
	if (r < 0.5)
		r := 0.5
	d := r*2
	DllCall("gdiplus\GdipCreatePath", "Int", 0, "Ptr*", pth)
	DllCall("gdiplus\GdipAddPathArc", "Ptr", pth, "Float", x, "Float", y, "Float", d, "Float", d, "Float", 180, "Float", 90)
	DllCall("gdiplus\GdipAddPathArc", "Ptr", pth, "Float", x+w-d, "Float", y, "Float", d, "Float", d, "Float", 270, "Float", 90)
	DllCall("gdiplus\GdipAddPathArc", "Ptr", pth, "Float", x+w-d, "Float", y+h-d, "Float", d, "Float", d, "Float", 0, "Float", 90)
	DllCall("gdiplus\GdipAddPathArc", "Ptr", pth, "Float", x, "Float", y+h-d, "Float", d, "Float", d, "Float", 90, "Float", 90)
	DllCall("gdiplus\GdipClosePathFigure", "Ptr", pth)
	DllCall("gdiplus\GdipCreateSolidFill", "UInt", argb, "Ptr*", br)
	DllCall("gdiplus\GdipFillPath", "Ptr", pHudGfx, "Ptr", br, "Ptr", pth)
	DllCall("gdiplus\GdipDeleteBrush", "Ptr", br)
	DllCall("gdiplus\GdipDeletePath", "Ptr", pth)
}

HudRoundOutline(x, y, w, h, r, argb, thick) {
	global pHudGfx
	if (w <= 0 or h <= 0)
		return
	if (r*2 > h)
		r := h/2
	if (r*2 > w)
		r := w/2
	if (r < 0.5)
		r := 0.5
	d := r*2
	DllCall("gdiplus\GdipCreatePath", "Int", 0, "Ptr*", pth)
	DllCall("gdiplus\GdipAddPathArc", "Ptr", pth, "Float", x, "Float", y, "Float", d, "Float", d, "Float", 180, "Float", 90)
	DllCall("gdiplus\GdipAddPathArc", "Ptr", pth, "Float", x+w-d, "Float", y, "Float", d, "Float", d, "Float", 270, "Float", 90)
	DllCall("gdiplus\GdipAddPathArc", "Ptr", pth, "Float", x+w-d, "Float", y+h-d, "Float", d, "Float", d, "Float", 0, "Float", 90)
	DllCall("gdiplus\GdipAddPathArc", "Ptr", pth, "Float", x, "Float", y+h-d, "Float", d, "Float", d, "Float", 90, "Float", 90)
	DllCall("gdiplus\GdipClosePathFigure", "Ptr", pth)
	DllCall("gdiplus\GdipCreatePen1", "UInt", argb, "Float", thick, "Int", 2, "Ptr*", pen)
	DllCall("gdiplus\GdipDrawPath", "Ptr", pHudGfx, "Ptr", pen, "Ptr", pth)
	DllCall("gdiplus\GdipDeletePen", "Ptr", pen)
	DllCall("gdiplus\GdipDeletePath", "Ptr", pth)
}

HudEllipse(cx, cy, rx, ry, argb) {
	global pHudGfx
	DllCall("gdiplus\GdipCreateSolidFill", "UInt", argb, "Ptr*", br)
	DllCall("gdiplus\GdipFillEllipse", "Ptr", pHudGfx, "Ptr", br, "Float", cx-rx, "Float", cy-ry, "Float", rx*2, "Float", ry*2)
	DllCall("gdiplus\GdipDeleteBrush", "Ptr", br)
}

HudRender() {
	global pHudGfx, pHudBmp, hHudDC, hHudGui, HudSurfW, HudSurfH, HudGpOk, HudBuilt
	global HudFishCur, HudBarCur, HudNoteX, HudNote2X, HudZoneShown
	global FishBarLeft, FishBarRight, MaxLeftBar, MaxRightBar, RunWidth, WhiteBarSize
	bx := -1
	bw := -1
	if (!HudBuilt or !HudGpOk or !pHudGfx)
		return
	W := HudSurfW
	H := HudSurfH

	DllCall("gdiplus\GdipSetCompositingMode", "Ptr", pHudGfx, "Int", 1)
	DllCall("gdiplus\GdipGraphicsClear", "Ptr", pHudGfx, "UInt", 0x00000000)
	DllCall("gdiplus\GdipSetCompositingMode", "Ptr", pHudGfx, "Int", 0)

	trY := 9
	trH := 16
	trR := trH / 2

	; --- track ---------------------------------------------------------------------------------
	HudRoundRect(0, trY, W, trH, trR, 0xDC0A0D13)
	HudRoundOutline(0.75, trY + 0.75, W - 1.5, trH - 1.5, trR, 0x8C3A465A, 1.5)

	; --- edge zones the macro will not chase into ----------------------------------------------
	if (HudZoneShown)
		{
		zl := Round(MaxLeftBar - FishBarLeft)
		zr := Round(MaxRightBar - FishBarLeft)
		if (zl > 2)
			{
			HudRoundRect(0, trY, zl, trH, trR, 0x4DF59E0B)
			HudRoundRect(zl - 1.25, trY - 2, 2.5, trH + 4, 1.25, 0xE6FBB63C)
			}
		if (zr < W - 2)
			{
			HudRoundRect(zr, trY, W - zr, trH, trR, 0x4DF59E0B)
			HudRoundRect(zr - 1.25, trY - 2, 2.5, trH + 4, 1.25, 0xE6FBB63C)
			}
		}

	; --- the reeling bar, at its true width -----------------------------------------------------
	if (HudBarCur >= 0)
		{
		bw := HudBarW()
		if (bw > W)
			bw := W
		bx := Round(HudBarCur - FishBarLeft - (bw / 2))
		if (bx < 0)
			bx := 0
		if (bx + bw > W)
			bx := W - bw
		HudRoundRect(bx, trY - 3, bw, trH + 6, (trH + 6) / 2, 0x4C5EA6FF)
		HudRoundOutline(bx + 1, trY - 2, bw - 2, trH + 4, (trH + 4) / 2, 0xE64EA1F7, 1.6)
		HudRoundRect(bx + (bw / 2) - 0.5, trY + 1, 1, trH - 2, 0.5, 0x805EA6FF)
		}

	; --- notes ----------------------------------------------------------------------------------
	if (HudNote2X >= 0)
		{
		nx := Round(HudNote2X - FishBarLeft)
		HudRoundRect(nx - 1.5, trY + 1, 3, trH - 2, 1.5, 0xCC8C1856)
		}
	if (HudNoteX >= 0)
		{
		nx := Round(HudNoteX - FishBarLeft)
		HudRoundRect(nx - 2, trY - 1, 4, trH + 2, 2, 0xF2FF2D9B)
		}

	; --- the fish --------------------------------------------------------------------------------
	if (HudFishCur >= 0)
		{
		fx := HudFishCur - FishBarLeft
		cy := trY + (trH / 2)
		HudEllipse(fx, cy, 11, 11, 0x2622C55E)
		HudEllipse(fx, cy, 6.5, 6.5, 0x4D22C55E)
		HudRoundRect(fx - 1.5, trY - 5, 3, trH + 10, 1.5, 0xE622C55E)
		HudEllipse(fx, cy, 3.6, 3.6, 0xFF34D96F)
		HudEllipse(fx - 1, cy - 1.2, 1.2, 1.2, 0xB3FFFFFF)
		}

	; --- push to screen ---------------------------------------------------------------------------
	DllCall("gdiplus\GdipFlush", "Ptr", pHudGfx, "Int", 0)
	VarSetCapacity(hsz, 8, 0)
	NumPut(W, hsz, 0, "Int")
	NumPut(H, hsz, 4, "Int")
	VarSetCapacity(hpt, 8, 0)
	VarSetCapacity(hbf, 4, 0)
	NumPut(0, hbf, 0, "UChar")
	NumPut(0, hbf, 1, "UChar")
	NumPut(255, hbf, 2, "UChar")
	NumPut(1, hbf, 3, "UChar")
	DllCall("UpdateLayeredWindow", "Ptr", hHudGui, "Ptr", 0, "Ptr", 0, "Ptr", &hsz
		, "Ptr", hHudDC, "Ptr", &hpt, "UInt", 0, "Ptr", &hbf, "UInt", 2)
}

HudDestroySurface:
if (pHudGfx)
	{
	DllCall("gdiplus\GdipDeleteGraphics", "Ptr", pHudGfx)
	pHudGfx := 0
	}
if (pHudBmp)
	{
	DllCall("gdiplus\GdipDisposeImage", "Ptr", pHudBmp)
	pHudBmp := 0
	}
if (hHudDC)
	{
	if (hHudOldBM)
		DllCall("SelectObject", "Ptr", hHudDC, "Ptr", hHudOldBM)
	DllCall("DeleteDC", "Ptr", hHudDC)
	hHudDC := 0
	hHudOldBM := 0
	}
if (hHudBM)
	{
	DllCall("DeleteObject", "Ptr", hHudBM)
	hHudBM := 0
	}
pHudBits := 0
return

;====================================================================================================;

ShowHud:
if (!HudBuilt)
	gosub, BuildHud
HudNeedW := Round(FishBarRight - FishBarLeft)
if (HudNeedW < 40)
	HudNeedW := 40
if (HudNeedW != HudSurfW or !HudGpOk)
	{
	HudW := HudNeedW
	HudGpOk := HudSurfaceMake(HudW, HudH)
	}
RobloxClientRect(RobloxHwnd, HudRX, HudRY)
HudX := HudRX + Round(FishBarLeft)
HudY := HudRY + Round(FishBarTooltipHeight) - 11
Gui, Hud:Show, x%HudX% y%HudY% w%HudW% h%HudH% NoActivate
HudDirty := true
HudLastKey := ""
HudPrevT := 0
settimer, HudSmooth, 8
return


HideHud:
settimer, HudSmooth, off
if (HudBuilt)
	Gui, Hud:Cancel
return

;====================================================================================================;

HudSmooth:
if (!HudBuilt or !HudGpOk)
	return
DllCall("QueryPerformanceCounter", "Int64*", HudNowT)
HudDt := HudPrevT ? ((HudNowT - HudPrevT) / QpcFreq) : 0.008
HudPrevT := HudNowT
if (HudDt > 0.1)
	HudDt := 0.1
HudEase := 1 - Exp(-HudDt / 0.030)
if (HudFishTgt >= 0)
	{
	if (HudFishCur < 0)
		HudFishCur := HudFishTgt
	else
		HudFishCur := HudFishCur + ((HudFishTgt - HudFishCur) * HudEase)
	}
if (HudBarTgt >= 0)
	{
	if (HudBarCur < 0)
		HudBarCur := HudBarTgt
	else
		HudBarCur := HudBarCur + ((HudBarTgt - HudBarCur) * HudEase)
	}
HudKey := Round(HudFishCur) . "|" . Round(HudBarCur) . "|" . Round(HudNoteX) . "|" . Round(HudNote2X)
	. "|" . Round(RunWidth) . "|" . (HudZoneShown ? Round(MaxLeftBar) . "," . Round(MaxRightBar) : "-")
if (!HudDirty and HudKey = HudLastKey)
	return
HudLastKey := HudKey
HudDirty := false
HudRender()
return

MoveHudFish(wx) {
	global HudBuilt, HudFishTgt, HudFishCur
	if (!HudBuilt or wx < 0)
		return
	HudFishTgt := wx
	if (HudFishCur < 0 or Abs(wx - HudFishCur) > 150)
		HudFishCur := wx
}

MoveHudNote(wx) {
	global HudBuilt, HudNoteX, HudDirty
	if (!HudBuilt)
		return
	nv := (wx < 0) ? -1 : wx
	if (nv >= 0 and HudNoteX >= 0 and Abs(nv - HudNoteX) < 2)
		return
	HudNoteX := nv
	HudDirty := true
}

MoveHudNote2(wx) {
	global HudBuilt, HudNote2X, HudDirty
	if (!HudBuilt)
		return
	nv := (wx < 0) ? -1 : wx
	if (nv >= 0 and HudNote2X >= 0 and Abs(nv - HudNote2X) < 2)
		return
	HudNote2X := nv
	HudDirty := true
}

MoveHudBarSpan(l, w) {
	global WhiteBarSize, FishX, HudWMed
	if (l < 0 or w <= 0)
		return
	HudWPush(w)
	if (HudWMed > 0 and Abs(w - HudWMed) > (HudWMed * 0.6))
		return
	MoveHudBarC(l + (w / 2))
}

MoveHudBarC(wx) {
	global HudBuilt, HudBarTgt, HudBarCur, FishBarLeft, FishBarRight, RunWidth, WhiteBarSize
	if (!HudBuilt or wx < 0)
		return
	bw := HudBarW()
	lo := FishBarLeft + (bw / 2)
	hi := FishBarRight - (bw / 2)
	if (hi < lo)
		hi := lo
	if (wx < lo)
		wx := lo
	else if (wx > hi)
		wx := hi
	if (HudBarCur >= 0)
		{
		maxStep := (FishBarRight - FishBarLeft) * 0.15
		if (maxStep > 8)
			{
			if (wx > HudBarCur + maxStep)
				wx := HudBarCur + maxStep
			else if (wx < HudBarCur - maxStep)
				wx := HudBarCur - maxStep
			}
		}
	HudBarTgt := wx
	if (HudBarCur < 0)
		HudBarCur := wx
}

UpdateHud:
if (!HudBuilt)
	return
HudDirty := true
return

RobloxClientRect(hwnd, ByRef rcx, ByRef rcy, ByRef rcw := "", ByRef rch := "") {
	VarSetCapacity(rcr, 16, 0)
	VarSetCapacity(rcp, 8, 0)
	if (!hwnd or !DllCall("GetClientRect", "Ptr", hwnd, "Ptr", &rcr) or !DllCall("ClientToScreen", "Ptr", hwnd, "Ptr", &rcp))
		{
		WinGetPos, rcx, rcy, rcw, rch, ahk_id %hwnd%
		return false
		}
	rcx := NumGet(rcp, 0, "Int")
	rcy := NumGet(rcp, 4, "Int")
	rcw := NumGet(rcr, 8, "Int")
	rch := NumGet(rcr, 12, "Int")
	return true
}

CaptureNoteRegion() {
	global hNoteMemDC, hNoteScreenDC, NoteW, NoteFullH, NoteOriginX, NoteOriginY, RobloxHwnd
	if (!hNoteMemDC)
		return
	RobloxClientRect(RobloxHwnd, nwx, nwy)
	DllCall("BitBlt", "Ptr", hNoteMemDC, "Int", 0, "Int", 0, "Int", NoteW, "Int", NoteFullH
		, "Ptr", hNoteScreenDC, "Int", nwx + NoteOriginX, "Int", nwy + NoteOriginY, "UInt", 0x00CC0020)
}

NoteParseColors() {
	global NoteColor, NoteColorCached, NoteColR, NoteColG, NoteColB, NoteColN
	if (NoteColor = NoteColorCached)
		return NoteColN
	NoteColorCached := NoteColor
	NoteColR := []
	NoteColG := []
	NoteColB := []
	NoteColN := 0
	Loop, Parse, NoteColor, `,; , %A_Space%%A_Tab%
		{
		s := A_LoopField
		if (s = "")
			continue
		if (SubStr(s, 1, 2) = "0x")
			s := SubStr(s, 3)
		if (!RegExMatch(s, "^[0-9a-fA-F]{6}$"))
			continue
		v := "0x" . s
		NoteColN := NoteColN + 1
		NoteColR.Push((v >> 16) & 0xFF)
		NoteColG.Push((v >> 8) & 0xFF)
		NoteColB.Push(v & 0xFF)
		}
	return NoteColN
}

NoteScanFind(lockX) {
	global pNoteBits, NoteW, NoteH, NoteColorTolerance
	global NoteColR, NoteColG, NoteColB, NoteColN
	global NoteDbgPx, NoteDbgRun, NoteDbgBest
	NoteDbgPx := 0
	NoteDbgRun := 0
	NoteDbgBest := "-"
	if (!pNoteBits)
		return -1
	if (NoteParseColors() < 1)
		return -1
	tol := NoteColorTolerance
	if (tol < 6)
		tol := 6
	if (tol > 25)
		tol := 25
	yStep := (lockX >= 0) ? 8 : 16
	xFrom := 0
	xTo := NoteW
	if (lockX >= 0)
		{
		xFrom := Round(lockX) - 80
		xTo := Round(lockX) + 80
		if (xFrom < 0)
			xFrom := 0
		if (xTo > NoteW)
			xTo := NoteW
		}
	y := NoteH - 13
	while (y >= 0)
		{
		off := y * NoteW * 4
		runs := []
		runStart := -1
		x := xFrom
		while (x < xTo)
			{
			v := NumGet(pNoteBits + 0, off + (x*4), "UInt")
			b := v & 0xFF
			g := (v >> 8) & 0xFF
			r := (v >> 16) & 0xFF
			ok := false
			ci := 1
			while (ci <= NoteColN)
				{
				if (Abs(r - NoteColR[ci]) <= tol and Abs(g - NoteColG[ci]) <= tol and Abs(b - NoteColB[ci]) <= tol)
					{
					ok := true
					break
					}
				ci++
				}
			if (ok)
				{
				NoteDbgPx := NoteDbgPx + 1
				if (runStart < 0)
					runStart := x
				}
			else if (runStart >= 0)
				{
				if (x - runStart > NoteDbgRun)
					{
					NoteDbgRun := x - runStart
					NoteDbgBest := "x" . runStart . "y" . y
					}
				if (x - runStart >= 8)
					runs.Push(runStart, x - 1)
				runStart := -1
				}
			x += 4
			}
		if (runStart >= 0 and xTo - runStart >= 8)
			runs.Push(runStart, xTo - 1)

		n := runs.Length() // 2
		if (n > 0)
			{
			gi := 1
			while (gi <= n)
				{
				gl := runs[(gi-1)*2 + 1]
				gr := runs[(gi-1)*2 + 2]
				gj := gi + 1
				while (gj <= n)
					{
					nl := runs[(gj-1)*2 + 1]
					if (nl - gr > 45)
						break
					gr := runs[(gj-1)*2 + 2]
					gj++
					}
				w := gr - gl + 1
				if (w >= 8 and w <= 120)
					{
					cx := gl + (w / 2)
					if (lockX < 0 or Abs(cx - lockX) <= 55)
						return cx
					}
				gi := gj
				}
			}
		y -= yStep
		}
	return -1
}

LullRing(rr) {
	global pNoteBits, NoteW, NoteFullH, NoteTop, FishBarTop, CaptureW, LullPivotUp
	out := []
	if (!pNoteBits or rr < 20)
		return out
	bx := Round(CaptureW / 2)
	by := Round((FishBarTop - LullPivotUp) - NoteTop)
	d := 180
	while (d <= 360)
		{
		th := d * 0.01745329252
		x := Round(bx + (rr * Cos(th)))
		y := Round(by + (rr * Sin(th)))
		if (x >= 0 and x < NoteW and y >= 0 and y < NoteFullH)
			{
			px := NumGet(pNoteBits + 0, ((y * NoteW) + x) * 4, "UInt")
			out[d] := ((px & 0xFF) + ((px >> 8) & 0xFF) + ((px >> 16) & 0xFF)) // 3
			}
		else
			out[d] := -1
		d := d + 2
		}
	return out
}

LullCalStep() {
	global CaptureW, LullCalN, LullCalLt, LullCalDk, LullCalLs, LullRadiusPct
	i := 0
	while (i < 14)
		{
		rr := Round(CaptureW * (7 + (i * 1.2)) / 100)
		v := LullRing(rr)
		d := 180
		while (d <= 360)
			{
			if (v[d] != "" and v[d] >= 0)
				{
				ky := (i * 1000) + d
				if (v[d] >= 140)
					{
					LullCalLt[ky] := ((LullCalLt[ky] = "") ? 0 : LullCalLt[ky]) + 1
					LullCalLs[ky] := ((LullCalLs[ky] = "") ? 0 : LullCalLs[ky]) + v[d]
					}
				else if (v[d] < 40)
					LullCalDk[ky] := ((LullCalDk[ky] = "") ? 0 : LullCalDk[ky]) + 1
				}
			d := d + 2
			}
		i := i + 1
		}
	LullCalN := LullCalN + 1
}

LullPickRadius() {
	global CaptureW, LullCalLt, LullCalDk, LullCalLs, LullR, LullBg, LullLightLum
	bestSc := -1
	bestI := -1
	i := 0
	while (i < 14)
		{
		nl := 0
		nd := 0
		nt := 0
		d := 180
		while (d <= 360)
			{
			ky := (i * 1000) + d
			lt := (LullCalLt[ky] = "") ? 0 : LullCalLt[ky]
			dk := (LullCalDk[ky] = "") ? 0 : LullCalDk[ky]
			if (lt > 0 or dk > 0)
				{
				nt := nt + 1
				if (lt > dk)
					nl := nl + 1
				else if (dk > lt)
					nd := nd + 1
				}
			d := d + 2
			}
		if (nt >= 30 and nd > bestSc)
			{
			bestSc := nd
			bestI := i
			}
		i := i + 1
		}
	if (bestI >= 0)
		{
		nl2 := 0
		d := 180
		while (d <= 360)
			{
			ky := (bestI * 1000) + d
			if (LullCalLt[ky] != "" and LullCalLt[ky] > 0)
				nl2 := nl2 + 1
			d := d + 2
			}
		if (nl2 < 2)
			bestI := -1
		}
	if (bestI < 0)
		{
		LullR := Round(CaptureW * LullRadiusPct / 100)
		return 0
		}
	LullR := Round(CaptureW * (7 + (bestI * 1.2)) / 100)
	LullBg := []
	d := 180
	while (d <= 360)
		{
		ky := (bestI * 1000) + d
		lt := (LullCalLt[ky] = "") ? 0 : LullCalLt[ky]
		dk := (LullCalDk[ky] = "") ? 0 : LullCalDk[ky]
		if (lt > dk and lt > 0)
			LullBg[d] := LullCalLs[ky] / lt
		else
			LullBg[d] := 0
		d := d + 2
		}
	return LullR
}

LullFindSectors() {
	global LullBg, LullSecN, LullSecA, LullSecB, LullLightLum, LullMinDeg
	ll := LullLightLum
	if (ll < 30)
		ll := 30
	if (ll > 220)
		ll := 220
	md := LullMinDeg
	if (md < 2)
		md := 2
	if (md > 60)
		md := 60
	LullSecN := 0
	LullSecA := []
	LullSecB := []
	runS := -1
	d := 180
	while (d <= 362)
		{
		lit := false
		if (d <= 360 and LullBg[d] != "")
			lit := (LullBg[d] >= ll)
		if (lit)
			{
			if (runS < 0)
				runS := d
			}
		else if (runS >= 0)
			{
			if (((d - 2) - runS) >= (md - 2))
				{
				LullSecN := LullSecN + 1
				LullSecA[LullSecN] := runS
				LullSecB[LullSecN] := d - 2
				}
			runS := -1
			}
		d := d + 2
		}
	return LullSecN
}

LullScan() {
	global LullFrames, LullCalN, LullR, LullBg, LullSecN, LullSecA, LullSecB
	global LullArmA, LullClrT, LullActive, LullHitSec
	global LullArmDelta, LullTrigPct, LullClearMs, LullRadiusPct, CaptureW
	LullHitSec := 0
	probe := (LullR > 0) ? LullR : Round(CaptureW * LullRadiusPct / 100)
	v := LullRing(probe)
	vmn := 999
	vmx := -1
	d := 180
	while (d <= 360)
		{
		if (v[d] != "" and v[d] >= 0)
			{
			if (v[d] < vmn)
				vmn := v[d]
			if (v[d] > vmx)
				vmx := v[d]
			}
		d := d + 2
		}
	if (vmx < 0 or vmx < 120)
		{
		LullActive := false
		return false
		}
	LullActive := true
	LullFrames := LullFrames + 1
	if (LullR <= 0)
		{
		LullCalStep()
		if (LullCalN >= 26)
			{
			LullPickRadius()
			LullFindSectors()
			}
		return false
		}
	dv := LullArmDelta
	if (dv < 15)
		dv := 15
	if (dv > 200)
		dv := 200
	tp := LullTrigPct
	if (tp < 3)
		tp := 3
	if (tp > 90)
		tp := 90
	cm := LullClearMs
	if (cm < 20)
		cm := 20
	if (cm > 2000)
		cm := 2000
	now := A_TickCount
	hit := false
	i := 1
	while (i <= LullSecN)
		{
		ka := LullSecA[i]
		dk := 0
		n := 0
		d := ka
		while (d <= LullSecB[i])
			{
			if (v[d] != "" and v[d] >= 0 and LullBg[d] != "")
				{
				n := n + 1
				if (Abs(v[d] - LullBg[d]) >= dv)
					dk := dk + 1
				}
			d := d + 2
			}
		if (n > 0 and (dk * 100) >= (n * tp))
			{
			LullClrT[ka] := 0
			if (LullArmA[ka] = "" or LullArmA[ka])
				{
				LullArmA[ka] := false
				LullHitSec := i
				hit := true
				}
			}
		else
			{
			if (LullClrT[ka] = "" or LullClrT[ka] = 0)
				LullClrT[ka] := now
			if ((now - LullClrT[ka]) >= cm)
				LullArmA[ka] := true
			}
		i := i + 1
		}
	return hit
}

NoteScanAll() {
	global pNoteBits, NoteW, NoteH, NoteColorTolerance
	global NoteColR, NoteColG, NoteColB, NoteColN
	global NoteAllX, NoteAllY, NoteAllN
	NoteAllX := []
	NoteAllY := []
	NoteAllN := 0
	sumX := []
	cntX := []
	if (!pNoteBits)
		return 0
	if (NoteParseColors() < 1)
		return 0
	tol := NoteColorTolerance
	if (tol < 6)
		tol := 6
	if (tol > 25)
		tol := 25
	c1r := NoteColR[1]
	c1g := NoteColG[1]
	c1b := NoteColB[1]
	r1lo := c1r - tol
	r1hi := c1r + tol
	g1lo := c1g - tol
	g1hi := c1g + tol
	b1lo := c1b - tol
	b1hi := c1b + tol
	multi := (NoteColN > 1)
	y := NoteH - 13
	while (y >= 0)
		{
		off := y * NoteW * 4
		runs := []
		runStart := -1
		x := 0
		while (x < NoteW)
			{
			v := NumGet(pNoteBits + 0, off + (x*4), "UInt")
			b := v & 0xFF
			ok := false
			if (b >= b1lo and b <= b1hi)
				{
				g := (v >> 8) & 0xFF
				if (g >= g1lo and g <= g1hi)
					{
					r := (v >> 16) & 0xFF
					ok := (r >= r1lo and r <= r1hi)
					}
				}
			if (!ok and multi)
				{
				g := (v >> 8) & 0xFF
				r := (v >> 16) & 0xFF
				ci := 2
				while (ci <= NoteColN)
					{
					if (Abs(r - NoteColR[ci]) <= tol and Abs(g - NoteColG[ci]) <= tol and Abs(b - NoteColB[ci]) <= tol)
						{
						ok := true
						break
						}
					ci++
					}
				}
			if (ok)
				{
				if (runStart < 0)
					runStart := x
				}
			else if (runStart >= 0)
				{
				if (x - runStart >= 8)
					runs.Push(runStart, x - 1)
				runStart := -1
				}
			x += 4
			}
		if (runStart >= 0 and NoteW - runStart >= 8)
			runs.Push(runStart, NoteW - 1)
		n := runs.Length() // 2
		if (n > 0)
			{
			gi := 1
			while (gi <= n)
				{
				gl := runs[(gi-1)*2 + 1]
				gr := runs[(gi-1)*2 + 2]
				gj := gi + 1
				while (gj <= n)
					{
					nl := runs[(gj-1)*2 + 1]
					if (nl - gr > 45)
						break
					gr := runs[(gj-1)*2 + 2]
					gj++
					}
				w := gr - gl + 1
				if (w >= 8 and w <= 120)
					{
					cx := gl + (w / 2)
					dup := false
					di := 1
					while (di <= NoteAllN)
						{
						if (Abs(cx - NoteAllX[di]) <= 55 and (NoteAllY[di] - y) <= 120)
							{
							sumX[di] := sumX[di] + cx
							cntX[di] := cntX[di] + 1
							NoteAllX[di] := sumX[di] / cntX[di]
							dup := true
							break
							}
						di++
						}
					if (!dup and NoteAllN < 2)
						{
						NoteAllN++
						NoteAllX[NoteAllN] := cx
						NoteAllY[NoteAllN] := y
						sumX[NoteAllN] := cx
						cntX[NoteAllN] := 1
						}
					}
				gi := gj
				}
			}
		if (NoteAllN >= 2)
			break
		y -= 16
		}
	return NoteAllN
}

NoteScan(refX) {
	global FishBarLeft, FishBarRight, NoteOriginX, NoteLockX, NoteLockN, LastNoteX, NoteDbgCalls, NoteMissN
	global NoteFresh, NoteIndep, NoteMissAt, QpcFreq
	global NoteAllX, NoteAllY, NoteAllN, NoteH, NoteHandoff
	global NoteNextX, NoteLockY, NoteNextY
	NoteDbgCalls := NoteDbgCalls + 1
	if (NoteIndep and !NoteFresh and NoteLockX >= 0)
		{
		LastNoteX := NoteLockX
		return NoteLockX
		}
	LastNoteX := -1
	NoteNextX := -1
	NoteNextY := -1
	if (NoteScanAll() < 1)
		{
		DllCall("QueryPerformanceCounter", "Int64*", NoteMissNow)
		if (!NoteMissAt)
			NoteMissAt := NoteMissNow
		if (NoteLockX >= 0 and ((NoteMissNow - NoteMissAt) * 1000.0 / QpcFreq) <= 260)
			{
			LastNoteX := NoteLockX
			return NoteLockX
			}
		NoteLockX := -1
		NoteLockN := 0
		NoteLockY := -1
		NoteMissAt := 0
		return -1
		}
	NoteMissAt := 0
	sel := 1
	matched := false
	if (NoteLockX >= 0)
		{
		i := 1
		while (i <= NoteAllN)
			{
			if (Abs((NoteOriginX + NoteAllX[i]) - NoteLockX) <= 55
				and (NoteLockY < 0 or NoteAllY[i] <= NoteLockY + 100))
				{
				sel := i
				matched := true
				break
				}
			i++
			}
		}
	hoff := NoteHandoff
	if (hoff < 0)
		hoff := 0
	if (hoff > 200)
		hoff := 200
	if (NoteAllN > sel and hoff > 0 and NoteAllY[sel] > (NoteH - 13 - hoff))
		{
		sel := sel + 1
		matched := false
		}
	newX := NoteOriginX + NoteAllX[sel]
	if (newX < FishBarLeft)
		newX := FishBarLeft
	if (newX > FishBarRight)
		newX := FishBarRight
	if (!matched)
		{
		NoteLockX := newX
		NoteLockN := 1
		}
	else
		{
		NoteLockN := NoteLockN + 1
		nAvg := (NoteLockN < 8) ? NoteLockN : 8
		NoteLockX := NoteLockX + ((newX - NoteLockX) / nAvg)
		}
	NoteLockY := NoteAllY[sel]
	LastNoteX := NoteLockX
	if (NoteAllN > sel)
		{
		NoteNextX := NoteOriginX + NoteAllX[sel + 1]
		if (NoteNextX < FishBarLeft)
			NoteNextX := FishBarLeft
		if (NoteNextX > FishBarRight)
			NoteNextX := FishBarRight
		NoteNextY := NoteAllY[sel + 1]
		}
	return NoteLockX
}

CaptureStrip() {
	global hCaptureMemDC, hCaptureScreenDC, CaptureW, CaptureH, FishBarLeft, FishBarTop, RobloxHwnd
	global hNoteMemDC, NoteW, NoteH, NoteFullH, NoteTop
	global pNoteBits, pCaptureBits, pCaptureOwn
	global NoteIndep, NoteOriginX, NoteOriginY, NoteNeeded
	global NoteFresh, NoteBlitAt, NoteRefreshMs, QpcFreq, NoteLockX
	RobloxClientRect(RobloxHwnd, cwx, cwy)
	if (!NoteNeeded)
		{
		pCaptureBits := pCaptureOwn
		DllCall("BitBlt", "Ptr", hCaptureMemDC, "Int", 0, "Int", 0, "Int", CaptureW, "Int", CaptureH
			, "Ptr", hCaptureScreenDC, "Int", cwx + Round(FishBarLeft), "Int", cwy + Round(FishBarTop), "UInt", 0x00CC0020)
		return
		}
	if (NoteIndep and hNoteMemDC)
		{
		DllCall("QueryPerformanceCounter", "Int64*", NoteNowT)
		NoteRefreshMs := (NoteLockX >= 0) ? 80 : 45
		NoteFresh := (!NoteBlitAt or ((NoteNowT - NoteBlitAt) * 1000.0 / QpcFreq) >= NoteRefreshMs)
		if (NoteFresh)
			{
			NoteBlitAt := NoteNowT
			DllCall("BitBlt", "Ptr", hNoteMemDC, "Int", 0, "Int", 0, "Int", NoteW, "Int", NoteFullH
				, "Ptr", hCaptureScreenDC, "Int", cwx + NoteOriginX, "Int", cwy + NoteOriginY, "UInt", 0x00CC0020)
			}
		pCaptureBits := pCaptureOwn
		DllCall("BitBlt", "Ptr", hCaptureMemDC, "Int", 0, "Int", 0, "Int", CaptureW, "Int", CaptureH
			, "Ptr", hCaptureScreenDC, "Int", cwx + Round(FishBarLeft), "Int", cwy + Round(FishBarTop), "UInt", 0x00CC0020)
		return
		}
	if (hNoteMemDC and NoteFullH > CaptureH)
		{
		DllCall("BitBlt", "Ptr", hNoteMemDC, "Int", 0, "Int", 0, "Int", NoteW, "Int", NoteFullH
			, "Ptr", hCaptureScreenDC, "Int", cwx + Round(FishBarLeft), "Int", cwy + Round(NoteTop), "UInt", 0x00CC0020)
		if (NoteW = CaptureW and pNoteBits)
			pCaptureBits := pNoteBits + (NoteH * NoteW * 4)
		else
			{
			pCaptureBits := pCaptureOwn
			DllCall("BitBlt", "Ptr", hCaptureMemDC, "Int", 0, "Int", 0, "Int", CaptureW, "Int", CaptureH
				, "Ptr", hNoteMemDC, "Int", 0, "Int", NoteH, "UInt", 0x00CC0020)
			}
		return
		}
	pCaptureBits := pCaptureOwn
	DllCall("BitBlt", "Ptr", hCaptureMemDC, "Int", 0, "Int", 0, "Int", CaptureW, "Int", CaptureH
		, "Ptr", hCaptureScreenDC, "Int", cwx + Round(FishBarLeft), "Int", cwy + Round(FishBarTop), "UInt", 0x00CC0020)
}

ClampPct(v, lo, hi) {
	if (v = "" or v < lo)
		return lo
	if (v > hi)
		return hi
	return v
}

PreciseSleep(ms) {
	global QpcFreq
	if (ms <= 0)
		return
	DllCall("QueryPerformanceCounter", "Int64*", tNow)
	tEnd := tNow + Round(ms * QpcFreq / 1000)
	Loop
		{
		DllCall("QueryPerformanceCounter", "Int64*", tNow)
		if (tNow >= tEnd)
			return
		Sleep, -1
		}
}

SleepTrack(ms, dir := "", useArrow := false) {
	global MacroRunning, FishX, FishBarTooltipHeight, QpcFreq, RunLeft, RunWidth, HeldFraction
	HeldFraction := 1.0
	if (ms <= 15)
		{
		Sleep, % (ms < 0 ? 0 : ms)
		return
		}

	DllCall("QueryPerformanceCounter", "Int64*", tStart)
	Loop
		{
		if (!MacroRunning)
			return
		DllCall("QueryPerformanceCounter", "Int64*", tNow)
		elapsed := (tNow - tStart) * 1000.0 / QpcFreq
		remain := ms - elapsed
		if (remain <= 0)
			return
		if (remain <= 20)
			{

			Sleep, % Round(remain)
			return
			}
		CaptureStrip()
		nx := GetFishPos()
		if (nx >= 0)
			{
			FishX := nx
			MoveHudFish(nx)
			}

		if (dir != "")
			{
			if (useArrow)
				bx := FindArrowX()
			else
				bx := (BarPresent() and RunWidth > 0) ? RunLeft + (RunWidth/2) : -1
			if (bx >= 0)
				{
				if (useArrow)
					MoveHudBarC(bx)
				else
					MoveHudBarSpan(RunLeft, RunWidth)
				if ((dir == "Left" and bx <= FishX) or (dir == "Right" and bx >= FishX))
					{
					HeldFraction := elapsed/ms
					return
					}
				}
			}
		}
}

;====================================================================================================;

ScanRowBar(y, minRun) {
	global pCaptureBits, CaptureW, CaptureH, FishBarLeft, RunLeft, RunWidth
	if (y < 0 or y >= CaptureH)
		return false
	rowOffset := y * CaptureW * 4
	minL := 255
	maxL := 0
	Loop, % CaptureW
		{
		px := NumGet(pCaptureBits + 0, rowOffset + ((A_Index-1)*4), "UInt")
		lum := ((px & 0xFF) + ((px >> 8) & 0xFF) + ((px >> 16) & 0xFF)) // 3
		if (lum < minL)
			minL := lum
		if (lum > maxL)
			maxL := lum
		}
	if (maxL - minL < 40)
		return false
	thr := minL + (maxL - minL) * 0.55

	maxGap := Round(CaptureW * 0.06)
	if (maxGap < 6)
		maxGap := 6
	bestStart := -1
	bestLen := 0
	spanStart := -1
	spanEnd := -1
	gap := 0
	Loop, % CaptureW
		{
		x := A_Index - 1
		px := NumGet(pCaptureBits + 0, rowOffset + (x*4), "UInt")
		lum := ((px & 0xFF) + ((px >> 8) & 0xFF) + ((px >> 16) & 0xFF)) // 3
		if (lum > thr)
			{
			if (spanStart < 0)
				spanStart := x
			spanEnd := x
			gap := 0
			}
		else if (spanStart >= 0)
			{
			gap++
			if (gap > maxGap)
				{
				spanLen := spanEnd - spanStart + 1
				if (spanLen > bestLen)
					{
					bestLen := spanLen
					bestStart := spanStart
					}
				spanStart := -1
				spanEnd := -1
				gap := 0
				}
			}
		}
	if (spanStart >= 0)
		{
		spanLen := spanEnd - spanStart + 1
		if (spanLen > bestLen)
			{
			bestLen := spanLen
			bestStart := spanStart
			}
		}
	if (bestLen < minRun)
		return false
	RunLeft := FishBarLeft + bestStart
	RunWidth := bestLen
	return true
}

CalibrateBarRow(minRun) {
	global CaptureH, CaptureW, BarScanRow, RunLeft, RunWidth, BarRowAgreement
	bestLen := 0
	bestRow := -1
	bestLeft := 0
	rowRuns := {}
	Loop, % CaptureH
		{
		y := A_Index - 1
		if (ScanRowBar(y, minRun))
			{
			rowRuns[y] := {l: RunLeft, w: RunWidth}
			if (RunWidth > bestLen)
				{
				bestLen := RunWidth
				bestRow := y
				bestLeft := RunLeft
				}
			}
		}
	if (bestRow < 0)
		{
		BarRowAgreement := 0
		return false
		}

	bestCentre := bestLeft + bestLen/2
	agree := 0
	for y, r in rowRuns
		{
		c := r.l + r.w/2
		if (Abs(c - bestCentre) <= CaptureW*0.15 and r.w >= bestLen*0.5 and r.w <= bestLen*1.5)
			agree++
		}
	BarRowAgreement := agree
	BarScanRow := bestRow
	RunLeft := bestLeft
	RunWidth := bestLen
	return true
}

ToBGR(rgbHex) {
	v := rgbHex + 0
	return ((v & 0xFF) << 16) | (v & 0xFF00) | ((v >> 16) & 0xFF)
}

ColSpread(x0, x1, fishX) {
	global pCaptureBits, CaptureW, CaptureH
	if (x0 < 0)
		x0 := 0
	if (x1 > CaptureW)
		x1 := CaptureW
	loR := 999999, hiR := -1, loG := 999999, hiG := -1, loB := 999999, hiB := -1
	n := 0
	x := x0
	while (x < x1)
		{
		if (Abs(x - fishX) > 14)
			{
			sR := 0, sG := 0, sB := 0
			y := 8
			while (y < 22)
				{
				px := NumGet(pCaptureBits + 0, (y*CaptureW + x)*4, "UInt")
				sB += px & 0xFF
				sG += (px >> 8) & 0xFF
				sR += (px >> 16) & 0xFF
				y += 2
				}
			if (sR < loR)
				loR := sR
			if (sR > hiR)
				hiR := sR
			if (sG < loG)
				loG := sG
			if (sG > hiG)
				hiG := sG
			if (sB < loB)
				loB := sB
			if (sB > hiB)
				hiB := sB
			n++
			}
		x += 2
		}
	if (n < 10)
		return -1
	return ((hiR - loR) + (hiG - loG) + (hiB - loB)) / 7
}

FrameIsDark() {
	global pCaptureBits, CaptureW, CaptureH
	dark := 0
	n := 0
	y := 0
	while (y < CaptureH)
		{
		off := y * CaptureW * 4
		x := 0
		while (x < CaptureW)
			{
			v := NumGet(pCaptureBits + 0, off + (x*4), "UInt")
			if ((((v & 0xFF) + ((v >> 8) & 0xFF) + ((v >> 16) & 0xFF)) // 3) < 40)
				dark++
			n++
			x += 4
			}
		y += 2
		}
	if (n < 1)
		return false
	return ((dark * 100 // n) >= 85)
}

ManiaVisible() {
	global pNoteBits, NoteW, NoteH, ManiaHitY, WindowHeight
	static fr := [0.1230, 0.3740, 0.6220, 0.8750]
	if (!pNoteBits or NoteH < 120)
		return false
	ys := []
	n := 0
	MvExpect := NoteH - (WindowHeight * 0.0767)
	MvWin := WindowHeight * 0.0625
	MvNear := 0
	li := 1
	while (li <= 4)
		{
		cx := Round(NoteW * fr[li])
		low := -1
		MvLaneNear := false
		s := -1
		y := 0
		while (y < NoteH)
			{
			v := NumGet(pNoteBits + 0, (y*NoteW + cx)*4, "UInt")
			b := v & 0xFF
			g := (v >> 8) & 0xFF
			r := (v >> 16) & 0xFF
			mx := r
			mn := r
			if (g > mx)
				mx := g
			if (b > mx)
				mx := b
			if (g < mn)
				mn := g
			if (b < mn)
				mn := b
			if (mx > 90 and (mx - mn) > 35)
				{
				if (s < 0)
					s := y
				}
			else
				{
				h := y - s
				if (s >= 0)
					{
					if (h >= 8 and h <= 30)
						low := s + (h // 2)
					if (Abs((s + (h // 2)) - MvExpect) <= MvWin)
						MvLaneNear := true
					}
				s := -1
				}
			y++
			}
		if (s >= 0 and Abs((s + ((NoteH - s) // 2)) - MvExpect) <= MvWin)
			MvLaneNear := true
		if (low >= 0)
			{
			n++
			ys[n] := low
			}
		if (MvLaneNear)
			MvNear++
		li++
		}
	if (n < 3)
		return false
	i := 1
	while (i <= n)
		{
		c := 0
		j := 1
		while (j <= n)
			{
			if (Abs(ys[j] - ys[i]) <= 10)
				c++
			j++
			}
		if (c >= 3)
			{
			hit := -1
			j := 1
			while (j <= n)
				{
				if (Abs(ys[j] - ys[i]) <= 10 and ys[j] > hit)
					hit := ys[j]
				j++
				}
			expect := NoteH - (WindowHeight * 0.0767)
			if (hit >= 0 and Abs(hit - expect) <= NoteH * 0.04)
				{
				if (ManiaHitY < 0)
					ManiaHitY := hit
				else
					ManiaHitY := (ManiaHitY * 0.8) + (hit * 0.2)
				}
			return true
			}
		i++
		}
	if (MvNear >= 3)
		return true
	return false
}

ManiaStep() {
	global pNoteBits, NoteW, NoteH, QpcFreq, WindowHeight
	global ManiaPrevY, ManiaPrevT, ManiaSpeed, ManiaFired, ManiaLead, ManiaSeen, ManiaHitY
	static fr := [0.1230, 0.3740, 0.6220, 0.8750]
	static keys := ["d", "f", "j", "k"]
	if (!pNoteBits or NoteH < 120)
		return false
	hitY := (ManiaHitY >= 0) ? ManiaHitY : (NoteH - (WindowHeight * 0.0767))
	minH := Round(NoteH * 0.047)
	if (minH < 20)
		minH := 20
	any := false
	DllCall("QueryPerformanceCounter", "Int64*", tn)
	li := 1
	while (li <= 4)
		{
		cx := Round(NoteW * fr[li])
		lowTop := -1
		lowBot := -1
		s := -1
		y := 0
		while (y < NoteH)
			{
			v := NumGet(pNoteBits + 0, (y*NoteW + cx)*4, "UInt")
			b := v & 0xFF
			g := (v >> 8) & 0xFF
			r := (v >> 16) & 0xFF
			mx := r
			mn := r
			if (g > mx)
				mx := g
			if (b > mx)
				mx := b
			if (g < mn)
				mn := g
			if (b < mn)
				mn := b
			if (mx > 90 and (mx - mn) > 35)
				{
				any := true
				if (s < 0)
					s := y
				}
			else
				{
				if (s >= 0 and y - s >= minH)
					{
					lowTop := s
					lowBot := y - 1
					}
				s := -1
				}
			y++
			}
		if (s >= 0 and NoteH - s >= minH)
			{
			lowTop := s
			lowBot := NoteH - 1
			}

		if (lowBot < 0)
			{
			ManiaFired[li] := false
			ManiaPrevY[li] := -1
			li++
			continue
			}
		cy := (lowTop + lowBot) / 2
		if (ManiaPrevY[li] >= 0 and cy < ManiaPrevY[li] - 60)
			ManiaFired[li] := false
		if (ManiaPrevY[li] >= 0 and ManiaPrevT[li] > 0)
			{
			dt := (tn - ManiaPrevT[li]) / QpcFreq
			if (dt > 0.001 and dt < 0.5 and cy > ManiaPrevY[li])
				ManiaSpeed[li] := ManiaSpeed[li] * 0.6 + ((cy - ManiaPrevY[li]) / dt) * 0.4
			}
		ManiaPrevY[li] := cy
		ManiaPrevT[li] := tn
		if (!ManiaFired[li] and ManiaSpeed[li] > 20)
			{
			tth := (hitY - cy) / ManiaSpeed[li] * 1000
			if (tth <= ManiaLead)
				{
				send % "{" . keys[li] . "}"
				ManiaFired[li] := true
				}
			}
		li++
		}
	ManiaSeen := any
	return any
}

NoiseScan() {
	global pCaptureBits, CaptureW, CaptureH, FishBarLeft, QpcFreq, FishColor, FishBarColorTolerance
	global NoiseBarL, NoiseBarW, NoiseFishX, NoiseFound, NoiseScanned, NoiseFishFresh
	global NoisePrevC, NoisePrevT, NoiseFishPrev, NoiseFishT, NoiseStillX, NoiseStillC, NoiseWCal, NoiseJumpN
	global NoiseWCnt, NoiseWVote, NoiseZOK, NoiseZoneTgt
	global NoiseLastD, NoiseOscN, NoiseVelC
	global NoiseRowOff
	global NoiseCoastN
	global NoiseEHist
	global NoiseJumpHold
	global NoiseRate, NoiseRateT, NoiseN6, NoiseN8, NoiseN15, NoiseN45
	global NoiseAltW, NoiseAltN, NoiseZSeenT
	if (NoiseScanned)
		return NoiseFound
	NoiseScanned := true
	DllCall("QueryPerformanceCounter", "Int64*", rtnow)
	rdt := (NoiseRateT > 0) ? ((rtnow - NoiseRateT) / QpcFreq) : 0
	NoiseRateT := rtnow
	if (rdt > 0 and rdt < 0.25)
		{
		rnow := rdt / 0.040
		if (rnow < 1)
			rnow := 1
		NoiseRate := (NoiseRate * 0.8) + (rnow * 0.2)
		}
	if (NoiseRate < 1)
		NoiseRate := 1
	NoiseN6 := (NoiseRate <= 1) ? 6 : Max(2, Round(6 / NoiseRate))
	NoiseN8 := (NoiseRate <= 1) ? 8 : Max(2, Round(8 / NoiseRate))
	NoiseN15 := (NoiseRate <= 1) ? 15 : Max(3, Round(15 / NoiseRate))
	NoiseN45 := (NoiseRate <= 1) ? 45 : Max(8, Round(45 / NoiseRate))
	NoiseFound := false
	NoiseFishX := -1
	NoiseFishFresh := false
	y0 := Round(CaptureH * 0.10)
	y1 := Round(CaptureH * 0.35)
	if (y1 - y0 < 2)
		{
		y0 := 0
		y1 := CaptureH
		}
	step := 1
	ncol := CaptureW // step
	if (ncol < 40)
		return false
	bmWmax := Round(CaptureW * 0.008) + 2
	bvStep := CaptureH // 13
	if (bvStep < 1)
		bvStep := 1
	bvTot := 0
	byq := 0
	while (byq < CaptureH)
		{
		bvTot++
		byq += bvStep
		}
	bvNeed := Round(bvTot * 0.60)
	if (bvNeed < 3)
		bvNeed := 3
	bmN := 0
	bmX := []
	brun := -1
	bx := 0
	while (bx <= CaptureW)
		{
		bIsEdge := false
		if (bx < CaptureW)
			{
			bHit := 0
			bSeen := 0
			by2 := 0
			while (by2 < CaptureH)
				{
				v := NumGet(pCaptureBits + 0, (by2*CaptureW + bx)*4, "UInt")
				bSeen++
				if (!(v & 0xF0F0F0) and (v & 0xFF) <= 6 and ((v >> 8) & 0xFF) <= 10 and ((v >> 16) & 0xFF) <= 6)
					bHit++
				if ((bHit + (bvTot - bSeen)) < bvNeed)
					break
				by2 += bvStep
				}
			if (bHit >= bvNeed)
				bIsEdge := true
			}
		if (bIsEdge)
			{
			if (brun < 0)
				brun := bx
			}
		else if (brun >= 0)
			{
			if (bx - brun <= bmWmax)
				{
				bmN++
				bmX[bmN] := (brun + bx - 1) // 2
				}
			brun := -1
			}
		bx++
		}
	NoiseEHist.Push(bmX.Clone())
	if (NoiseEHist.Length() > 20)
		NoiseEHist.RemoveAt(1)
	if (bmN >= 2 and NoiseEHist.Length() >= 20)
		{
		sN := 0
		sKeep := []
		si := 1
		while (si <= bmN)
			{
			sx := bmX[si]
			scnt := 0
			sh := 1
			while (sh <= NoiseEHist.Length())
				{
				harr := NoiseEHist[sh]
				sj := 1
				while (sj <= harr.Length())
					{
					if (Abs(harr[sj] - sx) <= 2)
						{
						scnt++
						break
						}
					sj++
					}
				sh++
				}
			if (scnt < 18)
				{
				sN++
				sKeep[sN] := sx
				}
			si++
			}
		if (sN >= 2)
			{
			bmN := sN
			bmX := sKeep
			}
		}
	if (bmN >= 2 and !NoiseZOK and bmX[1] > 3 and bmX[bmN] < CaptureW - 4)
		{
		wobs := bmX[bmN] - bmX[1]
		if (wobs >= CaptureW * 0.15 and wobs <= CaptureW * 0.60)
			{
			wq := (wobs // 4) * 4
			if (!NoiseWCnt.HasKey(wq))
				NoiseWCnt[wq] := 0
			if (NoiseWCnt[wq] < 40)
				NoiseWCnt[wq] := NoiseWCnt[wq] + 1
			if (NoiseWCal >= 40 and wq != NoiseWCal)
				{
				if (!NoiseWCnt.HasKey(NoiseWCal))
					NoiseWCnt[NoiseWCal] := 0
				if (NoiseWCnt[NoiseWCal] > 0)
					NoiseWCnt[NoiseWCal] := NoiseWCnt[NoiseWCal] - 1
				}
			wLead := 0
			if (NoiseWCal >= 40 and NoiseWCnt.HasKey(NoiseWCal))
				wLead := NoiseWCnt[NoiseWCal]
			if (NoiseWCal < 40 or NoiseWCnt[wq] > wLead)
				{
				NoiseWVote := NoiseWCnt[wq]
				NoiseWCal := wq
				}
			}
		}
	wexp := (NoiseWCal >= 40) ? NoiseWCal : (CaptureW * 0.303)
	wtol := Round(CaptureW * 0.016)
	if (wtol < 10)
		wtol := 10
	pairOK := false
	pi := 1
	while (pi <= bmN)
		{
		pj := pi + 1
		while (pj <= bmN)
			{
			if (Abs((bmX[pj] - bmX[pi]) - wexp) <= wtol)
				pairOK := true
			pj++
			}
		pi++
		}
	arwOK := false
	if (!pairOK)
		{
		ay0 := Round(CaptureH * 0.46)
		ay1 := Round(CaptureH * 0.87)
		if (ay1 <= ay0 + 1)
			{
			ay0 := CaptureH // 2
			ay1 := ay0 + 2
			}
		acnt := []
		astep := 2
		ax := 0
		while (ax < CaptureW)
			{
			cc := 0
			ay := ay0
			while (ay < ay1)
				{
				v := NumGet(pCaptureBits + 0, (ay*CaptureW + ax)*4, "UInt")
				if (((((v & 0xFF) + ((v >> 8) & 0xFF) + ((v >> 16) & 0xFF)) // 3)) <= 12)
					cc++
				ay += 4
				}
			acnt[ax] := cc
			ax += astep
			}
		awmin := Round(CaptureW * 0.019)
		awmax := Round(CaptureW * 0.09)
		bestAw := 0
		bestAa := -1
		bestAb := -1
		ra := -1
		ax := 0
		while (ax <= CaptureW)
			{
			isa := (ax < CaptureW and acnt[ax] >= 1)
			if (isa)
				{
				if (ra < 0)
					ra := ax
				}
			else if (ra >= 0)
				{
			rb := ax - astep
				aw := rb - ra + 1
				if (aw >= awmin and aw <= awmax and aw > bestAw)
					{
					bestAw := aw
					bestAa := ra
					bestAb := rb
					}
				ra := -1
				}
		ax += astep
			}
		if (bestAw > 0)
			{
			th := bestAw // 3
			if (th < 1)
				th := 1
			lsum := 0
			rsum := 0
			kk := 0
			while (kk < th)
				{
				lsum += acnt[bestAa + kk]
				rsum += acnt[bestAb - kk]
				kk++
				}
		useW := (NoiseWCal >= 40) ? NoiseWCal : (CaptureW * 0.30)
			ains := Round(useW * 0.125)
			acx := (bestAa + bestAb) // 2
			if (rsum > lsum)
				{
				barRp := acx + ains
			barLp := barRp - Round(useW)
				}
			else
				{
				barLp := acx - ains
			barRp := barLp + Round(useW)
				}
			if (barLp < 0)
			barLp := barLp
			if (barRp > CaptureW - 1)
			barRp := barRp
			if (barRp - barLp >= 40)
				{
				arwL := barLp
				arwR := barRp
				arwOK := true
				}
			}
		}
	wexp := (NoiseWCal >= 40) ? NoiseWCal : (CaptureW * 0.303)
	wtol := Round(CaptureW * 0.016)
	if (wtol < 10)
		wtol := 10
	nrun := 0
	if (!pairOK and !arwOK)
		{
		lum := []
		gex := []
		hist := []
		bi := 0
		while (bi < 64)
			{
			hist[bi] := 0
			bi++
			}
		i := 0
		while (i < ncol)
			{
			x := i * step
			s := 0
			sg := 0
			smx := 0
			c := 0
			y := y0
			while (y < y1)
				{
				v := NumGet(pCaptureBits + 0, (y*CaptureW + x)*4, "UInt")
				pb := (v & 0xFF)
				pg := ((v >> 8) & 0xFF)
				pr := ((v >> 16) & 0xFF)
				s += (pr + pg + pb) // 3
				sg += pg
				smx += (pr > pb) ? pr : pb
				c++
				y += 2
				}
			if (c < 1)
				c := 1
			lv := s // c
			lum[i] := lv
			gex[i] := (sg - smx) // c
			bi := lv // 4
			if (bi > 63)
				bi := 63
			if (bi < 0)
				bi := 0
			hist[bi] := hist[bi] + 1
			i++
			}
		need := Round(ncol * 0.20)
		acc := 0
		bg := 0
		bi := 0
		while (bi < 64)
			{
			acc += hist[bi]
			if (acc >= need)
				{
				bg := bi * 4
				break
				}
			bi++
			}
		need := Round(ncol * 0.98)
		acc := 0
		pk := 255
		bi := 0
		while (bi < 64)
			{
			acc += hist[bi]
			if (acc >= need)
				{
				pk := bi * 4
				break
				}
			bi++
			}
		if (pk - bg < 40)
			return false
		thr := bg + ((pk - bg) * 0.45)
		gapmax := Round(ncol * 0.025)
		if (gapmax < 5)
			gapmax := 5
		minw := Round(ncol * 0.22)
		if (minw < 20)
			minw := 20
		rs := -1
		re := -1
		gap := 0
		nrun := 0
		rA := []
		rB := []
		i := 0
		while (i <= ncol)
			{
			isb := (i < ncol and lum[i] >= thr)
			if (isb)
				{
				if (rs < 0)
					rs := i
				re := i
				gap := 0
				}
			else if (rs >= 0)
				{
				gap++
				if (gap > gapmax or i = ncol)
					{
					gsum := 0
					gn := 0
					gi := rs
					while (gi <= re)
						{
						gsum += gex[gi]
						gn++
						gi++
						}
					if (gn < 1)
						gn := 1
					if (re - rs + 1 >= minw and (gsum // gn) >= 25)
						{
						nrun++
						rA[nrun] := rs
						rB[nrun] := re
						}
					rs := -1
					gap := 0
					}
				}
			i++
			}
		}
	gotBar := (nrun >= 1)
	bs := -99999
	be := -1
	DllCall("QueryPerformanceCounter", "Int64*", tnow)
	fresh := (NoisePrevT > 0 and ((tnow - NoisePrevT) / QpcFreq) < 0.6)
	if (gotBar)
		{
		bestI := 0
		bestSc := -999999
		k := 1
		while (k <= nrun)
			{
			w := rB[k] - rA[k] + 1
			cx := ((rA[k] + rB[k]) * step) // 2
			sc := w
			if (fresh)
				sc := w - (Abs(cx - NoisePrevC) // step)
			if (sc > bestSc)
				{
				bestSc := sc
				bestI := k
				}
			k++
			}
		bs := rA[bestI]
		be := rB[bestI]
		if (NoiseWCal < 40 and rA[bestI] > 0 and rB[bestI] < ncol - 1)
			NoiseWCal := (be - bs + 1) * step
		}
	bdL := 0
	bdOK := false
	bdR := -1
	bdBest := 999999
	bdPair := false
	bdFresh := (NoisePrevT > 0 and NoisePrevC >= 0 and ((tnow - NoisePrevT) / QpcFreq) < 0.8)
	arwC := arwOK ? ((arwL + arwR) // 2) : -99999
	mirL := NoisePrevC - (wexp / 2)
	mirR := NoisePrevC + (wexp / 2)
	mirTol := Round(CaptureW * 0.03)
	if (mirTol < 12)
		mirTol := 12
	bi2 := 1
	while (bi2 <= bmN)
		{
		bj := bi2 + 1
		while (bj <= bmN)
			{
			sep := bmX[bj] - bmX[bi2]
			isMirror := (bdFresh and ((Abs(bmX[bj] - mirL) <= mirTol and bmX[bi2] < mirL - (wexp / 2))
				or (Abs(bmX[bi2] - mirR) <= mirTol and bmX[bj] > mirR + (wexp / 2))))
			if (Abs(sep - wexp) <= wtol and !isMirror)
				{
				cc := (bmX[bi2] + bmX[bj]) // 2
				scr := Abs(sep - wexp) * 2
				if (bdFresh)
					scr += Abs(cc - NoisePrevC)
				else if (arwOK)
					scr += Abs(cc - arwC)
				if (scr < bdBest)
					{
					bdBest := scr
					bdL := bmX[bi2]
					bdOK := true
					bdR := bmX[bj]
					bdPair := true
					}
				}
			bj++
			}
		bi2++
		}
	if (bdPair and arwOK and !bdFresh and Abs(((bdL + bdR) // 2) - arwC) > Round(CaptureW * 0.07))
		{
		bdOK := false
		bdPair := false
		}
	; --- the bar changed size: a consistent pair at a new spacing wins after 3 calls -----------
	DllCall("QueryPerformanceCounter", "Int64*", altNow)
	if (NoiseZOK)
		NoiseZSeenT := altNow
	altWin := (!NoiseZOK and NoiseZSeenT > 0 and ((altNow - NoiseZSeenT) / QpcFreq) < 4.0)
	if (bdPair or !altWin)
		NoiseAltN := 0
	else if (NoiseWCal >= 40)
		{
		altBest := -1
		altL := 0
		altR := 0
		ai := 1
		while (ai <= bmN)
			{
			aj := ai + 1
			while (aj <= bmN)
				{
				asep := bmX[aj] - bmX[ai]
				arat := (asep * 100) // NoiseWCal
				if ((arat >= 50 and arat <= 92) or (arat >= 108 and arat <= 150))
					{
					if (NoiseAltW > 0)
						asc := Abs(asep - NoiseAltW)
					else if (NoiseFishPrev >= 0)
						asc := Abs(((bmX[ai] + bmX[aj]) // 2) - NoiseFishPrev)
					else
						asc := 0
					if (altBest < 0 or asc < altBest)
						{
						altBest := asc
						altL := bmX[ai]
						altR := bmX[aj]
						}
					}
				aj++
				}
			ai++
			}
		if (altBest < 0)
			{
			NoiseAltN := 0
			NoiseAltW := 0
			}
		else if (NoiseAltW > 0 and Abs((altR - altL) - NoiseAltW) <= 4)
			NoiseAltN := NoiseAltN + 1
		else
			{
			NoiseAltW := altR - altL
			NoiseAltN := 1
			}
		if (NoiseAltN >= 3)
			{
			NoiseWCal := altR - altL
			NoiseWCnt := {}
			NoiseWVote := 0
			NoiseJumpN := 0
			NoiseOscN := 0
			NoiseCoastN := 0
			NoiseAltN := 0
			NoiseAltW := 0
			bdL := altL
			bdR := altR
			bdOK := true
			bdPair := true
			bdFresh := false
			wexp := NoiseWCal
			}
		}
	if (!bdOK)
		{
		bi2 := 1
		while (bi2 <= bmN)
			{
			cLx := bmX[bi2]
			cRx := Round(bmX[bi2] + wexp)
			cc := (cLx + cRx) // 2
			scr := bdFresh ? Abs(cc - NoisePrevC) : (arwOK ? Abs(cc - arwC) : 40)
			if (scr < bdBest)
				{
				bdBest := scr
				bdL := cLx
				bdOK := true
				bdR := cRx
				}
			cRx := bmX[bi2]
			cLx := Round(bmX[bi2] - wexp)
			cc := (cLx + cRx) // 2
			scr := bdFresh ? Abs(cc - NoisePrevC) : (arwOK ? Abs(cc - arwC) : 60)
			if (scr < bdBest)
				{
				bdBest := scr
				bdL := cLx
				bdOK := true
				bdR := cRx
				}
			bi2++
			}
		}
	if (!bdOK and arwOK)
		{
		bdL := arwL
		bdOK := true
		bdR := arwR
		}
	if (bdOK and bdFresh and NoiseCoastN = 0)
		{
		ccF := (bdL + bdR) // 2
		if (Abs(ccF - NoisePrevC) > Round(CaptureW * 0.12 * NoiseRate))
			{
			NoiseJumpN := NoiseJumpN + 1
			if (NoiseJumpN < NoiseN8)
				bdOK := false
			else
				NoiseJumpN := 0
			}
		}
	if (bdOK and bdR - bdL >= 40)
		{
		bs := bdL // step
		be := bdR // step
		gotBar := true
		if (bdPair and NoiseWVote < 2)
			{
			if (NoiseWCal < 40)
				NoiseWCal := bdR - bdL
			else if (Abs((bdR - bdL) - NoiseWCal) <= NoiseWCal * 0.10)
				NoiseWCal := (NoiseWCal * 0.90) + ((bdR - bdL) * 0.10)
			}
		}
	if (gotBar and bs >= 0 and bdFresh and NoiseCoastN = 0)
		{
		ccF2 := ((bs + be) * step) // 2
		if (Abs(ccF2 - NoisePrevC) > Round(CaptureW * 0.12 * NoiseRate))
			{
			NoiseJumpN := NoiseJumpN + 1
			if (NoiseJumpN < NoiseN15)
				gotBar := false
			else
				NoiseJumpN := 0
			}
		else
			NoiseJumpN := 0
		}
	if (gotBar and bdFresh and NoisePrevC >= 0)
		{
		ccF3 := ((bs + be) * step) // 2
		dNow := ccF3 - NoisePrevC
		if (NoiseLastD != 0 and (dNow * NoiseLastD) < 0 and Abs(dNow) > Round(CaptureW * 0.02 * NoiseRate) and NoiseOscN < NoiseN6)
			{
			NoiseOscN := NoiseOscN + 1
			oHalf := (be - bs) // 2
			bs := (NoisePrevC // step) - oHalf
			be := (NoisePrevC // step) + oHalf
			}
		else
			{
			NoiseOscN := 0
			NoiseLastD := dNow
			NoiseVelC := ((NoiseVelC * 6) + (dNow * 4)) // 10
			}
		}
	if (gotBar and NoiseWCal >= 40)
		{
		cwid := (be - bs + 1) * step
		if (Abs(cwid - NoiseWCal) > (NoiseWCal // 4))
			gotBar := false
		}
	if (!gotBar)
		{
		if (NoisePrevC >= 0 and NoiseWCal >= 40 and NoiseCoastN < NoiseN6)
			{
			NoiseCoastN := NoiseCoastN + 1
			cstep := NoiseVelC
			cmax := Round(CaptureW * 0.035 * NoiseRate)
			if (cmax < 25)
				cmax := 25
			if (cstep > cmax)
				cstep := cmax
			if (cstep < -cmax)
				cstep := -cmax
			predC := NoisePrevC + cstep
			if (predC < 0)
				predC := 0
			if (predC > CaptureW)
				predC := CaptureW
			bs := Round((predC - (NoiseWCal / 2)) / step)
			be := Round((predC + (NoiseWCal / 2)) / step)
			gotBar := true
			}
		else
			return false
		}
	else
		NoiseCoastN := 0
	NoiseBarL := FishBarLeft + (bs * step)
	NoiseBarW := (be - bs + 1) * step
	NoiseFound := true
	NoisePrevC := ((bs + be) * step) // 2
	NoisePrevT := tnow
	if (Abs(NoisePrevC - NoiseStillX) <= 2)
		NoiseStillC := NoiseStillC + 1
	else
		{
		NoiseStillC := 0
		NoiseStillX := NoisePrevC
		}
	if (NoiseStillC >= NoiseN45)
		{
		NoisePrevT := 0
		NoiseStillC := 0
		return true
		}
	fbgr := ToBGR(ColMain(FishColor))
	ftB := (fbgr >> 16) & 0xFF
	ftG := (fbgr >> 8) & 0xFF
	ftR := fbgr & 0xFF
	ftol := FishBarColorTolerance
	if (ftol < 6)
		ftol := 6
	frow := CaptureH // 2
	fneed := (NoiseZOK or NoiseZoneTgt >= 0) ? 3 : 4
	fwmax := Round(CaptureW * 0.028)
	if (fwmax < 8)
		fwmax := 8
	edgeM := Round(CaptureW * 0.016)
	if (edgeM < 10)
		edgeM := 10
	barA := bs * step
	barB := be * step
	nf := 0
	fX := []
	fx2 := 0
	while (fx2 < CaptureW)
		{
		pv := NumGet(pCaptureBits + 0, (frow*CaptureW + fx2)*4, "UInt")
		if ((Abs((pv & 0xFF) - ftB) <= ftol and Abs(((pv >> 8) & 0xFF) - ftG) <= ftol and Abs(((pv >> 16) & 0xFF) - ftR) <= ftol) or (((pv >> 8) & 0xFF) >= 34 and ((pv >> 8) & 0xFF) <= 104 and ((pv >> 16) & 0xFF) <= 52 and (pv & 0xFF) <= 76 and ((pv >> 8) & 0xFF) >= ((pv >> 16) & 0xFF) + 10 and ((pv >> 8) & 0xFF) >= (pv & 0xFF) + 4 and ((((pv >> 16) & 0xFF) + ((pv >> 8) & 0xFF) + (pv & 0xFF)) // 3) >= 14 and ((((pv >> 16) & 0xFF) + ((pv >> 8) & 0xFF) + (pv & 0xFF)) // 3) <= 74))
			{
			fst := fx2
			while (fx2 < CaptureW)
				{
				pv := NumGet(pCaptureBits + 0, (frow*CaptureW + fx2)*4, "UInt")
				if !((Abs((pv & 0xFF) - ftB) <= ftol and Abs(((pv >> 8) & 0xFF) - ftG) <= ftol and Abs(((pv >> 16) & 0xFF) - ftR) <= ftol) or (((pv >> 8) & 0xFF) >= 34 and ((pv >> 8) & 0xFF) <= 104 and ((pv >> 16) & 0xFF) <= 52 and (pv & 0xFF) <= 76 and ((pv >> 8) & 0xFF) >= ((pv >> 16) & 0xFF) + 10 and ((pv >> 8) & 0xFF) >= (pv & 0xFF) + 4 and ((((pv >> 16) & 0xFF) + ((pv >> 8) & 0xFF) + (pv & 0xFF)) // 3) >= 14 and ((((pv >> 16) & 0xFF) + ((pv >> 8) & 0xFF) + (pv & 0xFF)) // 3) <= 74))
					break
				fx2++
				}
			fw := fx2 - fst
			if (fw >= 3 and fw <= fwmax)
				{
				fcx := fst + (fw // 2)
				fhits := 0
				fk := 1
				while (fk <= 5)
					{
					fy := Floor(CaptureH * (fk*2 - 1) / 10)
					if (fy >= CaptureH)
						fy := CaptureH - 1
					pv := NumGet(pCaptureBits + 0, (fy*CaptureW + fcx)*4, "UInt")
					if (NoiseIsCore(pv, ftB, ftG, ftR, ftol))
						fhits++
					fk++
					}
				if (fhits >= fneed and Abs(fcx - barA) > edgeM and Abs(fcx - barB) > edgeM)
					{
					gSum := 0
					gN := 0
					fy := 2
					while (fy < CaptureH - 2)
						{
						v := NumGet(pCaptureBits + 0, (fy*CaptureW + fcx)*4, "UInt")
						gSum += ((v >> 8) & 0xFF)
						gN++
						fy++
						}
					if (gN < 1)
						gN := 1
					ownG := gSum // gN
					maxL := 0
					maxR := 0
					kk := 1
					while (kk <= 4)
						{
						xx := fst - kk
						if (xx < 0)
							xx := 0
						v := NumGet(pCaptureBits + 0, (frow*CaptureW + xx)*4, "UInt")
						gv := (v >> 8) & 0xFF
						if (gv > maxL)
							maxL := gv
						xx := fx2 - 1 + kk
						if (xx > CaptureW - 1)
							xx := CaptureW - 1
						v := NumGet(pCaptureBits + 0, (frow*CaptureW + xx)*4, "UInt")
						gv := (v >> 8) & 0xFF
						if (gv > maxR)
							maxR := gv
						kk++
						}
					if (maxL >= ownG + 80 and maxR >= ownG + 80)
						{
						nf++
						fX[nf] := fcx
						}
					}
				}
			}
		else
			fx2++
		}
	if (nf < 1)
		{
		if (NoiseFishT > 0 and NoiseFishPrev >= 0 and ((tnow - NoiseFishT) / QpcFreq) < 1.2)
			NoiseFishX := FishBarLeft + NoiseFishPrev
		return true
		}
	fpick := fX[1]
	if (NoiseFishT > 0 and NoiseFishPrev >= 0 and ((tnow - NoiseFishT) / QpcFreq) < 0.35)
		{
		fjmax := Round(CaptureW * 0.10)
		if (fjmax < 100)
			fjmax := 100
		fnear := false
		fk2 := 1
		while (fk2 <= nf)
			{
			if (Abs(fX[fk2] - NoiseFishPrev) <= fjmax)
				fnear := true
			fk2++
			}
		if (!fnear)
			{
			NoiseFishX := FishBarLeft + NoiseFishPrev
			return true
			}
		}
	if (NoiseFishT > 0 and ((tnow - NoiseFishT) / QpcFreq) < 0.6)
		{
		fbestd := 999999
		k := 1
		while (k <= nf)
			{
			fd := Abs(fX[k] - NoiseFishPrev)
			if (fd < fbestd)
				{
				fbestd := fd
				fpick := fX[k]
				}
			k++
			}
		}
	NoiseFishX := FishBarLeft + fpick
	NoiseFishFresh := true
	NoiseFishPrev := fpick
	NoiseFishT := tnow
	return true
}

;====================================================================================================;

BellonaScan() {
	global pCaptureBits, CaptureW, CaptureH
	global BelA, BelB, BelF, BelOK, BelSeen
	BelSeen := false
	BelA := [0, 0]
	BelB := [0, 0]
	BelF := [-1, -1]
	BelOK := [false, false]
	step := 4
	ncol := CaptureW // step
	col := []
	i := 0
	while (i < ncol)
		{
		x := i * step
		s := 0
		c := 0
		y := 5
		while (y < CaptureH - 5)
			{
			v := NumGet(pCaptureBits + 0, (y*CaptureW + x)*4, "UInt")
			s += ((v & 0xFF) + ((v >> 8) & 0xFF) + ((v >> 16) & 0xFF)) // 3
			c++
			y += 4
			}
		col[i] := (c > 0) ? (s // c) : 0
		i++
		}
	pref := []
	pref[0] := 0
	i := 0
	while (i < ncol)
		{
		pref[i+1] := pref[i] + col[i]
		i++
		}
	halfc := ncol // 2
	gapmax := Round(ncol * 0.035)
	if (gapmax < 4)
		gapmax := 4
		minw := Round(halfc * 0.15)
		maxw := Round(halfc * 0.85)
	sd := 1
	while (sd <= 2)
		{
		lo := (sd = 1) ? 0 : halfc
		hi := (sd = 1) ? halfc : ncol
		hist := []
		bi := 0
		while (bi < 64)
			{
			hist[bi] := 0
			bi++
			}
		k := 0
		i := lo
		while (i < hi)
			{
			bi := col[i] // 4
			if (bi > 63)
				bi := 63
			if (bi < 0)
				bi := 0
			hist[bi] := hist[bi] + 1
			k++
			i++
			}
		need := Round(k * 0.20)
		acc := 0
		bg := 0
		bi := 0
		while (bi < 64)
			{
			acc += hist[bi]
			if (acc >= need)
				{
				bg := bi * 4
				break
				}
			bi++
			}
		need := Round(k * 0.98)
		acc := 0
		pk := 255
		bi := 0
		while (bi < 64)
			{
			acc += hist[bi]
			if (acc >= need)
				{
				pk := bi * 4
				break
				}
			bi++
			}
		thr := bg + ((pk - bg) * 0.40)
		if (thr < bg + 25)
			thr := bg + 25

		bestLen := 0
		bestS := -1
		bestE := -1
		rs := -1
		re := -1
		gap := 0
		i := lo
		while (i < hi)
			{
			if (col[i] >= thr)
				{
				if (rs < 0)
					rs := i
				re := i
				gap := 0
				}
			else if (rs >= 0)
				{
				gap++
				if (gap > gapmax)
					{
					if (re - rs > bestLen)
						bestLen := re - rs, bestS := rs, bestE := re
					rs := -1
					gap := 0
					}
				}
			i++
			}
		if (rs >= 0 and re - rs > bestLen)
			bestLen := re - rs, bestS := rs, bestE := re

		barw := bestLen + 1
		bestIn := (bestS >= 0) ? ((pref[bestE+1] - pref[bestS]) / barw) : 0
		bestSc := bestIn - bg
		if (bestS >= 0 and barw >= minw and barw <= maxw and bestSc >= 28)
			BelSeen := true
		if (bestS >= 0 and barw >= minw and barw <= maxw and bestSc >= 120)
			{
			BelA[sd] := bestS * step
			BelB[sd] := bestE * step
			BelOK[sd] := true
			fhi := bestIn * 0.62
			flo := (pk - bg) * 0.15
			if (flo < 20)
				flo := 20
			flo := bg + flo
			wcap := Round(halfc * 0.10)
			if (wcap < 2)
				wcap := 2
			s0 := bestS - 3
			if (s0 < lo)
				s0 := lo
			s1 := bestE + 3
			if (s1 > hi - 1)
				s1 := hi - 1
			fbest := 99999
			fs := -1
			fe := -1
			cs := -1
			i := s0
			while (i <= s1 + 1)
				{
				isf := (i <= s1 and col[i] >= flo and col[i] < fhi)
				if (isf)
					{
					if (cs < 0)
						cs := i
					}
				else if (cs >= 0)
					{
					ce := i - 1
					if (ce - cs <= wcap)
						{
						cm := (pref[ce+1] - pref[cs]) / (ce - cs + 1)
						if (cm < fbest)
							fbest := cm, fs := cs, fe := ce
						}
					cs := -1
					}
				i++
				}
			if (fs >= 0)
				BelF[sd] := ((fs + fe) * step) // 2
			}
		sd++
		}
	return (BelOK[1] or BelOK[2]) ? 2 : (BelSeen ? 1 : 0)
}

BellonaDrive(sd) {
	global BelA, BelB, BelF, BelOK, BelPrevF, BelPrevB, BelPrevT, BelVel, BelBVel, BelDown, QpcFreq
	if (!BelOK[sd] or BelF[sd] < 0)
		return
	bar := (BelA[sd] + BelB[sd]) / 2
	fish := BelF[sd]
	DllCall("QueryPerformanceCounter", "Int64*", tn)
	if (BelPrevT[sd] > 0)
		{
		dt := (tn - BelPrevT[sd]) / QpcFreq
		if (dt > 0.0005 and dt < 0.5)
			{
			BelVel[sd]  := BelVel[sd]  * 0.55 + ((fish - BelPrevF[sd]) / dt) * 0.45
			BelBVel[sd] := BelBVel[sd] * 0.55 + ((bar  - BelPrevB[sd]) / dt) * 0.45
			}
		}
	BelPrevT[sd] := tn
	BelPrevF[sd] := fish
	BelPrevB[sd] := bar

	span := BelB[sd] - BelA[sd]
	dead := span * 0.035
	err := fish - bar
	rel := BelBVel[sd] - BelVel[sd]
	pe := err - (rel * 0.13)

	if (pe > dead)
		want := true
	else if (pe < -dead)
		want := false
	else
		want := BelDown[sd]

	if (want and !BelDown[sd])
		{
		if (sd = 1)
			send {lbutton down}
		else
			send {rbutton down}
		BelDown[sd] := true
		}
	else if (!want and BelDown[sd])
		{
		if (sd = 1)
			send {lbutton up}
		else
			send {rbutton up}
		BelDown[sd] := false
		}
}

BellonaRelease() {
	global BelDown
	send {lbutton up}
	send {rbutton up}
	BelDown := [false, false]
}

LineScan() {
	global pCaptureBits, CaptureW, CaptureH, FishBarLeft
	global LineList, LineFishX, LineNoteX, LineFound, LineScanned
	global LineBarL, LineBarW, LineBarAge, LineFishSeen, SpecialRod, DarkHoldN, DarkFlashing, DarkAcc
	if (LineScanned)
		return LineFound
	LineScanned := true
	if (SpecialRod = "Darkheart")
		{
		if (FrameIsDark())
			{
			DarkHoldN := DarkHoldN + 1
			if (DarkHoldN <= 45 and LineBarW >= 1)
				{
				if (!DarkFlashing)
					DarkAcc := 0
				DarkFlashing := true
				return LineFound
				}
			}
		else
			{
			DarkHoldN := 0
			DarkFlashing := false
			}
		}
	LineFound := false
	LineFishSeen := false
	LineFishX := -1
	LineNoteX := -1
	LineList := []

	VarSetCapacity(HitBuf, CaptureW * 4, 0)
	pHits := &HitBuf

	pFn := LineHitsFn()
	if (pFn)
		rows := DllCall(pFn, "Ptr", pCaptureBits, "Int", CaptureW, "Int", CaptureH, "Ptr", pHits, "Int")
	else
		rows := LineHitsAhk(pCaptureBits, CaptureW, CaptureH, pHits)

	need := Round(rows * 0.5)
	if (need < 2)
		need := 2

	s := -1
	p := -1
	x := 1
	q := pHits + 4
	while (x < CaptureW)
		{
		if (NumGet(q + 0, 0, "UInt") >= need)
			{
			if (s < 0)
				s := x, p := x
			else if (x - p <= 3)
				p := x
			else
				{
				LineList.Push((s + p) // 2)
				s := x
				p := x
				}
			}
		x++, q += 4
		}
	if (s >= 0)
		{
		LineList.Push((s + p) // 2)
		}

	bestGap := 999
	fi := -1
	i := 1
	while (i < LineList.Length())
		{
		gap := LineList[i+1] - LineList[i]
		if (gap >= 4 and gap <= 20 and gap < bestGap)
			bestGap := gap, fi := i
		i++
		}
	if (fi < 0)
		{
		LineBarAge := LineBarAge + 1
		return false
		}

	fcx := (LineList[fi] + LineList[fi+1]) / 2
	LineFishX := FishBarLeft + fcx
	LineFishSeen := true

	others := []
	i := 1
	while (i <= LineList.Length())
		{
		if (i != fi and i != fi + 1)
			others.Push(LineList[i])
		i++
		}

	if (others.Length() >= 2)
		{
		expW := (LineBarW >= 40) ? LineBarW : 0
		lo := -1
		hi := -1
		bestScore := 999999
		oi := 1
		while (oi < others.Length())
			{
			oj := oi + 1
			while (oj <= others.Length())
				{
				sep := others[oj] - others[oi]
				if (sep >= 40)
					{
					score := (expW > 0) ? Abs(sep - expW) : Abs(sep - 200)
					if (score < bestScore)
						{
						bestScore := score
						lo := others[oi]
						hi := others[oj]
						}
					}
				oj++
				}
			oi++
			}
		if (lo >= 0)
			{
			LineBarL := FishBarLeft + lo
			LineBarW := hi - lo + 1
			LineBarAge := 0
			}
		else
			LineBarAge := LineBarAge + 1
		}
	else if (others.Length() = 1)
		{
		e := others[1]
		spL := ColSpread(e - 120, e - 6, fcx)
		spR := ColSpread(e + 6, e + 120, fcx)
		ext := (LineBarW >= 40) ? LineBarW : 200
		if (spL > spR and spL > 0)
			{
			bl := e - ext
			if (bl < 0)
				bl := 0
			LineBarL := FishBarLeft + bl
			LineBarW := e - bl + 1
			LineBarAge := 0
			}
		else if (spR > 0)
			{
			br := e + ext
			if (br > CaptureW - 1)
				br := CaptureW - 1
			LineBarL := FishBarLeft + e
			LineBarW := br - e + 1
			LineBarAge := 0
			}
		else
			LineBarAge := LineBarAge + 1
		}
	else
		LineBarAge := LineBarAge + 1

	if (LineBarW < 1 or LineBarAge > 12)
		return false

	LineFound := true
	return true
}

LineHitsAhk(pBits, w, h, pHits) {
	rowBytes := w * 4
	rows := 0
	y := 0
	while (y < h)
		{
		p := pBits + (y * rowBytes)
		pe := p + rowBytes
		px := NumGet(p + 0, 0, "UInt")
		prev := (px & 0xFF) + ((px >> 8) & 0xFF) + ((px >> 16) & 0xFF)
		p += 4, q := pHits + 4
		while (p < pe)
			px := NumGet(p + 0, 0, "UInt"), cur := (px & 0xFF) + ((px >> 8) & 0xFF) + ((px >> 16) & 0xFF), (cur - prev > 54 or prev - cur > 54) ? NumPut(NumGet(q + 0, 0, "UInt") + 1, q + 0, 0, "UInt") : 0, prev := cur, p += 4, q += 4
		rows++
		y += 3
		}
	return rows
}

LineHitsFn() {
	static pFn := "", Hex := "53565755415431C04531D24189D349C1E3024539C20F8D5B000000498BF2490FAFF34801CE0FB61E0FB67E0101FB0FB67E0201FBBF0100000039D77D310FB62CBE440FB664BE014401E5440FB664BE024401E54189EC4129DC790341F7DC4183FC367E0441FF04B989EBFFC7EBCBFFC04183C203EB9C415C5D5F5E5BC3"
	if (pFn != "")
		return pFn
	pFn := 0
	if (A_PtrSize != 8)
		return 0
	n := StrLen(Hex) // 2
	p := DllCall("VirtualAlloc", "Ptr", 0, "Ptr", n, "UInt", 0x3000, "UInt", 0x04, "Ptr")
	if (!p)
		return 0
	Loop, %n%
		NumPut("0x" . SubStr(Hex, 2 * A_Index - 1, 2), p + 0, A_Index - 1, "UChar")
	if (!DllCall("VirtualProtect", "Ptr", p, "Ptr", n, "UInt", 0x20, "UIntP", oldProt))
		{
		DllCall("VirtualFree", "Ptr", p, "Ptr", 0, "UInt", 0x8000)
		return 0
		}
	tw := 157, th := 23
	VarSetCapacity(tBits, tw * th * 4, 0)
	seed := 12345
	Loop, % tw * th
		{
		seed := Mod(seed * 1103515245 + 12345, 2147483648)
		v := (seed >> 8) & 0xFFFFFFFF
		if (Mod(A_Index, 7) < 3)
			v := v & 0x3F3F3F3F
		NumPut(v, tBits, (A_Index - 1) * 4, "UInt")
		}
	VarSetCapacity(hA, tw * 4, 0)
	VarSetCapacity(hB, tw * 4, 0)
	rA := LineHitsAhk(&tBits, tw, th, &hA)
	rB := DllCall(p, "Ptr", &tBits, "Int", tw, "Int", th, "Ptr", &hB, "Int")
	same := (rA = rB)
	anyHit := false
	Loop, %tw%
		{
		a := NumGet(hA, (A_Index - 1) * 4, "UInt")
		if (a != NumGet(hB, (A_Index - 1) * 4, "UInt"))
			same := false
		if (a)
			anyHit := true
		}
	if (!same or !anyHit)
		{
		DllCall("VirtualFree", "Ptr", p, "Ptr", 0, "UInt", 0x8000)
		return 0
		}
	pFn := p
	return pFn
}

PinionScan() {
	global pCaptureBits, CaptureW, CaptureH, FishBarLeft, BarScanRow
	global FishColor, FishBarColorTolerance, NoteColor, NoteColorTolerance
	global PinFishX, PinNoteX, PinFound
	PinFishX := -1
	PinNoteX := -1
	PinFound := false
	row := BarScanRow
	if (row < 0 or row >= CaptureH)
		row := CaptureH // 2
	rowOff := row * CaptureW * 4

	fb := ToBGR(ColMain(FishColor))
	fB := (fb >> 16) & 0xFF
	fG := (fb >> 8) & 0xFF
	fR := fb & 0xFF
	ftol := FishBarColorTolerance
	if (ftol < 4)
		ftol := 4

	nb := ToBGR(NoteColor)
	nB := (nb >> 16) & 0xFF
	nG := (nb >> 8) & 0xFF
	nR := nb & 0xFF
	ntol := NoteColorTolerance
	if (ntol < 4)
		ntol := 4

	bestW := 0
	fRunS := -1
	fRunE := -1
	nRunS := -1
	nRunE := -1
	x := 0
	while (x <= CaptureW)
		{
		isF := false
		isN := false
		if (x < CaptureW)
			{
			px := NumGet(pCaptureBits + 0, rowOff + (x*4), "UInt")
			b := px & 0xFF
			g := (px >> 8) & 0xFF
			r := (px >> 16) & 0xFF
			isF := (Abs(b - fB) <= ftol and Abs(g - fG) <= ftol and Abs(r - fR) <= ftol)
			isN := (Abs(b - nB) <= ntol and Abs(g - nG) <= ntol and Abs(r - nR) <= ntol)
			}
		if (isF)
			{
			if (fRunS < 0)
				fRunS := x
			fRunE := x
			}
		else if (fRunS >= 0)
			{
			w := fRunE - fRunS + 1
			if (w >= 3 and w <= 25 and w > bestW)
				{
				bestW := w
				PinFishX := FishBarLeft + ((fRunS + fRunE) / 2)
				}
			fRunS := -1
			}
		if (isN)
			{
			if (nRunS < 0)
				nRunS := x
			nRunE := x
			}
		else if (nRunS >= 0)
			{
			w := nRunE - nRunS + 1
			if (w >= 2 and w <= 10 and PinNoteX < 0)
				PinNoteX := FishBarLeft + ((nRunS + nRunE) / 2)
			nRunS := -1
			}
		x++
		}
	PinFound := (PinFishX >= 0)
	return PinFound
}


; --- Noiseform zone gimmick -------------------------------------------------------------------

TotemMaybeRun:
if (!TotemAuto or !MacroRunning)
	return
if (TotemLastCheck and (A_TickCount - TotemLastCheck) < (TotemPollSec * 1000))
	return
TotemLastCheck := A_TickCount
gosub, TotemRunCycle
return

;====================================================================================================;

TotemRunCycle:
TotemDidPop := false
TotemPass := 0
TotemLoop:
TotemPass++
if (TotemPass > 6 or !MacroRunning)
	goto TotemDone
if (!TotemStripInit())
	goto TotemDone
if (!TotemCaptureStrip())
	goto TotemDone
if (!TotemReadState())
	goto TotemDone
TotemNext := ""
TotemNextKey := ""
TotemFor := ""
for i, sel in [TotemSel1, TotemSel2]
	{
	if (sel = "" or sel = "None")
		continue
	if (sel = "Day" or sel = "Night")
		tkey := TotemKeySundial
	else
		{
		tkv := "TotemKey" . sel
		tkey := %tkv%
		}
	if (tkey = "")
		continue
	if (TotemHas(sel))
		continue
	if (TotemWeatherConflict(sel))
		continue
	tneed := TotemNeedsTime(sel)
	if (tneed != "" and TotemTime != "" and TotemTime != tneed)
		{
		if (TotemConflict(sel))
			continue
		if (TotemKeySundial = "")
			continue
		TotemNext := "Sundial"
		TotemFor := sel
		TotemNextKey := TotemKeySundial
		TotemWantTime := tneed
		break
		}
	if (TotemIsWeather(sel) and TotemWeather != "" and TotemWeather != "Clear")
		{
		if (TotemKeyClearcast = "")
			continue
		TotemNext := "Clearcast"
		TotemFor := sel
		TotemNextKey := TotemKeyClearcast
		break
		}
	if (sel = "Day" or sel = "Night")
		continue
	TotemNext := sel
	TotemFor := sel
	TotemNextKey := tkey
	break
	}
if (TotemNext = "")
	goto TotemDone
tooltip, Current Task: Totem - %TotemNext%, %TooltipX%, %Tooltip7%, 7
send {%TotemNextKey%}
sleep 300
click
TotemDidPop := true
if (TotemNext = "Sundial")
	WhEvent("totem", "Sundial Totem - changing the time to " . TotemWantTime
		. ((TotemFor = "Day" or TotemFor = "Night") ? "" : " for the " . TotemFor . " Totem"))
else if (TotemNext = "Clearcast")
	WhEvent("totem", "Clearcast Totem - clearing the weather for the " . TotemFor . " Totem")
else
	WhEvent("totem", TotemNext . " Totem")
if (TotemNext = "Sundial")
	{
	TotemWaited := 0
	while (MacroRunning and TotemWaited < 40000)
		{
		sleep 1000
		TotemWaited := TotemWaited + 1000
		TotemWaitS := TotemWaited // 1000
		tooltip, Current Task: Totem - waiting for %TotemWantTime% (%TotemWaitS%s), %TooltipX%, %Tooltip7%, 7
		if (!TotemCaptureStrip())
			continue
		TotemReadState()
		if (TotemTime = TotemWantTime)
			break
		}
	}
else
	sleep %TotemActDelay%
if (!MacroRunning)
	goto TotemDone
goto TotemLoop

TotemDone:
if (TotemDidPop and RodSlotKey != "")
	{
	send {%RodSlotKey%}
	sleep 400
	}
return

;====================================================================================================;

TotemHas(nm) {
	global TotemWeather, TotemEvents, TotemTime
	if (nm = "Day" or nm = "Night")
		return (TotemTime = nm)
	if (nm = "Clearcast")
		return (TotemWeather = "Clear")
	if (nm = "Tempest")
		return (TotemWeather = "Rain")
	if (nm = "Windset")
		return (TotemWeather = "Windy")
	if (nm = "Smokescreen")
		return (TotemWeather = "Foggy")
	return InStr(TotemEvents, nm . ",") ? true : false
}

TotemNeedsTime(nm) {
	if (nm = "Day" or nm = "Night")
		return nm
	if (nm = "Aurora" or nm = "Starfall")
		return "Night"
	if (nm = "Eclipse")
		return "Day"
	return ""
}

TotemIsWeather(nm) {
	return (nm = "Tempest" or nm = "Windset" or nm = "Smokescreen")
}

TotemConflict(nm) {
	global TotemSel1, TotemSel2
	a := TotemNeedsTime(TotemSel1)
	b := TotemNeedsTime(TotemSel2)
	if (a = "" or b = "" or a = b)
		return false
	return (nm = TotemSel2)
}

TotemIsWeatherState(nm) {
	return (nm = "Clearcast" or nm = "Tempest" or nm = "Windset" or nm = "Smokescreen")
}

TotemWeatherConflict(nm) {
	global TotemSel1, TotemSel2
	if (!TotemIsWeatherState(TotemSel1) or !TotemIsWeatherState(TotemSel2))
		return false
	if (TotemSel1 = TotemSel2)
		return false
	return (nm = TotemSel2)
}

WhEsc(t) {
	t := StrReplace(t, "\", "\\")
	t := StrReplace(t, """", "\""")
	t := StrReplace(t, "`r", "")
	t := StrReplace(t, "`n", "\n")
	t := StrReplace(t, "`t", " ")
	return t
}

WhField(nm, val, inline := true) {
	return "{""name"":""" . WhEsc(nm) . """,""value"":""" . WhEsc(val) . """,""inline"":" . (inline ? "true" : "false") . "}"
}

WhStamp() {
	ts := A_NowUTC
	FormatTime, d, %ts%, yyyy-MM-dd
	FormatTime, t, %ts%, HH:mm:ss
	return d . "T" . t . ".000Z"
}

WhBuildJson(title, desc, color, fieldsJson, footer, img := "") {
	j := "{""username"":""DeepFish"",""embeds"":[{"
	j .= """title"":""" . WhEsc(title) . ""","
	if (desc != "")
		j .= """description"":""" . WhEsc(desc) . ""","
	j .= """color"":" . color . ","
	if (fieldsJson != "")
		j .= """fields"":[" . fieldsJson . "],"
	if (img != "")
		j .= """image"":{""url"":""attachment://" . img . """},"
	j .= """footer"":{""text"":""" . WhEsc(footer) . """},"
	j .= """timestamp"":""" . WhStamp() . """"
	j .= "}]}"
	return j
}

WhPost(json) {
	global WebhookURL
	if (WebhookURL = "" or InStr(WebhookURL, "discord") = 0)
		return false
	try
		{
		req := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		req.SetTimeouts(4000, 4000, 4000, 6000)
		req.Open("POST", WebhookURL, false)
		req.SetRequestHeader("Content-Type", "application/json; charset=utf-8")
		req.Send(json)
		}
	catch e
		return false
	return true
}

WhTick:
if (!WebhookOn or WebhookURL = "" or !MacroRunning)
	return
if (WebhookSummaryMin >= 1 and (A_TickCount - WhLastSummary) >= (WebhookSummaryMin * 60000))
	{
	WhLastSummary := A_TickCount
	WhEvent("summary")
	}
if (WebhookOnAlert and !WhStalled and WebhookStallMin >= 1)
	{
	WhRef := WhLastCatchTick ? WhLastCatchTick : WhStartTick
	if (WhRef and (A_TickCount - WhRef) >= (WebhookStallMin * 60000))
		{
		WhStalled := true
		WhEvent("stall")
		}
	}
return

;====================================================================================================;

WhSendShot(json, fallback := "") {
	global WebhookURL
	if (WebhookURL = "")
		return false
	cu := A_WinDir . "\System32\curl.exe"
	if (!FileExist(cu))
		return WhSendAsync(fallback != "" ? fallback : json)
	stamp := A_TickCount
	jf := A_Temp . "\deepfish_wh_" . stamp . ".json"
	pf := A_Temp . "\deepfish_shot_" . stamp . ".jpg"
	sf := A_Temp . "\deepfish_shot_" . stamp . ".ps1"
	FileDelete, %jf%
	FileAppend, % json, %jf%, UTF-8-RAW
	if (!FileExist(jf))
		return false
	sw := A_ScreenWidth
	sh := A_ScreenHeight
	tw := sw // 2
	if (tw > 1280)
		tw := 1280
	if (tw < 640)
		tw := 640
	th := Round(sh * tw / sw)
	ps := "Add-Type -AssemblyName System.Drawing`n"
	ps .= "$ErrorActionPreference='SilentlyContinue'`n"
	ps .= "$W=" . sw . "; $H=" . sh . "; $TW=" . tw . "; $TH=" . th . "`n"
	ps .= "$J='" . jf . "'; $P='" . pf . "'; $S='" . sf . "'`n"
	ps .= "$C='" . cu . "'; $U='" . WebhookURL . "'`n"
	ps .= "$b=New-Object System.Drawing.Bitmap $W,$H`n"
	ps .= "$g=[System.Drawing.Graphics]::FromImage($b)`n"
	ps .= "$g.CopyFromScreen(0,0,0,0,$b.Size)`n"
	ps .= "$t=New-Object System.Drawing.Bitmap $TW,$TH`n"
	ps .= "$g2=[System.Drawing.Graphics]::FromImage($t)`n"
	ps .= "$g2.InterpolationMode='HighQualityBicubic'`n"
	ps .= "$g2.DrawImage($b,0,0,$TW,$TH)`n"
	ps .= "$enc=[System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }`n"
	ps .= "$ep=New-Object System.Drawing.Imaging.EncoderParameters 1`n"
	ps .= "$ep.Param[0]=New-Object System.Drawing.Imaging.EncoderParameter -ArgumentList ([System.Drawing.Imaging.Encoder]::Quality), ([long]70)`n"
	ps .= "$t.Save($P,$enc,$ep)`n"
	ps .= "$g.Dispose(); $g2.Dispose(); $b.Dispose(); $t.Dispose()`n"
	ps .= "$ca=@('-s','-m','30','-F',""payload_json=<$J"",'-F',""files[0]=@$P;filename=shot.jpg"",$U)`n"
	ps .= "& $C @ca`n"
	ps .= "Remove-Item $J,$P,$S -Force -ErrorAction SilentlyContinue`n"
	FileDelete, %sf%
	FileAppend, % ps, %sf%, UTF-8-RAW
	if (!FileExist(sf))
		{
		FileDelete, %jf%
		return false
		}
	Run, powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%sf%", , Hide
	return true
}

WhSendAsync(json) {
	global WebhookURL
	if (WebhookURL = "")
		return false
	tf := A_Temp . "\deepfish_wh_" . A_TickCount . ".json"
	FileDelete, %tf%
	FileAppend, % json, %tf%, UTF-8-RAW
	if (!FileExist(tf))
		return false
	cu := A_WinDir . "\System32\curl.exe"
	if (FileExist(cu))
		{
		cmd := A_ComSpec . " /c """"" . cu . """ -s -m 15 -H ""Content-Type: application/json"" --data-binary @""" . tf . """ """ . WebhookURL . """ & del """ . tf . """"""
		Run, %cmd%, , Hide
		return true
		}
	WhPost(json)
	FileDelete, %tf%
	return true
}

WhRuntimeText() {
	global WhStartTick
	if (!WhStartTick)
		return "0h 0m"
	ms := A_TickCount - WhStartTick
	tsec := ms // 1000
	th := tsec // 3600
	tm := Mod(tsec, 3600) // 60
	return th . "h " . tm . "m"
}

WhCommonFields() {
	global WhCatches, WhStartTick, ActiveProfile
	global TotemAuto, TotemTime, TotemWeather
	ms := WhStartTick ? (A_TickCount - WhStartTick) : 0
	hrs := (ms > 0) ? (ms / 3600000.0) : 0
	rate := (hrs > 0.01) ? Round(WhCatches / hrs) : 0
	f := WhField("Runtime", WhRuntimeText(), true)
	f .= "," . WhField("Fish", WhCatches . "", true)
	f .= "," . WhField("Per hour", rate . "", true)
	f .= "," . WhField("Profile", ActiveProfile, true)
	if (TotemAuto)
		{
		st := (TotemTime = "" ? "?" : TotemTime)
		st .= " / " . (TotemWeather = "" ? "?" : TotemWeather)
		f .= "," . WhField("Server", st, true)
		}
	return f
}

WhEvent(kind, detail := "") {
	global WebhookOn, WebhookURL, WebhookOnAlert, WebhookShot, ActiveProfile
	if (!WebhookOn or WebhookURL = "")
		return
	if (kind = "start")
		j := WhBuildJson("Macro started", "", 3066993, WhCommonFields(), "DeepFish")
	else if (kind = "stop")
		{
		if (!WebhookOnAlert)
			return
		j := WhBuildJson("Macro stopped", "The macro is no longer running.", 15158332, WhCommonFields(), "DeepFish")
		}
	else if (kind = "stall")
		{
		if (!WebhookOnAlert)
			return
		j := WhBuildJson("No fish caught recently", "The macro is running but has not landed a fish for a while.", 15844367, WhCommonFields(), "DeepFish")
		if (WebhookShot)
			{
			cf := WhCommonFields()
			WhSendShot(WhBuildJson("No fish caught recently", "The macro is running but has not landed a fish for a while.", 15844367, cf, "DeepFish", "shot.jpg"), j)
			return
			}
		}
	else if (kind = "summary")
		{
		j := WhBuildJson("Status report", "", 3447003, WhCommonFields(), "DeepFish")
		if (WebhookShot)
			{
			cf := WhCommonFields()
			WhSendShot(WhBuildJson("Status report", "", 3447003, cf, "DeepFish", "shot.jpg"), j)
			return
			}
		}
	else if (kind = "catch")
		j := WhBuildJson("Fish caught", "", 10181046, WhCommonFields(), "DeepFish")
	else if (kind = "totem")
		j := WhBuildJson("Totem used", detail, 15105570, WhCommonFields(), "DeepFish")
	else if (kind = "aquarium")
		j := WhBuildJson("Aquarium", detail, 1752220, WhCommonFields(), "DeepFish")
	else if (kind = "keeper")
		j := WhBuildJson("Keeperbound recharge", detail, 11342935, WhCommonFields(), "DeepFish")
	else
		return
	WhSendAsync(j)
}

TotemTplInit() {
	global TotemTpl
	if (TotemTpl.MaxIndex() >= 13)
		return
	TotemTpl := []
	TotemTpl.Push({n: "Day", g: "000000000051510000000000000922000025260000211000001985000004040000842000000000078399998407000000000000834800004684000000512504990000000099052551512604990000000099052551000000834600004585000000000000078499998508000000001884000005050000831900001023000025250000221000000000000051510000000000", ar: 1.0, hue: -1, sat: 0})
	TotemTpl.Push({n: "Night", g: "000000001641586565666131000014565627080011653801002566240000000563320000156915000000004249000000523900000000037016000000701800000000157201000000701800000000157201000000523800000000037016000000156914000000004349000000002566230000000564310000000015575526070012653701000000001741586464656131", ar: 0.734, hue: -1, sat: 0})
	TotemTpl.Push({n: "Clear", g: "273300000004040000000000035925045567675408000000000662201500002361030000000035711400000036310000024170256410000015480000434103001862060012684104640100000025590302143552640000000000325401000063552100000000003948000763116453494949494973411528000218212121212121543300000000000000000000035304", ar: 1.11, hue: -1, sat: 0})
	TotemTpl.Push({n: "Foggy", g: "000000054565654706000000000007563101013056010000034959360000000046210000433500000000000030645208640100000000000000002453640200000000000000000064414001000000000000001857024463575757575757586013000003070707070707060000000463656565656516530400000008091012121204050000000029314371717171300000", ar: 1.0, hue: -1, sat: 0})
	TotemTpl.Push({n: "Windy", g: "000000000000105461310000000000000000402808560500000000000000170300461100161616161616161620570300515151515151515149210000060606060606060606060300616161616161616161616226020202020202000000000856636363636363550600000057020202020202392400003449000000005813382500003308000000002861530600000000", ar: 1.178, hue: -1, sat: 0})
	TotemTpl.Push({n: "Rain", g: "510021280045040842000000521112500037240259020000313200560617450044190000105200362601580323390000005507164600412004580000003528015803204100471500001548004022025801273500000058051943004517075600000039240258012438005111000018440044180557003132000001590223390049131052000000410804450026210048", ar: 1.591, hue: -1, sat: 0})
	TotemTpl.Push({n: "Stormy", g: "000000064866665007000000000012592901002760020000055555330000000045270000493000000000000026606114680000000153613400001659660500002574670500000066345309016274391400013053003059707474746464634806000000204574400000000000000000005250010000000000000000115803000000000000000000320600000000000000", ar: 0.97, hue: 60, sat: 31})
	TotemTpl.Push({n: "Eclipse", g: "000000000007250000000000000000000000010000040600000321282126422905150900054046464640284641040000314646464646324146260000444646464646443146380015444646464646443146380017314646464646324146260000054046464640284641040000000321282127433005130700000000000000000000050800000000000007250000000000", ar: 1.032, hue: 27, sat: 75})
	TotemTpl.Push({n: "Starfall", g: "000000000000116376739854000000000045651303674300000000004148000069200000000000176700003444000000003207650725007300000000006475516996185300000000004030280864531600000000016723000070390000000000763500000009790600000000435885086269641800000000000018656700000000000000000000861400000000000000", ar: 1.058, hue: 252, sat: 52})
	TotemTpl.Push({n: "Aurora", g: "000000000000000000000561000018320000000000208257004187853600000145863100667513158436107072110000510200001584874701000000000000000015220000000000000704000000000000000000248472050000000000000000852756740600000027595959080000547507004584403737000000005177647410000000000000000048580300000000", ar: 1.0, hue: 161, sat: 41})
	TotemTpl.Push({n: "Shiny", g: "000000000019200000000000000000000051530000000000000000000574750700000000000000003548473800000000334755627616157763554733116961191200001321597112000765450000000040670800000005711900001673060000000001740415160275010000000013684373734566160000000030815407065281330000000038240000000023400000", ar: 1.057, hue: 47, sat: 38})
	TotemTpl.Push({n: "Sparkling", g: "000000000019190000000000000000000050500000000000000000000674740600000000000000003549493500000000334855627517187562554833126962201300001422626912000865460100000044650800000005701900001970050000000001740417170574010000000014694572724569140000000032795106065179320000000038230000000023390000", ar: 1.057, hue: 98, sat: 35})
	TotemTpl.Push({n: "Mutation", g: "000000000020200000000000000000000050500000000000000000000672720600000000000000003549493500000000354755627318197362554735136762211400001523626713000964460100000145640900000006692000002069060000000001730618180673010000000015684570704568150000000032765107075176320000000039230000000023390000", ar: 1.057, hue: 109, sat: 55})
}

TotemReadState() {
	global TotemTime, TotemWeather, TotemEvents, TotemDbg
	kOk := TotemReadStateAt(0)
	if (kOk and TotemTime != "")
		return true
	kWeather := TotemWeather
	kEvents := TotemEvents
	kDbg := TotemDbg
	kTime := ""
	for kI, kThr in [215, 190]
		{
		if (TotemReadStateAt(kThr))
			{
			kOk := true
			if (TotemTime != "")
				{
				kTime := TotemTime
				break
				}
			}
		}
	TotemTime := kTime
	TotemWeather := kWeather
	TotemEvents := kEvents
	TotemDbg := kDbg
	return kOk
}

TotemReadStateAt(thrOverride := 0) {
	global pTotemBits, TotemW, TotemH, TotemTpl
	global TotemTime, TotemWeather, TotemEvents, TotemDbg
	TotemTime := ""
	TotemWeather := ""
	TotemEvents := ""
	TotemDbg := ""
	if (!pTotemBits or TotemW < 24 or TotemH < 12)
		return false
	TotemTplInit()
	hist := []
	hi := 0
	while (hi < 256)
		{
		hist[hi] := 0
		hi++
		}
	tot := TotemW * TotemH
	ty := 0
	while (ty < TotemH)
		{
		roff := ty * TotemW * 4
		tx := 0
		while (tx < TotemW)
			{
			pv := NumGet(pTotemBits + 0, roff + (tx*4), "UInt")
			pl := ((pv & 0xFF) + ((pv >> 8) & 0xFF) + ((pv >> 16) & 0xFF)) // 3
			hist[pl] := hist[pl] + 1
			tx++
			}
		ty++
		}
	need50 := tot // 2
	need97 := (tot * 97) // 100
	acc := 0
	p50 := -1
	p97 := -1
	hi := 0
	while (hi < 256)
		{
		acc := acc + hist[hi]
		if (p50 < 0 and acc >= need50)
			p50 := hi
		if (acc >= need97)
			{
			p97 := hi
			break
			}
		hi++
		}
	if (p50 < 0)
		p50 := 0
	if (p97 < 0)
		p97 := 255
	thr := p97
	if (thr < p50 + 40)
		thr := p50 + 40
	if (thr < 200)
		thr := 200
	if (thr > 250)
		thr := 250
	if (thrOverride > 0)
		thr := thrOverride
	cnt := []
	ctop := []
	cbot := []
	tx := 0
	while (tx < TotemW)
		{
		cnt[tx] := 0
		ctop[tx] := 9999
		cbot[tx] := -1
		tx++
		}
	ty := 0
	while (ty < TotemH)
		{
		roff := ty * TotemW * 4
		tx := 0
		while (tx < TotemW)
			{
			pv := NumGet(pTotemBits + 0, roff + (tx*4), "UInt")
			qb := pv & 0xFF
			qg := (pv >> 8) & 0xFF
			qr := (pv >> 16) & 0xFF
			pl := (qr + qg + qb) // 3
			qmx := (qr > qg) ? qr : qg
			if (qb > qmx)
				qmx := qb
			qmn := (qr < qg) ? qr : qg
			if (qb < qmn)
				qmn := qb
			qs := (qmx > 0) ? ((qmx - qmn) * 100) // qmx : 0
			if (pl >= thr or (qs >= 40 and qmx >= 160))
				{
				cnt[tx] := cnt[tx] + 1
				if (ty < ctop[tx])
					ctop[tx] := ty
				if (ty > cbot[tx])
					cbot[tx] := ty
				}
			tx++
			}
		ty++
		}
	rs := []
	re := []
	nr := 0
	st := -1
	tx := 0
	while (tx < TotemW)
		{
		if (cnt[tx] >= 2)
			{
			if (st < 0)
				st := tx
			}
		else if (st >= 0)
			{
			nr++
			rs[nr] := st
			re[nr] := tx - 1
			st := -1
			}
		tx++
		}
	if (st >= 0)
		{
		nr++
		rs[nr] := st
		re[nr] := TotemW - 1
		}
	ms := []
	me := []
	nm := 0
	ri := 1
	while (ri <= nr)
		{
		if (nm > 0 and (rs[ri] - me[nm] - 1) <= 5)
			me[nm] := re[ri]
		else
			{
			nm++
			ms[nm] := rs[ri]
			me[nm] := re[ri]
			}
		ri++
		}
	keepS := []
	keepE := []
	nk := 0
	mi := 1
	while (mi <= nm)
		{
		if ((me[mi] - ms[mi] + 1) >= 14)
			{
			nk++
			keepS[nk] := ms[mi]
			keepE[nk] := me[mi]
			}
		mi++
		}
	if (nk < 1)
		return false
	nk := nk - 1
	if (nk < 1)
		return false
	ki := 1
	while (ki <= nk)
		{
		a := keepS[ki]
		b := keepE[ki]
		y0 := 9999
		y1 := -1
		tx := a
		while (tx <= b)
			{
			if (cbot[tx] >= 0)
				{
				if (ctop[tx] < y0)
					y0 := ctop[tx]
				if (cbot[tx] > y1)
					y1 := cbot[tx]
				}
			tx++
			}
		if (y1 < y0)
			{
			ki++
			continue
			}
		bw := b - a + 1
		bh := y1 - y0 + 1
		grid := []
		gsum := 0
		gi := 0
		while (gi < 12)
			{
			gj := 0
			while (gj < 12)
				{
				sy0 := y0 + (bh * gi) // 12
				sy1 := y0 + (bh * (gi + 1)) // 12
				if (sy1 <= sy0)
					sy1 := sy0 + 1
				sx0 := a + (bw * gj) // 12
				sx1 := a + (bw * (gj + 1)) // 12
				if (sx1 <= sx0)
					sx1 := sx0 + 1
				ss := 0
				sn := 0
				yy := sy0
				while (yy < sy1 and yy < TotemH)
					{
					roff := yy * TotemW * 4
					xx := sx0
					while (xx < sx1 and xx < TotemW)
						{
						pv := NumGet(pTotemBits + 0, roff + (xx*4), "UInt")
						qb := pv & 0xFF
						qg := (pv >> 8) & 0xFF
						qr := (pv >> 16) & 0xFF
						pl := (qr + qg + qb) // 3
						qmx := (qr > qg) ? qr : qg
						if (qb > qmx)
							qmx := qb
						qmn := (qr < qg) ? qr : qg
						if (qb < qmn)
							qmn := qb
						qs := (qmx > 0) ? ((qmx - qmn) * 100) // qmx : 0
						if (pl >= thr or (qs >= 40 and qmx >= 160))
							ss++
						sn++
						xx++
						}
					yy++
					}
				gv := sn ? (ss * 100) // sn : 0
				grid[gi*12 + gj] := gv
				gsum := gsum + gv
				gj++
				}
			gi++
			}
		if (gsum < 1)
			{
			ki++
			continue
			}
		gmean := gsum / 144
		gi := 0
		while (gi < 144)
			{
			grid[gi] := Round((grid[gi] / gmean) * 20)
			gi++
			}
		sr := 0
		sg := 0
		sb := 0
		sc := 0
		yy := y0
		while (yy <= y1)
			{
			roff := yy * TotemW * 4
			xx := a
			while (xx <= b)
				{
				pv := NumGet(pTotemBits + 0, roff + (xx*4), "UInt")
				cb := pv & 0xFF
				cg := (pv >> 8) & 0xFF
				cr := (pv >> 16) & 0xFF
				pl := (cr + cg + cb) // 3
				mx := (cr > cg) ? cr : cg
				if (cb > mx)
					mx := cb
				mn := (cr < cg) ? cr : cg
				if (cb < mn)
					mn := cb
				csat := (mx > 0) ? ((mx - mn) * 100) // mx : 0
				if (pl >= thr or (csat >= 40 and mx >= 160))
					{
					if ((mx - mn) > 30)
						{
						sr := sr + cr
						sg := sg + cg
						sb := sb + cb
						sc++
						}
					}
				xx++
				}
			yy++
			}
		ihue := -1
		isat := 0
		if (sc > 4)
			{
			ar2 := sr // sc
			ag2 := sg // sc
			ab2 := sb // sc
			ihue := TotemHue(ar2, ag2, ab2)
			mx2 := (ar2 > ag2) ? ar2 : ag2
			if (ab2 > mx2)
				mx2 := ab2
			mn2 := (ar2 < ag2) ? ar2 : ag2
			if (ab2 < mn2)
				mn2 := ab2
			if (mx2 > 0)
				isat := ((mx2 - mn2) * 100) // mx2
			}
		iar := Round((bw * 100) / bh)
		bestD := 999999
		bestN := ""
		nextD := 999999
		ti := 1
		while (ti <= TotemTpl.MaxIndex())
			{
			t := TotemTpl[ti]
			if (t.hue >= 0 and ihue >= 0)
				{
				hd := Abs(t.hue - ihue)
				if (hd > 180)
					hd := 360 - hd
				}
			else
				hd := 0
			d := 0
			gi := 0
			while (gi < 144)
				{
				tv := SubStr(t.g, gi*2 + 1, 2) + 0
				dv := grid[gi] - tv
				if (dv < 0)
					dv := 0 - dv
				d := d + dv
				gi++
				}
			d := d + Abs(iar - Round(t.ar * 100)) * 8
			if (t.hue >= 0 and ihue >= 0)
				{
				d := d + hd * 20
				d := d + Abs(isat - t.sat) * 15
				}
			else if (t.hue >= 0 and ihue < 0)
				d := d + 300
			else if (t.hue < 0 and ihue >= 0)
				d := d + 300
			if (d < bestD)
				{
				nextD := bestD
				bestD := d
				bestN := t.n
				}
			else if (d < nextD)
				nextD := d
			ti++
			}
		TotemDbg .= bestN . "(" . Round(bestD) . "/" . Round(nextD) . ") "
		if (bestD <= 2800 and (nextD - bestD) >= 500)
			{
			if (bestN = "Day" or bestN = "Night")
				TotemTime := bestN
			else if (bestN = "Shiny" or bestN = "Sparkling" or bestN = "Mutation"
				or bestN = "Aurora" or bestN = "Starfall" or bestN = "Eclipse")
				TotemEvents .= bestN . ","
			else
				TotemWeather := bestN
			}
		ki++
		}
	return true
}

TotemHue(r, g, b) {
	mx := (r > g) ? r : g
	if (b > mx)
		mx := b
	mn := (r < g) ? r : g
	if (b < mn)
		mn := b
	dl := mx - mn
	if (dl < 1)
		return -1
	if (mx = r)
		h := 60 * (((g - b) / dl) + 0)
	else if (mx = g)
		h := 60 * (((b - r) / dl) + 2)
	else
		h := 60 * (((r - g) / dl) + 4)
	h := Round(h)
	if (h < 0)
		h := h + 360
	if (h >= 360)
		h := h - 360
	return h
}

TotemStripInit() {
	global hTotemMemDC, hTotemScreenDC, hTotemBM, pTotemBits
	global TotemW, TotemH, TotemX0, TotemY0, WindowWidth, WindowHeight
	nx0 := Round(WindowWidth * 0.836)
	ny0 := Round(WindowHeight * 0.876)
	nw := Round(WindowWidth * 0.162)
	nh := Round(WindowHeight * 0.048)
	if (nw < 48)
		nw := 48
	if (nh < 20)
		nh := 20
	if (hTotemMemDC and nw = TotemW and nh = TotemH)
		{
		TotemX0 := nx0
		TotemY0 := ny0
		return true
		}
	if (hTotemMemDC)
		{
		DllCall("DeleteObject", "Ptr", hTotemBM)
		DllCall("DeleteDC", "Ptr", hTotemMemDC)
		DllCall("ReleaseDC", "Ptr", 0, "Ptr", hTotemScreenDC)
		hTotemMemDC := 0
		}
	TotemX0 := nx0
	TotemY0 := ny0
	TotemW := nw
	TotemH := nh
	hTotemScreenDC := DllCall("GetDC", "Ptr", 0, "Ptr")
	hTotemMemDC := DllCall("CreateCompatibleDC", "Ptr", hTotemScreenDC, "Ptr")
	VarSetCapacity(TotemBMI, 40, 0)
	NumPut(40, TotemBMI, 0, "UInt")
	NumPut(TotemW, TotemBMI, 4, "Int")
	NumPut(-TotemH, TotemBMI, 8, "Int")
	NumPut(1, TotemBMI, 12, "UShort")
	NumPut(32, TotemBMI, 14, "UShort")
	NumPut(0, TotemBMI, 16, "UInt")
	hTotemBM := DllCall("CreateDIBSection", "Ptr", hTotemScreenDC, "Ptr", &TotemBMI, "UInt", 0, "Ptr*", pTotemBits, "Ptr", 0, "UInt", 0, "Ptr")
	if (!hTotemBM)
		{
		hTotemMemDC := 0
		return false
		}
	DllCall("SelectObject", "Ptr", hTotemMemDC, "Ptr", hTotemBM)
	return true
}

TotemCaptureStrip() {
	global hTotemMemDC, hTotemScreenDC, TotemW, TotemH, TotemX0, TotemY0, RobloxHwnd
	if (!hTotemMemDC or !RobloxHwnd)
		return false
	RobloxClientRect(RobloxHwnd, twx, twy)
	DllCall("BitBlt", "Ptr", hTotemMemDC, "Int", 0, "Int", 0, "Int", TotemW, "Int", TotemH
		, "Ptr", hTotemScreenDC, "Int", twx + TotemX0, "Int", twy + TotemY0, "UInt", 0x00CC0020)
	return true
}

;====================================================================================================;
;
;====================================================================================================;

KbIsEdge(vb, vg, vr, kind) {
	if (kind = "enchant")
		return (vb - vg >= 35 and vr - vg >= 5 and vb > vr and vb >= 90)
	if (kind = "confirm")
		return (vg - vb >= 45 and vg - vr >= 25 and vg >= 110)
	if (kind = "red")
		return (vr - vg >= 60 and vr - vb >= 60 and vr >= 100)
	return false
}

KbRuns(ry, kind, minW, ByRef starts, ByRef ends) {
	global pAqBits, AqW, AqH
	starts := []
	ends := []
	if (ry < 0 or ry >= AqH)
		return 0
	roff := ry * AqW * 4
	runS := -1
	x := 0
	while (x <= AqW)
		{
		on := false
		if (x < AqW)
			{
			pv := NumGet(pAqBits + 0, roff + (x*4), "UInt")
			on := KbIsEdge(pv & 0xFF, (pv >> 8) & 0xFF, (pv >> 16) & 0xFF, kind)
			}
		if (on and runS < 0)
			runS := x
		else if (!on and runS >= 0)
			{
			if (x - runS >= minW)
				{
				starts.Push(runS)
				ends.Push(x)
				}
			runS := -1
			}
		x++
		}
	return starts.MaxIndex() ? starts.MaxIndex() : 0
}

KbBoxes(kind, ByRef bL, ByRef bR, ByRef bT, ByRef bB) {
	global pAqBits, AqW, AqH
	bL := []
	bR := []
	bT := []
	bB := []
	if (!pAqBits or AqW < 120 or AqH < 60)
		return 0
	minW := (kind = "red") ? 24 : 45
	kstep := (kind = "red") ? 3 : 8
	maxW := Round(AqW * 0.45)
	minH := 16
	maxH := 70
	cand := []
	y := 0
	while (y < AqH)
		{
		hits := 0
		roff := y * AqW * 4
		x := 0
		while (x < AqW)
			{
			pv := NumGet(pAqBits + 0, roff + (x*4), "UInt")
			if (KbIsEdge(pv & 0xFF, (pv >> 8) & 0xFF, (pv >> 16) & 0xFF, kind))
				hits++
			x += kstep
			}
		if (hits >= 5)
			cand.Push(y)
		y++
		}
	if (!cand.MaxIndex())
		return 0
	lines := []
	i := 1
	prev := -99
	while (i <= cand.MaxIndex())
		{
		if (cand[i] - prev > 2)
			lines.Push(cand[i])
		prev := cand[i]
		i++
		}
	a := 1
	while (a <= lines.MaxIndex())
		{
		ya := lines[a]
		KbRuns(ya, kind, minW, sa, ea)
		b := a + 1
		while (b <= lines.MaxIndex())
			{
			yb := lines[b]
			gap := yb - ya
			if (gap < minH)
				{
				b++
				continue
				}
			if (gap > maxH)
				break
			KbRuns(yb, kind, minW, sb, eb)
			ia := 1
			while (ia <= sa.MaxIndex())
				{
				if (ea[ia] - sa[ia] > maxW)
					{
					ia++
					continue
					}
				ib := 1
				while (ib <= sb.MaxIndex())
					{
					if (Abs(sa[ia] - sb[ib]) <= 8 and Abs(ea[ia] - eb[ib]) <= 8)
						{
						bL.Push(sa[ia])
						bR.Push(ea[ia])
						bT.Push(ya)
						bB.Push(yb)
						}
					ib++
					}
				ia++
				}
			b++
			}
		a++
		}
	return bL.MaxIndex() ? bL.MaxIndex() : 0
}

KbFind(kind, ByRef fx, ByRef fy, want := "") {
	global AqX0, AqY0
	fx := -1
	fy := -1
	if (!AqGrab())
		return false
	if (!KbBoxes(kind, gL, gR, gT, gB))
		return false
	if (!KbBoxes("red", rL, rR, rT, rB))
		return false
	i := 1
	while (i <= gL.MaxIndex())
		{
		j := 1
		while (j <= rL.MaxIndex())
			{
			if (Abs(gT[i] - rT[j]) <= 5 and Abs(gB[i] - rB[j]) <= 5)
				{
				ok := (kind = "enchant") ? (rL[j] > gR[i]) : (rR[j] < gL[i])
				if (ok)
					{
					if (want = "red")
						{
						fx := AqX0 + ((rL[j] + rR[j]) // 2)
						fy := AqY0 + ((rT[j] + rB[j]) // 2)
						}
					else
						{
						fx := AqX0 + ((gL[i] + gR[i]) // 2)
						fy := AqY0 + ((gT[i] + gB[i]) // 2)
						}
					return true
					}
				}
			j++
			}
		i++
		}
	return false
}

KbWaitFor(kind, ByRef fx, ByRef fy, ms) {
	started := A_TickCount
	Loop
		{
		if (KbFind(kind, fx, fy))
			return true
		if (A_TickCount - started >= ms)
			return false
		sleep 150
		}
}

KbKey(k) {
	if (k = "")
		return false
	SetKeyDelay, 60, 90
	Send, %k%
	SetKeyDelay, -1, -1
	sleep 200
	return true
}

KbSpot(kind, ByRef fx, ByRef fy) {
	global KeeperEnchantX, KeeperEnchantY, KeeperConfirmX, KeeperConfirmY
	if (kind = "enchant")
		{
		if (Round(KeeperEnchantX) > 0 and Round(KeeperEnchantY) > 0)
			{
			fx := Round(KeeperEnchantX)
			fy := Round(KeeperEnchantY)
			return true
			}
		}
	else if (kind = "confirm")
		{
		if (Round(KeeperConfirmX) > 0 and Round(KeeperConfirmY) > 0)
			{
			fx := Round(KeeperConfirmX)
			fy := Round(KeeperConfirmY)
			return true
			}
		}
	return false
}

KbAt(kind, ByRef fx, ByRef fy) {
	if (KbSpot(kind, fx, fy))
		return true
	return KbFind(kind, fx, fy)
}

KbGone(kind, ms) {
	started := A_TickCount
	miss := 0
	Loop
		{
		if (!KbFind(kind, gx, gy))
			{
			miss++
			if (miss >= 2)
				return true
			}
		else
			miss := 0
		if (A_TickCount - started >= ms)
			return false
		sleep 120
		}
}

KbRodOn() {
	global pAqBits, AqW, AqH, AqY0, WindowHeight
	if (!AqGrab())
		return false
	y0 := Round(WindowHeight * 0.923) - AqY0
	y1 := Round(WindowHeight * 0.942) - AqY0
	if (y0 < 0)
		y0 := 0
	if (y1 >= AqH)
		y1 := AqH - 1
	hits := 0
	y := y0
	while (y <= y1)
		{
		roff := y * AqW * 4
		x := 0
		while (x < AqW)
			{
			pv := NumGet(pAqBits + 0, roff + (x*4), "UInt")
			vb := pv & 0xFF
			vg := (pv >> 8) & 0xFF
			vr := (pv >> 16) & 0xFF
			if (vb > 200 and vr > 130 and vb - vg > 90 and vr - vg > 30)
				hits++
			x += 2
			}
		y++
		}
	return (hits >= 40)
}

KbTap(x, y) {
	MouseMove, %x%, %y%
	sleep 180
	Click, Down
	sleep 90
	Click, Up
	sleep 120
	return
}

KbTapSaved(x, y) {
	global RobloxHwnd
	VarSetCapacity(KbSpt, 8, 0)
	NumPut(x, KbSpt, 0, "Int")
	NumPut(y, KbSpt, 4, "Int")
	if (RobloxHwnd)
		DllCall("ClientToScreen", "Ptr", RobloxHwnd, "Ptr", &KbSpt)
	KbSx := NumGet(KbSpt, 0, "Int")
	KbSy := NumGet(KbSpt, 4, "Int")
	CoordMode, Mouse, Screen
	MouseMove, %KbSx%, %KbSy%
	sleep 180
	Click, Down
	sleep 90
	Click, Up
	sleep 120
	CoordMode, Mouse, Client
	return
}

;====================================================================================================;
;
;====================================================================================================;

AqRegion() {
	global hAqMemDC, hAqScreenDC, hAqBM, pAqBits, AqW, AqH, AqX0, AqY0
	global WindowWidth, WindowHeight
	nx0 := Round(WindowWidth * 0.04)
	ny0 := Round(WindowHeight * 0.33)
	nw := Round(WindowWidth * 0.92)
	nh := Round(WindowHeight * 0.65)
	if (nw < 120 or nh < 60)
		return false
	if (hAqMemDC and nw = AqW and nh = AqH and nx0 = AqX0 and ny0 = AqY0)
		return true
	if (hAqMemDC)
		{
		DllCall("DeleteObject", "Ptr", hAqBM)
		DllCall("DeleteDC", "Ptr", hAqMemDC)
		DllCall("ReleaseDC", "Ptr", 0, "Ptr", hAqScreenDC)
		hAqMemDC := 0
		}
	AqX0 := nx0
	AqY0 := ny0
	AqW := nw
	AqH := nh
	hAqScreenDC := DllCall("GetDC", "Ptr", 0, "Ptr")
	hAqMemDC := DllCall("CreateCompatibleDC", "Ptr", hAqScreenDC, "Ptr")
	VarSetCapacity(AqBMI, 40, 0)
	NumPut(40, AqBMI, 0, "UInt")
	NumPut(AqW, AqBMI, 4, "Int")
	NumPut(-AqH, AqBMI, 8, "Int")
	NumPut(1, AqBMI, 12, "UShort")
	NumPut(32, AqBMI, 14, "UShort")
	NumPut(0, AqBMI, 16, "UInt")
	hAqBM := DllCall("CreateDIBSection", "Ptr", hAqScreenDC, "Ptr", &AqBMI, "UInt", 0, "Ptr*", pAqBits, "Ptr", 0, "UInt", 0, "Ptr")
	if (!hAqBM)
		{
		hAqMemDC := 0
		return false
		}
	DllCall("SelectObject", "Ptr", hAqMemDC, "Ptr", hAqBM)
	return true
}

AqGrab() {
	global hAqMemDC, hAqScreenDC, AqW, AqH, AqX0, AqY0, RobloxHwnd
	if (!AqRegion() or !RobloxHwnd)
		return false
	RobloxClientRect(RobloxHwnd, awx, awy)
	DllCall("BitBlt", "Ptr", hAqMemDC, "Int", 0, "Int", 0, "Int", AqW, "Int", AqH
		, "Ptr", hAqScreenDC, "Int", awx + AqX0, "Int", awy + AqY0, "UInt", 0x00CC0020)
	return true
}

AqEdge(ry, x) {
	global pAqBits, AqW, AqH
	if (ry < 0 or ry >= AqH or x < 0 or x >= AqW)
		return false
	pv := NumGet(pAqBits + 0, (ry*AqW*4) + (x*4), "UInt")
	vb := pv & 0xFF
	vg := (pv >> 8) & 0xFF
	return (vg >= 240 and vb >= 100 and vb <= 160)
}

AqRowRuns(ry, minW, ByRef starts, ByRef ends) {
	global AqW
	starts := []
	ends := []
	runS := -1
	x := 0
	while (x <= AqW)
		{
		on := (x < AqW) ? AqEdge(ry, x) : false
		if (on and runS < 0)
			runS := x
		else if (!on and runS >= 0)
			{
			if (x - runS >= minW)
				{
				starts.Push(runS)
				ends.Push(x)
				}
			runS := -1
			}
		x++
		}
	return starts.MaxIndex() ? starts.MaxIndex() : 0
}

AqFindAll() {
	global pAqBits, AqW, AqH, AqX0, AqY0
	global AqBtnN, AqBtnCX, AqBtnCY, AqBtnKind, AqBtnW, AqBtnH
	AqBtnN := 0
	AqBtnCX := []
	AqBtnCY := []
	AqBtnKind := []
	AqBtnW := 0
	AqBtnH := 0
	if (!pAqBits or AqW < 120 or AqH < 60)
		return 0

	minW := 55
	maxW := Round(AqW * 0.45)
	minH := 16
	maxH := 96

	cand := []
	y := 0
	while (y < AqH)
		{
		hits := 0
		roff := y * AqW * 4
		x := 0
		while (x < AqW)
			{
			pv := NumGet(pAqBits + 0, roff + (x*4), "UInt")
			vb := pv & 0xFF
			if (vb >= 100 and vb <= 160 and ((pv >> 8) & 0xFF) >= 240)
				hits++
			x += 8
			}
		if (hits >= 6)
			cand.Push(y)
		y++
		}
	if (!cand.MaxIndex())
		return 0

	lines := []
	i := 1
	prev := -99
	while (i <= cand.MaxIndex())
		{
		if (cand[i] - prev > 2)
			lines.Push(cand[i])
		prev := cand[i]
		i++
		}

	used := {}
	a := 1
	while (a <= lines.MaxIndex())
		{
		ya := lines[a]
		AqRowRuns(ya, minW, sa, ea)
		b := a + 1
		while (b <= lines.MaxIndex())
			{
			yb := lines[b]
			gap := yb - ya
			if (gap < minH)
				{
				b++
				continue
				}
			if (gap > maxH)
				break
			AqRowRuns(yb, minW, sb, eb)
			ia := 1
			while (ia <= sa.MaxIndex())
				{
				wA := ea[ia] - sa[ia]
				if (wA > maxW)
					{
					ia++
					continue
					}
				ib := 1
				while (ib <= sb.MaxIndex())
					{
					if (Abs(sa[ia] - sb[ib]) <= 6 and Abs(ea[ia] - eb[ib]) <= 6)
						{
						key := Round((sa[ia] + ea[ia]) / 2) . "_" . ya
						if (!used.HasKey(key))
							{
							used[key] := 1
							AqAddBtn(sa[ia], ea[ia], ya, yb)
							}
						}
					ib++
					}
				ia++
				}
			b++
			}
		a++
		}
	AqSortBtns()
	return AqBtnN
}

AqRemember() {
	global AqBtnN, AqBtnCX, AqBtnCY, AqHoverX, AqHoverY, AqHoverOk
	if (AqBtnN >= 1)
		{
		AqHoverX := AqBtnCX[1]
		AqHoverY := AqBtnCY[1]
		AqHoverOk := true
		}
}

AqShiftBetween(ox, on, nx, nn, pitch) {
	if (on < 1 or nn < 1 or pitch < 20)
		return 0
	lo := 3
	hi := Round(pitch * 0.92)
	ds := []
	i := 1
	while (i <= on)
		{
		j := 1
		while (j <= nn)
			{
			d := ox[i] - nx[j]
			if (d >= lo and d <= hi)
				ds.Push(d)
			j++
			}
		i++
		}
	n := ds.MaxIndex()
	if (!n)
		return pitch // 4
	i := 2
	while (i <= n)
		{
		v := ds[i]
		j := i - 1
		while (j >= 1 and ds[j] > v)
			{
			ds[j+1] := ds[j]
			j--
			}
		ds[j+1] := v
		i++
		}
	return ds[(n // 2) + 1]
}

AqAddBtn(s, e, ya, yb) {
	global pAqBits, AqW, AqX0, AqY0
	global AqBtnN, AqBtnCX, AqBtnCY, AqBtnKind, AqBtnW, AqBtnH
	sg := 0
	sn := 0
	x := s
	while (x < e)
		{
		pv := NumGet(pAqBits + 0, (ya*AqW*4) + (x*4), "UInt")
		vb := pv & 0xFF
		vg := (pv >> 8) & 0xFF
		vr := (pv >> 16) & 0xFF
		if (vg >= 240 and vb >= 100 and vb <= 160)
			{
			sg := sg + (vg - vr)
			sn++
			}
		x++
		}
	if (sn < 12)
		return
	gr := sg // sn
	AqBtnN++
	AqBtnCX.Push(AqX0 + ((s + e) // 2))
	AqBtnCY.Push(AqY0 + ((ya + yb) // 2))
	AqBtnKind.Push((gr > 60) ? "buy" : "use")
	if (e - s > AqBtnW)
		AqBtnW := e - s
	if (yb - ya > AqBtnH)
		AqBtnH := yb - ya
}

AqSortBtns() {
	global AqBtnN, AqBtnCX, AqBtnCY, AqBtnKind
	i := 2
	while (i <= AqBtnN)
		{
		j := i
		while (j > 1 and AqBtnCX[j-1] > AqBtnCX[j])
			{
			t := AqBtnCX[j-1]
			AqBtnCX[j-1] := AqBtnCX[j]
			AqBtnCX[j] := t
			t := AqBtnCY[j-1]
			AqBtnCY[j-1] := AqBtnCY[j]
			AqBtnCY[j] := t
			t := AqBtnKind[j-1]
			AqBtnKind[j-1] := AqBtnKind[j]
			AqBtnKind[j] := t
			j--
			}
		i++
		}
}

AqScan() {
	global AqBtnN
	if (!AqGrab())
		return 0
	AqFindAll()
	AqRemember()
	return AqBtnN
}

AqPanelOpen() {
	return (AqScan() > 0)
}

AqPanelSure() {
	tries := 0
	while (tries < 3)
		{
		tries++
		if (AqScan() > 0)
			return true
		sleep 150
		}
	return false
}

AqWheel(n, dir) {
	global AqBtnN, AqHoverX, AqHoverY, AqHoverOk
	if (AqBtnN < 1 and !AqHoverOk)
		{
		if (AqScan() < 1)
			return false
		}
	if (!AqHoverOk)
		return false
	hx := AqHoverX
	hy := AqHoverY
	MouseMove, hx, hy
	sleep 60
	Loop, %n%
		{
		if (dir > 0)
			Click, WheelDown
		else
			Click, WheelUp
		sleep 30
		}
	sleep 130
	return true
}

AqRecoverRow() {
	global WindowWidth, WindowHeight, AqHoverX, AqHoverY, AqHoverOk
	AqHoverX := Round(WindowWidth * 0.50)
	AqHoverY := Round(WindowHeight * 0.62)
	AqHoverOk := true
	spent := 0
	Loop, 6
		{
		if (!AqWheel(5, -1))
			break
		spent := spent + 5
		if (AqScan() >= 1)
			return true
		}
	if (spent > 0)
		AqWheel(spent, 1)
	AqHoverOk := false
	return false
}

AqWaitPanel(want) {
	global AquariumOpenDelay
	started := A_TickCount
	cap := AquariumOpenDelay + 3000
	Loop
		{
		sleep 150
		now := (AqScan() > 0) ? 1 : 0
		if (now = want)
			return true
		if (A_TickCount - started >= cap)
			return false
		}
}

AqTap(x, y) {
	MouseMove, %x%, %y%
	sleep 55
	Click
	return
}

AqLeftX() {
	global AqBtnN, AqBtnCX
	return (AqBtnN >= 1) ? AqBtnCX[1] : -99999
}

AqScrollHome() {
	global AquariumScrollSteps, AqBtnN
	tries := 0
	same := 0
	last := -99999
	while (tries < 20)
		{
		tries++
		if (!AqWheel(AquariumScrollSteps, -1))
			return false
		AqScan()
		cur := AqLeftX()
		if (AqBtnN >= 1 and cur = last)
			{
			same++
			if (same >= 1)
				return true
			}
		else
			same := 0
		last := cur
		}
	return true
}

AqMeasurePitch() {
	global AqBtnN, AqBtnCX, AqCardPitch, AqBtnW
	AqCardPitch := 0
	if (AqScan() < 1)
		return false
	if (AqBtnN >= 2)
		{
		best := 0
		i := 2
		while (i <= AqBtnN)
			{
			d := AqBtnCX[i] - AqBtnCX[i-1]
			if (d > best)
				best := d
			i++
			}
		AqCardPitch := best
		}
	if (AqCardPitch < 20)
		AqCardPitch := Round(AqBtnW * 1.15)
	return (AqCardPitch >= 20)
}

NoiseIsCore(pv, cB, cG, cR, ctol) {
	vb := pv & 0xFF
	vg := (pv >> 8) & 0xFF
	vr := (pv >> 16) & 0xFF
	if (Abs(vb - cB) <= ctol and Abs(vg - cG) <= ctol and Abs(vr - cR) <= ctol)
		return true
	if (vg < 34 or vg > 104)
		return false
	if (vr > 52 or vb > 76)
		return false
	if (vg < vr + 10 or vg < vb + 4)
		return false
	vl := (vr + vg + vb) // 3
	if (vl < 14 or vl > 74)
		return false
	return true
}

NoiseWarnKind() {
	global pNoteBits, NoteW, NoteH, FishBarLeft, NoteTop, WindowWidth, WindowHeight
	global NoiseWBase, NoiseWBN, NoiseWGR, NoiseWDK, NoiseWML, NoiseWNow, NoiseWBlk
	global NoiseWD6, NoiseD6Ring, NoiseWBaseML, NoiseWDthr
	global NoiseDkRing, NoiseDkIdx, NoiseDkN, NoiseWGT, QpcFreq, NoiseMlRing
	global WRBuf, pWRing, WRIdx, WRN, WRW, WRH, WRFS, WRx0, WRy0, WRSkip
	NoiseWBN := 0
	NoiseWGR := 0
	NoiseWDK := 0
	NoiseWD6 := 0
	NoiseWML := -1
	if (!pNoteBits or NoteH < 80 or NoteW < 100)
		return ""
	wcx := Round((WindowWidth * 0.500) - FishBarLeft)
	wcy := Round((WindowHeight * 0.5194) - NoteTop)
	whw := Round(WindowWidth * 0.082)
	wskip := Round(WindowWidth * 0.023)
	whh := Round(WindowHeight * 0.052)
	wx0 := wcx - whw
	wx1 := wcx + whw
	wy0 := wcy - whh
	wy1 := wcy + whh
	if (wx0 < 0)
		wx0 := 0
	if (wy0 < 0)
		wy0 := 0
	if (wx1 > NoteW - 1)
		wx1 := NoteW - 1
	if (wy1 > NoteH - 1)
		wy1 := NoteH - 1
	if (wx1 - wx0 < 24 or wy1 - wy0 < 24)
		return ""
	dthr := 6
	if (NoiseWBaseML >= 200)
		{
		dthr := Round((NoiseWBaseML * 45) / 10000)
		if (dthr < 6)
			dthr := 6
		if (dthr > 60)
			dthr := 60
		}
	NoiseWDthr := dthr
	wn := 0
	wbn := 0
	wgr := 0
	wdk := 0
	wd6 := 0
	wls := 0
	wy := wy0
	while (wy <= wy1)
		{
		wx := wx0
		while (wx <= wx1)
			{
			if (Abs(wx - wcx) <= wskip)
				{
				wx := wx + 9
				continue
				}
			v := NumGet(pNoteBits + 0, (wy*NoteW + wx)*4, "UInt")
			vb := v & 0xFF
			vg := (v >> 8) & 0xFF
			vr := (v >> 16) & 0xFF
			vl := (vr + vg + vb) // 3
			wn := wn + 1
			wls := wls + vl
			if (vl < 28)
				wdk := wdk + 1
			if (vl < dthr)
				wd6 := wd6 + 1
			if (vl > 120 and Abs(vr - vg) < 40 and Abs(vg - vb) < 40)
				wbn := wbn + 1
			else if (vg > vr + 40 and vg > vb + 30 and vg > 90)
				wgr := wgr + 1
			wx := wx + 9
			}
		wy := wy + 9
		}
	if (wn < 30)
		return ""
	if (WRW != (wx1 - wx0 + 1) or WRH != (wy1 - wy0 + 1))
		{
		WRW := wx1 - wx0 + 1
		WRH := wy1 - wy0 + 1
		WRFS := WRW * WRH * 4
		VarSetCapacity(WRBuf, WRFS * 48, 0)
		pWRing := &WRBuf
		WRIdx := 0
		WRN := 0
		}
	WRx0 := wx0
	WRy0 := wy0
	wrRow := 0
	while (wrRow < WRH)
		{
		DllCall("RtlMoveMemory", "Ptr", pWRing + (WRIdx * WRFS) + (wrRow * WRW * 4)
			, "Ptr", pNoteBits + (((wy0 + wrRow) * NoteW + wx0) * 4), "Ptr", WRW * 4)
		wrRow := wrRow + 1
		}
	WRSkip := WRSkip + 1
	if (WRSkip >= 3)
		{
		WRSkip := 0
		WRIdx := Mod(WRIdx + 1, 48)
		if (WRN < 48)
			WRN := WRN + 1
		}
	NoiseWBN := (wbn * 100) // wn
	NoiseWGR := (wgr * 100) // wn
	NoiseWDK := (wdk * 100) // wn
	NoiseWD6 := (wd6 * 100) // wn
	NoiseWML := (wls * 100) // wn
	if (NoiseWBN > 35)
		{
		NoiseWNow := "WHITE"
		DllCall("QueryPerformanceCounter", "Int64*", NoiseWGT)
		return "WHITE"
		}
	if (NoiseWGR > 35)
		{
		NoiseWNow := "GREEN"
		DllCall("QueryPerformanceCounter", "Int64*", NoiseWGT)
		return "GREEN"
		}
	NoiseDkRing[NoiseDkIdx] := NoiseWDK
	NoiseMlRing[NoiseDkIdx] := NoiseWML
	NoiseD6Ring[NoiseDkIdx] := NoiseWD6
	NoiseDkIdx := Mod(NoiseDkIdx + 1, 32)
	if (NoiseDkN < 32)
		NoiseDkN := NoiseDkN + 1
	pastMin := 999
	pastMaxL := -1
	if (NoiseDkN >= 12)
		{
		kk := 3
		while (kk <= 9)
			{
			pri := Mod(NoiseDkIdx - kk + 64, 32)
			pv := NoiseD6Ring[pri]
			if (pv >= 0 and pv < pastMin)
				pastMin := pv
			pm := NoiseMlRing[pri]
			if (pm > pastMaxL)
				pastMaxL := pm
			kk := kk + 1
			}
		}
	gapT := 9.0
	if (NoiseWGT > 0)
		{
		DllCall("QueryPerformanceCounter", "Int64*", bnow)
		gapT := (bnow - NoiseWGT) / QpcFreq
		}
	blkHit := false
	if (pastMin < 999 and pastMaxL > 0)
		{
		if ((NoiseWML * 100) <= (pastMaxL * 70) and (NoiseWD6 - pastMin) >= 8)
			blkHit := true
		}
	if (gapT >= 1.60 and blkHit)
		{
		NoiseWNow := "BLACK"
		NoiseWBlk := NoiseWBlk + 1
		return "BLACK"
		}
	NoiseWNow := ""
	if (NoiseWBase < 1)
		NoiseWBase := NoiseWDK
	else
		NoiseWBase := ((NoiseWBase * 24) + NoiseWDK) // 25
	if (NoiseWBaseML < 1)
		NoiseWBaseML := NoiseWML
	else
		NoiseWBaseML := ((NoiseWBaseML * 24) + NoiseWML) // 25
	return ""
}

NoiseZoneScanAll() {
	global pCaptureBits, CaptureW, CaptureH, FishBarLeft
	global NoiseZBD, NoiseZBB, NoiseZBL, NoiseZBG
	global NoiseZWx, NoiseZGx, NoiseZKx
	NoiseZWx := -1
	NoiseZGx := -1
	NoiseZKx := -1
	NoiseZBD := 0
	NoiseZBB := 0
	NoiseZBL := 0
	NoiseZBG := 0
	if (!pCaptureBits or CaptureW < 200 or CaptureH < 14)
		return false
	zw := Round(CaptureW * 0.12)
	if (zw < 24)
		return false
	cL := []
	cG := []
	cD := []
	cB := []
	zx := 0
	while (zx < CaptureW)
		{
		cL[zx] := 0
		cG[zx] := 0
		cD[zx] := 0
		cB[zx] := 0
		zx := zx + 1
		}
	nrow := 0
	zy := 3
	while (zy < CaptureH - 3)
		{
		nrow := nrow + 1
		pl := -1
		zx := 0
		while (zx < CaptureW)
			{
			v := NumGet(pCaptureBits + 0, (zy*CaptureW + zx)*4, "UInt")
			zb := v & 0xFF
			zg := (v >> 8) & 0xFF
			zr := (v >> 16) & 0xFF
			zl := (zr + zg + zb) // 3
			zm := (zr > zb) ? zr : zb
			cL[zx] := cL[zx] + zl
			cG[zx] := cG[zx] + (zg - zm)
			if (zl > 140)
				cB[zx] := cB[zx] + 1
			if (pl >= 0)
				{
				dd := zl - pl
				if (dd < 0)
					dd := 0 - dd
				cD[zx] := cD[zx] + dd
				}
			pl := zl
			zx := zx + 1
			}
		zy := zy + 5
		}
	if (nrow < 3)
		return false
	rWA := -1
	rWN := 0
	bWA := -1
	bWN := 0
	rGA := -1
	rGN := 0
	bGA := -1
	bGN := 0
	rKA := -1
	rKN := 0
	bKA := -1
	bKN := 0
	qL := [0]
	qG := [0]
	qD := [0]
	qB := [0]
	qL[0] := 0
	qG[0] := 0
	qD[0] := 0
	qB[0] := 0
	zx := 0
	while (zx < CaptureW)
		{
		qL[zx + 1] := qL[zx] + cL[zx]
		qG[zx + 1] := qG[zx] + cG[zx]
		qD[zx + 1] := qD[zx] + cD[zx]
		qB[zx + 1] := qB[zx] + cB[zx]
		zx := zx + 1
		}
	a := 0
	while (a + zw <= CaptureW)
		{
		sL := qL[a + zw] - qL[a]
		sG := qG[a + zw] - qG[a]
		sD := qD[a + zw] - qD[a]
		sB := qB[a + zw] - qB[a]
		tot := zw * nrow
		mL := sL // tot
		mG := sG // tot
		mD := sD // tot
		mB := (sB * 100) // tot
		if (mD > NoiseZBD)
			{
			NoiseZBD := mD
			NoiseZBL := mL
			NoiseZBG := mG
			}
		if (mL < 60 and mB > NoiseZBB)
			NoiseZBB := mB
		isW := (mD >= 8 and mL > 110 and mG < 45)
		isG := (mD >= 8 and mL > 40 and mL < 115 and mG > 45)
		isK := (mL < 60 and mB >= 3 and mD >= 2 and !isW and !isG)
		if (isW)
			{
			if (rWA < 0)
				rWA := a
			rWN := rWN + 1
			if (rWN > bWN)
				{
				bWN := rWN
				bWA := rWA
				}
			}
		else
			{
			rWA := -1
			rWN := 0
			}
		if (isG)
			{
			if (rGA < 0)
				rGA := a
			rGN := rGN + 1
			if (rGN > bGN)
				{
				bGN := rGN
				bGA := rGA
				}
			}
		else
			{
			rGA := -1
			rGN := 0
			}
		if (isK)
			{
			if (rKA < 0)
				rKA := a
			rKN := rKN + 1
			if (rKN > bKN)
				{
				bKN := rKN
				bKA := rKA
				}
			}
		else
			{
			rKA := -1
			rKN := 0
			}
		a := a + 16
		}
	if (bWN > 0)
		NoiseZWx := Round(FishBarLeft + bWA + (((bWN - 1) * 16) // 2) + (zw // 2))
	if (bGN > 0)
		NoiseZGx := Round(FishBarLeft + bGA + (((bGN - 1) * 16) // 2) + (zw // 2))
	if (bKN > 0)
		NoiseZKx := Round(FishBarLeft + bKA + (((bKN - 1) * 16) // 2) + (zw // 2))
	if (NoiseZKx >= 0 and NoiseZWx >= 0 and Abs(NoiseZKx - NoiseZWx) < zw)
		NoiseZKx := -1
	if (NoiseZKx >= 0 and NoiseZGx >= 0 and Abs(NoiseZKx - NoiseZGx) < zw)
		NoiseZKx := -1
	if (NoiseZWx >= 0 and NoiseZGx >= 0 and Abs(NoiseZWx - NoiseZGx) < zw)
		{
		if (bWN >= bGN)
			NoiseZGx := -1
		else
			NoiseZWx := -1
		}
	return (NoiseZWx >= 0 and NoiseZGx >= 0 and NoiseZKx >= 0)
}


HalibutCircleX() {
	global QpcFreq, HaliLastX, HaliLastT
	DllCall("QueryPerformanceCounter", "Int64*", hnow)
	hx := HalibutFindCircle()
	if (hx >= 0)
		{
		HaliLastX := hx
		HaliLastT := hnow
		return hx
		}
	if (HaliLastT and ((hnow - HaliLastT) / QpcFreq) < 0.15)
		return HaliLastX
	HaliLastT := 0
	return -1
}

HalibutBlue(px) {
	b := px & 0xFF, g := (px >> 8) & 0xFF, r := (px >> 16) & 0xFF
	return (b >= 90 and b - r >= 45 and b - g >= 45 and r <= 90 and g <= 90)
}

HalibutFindCircle() {
	global pNoteBits, NoteW, NoteH, FishBarLeft, WindowHeight
	if (!pNoteBits or NoteH < 20 or NoteW < 20)
		return -1
	D := WindowHeight * 0.040
	gapMax := Round(D * 0.3)
	for ri, fr in [0.55, 0.45, 0.65]
		{
		p := pNoteBits + (Round(NoteH * fr) * NoteW * 4)
		runS := -1
		runE := -1
		x := 0
		while (x < NoteW + gapMax + 2)
			{
			if (x < NoteW and HalibutBlue(NumGet(p + 0, x * 4, "UInt")))
				{
				if (runS < 0)
					runS := x
				runE := x
				}
			else if (runS >= 0 and (x - runE > gapMax))
				{
				w := runE - runS + 1
				if (w >= D * 0.35 and w <= D * 1.5)
					{
					cx := HalibutVerify(runS, runE, D)
					if (cx >= 0)
						return FishBarLeft + cx
					}
				runS := -1
				}
			x += 2
			}
		}
	return -1
}

HalibutVerify(s, e, D) {
	global pNoteBits, NoteW, NoteH
	x0 := s - Round(D * 0.3)
	x1 := e + Round(D * 0.3)
	if (x0 < 0)
		x0 := 0
	if (x1 > NoteW - 1)
		x1 := NoteW - 1
	n := 0, minX := 99999, maxX := -1, minY := 99999, maxY := -1
	y := 0
	while (y < NoteH)
		{
		p := pNoteBits + (y * NoteW * 4)
		x := x0
		while (x <= x1)
			{
			if (HalibutBlue(NumGet(p + 0, x * 4, "UInt")))
				{
				n++
				if (x < minX)
					minX := x
				if (x > maxX)
					maxX := x
				if (y < minY)
					minY := y
				maxY := y
				}
			x += 2
			}
		y += 2
		}
	if (n < 4)
		return -1
	w := maxX - minX + 2
	h := maxY - minY + 2
	if (w < D * 0.45 or w > D * 1.4 or h < D * 0.45 or h > D * 1.4)
		return -1
	if (Abs(w - h) > 0.3 * ((w > h) ? w : h))
		return -1
	if ((n * 4) / (0.7854 * w * h) < 0.6)
		return -1
	cy := (minY + maxY) / 2
	if (cy < NoteH * 0.3 or cy > NoteH * 0.8 or maxY >= NoteH - 3)
		return -1
	return (minX + maxX) / 2
}

NoiseGimmickTarget() {
	global QpcFreq, NoiseZoneTgt, NoiseZoneT, NoiseZoneKind
	global NoiseZScanT, NoiseZWx, NoiseZGx, NoiseZKx, NoiseZOK, NoiseZFreshT
	global NoisePendKind, NoisePendT, NoiseZPrevOK, NoiseOnZoneN
	DllCall("QueryPerformanceCounter", "Int64*", gnow)
	gk := NoiseWarnKind()
	seq := (NoisePendT > 0 and ((gnow - NoisePendT) / QpcFreq) < 2.0)
	if (gk != "")
		{
		if (gk != "BLACK")
			{
			NoisePendKind := gk
			NoisePendT := gnow
			}
		else if (NoisePendKind = "" or NoisePendKind = "BLACK" or !seq)
			{
			NoisePendKind := "BLACK"
			NoisePendT := gnow
			}
		}
	pend := (NoisePendT > 0 and ((gnow - NoisePendT) / QpcFreq) < 2.20)
	gint := 1.00
	if (pend or NoiseZoneTgt >= 0)
		gint := 0.15
	zlock := (NoiseZFreshT > 0 and ((gnow - NoiseZFreshT) / QpcFreq) < 0.60)
	if (NoiseZScanT < 1 or ((gnow - NoiseZScanT) / QpcFreq) >= gint)
		{
		NoiseZScanT := gnow
		zpW := NoiseZWx
		zpG := NoiseZGx
		zpK := NoiseZKx
		if (NoiseZoneScanAll())
			{
			NoiseZFreshT := gnow
			if (zlock)
				{
				NoiseZWx := zpW
				NoiseZGx := zpG
				NoiseZKx := zpK
				}
			}
		else
			{
			NoiseZWx := zpW
			NoiseZGx := zpG
			NoiseZKx := zpK
			}
		}
	NoiseZPrevOK := NoiseZOK
	NoiseZOK := (NoiseZFreshT > 0 and ((gnow - NoiseZFreshT) / QpcFreq) < 0.60)
	if (NoiseZoneTgt >= 0)
		{
		zage := (gnow - NoiseZoneT) / QpcFreq
		zgap := (NoiseZFreshT > 0) ? ((gnow - NoiseZFreshT) / QpcFreq) : 99
		if (zage < 1.85 and zgap < 1.00)
			return NoiseZoneTgt
		if (zage < 4.00 and NoiseZOK)
			return NoiseZoneTgt
		NoiseZoneTgt := -1
		NoiseZoneKind := ""
		NoisePendKind := ""
		NoisePendT := 0
		}
	if (!pend)
		{
		return -1
		}
	if (!NoiseZOK)
		{
		return -1
		}
	gz := -1
	if (NoisePendKind = "WHITE")
		gz := NoiseZWx
	else if (NoisePendKind = "GREEN")
		gz := NoiseZGx
	else if (NoisePendKind = "BLACK")
		gz := NoiseZKx
	if (gz < 0)
		return -1
	NoiseZoneTgt := gz
	NoiseZoneT := gnow
	NoiseZoneKind := NoisePendKind
	NoisePendT := 0
	return gz
}
NoteTarget() {
	global SpecialRod, RunLeft, RunWidth, NoteDbgRod
	NoteDbgRod := NoteDbgRod + 1
	if (SpecialRod = "Noiseform")
		return NoiseGimmickTarget()
	if (SpecialRod = "Halibut Harpoon")
		return HalibutCircleX()
	if (SpecialRod != "Pinions Aria")
		return -1
	ref := (RunWidth > 0) ? RunLeft + (RunWidth / 2) : -1
	return NoteScan(ref)
}

FindBarRelative() {
	global pCaptureBits, CaptureW, CaptureH, FishBarLeft, BarScanRow
	global RunLeft, RunWidth, RelBarL, RelBarR, RelBarRow
	row := BarScanRow
	if (row < 0 or row >= CaptureH)
		row := CaptureH // 2
	rowOff := row * CaptureW * 4
	sum := 0
	mx := 0
	x := 0
	while (x < CaptureW)
		{
		px := NumGet(pCaptureBits + 0, rowOff + (x*4), "UInt")
		l := ((px & 0xFF) + ((px >> 8) & 0xFF) + ((px >> 16) & 0xFF)) // 3
		sum += l
		if (l > mx)
			mx := l
		x++
		}
	avg := sum // CaptureW
	thr := (mx - avg) * 35 // 100
	if (thr < 30)
		thr := 30
	thr += avg
	if (mx < thr)
		return false
	bestW := 0
	bestS := -1
	bestE := -1
	runS := -1
	runE := -1
	gap := 0
	x := 0
	while (x < CaptureW)
		{
		px := NumGet(pCaptureBits + 0, rowOff + (x*4), "UInt")
		l := ((px & 0xFF) + ((px >> 8) & 0xFF) + ((px >> 16) & 0xFF)) // 3
		if (l >= thr)
			{
			if (runS < 0)
				runS := x
			runE := x
			gap := 0
			}
		else if (runS >= 0)
			{
			gap++
			if (gap > 4)
				{
				if (runE - runS + 1 > bestW)
					{
					bestW := runE - runS + 1
					bestS := runS
					bestE := runE
					}
				runS := -1
				gap := 0
				}
			}
		x++
		}
	if (runS >= 0 and runE - runS + 1 > bestW)
		{
		bestW := runE - runS + 1
		bestS := runS
		bestE := runE
		}
	if (bestW < 8 or bestW > CaptureW * 0.6)
		return false
	RunLeft := FishBarLeft + bestS
	RunWidth := bestW
	RelBarL := bestS
	RelBarR := bestE
	RelBarRow := row
	return true
}

FindFishRelative() {
	global pCaptureBits, CaptureW, FishBarLeft, RelBarL, RelBarR, RelBarRow, LastFishX
	if (RelBarR - RelBarL < 20)
		return -1
	rowOff := RelBarRow * CaptureW * 4
	sumB := 0
	sumG := 0
	sumR := 0
	n := 0
	x := RelBarL
	while (x <= RelBarR)
		{
		px := NumGet(pCaptureBits + 0, rowOff + (x*4), "UInt")
		sumB += px & 0xFF
		sumG += (px >> 8) & 0xFF
		sumR += (px >> 16) & 0xFF
		n++
		x++
		}
	mB := sumB // n
	mG := sumG // n
	mR := sumR // n
	madSum := 0
	x := RelBarL
	while (x <= RelBarR)
		{
		px := NumGet(pCaptureBits + 0, rowOff + (x*4), "UInt")
		madSum += Abs((px & 0xFF) - mB) + Abs(((px >> 8) & 0xFF) - mG) + Abs(((px >> 16) & 0xFF) - mR)
		x++
		}
	thr := (madSum // n) * 3
	if (thr < 16)
		thr := 16
	bestScore := 0
	bestS := -1
	bestE := -1
	runS := -1
	runE := -1
	runSum := 0
	x := RelBarL
	while (x <= RelBarR)
		{
		px := NumGet(pCaptureBits + 0, rowOff + (x*4), "UInt")
		d := Abs((px & 0xFF) - mB) + Abs(((px >> 8) & 0xFF) - mG) + Abs(((px >> 16) & 0xFF) - mR)
		if (d >= thr)
			{
			if (runS < 0)
				{
				runS := x
				runSum := 0
				}
			runE := x
			runSum += d
			}
		else if (runS >= 0)
			{
			if (runE - runS + 1 <= 25 and runSum > bestScore)
				{
				bestScore := runSum
				bestS := runS
				bestE := runE
				}
			runS := -1
			}
		x++
		}
	if (runS >= 0 and runE - runS + 1 <= 25 and runSum > bestScore)
		{
		bestScore := runSum
		bestS := runS
		bestE := runE
		}
	if (bestS < 0)
		return -1
	fx := FishBarLeft + ((bestS + bestE) / 2)
	LastFishX := fx
	return fx
}

BarWPush(w) {
	global BarWRing, BarWMed
	if (!IsObject(BarWRing))
		BarWRing := []
	BarWRing.Push(w)
	if (BarWRing.MaxIndex() > 5)
		BarWRing.RemoveAt(1)
	n := BarWRing.MaxIndex()
	srt := []
	Loop, %n%
		srt.Push(BarWRing[A_Index])
	i := 2
	while (i <= n)
		{
		v := srt[i]
		j := i - 1
		while (j >= 1 and srt[j] > v)
			{
			srt[j+1] := srt[j]
			j--
			}
		srt[j+1] := v
		i++
		}
	BarWMed := srt[(n // 2) + 1]
}

BarPresent() {
	global BarLeftColor, BarRightColor, BarScanRow, RelLock, SpecialRod, PinFishX
	global ControlMode, LineBarL, LineBarW, RunLeft, RunWidth, LineFishSeen, NoiseBarL, NoiseBarW
	global BarWidthTrusted, CastBarL, CastBarW, RemBarL, RemBarW, MiguBarL, MiguBarW, HaliBarL, HaliBarW
	BarWidthTrusted := true
	if (SpecialRod = "Castbound")
		{
		if (CastboundScan())
			{
			RunLeft := CastBarL
			RunWidth := CastBarW
			return true
			}
		return false
		}
	if (SpecialRod = "Noiseform")
		{
		if (NoiseScan())
			{
			RunLeft := NoiseBarL
			RunWidth := NoiseBarW
			return true
			}
		return false
		}
	if (SpecialRod = "Remembrance")
		{
		if (RemBarScan())
			{
			RunLeft := RemBarL
			RunWidth := RemBarW
			return true
			}
		return false
		}
	if (SpecialRod = "MiguRod")
		{
		if (MiguBarScan())
			{
			RunLeft := MiguBarL
			RunWidth := MiguBarW
			return true
			}
		return false
		}
	if (SpecialRod = "Halibut Harpoon")
		{
		if (HalibutBarScan())
			{
			RunLeft := HaliBarL
			RunWidth := HaliBarW
			return true
			}
		return false
		}
	if (ControlMode = "Lines")
		{
		if (LineScan())
			{
			RunLeft := LineBarL
			RunWidth := LineBarW
			return true
			}
		if (LineFishSeen and LineBarW >= 1)
			{
			RunLeft := LineBarL
			RunWidth := LineBarW
			return true
			}
		return false
		}
	if (SpecialRod = "Pinions Aria")
		{
		PinionScan()
		if (LineScan())
			{
			RunLeft := LineBarL
			RunWidth := LineBarW
			return true
			}
		if (LineFishSeen and LineBarW >= 1)
			{
			RunLeft := LineBarL
			RunWidth := LineBarW
			return true
			}
		return false
		}
	if (BarLeftColor != "" and BarRightColor != "" and RelLock != 1)
		{
		if (FindBarByColor())
			{
			RelLock := 2
			return true
			}
		if (RelLock = 2)
			return false
		}
	if (RelLock != 2)
		{
		ok := FindBarRelative()
		if (ok and RelLock = 0 and FindFishRelative() >= 0)
			RelLock := 1
		if (RelLock = 1)
			return ok
		}
	BarWidthTrusted := false
	if (ScanRowBar(BarScanRow, 6))
		return true
	return CalibrateBarRow(6)
}

FindArrowX() {
	global ArrowColor, ArrowColorTolerance, CaptureW, CaptureH, BarScanRow
	if (ArrowColor = "")
		return -1
	tol := ArrowColorTolerance
	if (tol < 8)
		tol := 8
	aList := ColorListParse(ArrowColor)
	if (aList.n < 1)
		return -1
	row := BarScanRow
	if (row < 0 or row >= CaptureH)
		row := CaptureH // 2
	ax := ColorListCenterX(aList, tol, row, 0, CaptureW - 1)
	if (ax >= 0)
		return ax
	Loop, 5
		{
		y2 := Floor(CaptureH * (A_Index*2 - 1) / 10)
		ax := ColorListCenterX(aList, tol, y2, 0, CaptureW - 1)
		if (ax >= 0)
			return ax
		}
	return -1
}

FishLineVisible() {
	global pCaptureBits, CaptureW, CaptureH, FishColor, FishBarColorTolerance, BarScanRow
	global ControlMode, LineFishSeen, SpecialRod, CastFishX, RemWhiteX, MiguFishX, HaliFishX
	if (SpecialRod = "Castbound")
		{
		CastboundScan()
		return (CastFishX >= 0)
		}
	if (SpecialRod = "Halibut Harpoon")
		return (HalibutBarScan() and HaliFishX >= 0)
	if (SpecialRod = "Remembrance")
		{
		RemembranceScan()
		return (RemWhiteX >= 0)
		}
	if (SpecialRod = "MiguRod")
		{
		MiguScan()
		return (MiguFishX >= 0 and BarPresent())
		}
	if (ControlMode = "Lines")
		{
		LineScan()
		return LineFishSeen
		}
	fList := ColorListParse(FishColor)
	if (fList.n < 1)
		return false
	tol := FishBarColorTolerance
	row := BarScanRow
	if (row < 0 or row >= CaptureH)
		row := CaptureH // 2
	rowOffset := row * CaptureW * 4
	x := 0
	while (x < CaptureW)
		{
		if (ColorListHitPx(fList, NumGet(pCaptureBits + 0, rowOffset + (x*4), "UInt"), tol))
			{
			runStart := x
			while (x < CaptureW)
				{
				if (!ColorListHitPx(fList, NumGet(pCaptureBits + 0, rowOffset + (x*4), "UInt"), tol))
					break
				x++
				}
			runLen := x - runStart
			if (runLen > 25)
				continue
			cx := runStart + (runLen // 2)
			hits := 0
			Loop, 7
				{
				y2 := Floor(CaptureH * (A_Index*2 - 1) / 14)
				if (y2 >= CaptureH)
					y2 := CaptureH - 1
				if (ColorListHitPx(fList, NumGet(pCaptureBits + 0, (y2*CaptureW*4) + (cx*4), "UInt"), tol))
					hits++
				}
			if (hits >= 5)
				return true
			continue
			}
		x++
		}
	return false
}

MedianOf(arr) {
	n := arr.MaxIndex()
	if (!n)
		return 0
	vals := []
	for i, v in arr
		vals.Push(v)
	i := 2
	while (i <= n)
		{
		key := vals[i]
		j := i - 1
		while (j >= 1 and vals[j] > key)
			{
			vals[j+1] := vals[j]
			j--
			}
		vals[j+1] := key
		i++
		}
	mid := (n // 2) + 1
	if (Mod(n, 2) = 0)
		return (vals[n//2] + vals[(n//2)+1]) / 2
	return vals[mid]
}

; ---- Single-row bounded scans -------------------------------------------------------------

ScanRowFirst(targetBGR, tol, y, xFrom, xTo) {
	global pCaptureBits, CaptureW, CaptureH, FishBarLeft
	if (y < 0 or y >= CaptureH)
		return -1
	if (xFrom < 0)
		xFrom := 0
	if (xTo > CaptureW - 1)
		xTo := CaptureW - 1
	tB := (targetBGR >> 16) & 0xFF
	tG := (targetBGR >> 8) & 0xFF
	tR := targetBGR & 0xFF
	rowOffset := y * CaptureW * 4
	x := xFrom
	while (x <= xTo)
		{
		px := NumGet(pCaptureBits + 0, rowOffset + (x*4), "UInt")
		if (Abs((px & 0xFF) - tB) <= tol and Abs(((px >> 8) & 0xFF) - tG) <= tol and Abs(((px >> 16) & 0xFF) - tR) <= tol)
			return FishBarLeft + x
		x++
		}
	return -1
}

ScanRowLast(targetBGR, tol, y, xFrom, xTo) {
	global pCaptureBits, CaptureW, CaptureH, FishBarLeft
	if (y < 0 or y >= CaptureH)
		return -1
	if (xFrom < 0)
		xFrom := 0
	if (xTo > CaptureW - 1)
		xTo := CaptureW - 1
	tB := (targetBGR >> 16) & 0xFF
	tG := (targetBGR >> 8) & 0xFF
	tR := targetBGR & 0xFF
	rowOffset := y * CaptureW * 4
	x := xTo
	while (x >= xFrom)
		{
		px := NumGet(pCaptureBits + 0, rowOffset + (x*4), "UInt")
		if (Abs((px & 0xFF) - tB) <= tol and Abs(((px >> 8) & 0xFF) - tG) <= tol and Abs(((px >> 16) & 0xFF) - tR) <= tol)
			return FishBarLeft + x
		x--
		}
	return -1
}

ScanRowCenter(targetBGR, tol, y, xFrom, xTo) {
	global pCaptureBits, CaptureW, CaptureH, FishBarLeft
	if (y < 0 or y >= CaptureH)
		return -1
	if (xFrom < 0)
		xFrom := 0
	if (xTo > CaptureW - 1)
		xTo := CaptureW - 1
	tB := (targetBGR >> 16) & 0xFF
	tG := (targetBGR >> 8) & 0xFF
	tR := targetBGR & 0xFF
	rowOffset := y * CaptureW * 4
	runStart := -1
	runEnd := -1
	x := xFrom
	while (x <= xTo)
		{
		px := NumGet(pCaptureBits + 0, rowOffset + (x*4), "UInt")
		if (Abs((px & 0xFF) - tB) <= tol and Abs(((px >> 8) & 0xFF) - tG) <= tol and Abs(((px >> 16) & 0xFF) - tR) <= tol)
			{
			if (runStart < 0)
				runStart := x
			runEnd := x
			}
		else if (runStart >= 0 and (x - runEnd) > 4)
			break
		x++
		}
	if (runStart < 0)
		return -1
	return FishBarLeft + ((runStart + runEnd) / 2)
}


ColorListParse(s) {
	global ColorListCache, ColorListCacheN
	if (!IsObject(ColorListCache))
		{
		ColorListCache := {}
		ColorListCacheN := 0
		}
	if (ColorListCache.HasKey(s))
		return ColorListCache[s]
	if (ColorListCacheN > 96)
		{
		ColorListCache := {}
		ColorListCacheN := 0
		}
	o := {n: 0, r: [], g: [], b: []}
	Loop, Parse, s, `,;| , %A_Space%%A_Tab%
		{
		v := ColNorm(A_LoopField)
		if (v < 0)
			continue
		o.n := o.n + 1
		o.r.Push((v >> 16) & 0xFF)
		o.g.Push((v >> 8) & 0xFF)
		o.b.Push(v & 0xFF)
		}
	ColorListCache[s] := o
	ColorListCacheN := ColorListCacheN + 1
	return o
}

ColMain(s) {
	o := ColorListParse(s)
	if (o.n < 1)
		return 0
	return (o.r[1] << 16) | (o.g[1] << 8) | o.b[1]
}

ColCount(s) {
	o := ColorListParse(s)
	return o.n
}

ColorListHitPx(o, px, tol) {
	pb := px & 0xFF
	pg := (px >> 8) & 0xFF
	pr := (px >> 16) & 0xFF
	i := 1
	n := o.n
	while (i <= n)
		{
		if (Abs(pr - o.r[i]) <= tol and Abs(pg - o.g[i]) <= tol and Abs(pb - o.b[i]) <= tol)
			return true
		i++
		}
	return false
}

ColorListFirstX(o, tol, y, xFrom, xTo) {
	global pCaptureBits, CaptureW, CaptureH, FishBarLeft
	if (o.n < 1 or y < 0 or y >= CaptureH)
		return -1
	if (xFrom < 0)
		xFrom := 0
	if (xTo > CaptureW - 1)
		xTo := CaptureW - 1
	rowOffset := y * CaptureW * 4
	x := xFrom
	while (x <= xTo)
		{
		if (ColorListHitPx(o, NumGet(pCaptureBits + 0, rowOffset + (x*4), "UInt"), tol))
			return FishBarLeft + x
		x++
		}
	return -1
}

ColorListLastX(o, tol, y, xFrom, xTo) {
	global pCaptureBits, CaptureW, CaptureH, FishBarLeft
	if (o.n < 1 or y < 0 or y >= CaptureH)
		return -1
	if (xFrom < 0)
		xFrom := 0
	if (xTo > CaptureW - 1)
		xTo := CaptureW - 1
	rowOffset := y * CaptureW * 4
	x := xTo
	while (x >= xFrom)
		{
		if (ColorListHitPx(o, NumGet(pCaptureBits + 0, rowOffset + (x*4), "UInt"), tol))
			return FishBarLeft + x
		x--
		}
	return -1
}

ColorListLineX(o, tol, y, xFrom, xTo) {
	global pCaptureBits, CaptureW, CaptureH, FishBarLeft
	if (o.n < 1 or y < 0 or y >= CaptureH)
		return -1
	if (xFrom < 0)
		xFrom := 0
	if (xTo > CaptureW - 1)
		xTo := CaptureW - 1
	rowOffset := y * CaptureW * 4
	x := xFrom
	while (x <= xTo)
		{
		if (!ColorListHitPx(o, NumGet(pCaptureBits + 0, rowOffset + (x*4), "UInt"), tol))
			{
			x++
			continue
			}
		runStart := x
		while (x <= xTo and ColorListHitPx(o, NumGet(pCaptureBits + 0, rowOffset + (x*4), "UInt"), tol))
			x++
		runLen := x - runStart
		if (runLen <= 25)
			{
			cx := runStart + (runLen // 2)
			hits := 0
			Loop, 7
				{
				y2 := Floor(CaptureH * (A_Index*2 - 1) / 14)
				if (y2 >= CaptureH)
					y2 := CaptureH - 1
				if (ColorListHitPx(o, NumGet(pCaptureBits + 0, (y2*CaptureW*4) + (cx*4), "UInt"), tol))
					hits++
				}
			if (hits >= 5)
				return FishBarLeft + cx
			}
		}
	return -1
}

ColorListCenterX(o, tol, y, xFrom, xTo) {
	global pCaptureBits, CaptureW, CaptureH, FishBarLeft
	if (o.n < 1 or y < 0 or y >= CaptureH)
		return -1
	if (xFrom < 0)
		xFrom := 0
	if (xTo > CaptureW - 1)
		xTo := CaptureW - 1
	rowOffset := y * CaptureW * 4
	runStart := -1
	runEnd := -1
	x := xFrom
	while (x <= xTo)
		{
		if (ColorListHitPx(o, NumGet(pCaptureBits + 0, rowOffset + (x*4), "UInt"), tol))
			{
			if (runStart < 0)
				runStart := x
			runEnd := x
			}
		else if (runStart >= 0 and (x - runEnd) > 4)
			break
		x++
		}
	if (runStart < 0)
		return -1
	return FishBarLeft + ((runStart + runEnd) / 2)
}

; ---- Color-free structural bar detector -----------------------------------------------------

StructBar() {
	global CaptureW, CaptureH, RunLeft, RunWidth, BarScanRow, BarRowAgreement
	if (CaptureW < 24 or CaptureH < 4)
		return false
	nRows := 9
	if (CaptureH < nRows)
		nRows := CaptureH
	ls := []
	ws := []
	cs := []
	ys := []
	Loop, % nRows
		{
		y := Floor(CaptureH * (A_Index*2 - 1) / (nRows*2))
		if (y < 0)
			y := 0
		if (y >= CaptureH)
			y := CaptureH - 1
		if (!ScanRowBar(y, 8))
			continue
		if (RunWidth < CaptureW * 0.05 or RunWidth > CaptureW * 0.72)
			continue
		ls.Push(RunLeft)
		ws.Push(RunWidth)
		cs.Push(RunLeft + RunWidth/2)
		ys.Push(y)
		}
	cnt := cs.MaxIndex()
	if (!cnt)
		cnt := 0
	if (cnt < 4)
		{
		BarRowAgreement := cnt
		return false
		}
	mc := MedianOf(cs)
	mw := MedianOf(ws)
	agree := 0
	bi := 0
	bd := 999999
	for i, c in cs
		{
		if (Abs(c - mc) <= CaptureW * 0.10 and ws[i] >= mw*0.6 and ws[i] <= mw*1.6)
			{
			agree++
			d := Abs(c - mc)
			if (d < bd)
				{
				bd := d
				bi := i
				}
			}
		}
	BarRowAgreement := agree
	if (agree < 4 or !bi)
		return false
	RunLeft := ls[bi]
	RunWidth := ws[bi]
	BarScanRow := ys[bi]
	return true
}

; ---- Cheap signature of the capture strip, for the "nothing is moving" watchdog ---------------

StripSig() {
	global pCaptureBits, CaptureW, CaptureH
	if (!pCaptureBits or CaptureW < 4 or CaptureH < 1)
		return 0
	sg := 0
	yN := 3
	Loop, % yN
		{
		y := Floor(CaptureH * (A_Index*2 - 1) / (yN*2))
		if (y < 0)
			y := 0
		if (y >= CaptureH)
			y := CaptureH - 1
		off := y * CaptureW * 4
		x := 0
		while (x < CaptureW)
			{
			sg := sg + ((NumGet(pCaptureBits + 0, off + (x*4), "UInt") & 0xFFFFFF) * (x + 1))
			x += 3
			}
		}
	return sg
}

; ---- Minigame presence, scored 0-100 ---------------------------------------------------------

NoteHoldZone(w) {
	z := w * 0.20
	if (z < 10)
		z := 10
	return z
}

MgDetect() {
	global SpecialRod, CaptureW, RunWidth
	global MgSawBar, MgSawFish, MgSawArrow, MgConf
	MgSawBar := false
	MgSawFish := false
	MgSawArrow := false
	if (SpecialRod = "Tranquility")
		{
		MgSawFish := ManiaVisible()
		MgConf := MgSawFish ? 80 : 0
		return MgConf
		}
	sc := 0
	if (FishLineVisible())
		{
		MgSawFish := true
		sc += 55
		}
	if (MinigameVisible(6))
		{
		MgSawBar := true
		sc += 40
		}
	if (sc = 0 and FindArrowX() >= 0)
		{
		MgSawArrow := true
		sc := 30
		}
	if (MgSawBar and RunWidth > 10 and RunWidth < CaptureW * 0.7)
		sc += 5
	if (sc > 100)
		sc := 100
	MgConf := sc
	return sc
}

MgAccumulate() {
	global MgScore
	c := MgDetect()
	if (c >= 90)
		{
		MgScore := 6
		return true
		}
	if (c >= 55)
		MgScore := MgScore + 2
	else if (c >= 30)
		MgScore := MgScore + 1
	else
		MgScore := MgScore - 2
	if (MgScore < 0)
		MgScore := 0
	if (MgScore > 6)
		MgScore := 6
	return (MgScore >= 4)
}

BarByEdges() {
	global RunLeft, RunWidth, LineBarL, LineBarW, LastBarL, LastBarR, CaptureW, MgInPlay
	if (!MgInPlay)
		return false
	if (!LineScan())
		return false
	if (LineBarW < 8 or LineBarW > CaptureW * 0.92)
		return false
	RunLeft := LineBarL
	RunWidth := LineBarW
	LastBarL := LineBarL
	LastBarR := LineBarL + LineBarW - 1
	return true
}

BarSpanFill(lList, rList, tol, y, xFrom, xTo) {
	global pCaptureBits, CaptureW, CaptureH
	if (y < 0 or y >= CaptureH or xTo <= xFrom)
		return 0
	if (xFrom < 0)
		xFrom := 0
	if (xTo > CaptureW - 1)
		xTo := CaptureW - 1
	rowOffset := y * CaptureW * 4
	n := 0
	m := 0
	x := xFrom
	while (x <= xTo)
		{
		px := NumGet(pCaptureBits + 0, rowOffset + (x*4), "UInt")
		n++
		if (ColorListHitPx(lList, px, tol) or ColorListHitPx(rList, px, tol))
			m++
		x += 3
		}
	return (n > 0) ? (m / n) : 0
}

;
RemBarScan() {
	global pCaptureBits, CaptureW, CaptureH, FishBarLeft, RemembranceMode
	global RemBarScanned, RemBarFound, RemBarL, RemBarW, RemBarRing
	if (RemBarScanned)
		return RemBarFound
	RemBarScanned := true
	RemBarFound := false
	if (CaptureW < 40 or CaptureH < 6)
		return false
	if (RemembranceMode = "Departed")
		{
		bLo := 55
		bHi := 110
		}
	else
		{
		bLo := 145
		bHi := 235
		}
	bRows := [Floor(CaptureH * 0.2), Floor(CaptureH * 0.5), Floor(CaptureH * 0.8)]
	VarSetCapacity(bHits, CaptureW, 0)
	for bI, bY in bRows
		{
		bOff := bY * CaptureW * 4
		bX := 0
		while (bX < CaptureW)
			{
			bP := NumGet(pCaptureBits + 0, bOff + (bX*4), "UInt")
			bB := bP & 0xFF
			bG := (bP >> 8) & 0xFF
			bR := (bP >> 16) & 0xFF
			if (Abs(bR - bG) <= 10 and Abs(bG - bB) <= 10)
				{
				bLum := (bR + bG + bB) // 3
				if (bLum >= bLo and bLum <= bHi)
					NumPut(NumGet(bHits, bX, "UChar") + 1, bHits, bX, "UChar")
				}
			bX++
			}
		}
	bMinRef := Round(CaptureW * 0.08)
	bMaxRef := Round(CaptureW * 0.35)
	if (!IsObject(RemBarRing))
		RemBarRing := []
	bHaveRef := (RemBarRing.MaxIndex() >= 3)
	bRef := bHaveRef ? Round(MedianOf(RemBarRing)) : Round(CaptureW * 0.206)
	bAccLo := bHaveRef ? Round(bRef * 0.7) : bMinRef
	bAccHi := bHaveRef ? Round(bRef * 1.3) : bMaxRef
	bGap := Round(CaptureW * 0.018)
	if (bGap < 6)
		bGap := 6
	bBestL := -1
	bBestLen := 0
	bRunS := -1
	bLast := -1
	bX := 0
	while (bX <= CaptureW)
		{
		bOn := false
		if (bX < CaptureW)
			bOn := (NumGet(bHits, bX, "UChar") >= 2)
		if (bOn)
			{
			if (bRunS < 0)
				bRunS := bX
			bLast := bX
			}
		else if (bRunS >= 0 and ((bX - bLast) > bGap or bX = CaptureW))
			{
			if ((bLast - bRunS + 1) > bBestLen)
				{
				bBestLen := bLast - bRunS + 1
				bBestL := bRunS
				}
			bRunS := -1
			}
		bX++
		}
	if (bBestL >= 0 and bBestLen >= bAccLo and bBestLen <= bAccHi)
		{
		RemBarL := FishBarLeft + bBestL
		RemBarW := bBestLen
		RemBarRing.Push(bBestLen)
		if (RemBarRing.MaxIndex() > 5)
			RemBarRing.RemoveAt(1)
		RemBarFound := true
		return true
		}
	bSum := 0
	bBest := -1
	bBestSum := 0
	bX := 0
	while (bX < CaptureW)
		{
		bSum := bSum + NumGet(bHits, bX, "UChar")
		if (bX >= bRef)
			bSum := bSum - NumGet(bHits, bX - bRef, "UChar")
		if (bX >= bRef - 1 and bSum > bBestSum)
			{
			bBestSum := bSum
			bBest := bX - bRef + 1
			}
		bX++
		}
	if (bBest < 0 or bBestSum < bRef * 3 * 0.45)
		return false
	RemBarL := FishBarLeft + bBest
	RemBarW := bRef
	RemBarFound := true
	return true
}

RemembranceScan() {
	global pCaptureBits, CaptureW, CaptureH, FishBarLeft, BarScanRow
	global FishColor, FishBarColorTolerance
	global RemWhiteX, RemBlackX, RemTargetX, RemScanned, RemFound
	if (RemScanned)
		return RemFound
	RemScanned := true
	RemFound := false
	RemWhiteX := -1
	RemBlackX := -1
	RemTargetX := -1
	if (CaptureW < 40 or CaptureH < 6)
		return false

	rRows := []
	Loop, 5
		{
		ry := Floor(CaptureH * (A_Index*2 - 1) / 10)
		if (ry >= CaptureH)
			ry := CaptureH - 1
		rRows.Push(ry)
		}

	wList := ColorListParse(FishColor)
	if (wList.n < 1)
		wList := ColorListParse("0xFFFFFF")
	wR := wList.r[1]
	wG := wList.g[1]
	wB := wList.b[1]
	wTol := FishBarColorTolerance
	if (wTol < 6)
		wTol := 6
	wMaxW := Round(CaptureW * 0.03)
	if (wMaxW < 8)
		wMaxW := 8
	wBestX := -1
	wBestV := 0
	for wPass, wRowI in [3, 2, 4]
		{
		wRy := rRows[wRowI]
		wOff := wRy * CaptureW * 4
		wRunS := -1
		wX := 0
		while (wX <= CaptureW)
			{
			wHit := false
			if (wX < CaptureW)
				{
				wPx := NumGet(pCaptureBits + 0, wOff + (wX*4), "UInt")
				wHit := (Abs(((wPx >> 16) & 0xFF) - wR) <= wTol and Abs(((wPx >> 8) & 0xFF) - wG) <= wTol and Abs((wPx & 0xFF) - wB) <= wTol)
				}
			if (wHit)
				{
				if (wRunS < 0)
					wRunS := wX
				}
			else if (wRunS >= 0)
				{
				wRunW := wX - wRunS
				if (wRunW >= 2 and wRunW <= wMaxW)
					{
					wCx := wRunS + (wRunW // 2)
					wVotes := 0
					for rI, ry in rRows
						{
						if (RemWhiteAt(wCx, ry, wR, wG, wB, wTol))
							wVotes++
						}
					if (wVotes > wBestV)
						{
						wBestV := wVotes
						wBestX := wCx
						}
					}
				wRunS := -1
				}
			wX++
			}
		if (wBestV >= 4)
			break
		}
	if (wBestV < 4)
		return false
	RemWhiteX := FishBarLeft + wBestX

	rOff := Round(CaptureW * 0.02)
	if (rOff < 8)
		rOff := 8
	bX := -1
	bV := 0
	rx := rOff
	while (rx < CaptureW - rOff)
		{
		if (IsDarkNotch(rx, BarScanRow, rOff))
			{
			rVotes := 0
			for rI, ry in rRows
				{
				if (IsDarkNotch(rx, ry, rOff))
					rVotes++
				}
			if (rVotes >= 3 and rVotes > bV)
				{
				bV := rVotes
				bX := rx
				}
			}
		rx++
		}
	if (bX >= 0)
		RemBlackX := FishBarLeft + bX

	RemFound := true
	RemTargetX := RemAimX(RemWhiteX, RemBlackX)
	return true
}

RemWhiteAt(hx, hy, hr, hg, hb, htol) {
	global pCaptureBits, CaptureW, CaptureH
	if (hy < 0 or hy >= CaptureH)
		return false
	hOff := hy * CaptureW * 4
	hI := hx - 5
	if (hI < 0)
		hI := 0
	hE := hx + 5
	if (hE > CaptureW - 1)
		hE := CaptureW - 1
	while (hI <= hE)
		{
		hP := NumGet(pCaptureBits + 0, hOff + (hI*4), "UInt")
		if (Abs(((hP >> 16) & 0xFF) - hr) <= htol and Abs(((hP >> 8) & 0xFF) - hg) <= htol and Abs((hP & 0xFF) - hb) <= htol)
			return true
		hI++
		}
	return false
}

RemAimX(wx, bx) {
	global RunWidth, RemembranceMode
	rHalf := RunWidth / 2
	if (rHalf < 4 or bx < 0)
		return wx
	rDep := (RemembranceMode = "Departed")
	rClear := rHalf + (rDep ? (RunWidth * 0.15) : (RunWidth * 0.06))
	if (Abs(bx - wx) > rClear + rHalf)
		return wx
	if (bx > wx)
		{
		rAim := bx - rClear
		if (!rDep)
			{
			rLo := wx - rHalf + 2
			if (rAim < rLo)
				rAim := rLo
			}
		return rAim
		}
	rAim := bx + rClear
	if (!rDep)
		{
		rHi := wx + rHalf - 2
		if (rAim > rHi)
			rAim := rHi
		}
	return rAim
}

HalibutBarScan() {
	global pCaptureBits, CaptureW, CaptureH, FishBarLeft
	global HaliBarScanned, HaliBarFound, HaliBarL, HaliBarW, HaliFishX
	if (HaliBarScanned)
		return HaliBarFound
	HaliBarScanned := true
	HaliBarFound := false
	HaliFishX := -1
	if (CaptureW < 40 or CaptureH < 8)
		return false
	hRows := [Floor(CaptureH * 0.28), Floor(CaptureH * 0.38), Floor(CaptureH * 0.78), Floor(CaptureH * 0.88)]
	VarSetCapacity(hBar, CaptureW, 0)
	VarSetCapacity(hDark, CaptureW, 0)
	hTrk := 0
	for hI, hY in hRows
		{
		p := pCaptureBits + (hY * CaptureW * 4)
		x := 0
		while (x < CaptureW)
			{
			px := NumGet(p + 0, x * 4, "UInt"), b := px & 0xFF, g := (px >> 8) & 0xFF, r := (px >> 16) & 0xFF
			if (Abs(r - 0x53) <= 12 and Abs(g - 0x48) <= 12 and Abs(b - 0xA0) <= 14)
				NumPut(NumGet(hBar, x, "UChar") + 1, hBar, x, "UChar")
			else if (Abs(r - 0x2A) <= 12 and Abs(g - 0x26) <= 12 and Abs(b - 0x75) <= 14)
				hTrk++
			else
				{
				mx := (r > g) ? r : g
				mx := (b > mx) ? b : mx
				mn := (r < g) ? r : g
				mn := (b < mn) ? b : mn
				if (mx < 60 and mx - mn <= 10)
					NumPut(NumGet(hDark, x, "UChar") + 1, hDark, x, "UChar")
				}
			x++
			}
		}
	if (hTrk < CaptureW * 0.6)
		return false

	hGap := Round(CaptureW * 0.03)
	if (hGap < 12)
		hGap := 12
	hBestL := -1, hBestLen := 0, hRunS := -1, hLast := -1
	x := 0
	while (x <= CaptureW)
		{
		if (x < CaptureW and NumGet(hBar, x, "UChar") >= 2)
			{
			if (hRunS < 0)
				hRunS := x
			hLast := x
			}
		else if (hRunS >= 0 and ((x - hLast) > hGap or x = CaptureW))
			{
			if ((hLast - hRunS + 1) > hBestLen)
				{
				hBestLen := hLast - hRunS + 1
				hBestL := hRunS
				}
			hRunS := -1
			}
		x++
		}

	hMaxFW := Round(CaptureW * 0.02)
	if (hMaxFW < 12)
		hMaxFW := 12
	hBestHits := 0, hRunS := -1, hHits := 0
	x := 0
	while (x <= CaptureW)
		{
		hd := (x < CaptureW) ? NumGet(hDark, x, "UChar") : 0
		if (hd >= 2)
			{
			if (hRunS < 0)
				hRunS := x, hHits := 0
			hHits += hd
			}
		else if (hRunS >= 0)
			{
			if ((x - hRunS) <= hMaxFW and hHits > hBestHits)
				{
				hBestHits := hHits
				HaliFishX := FishBarLeft + ((hRunS + x - 1) / 2)
				}
			hRunS := -1
			}
		x++
		}

	if (hBestL < 0 or hBestLen < CaptureW * 0.08 or hBestLen > CaptureW * 0.85)
		return false
	HaliBarL := FishBarLeft + hBestL
	HaliBarW := hBestLen
	HaliBarFound := true
	return true
}

MiguBarScan() {
	global pCaptureBits, CaptureW, CaptureH, FishBarLeft
	global MiguBarScanned, MiguBarFound, MiguBarL, MiguBarW
	if (MiguBarScanned)
		return MiguBarFound
	MiguBarScanned := true
	MiguBarFound := false
	if (CaptureW < 40 or CaptureH < 6)
		return false
	qRows := [Floor(CaptureH * 0.30), Floor(CaptureH * 0.50), Floor(CaptureH * 0.70)]
	qTrk := 0
	qOff := qRows[2] * CaptureW * 4
	qX := 0
	while (qX < CaptureW)
		{
		qP := NumGet(pCaptureBits + 0, qOff + (qX*4), "UInt")
		qB := qP & 0xFF
		qG := (qP >> 8) & 0xFF
		qR := (qP >> 16) & 0xFF
		if (qR > 150 and qG < 110 and (qR - qG) > 90 and (qR - qB) > 55)
			qTrk++
		qX++
		}
	if (qTrk < CaptureW * 0.25)
		return false
	VarSetCapacity(qHits, CaptureW, 0)
	for qI, qY in qRows
		{
		qOff := qY * CaptureW * 4
		qX := 0
		while (qX < CaptureW)
			{
			qP := NumGet(pCaptureBits + 0, qOff + (qX*4), "UInt")
			qB := qP & 0xFF
			qG := (qP >> 8) & 0xFF
			qR := (qP >> 16) & 0xFF
			if (qR > 190 and qG >= 140 and qG <= 245 and qB >= 90 and qB <= 215 and (qR - qB) > 40)
				NumPut(NumGet(qHits, qX, "UChar") + 1, qHits, qX, "UChar")
			qX++
			}
		}
	qGap := Round(CaptureW * 0.035)
	if (qGap < 12)
		qGap := 12
	qMinW := Round(CaptureW * 0.05)
	if (qMinW < 24)
		qMinW := 24
	qBestL := -1
	qBestLen := 0
	qRunS := -1
	qLast := -1
	qX := 0
	while (qX <= CaptureW)
		{
		qOn := false
		if (qX < CaptureW)
			qOn := (NumGet(qHits, qX, "UChar") >= 2)
		if (qOn)
			{
			if (qRunS < 0)
				qRunS := qX
			qLast := qX
			}
		else if (qRunS >= 0 and ((qX - qLast) > qGap or qX = CaptureW))
			{
			if ((qLast - qRunS + 1) > qBestLen)
				{
				qBestLen := qLast - qRunS + 1
				qBestL := qRunS
				}
			qRunS := -1
			}
		qX++
		}
	if (qBestL < 0 or qBestLen < qMinW or qBestLen > CaptureW * 0.85)
		return false
	MiguBarL := FishBarLeft + qBestL
	MiguBarW := qBestLen
	MiguBarFound := true
	return true
}

MiguScan() {
	global pCaptureBits, CaptureW, CaptureH, FishBarLeft, FishColor, FishBarColorTolerance
	global MiguFishX, MiguLastX, MiguScanned, MiguFound
	if (MiguScanned)
		return MiguFound
	MiguScanned := true
	MiguFound := false
	MiguFishX := -1
	if (CaptureW < 40 or CaptureH < 6)
		return false

	gkRows := [Floor(CaptureH * 0.30), Floor(CaptureH * 0.55), Floor(CaptureH * 0.85)]
	VarSetCapacity(gkBuf, CaptureW, 0)
	for gkI, gkY in gkRows
		{
		gkOff := gkY * CaptureW * 4
		gkX := 0
		while (gkX < CaptureW)
			{
			gkP := NumGet(pCaptureBits + 0, gkOff + (gkX*4), "UInt")
			if (((gkP >> 16) & 0xFF) < 110 and ((gkP >> 8) & 0xFF) < 35 and (gkP & 0xFF) < 40)
				NumPut(1, gkBuf, gkX, "UChar")
			gkX++
			}
		}
	gkMinW := Round(CaptureW * 0.005)
	if (gkMinW < 3)
		gkMinW := 3
	gkMaxW := Round(CaptureW * 0.034)
	if (gkMaxW < 12)
		gkMaxW := 12
	gkGap := Round(CaptureW * 0.006)
	if (gkGap < 3)
		gkGap := 3
	gkPad := Round(CaptureW * 0.004)
	if (gkPad < 2)
		gkPad := 2
	VarSetCapacity(gkMask, CaptureW, 0)
	gkX := 0
	while (gkX < CaptureW)
		{
		if (!NumGet(gkBuf, gkX, "UChar"))
			{
			gkX++
			continue
			}
		gkA := gkX
		gkLast := gkX
		while (gkX < CaptureW and (NumGet(gkBuf, gkX, "UChar") or (gkX - gkLast) <= gkGap))
			{
			if (NumGet(gkBuf, gkX, "UChar"))
				gkLast := gkX
			gkX++
			}
		gkW := gkLast - gkA + 1
		if (gkW < gkMinW or gkW > gkMaxW)
			continue
		gkM := gkA - gkPad
		if (gkM < 0)
			gkM := 0
		while (gkM <= gkLast + gkPad and gkM < CaptureW)
			{
			NumPut(1, gkMask, gkM, "UChar")
			gkM++
			}
		}

	gkList := ColorListParse(FishColor)
	if (gkList.n < 1)
		return false
	gkTol := FishBarColorTolerance
	if (gkTol < 6)
		gkTol := 6
	gkMinR := 255
	gkMinG := 255
	gkI := 1
	while (gkI <= gkList.n)
		{
		if (gkList.r[gkI] < gkMinR)
			gkMinR := gkList.r[gkI]
		if (gkList.g[gkI] < gkMinG)
			gkMinG := gkList.g[gkI]
		gkI++
		}
	gkMinR := gkMinR - gkTol
	gkMinG := gkMinG - gkTol
	gkFRows := []
	Loop, 5
		{
		gkY := Floor(CaptureH * (A_Index*2 - 1) / 10)
		if (gkY >= CaptureH)
			gkY := CaptureH - 1
		gkFRows.Push(gkY)
		}
	gkFW := Round(CaptureW * 0.03)
	if (gkFW < 8)
		gkFW := 8
	gkCandX := []
	gkCandV := []
	for gkPass, gkRi in [3, 2, 4]
		{
		gkOff := gkFRows[gkRi] * CaptureW * 4
		gkS := -1
		gkX := 0
		while (gkX <= CaptureW)
			{
			gkHit := false
			if (gkX < CaptureW and !NumGet(gkMask, gkX, "UChar"))
				{
				gkP := NumGet(pCaptureBits + 0, gkOff + (gkX*4), "UInt")
				if (((gkP >> 16) & 0xFF) >= gkMinR and ((gkP >> 8) & 0xFF) >= gkMinG)
					gkHit := ColorListHitPx(gkList, gkP, gkTol)
				}
			if (gkHit)
				{
				if (gkS < 0)
					gkS := gkX
				}
			else if (gkS >= 0)
				{
				gkRw := gkX - gkS
				if (gkRw >= 2 and gkRw <= gkFW)
					{
					gkCx := gkS + (gkRw // 2)
					gkV := 0
					for gkI, gkY in gkFRows
						{
						if (MiguFishAt(gkCx, gkY, gkList, gkTol, &gkMask))
							gkV++
						}
					if (gkV >= 4)
						{
						gkCandX.Push(gkCx)
						gkCandV.Push(gkV)
						}
					}
				gkS := -1
				}
			gkX++
			}
		if (gkCandX.MaxIndex())
			break
		}
	if (!gkCandX.MaxIndex())
		return false
	gkBestV := 0
	for gkI, gkV in gkCandV
		{
		if (gkV > gkBestV)
			gkBestV := gkV
		}
	gkBestX := -1
	gkNear := 999999
	for gkI, gkCx in gkCandX
		{
		if (gkCandV[gkI] < gkBestV)
			continue
		if (MiguLastX >= 0)
			{
			gkD := Abs((FishBarLeft + gkCx) - MiguLastX)
			if (gkD < gkNear and gkD <= CaptureW * 0.25)
				{
				gkNear := gkD
				gkBestX := gkCx
				}
			}
		}
	if (gkBestX < 0)
		{
		for gkI, gkCx in gkCandX
			{
			if (gkCandV[gkI] >= gkBestV and (gkBestX < 0 or gkCx < gkBestX))
				gkBestX := gkCx
			}
		}
	MiguFishX := FishBarLeft + gkBestX
	MiguLastX := MiguFishX
	MiguFound := true
	return true
}

MiguFishAt(fx, fy, fList, fTol, pMask) {
	global pCaptureBits, CaptureW, CaptureH
	if (fy < 0 or fy >= CaptureH)
		return false
	fOff := fy * CaptureW * 4
	fI := fx - 5
	if (fI < 0)
		fI := 0
	fE := fx + 5
	if (fE > CaptureW - 1)
		fE := CaptureW - 1
	while (fI <= fE)
		{
		if (!NumGet(pMask + 0, fI, "UChar") and ColorListHitPx(fList, NumGet(pCaptureBits + 0, fOff + (fI*4), "UInt"), fTol))
			return true
		fI++
		}
	return false
}

CastboundScan() {
	global pCaptureBits, CaptureW, CaptureH, FishBarLeft
	global CastBarL, CastBarW, CastFishX, CastScanned, CastFound
	global CastPrevL, CastPrevW, CastPrevF, CastSameN, CastSameT, CastStatic, QpcFreq
	if (CastScanned)
		return CastFound
	CastScanned := true
	CastFound := false
	CastBarL := -1
	CastBarW := 0
	CastFishX := -1
	if (CaptureW < 80 or CaptureH < 6)
		return false

	row := CaptureH // 2
	rowOffset := row * CaptureW * 4

	; --- is the minigame even on screen? ----------------------------------------------------
	nTrk := 0
	trkFirst := -1
	trkLast := -1
	x := 0
	while (x < CaptureW)
		{
		px := NumGet(pCaptureBits + 0, rowOffset + (x*4), "UInt")
		tb := px & 0xFF
		tg := (px >> 8) & 0xFF
		tr := (px >> 16) & 0xFF
		tsum := tb + tg + tr
		if ((tb - tg) > 20 and (tr - tg) > 5 and tsum >= 180 and tsum <= 340)
			{
			nTrk++
			if (trkFirst < 0)
				trkFirst := x
			trkLast := x
			}
		x++
		}
	if (nTrk < CaptureW * 0.10)
		return false
	if ((trkLast - trkFirst + 1) < CaptureW * 0.45)
		{
		return false
		}

	; --- the reeling bar: whatever is neither track, nor sword, nor shadow -------------------
	cbY1 := CaptureH // 3
	cbY2 := CaptureH // 2
	cbY3 := (CaptureH * 2) // 3
	cbGapMax := Round(CaptureW * 0.035)
	if (cbGapMax < 30)
		cbGapMax := 30
	bestL := -1
	bestLen := 0
	runS := -1
	runE := -1
	gap := 0
	cbX := 0
	while (cbX < CaptureW)
		{
		cbHits := 0
		for cbK, cbYY in [cbY1, cbY2, cbY3]
			{
			px := NumGet(pCaptureBits + 0, (cbYY*CaptureW*4) + (cbX*4), "UInt")
			cbB := px & 0xFF
			cbG := (px >> 8) & 0xFF
			cbR := (px >> 16) & 0xFF
			cbSum := cbB + cbG + cbR
			cbIsTrk := ((cbB - cbG) > 20 and (cbR - cbG) > 5 and cbSum >= 180 and cbSum <= 340)
			cbIsSw := (cbG < 90 and cbB > 130 and (cbB - cbG) > 80 and cbR < 160)
			if (!cbIsTrk and !cbIsSw and cbSum >= 110)
				cbHits++
			}
		if (cbHits >= 2)
			{
			if (runS < 0)
				runS := cbX
			runE := cbX
			gap := 0
			}
		else if (runS >= 0)
			{
			gap++
			if (gap > cbGapMax)
				{
				if (runE - runS + 1 > bestLen)
					{
					bestLen := runE - runS + 1
					bestL := runS
					}
				runS := -1
				gap := 0
				}
			}
		cbX++
		}
	if (runS >= 0 and (runE - runS + 1) > bestLen)
		{
		bestLen := runE - runS + 1
		bestL := runS
		}
	if (bestL >= 0 and bestLen >= 24 and bestLen <= CaptureW * 0.85)
		{
		CastBarL := FishBarLeft + bestL
		CastBarW := bestLen
		}

	; --- fallback: the gap the bar leaves in the purple track --------------------------------
	if (CastBarW <= 0)
		{
		tGap := Round(CaptureW * 0.02)
		if (tGap < 10)
			tGap := 10
		nTrk := 0
		tBest := -1
		tLen := 0
		tRun := -1
		tEnd := -1
		tG := 0
		x := 0
		while (x < CaptureW)
			{
			px := NumGet(pCaptureBits + 0, rowOffset + (x*4), "UInt")
			bb := px & 0xFF
			gg := (px >> 8) & 0xFF
			rr := (px >> 16) & 0xFF
			sum := bb + gg + rr
			isTrk := ((bb - gg) > 20 and (rr - gg) > 5 and sum >= 180 and sum <= 340)
			if (isTrk)
				{
				nTrk++
				if (tRun >= 0)
					{
					tG++
					if (tG > tGap)
						{
						if (tEnd - tRun + 1 > tLen)
							{
							tLen := tEnd - tRun + 1
							tBest := tRun
							}
						tRun := -1
						tG := 0
						}
					}
				}
			else
				{
				if (tRun < 0)
					tRun := x
				tEnd := x
				tG := 0
				}
			x++
			}
		if (tRun >= 0 and (tEnd - tRun + 1) > tLen)
			{
			tLen := tEnd - tRun + 1
			tBest := tRun
			}
		if (nTrk >= CaptureW * 0.25 and tBest >= 0 and tLen >= CaptureW * 0.05 and tLen <= CaptureW * 0.9)
			{
			CastBarL := FishBarLeft + tBest
			CastBarW := tLen
			}
		}

	; --- the sword marker: deep violet, almost no green --------------------------------------
	y1 := CaptureH // 6
	y2 := CaptureH // 2
	y3 := (CaptureH * 5) // 6
	sBest := -1
	sLen := 0
	sRun := -1
	sPrev := -1
	sGap := 0
	x := 0
	while (x < CaptureW)
		{
		hits := 0
		for i, yy in [y1, y2, y3]
			{
			px := NumGet(pCaptureBits + 0, (yy*CaptureW*4) + (x*4), "UInt")
			bb := px & 0xFF
			gg := (px >> 8) & 0xFF
			rr := (px >> 16) & 0xFF
			if (gg < 90 and bb > 130 and (bb - gg) > 80 and rr < 160)
				hits++
			}
		if (hits >= 2)
			{
			if (sRun < 0)
				sRun := x
			sPrev := x
			sGap := 0
			}
		else if (sRun >= 0)
			{
			sGap++
			if (sGap > 6)
				{
				if ((sPrev - sRun + 1) > sLen)
					{
					sLen := sPrev - sRun + 1
					sBest := (sRun + sPrev) // 2
					}
				sRun := -1
				sGap := 0
				}
			}
		x++
		}
	if (sRun >= 0 and (sPrev - sRun + 1) > sLen)
		{
		sLen := sPrev - sRun + 1
		sBest := (sRun + sPrev) // 2
		}
	if (sBest >= 0 and sLen >= 6)
		CastFishX := FishBarLeft + sBest

	DllCall("QueryPerformanceCounter", "Int64*", csNow)
	if (CastBarW > 0 and CastBarL = CastPrevL and CastBarW = CastPrevW and CastFishX = CastPrevF)
		{
		CastSameN := CastSameN + 1
		if (!CastSameT)
			CastSameT := csNow
		}
	else
		{
		CastSameN := 0
		CastSameT := 0
		}
	CastPrevL := CastBarL
	CastPrevW := CastBarW
	CastPrevF := CastFishX
	CastStatic := (CastSameT and ((csNow - CastSameT) / QpcFreq) >= 0.25)

	CastFound := (CastBarW > 0 and CastFishX >= 0)
	return CastFound
}

BarOneColor(px) {
	o := {n: 1, r: [(px >> 16) & 0xFF], g: [(px >> 8) & 0xFF], b: [px & 0xFF]}
	return o
}

BarPixAt(x, y) {
	global pCaptureBits, CaptureW, CaptureH
	if (x < 0 or x >= CaptureW or y < 0 or y >= CaptureH)
		return -1
	return NumGet(pCaptureBits + 0, (y*CaptureW*4) + (x*4), "UInt") & 0xFFFFFF
}

BarByTrackContrast(row, ByRef bl, ByRef bw) {
	global CaptureH, FishBarLeft
	bl := -1
	bw := 0
	if (!TrackRunAt(row, s0, e0))
		return false
	w0 := e0 - s0 + 1
	slack := Round(w0 * 0.06)
	if (slack < 6)
		slack := 6
	dy := Round(CaptureH * 0.15)
	if (dy < 2)
		dy := 2
	for i, sgn in [-1, 1]
		{
		ry := row + (sgn * dy)
		if (ry < 1)
			ry := 1
		if (ry > CaptureH - 2)
			ry := CaptureH - 2
		if (ry = row)
			continue
		if (!TrackRunAt(ry, s1, e1) or Abs(s1 - s0) > slack or Abs(e1 - e0) > slack)
			return false
		}
	bl := FishBarLeft + s0
	bw := w0
	return true
}

TrackRunAt(row, ByRef rs, ByRef re) {
	global pCaptureBits, CaptureW, CaptureH
	rs := -1
	re := -1
	if (row < 0 or row >= CaptureH or CaptureW < 40)
		return false
	rowOff := row * CaptureW * 4
	VarSetCapacity(tcHist, 64 * 4, 0)
	x := 0
	while (x < CaptureW)
		{
		px := NumGet(pCaptureBits + 0, rowOff + (x*4), "UInt")
		v := ((((px & 0xFF) + ((px >> 8) & 0xFF) + ((px >> 16) & 0xFF)) // 3) // 4)
		NumPut(NumGet(tcHist, v*4, "UInt") + 1, tcHist, v*4, "UInt")
		x++
		}
	half := CaptureW // 2
	acc := 0
	med := 0
	b := 0
	while (b < 64)
		{
		acc += NumGet(tcHist, b*4, "UInt")
		if (acc >= half)
			{
			med := (b * 4) + 2
			break
			}
		b++
		}
	thr := med * 2
	if (thr < med + 15)
		thr := med + 15
	bestLen := 0
	bestS := -1
	runS := -1
	runE := -1
	x := 0
	while (x <= CaptureW)
		{
		on := false
		if (x < CaptureW)
			{
			px := NumGet(pCaptureBits + 0, rowOff + (x*4), "UInt")
			on := ((((px & 0xFF) + ((px >> 8) & 0xFF) + ((px >> 16) & 0xFF)) // 3) > thr)
			}
		if (on)
			{
			if (runS < 0)
				runS := x
			runE := x
			}
		else if (runS >= 0 and ((x - runE) > 20 or x = CaptureW))
			{
			if ((runE - runS + 1) > bestLen)
				{
				bestLen := runE - runS + 1
				bestS := runS
				}
			runS := -1
			}
		x++
		}
	if (bestS < 0 or bestLen < 40)
		return false
	rs := bestS
	re := bestS + bestLen - 1
	return true
}

BarColRef() {
	global BarColRing
	if (!IsObject(BarColRing) or BarColRing.MaxIndex() < 3)
		return 0
	return MedianOf(BarColRing)
}

FindBarByColor() {
	global BarLeftColor, BarRightColor, BarColorTolerance, RunLeft, RunWidth, BarScanRow, BarColRing, BarColT, QpcFreq
	global CaptureH, CaptureW, FishBarLeft, LastBarL, LastBarR
	global BarLiveL, BarLiveR, BarLiveMiss, BarWLive, BarLiveOnlyAt, MgInPlay
	if (BarLeftColor = "" or BarRightColor = "")
		return false
	row := BarScanRow
	if (row < 0 or row >= CaptureH)
		row := CaptureH // 2
	lList := ColorListParse(BarLeftColor)
	rList := ColorListParse(BarRightColor)
	if (lList.n < 1 or rList.n < 1)
		return false

	adTol := BarColorTolerance + 24
	lLive := (MgInPlay and BarLiveL >= 0) ? BarOneColor(BarLiveL) : 0
	rLive := (MgInPlay and BarLiveR >= 0) ? BarOneColor(BarLiveR) : 0

	l := -1
	r := -1
	if (LastBarL >= 0)
		{
		lx := Round(LastBarL - FishBarLeft)
		if (lLive)
			l := ColorListFirstX(lLive, adTol, row, lx - 70, lx + 70)
		if (l < 0)
			l := ColorListFirstX(lList, BarColorTolerance, row, lx - 70, lx + 70)
		}
	if (LastBarR >= 0)
		{
		rx := Round(LastBarR - FishBarLeft)
		if (rLive)
			r := ColorListLastX(rLive, adTol, row, rx - 70, rx + 70)
		if (r < 0)
			r := ColorListLastX(rList, BarColorTolerance, row, rx - 70, rx + 70)
		}
	if (l < 0)
		l := ColorListFirstX(lList, BarColorTolerance, row, 0, CaptureW - 1)
	if (r < 0)
		r := ColorListLastX(rList, BarColorTolerance, row, 0, CaptureW - 1)

	if (l < 0 or r < 0)
		{
		Loop, 3
			{
			y2 := Floor(CaptureH * (A_Index*2 - 1) / 6)
			if (l < 0)
				l := ColorListFirstX(lList, BarColorTolerance, y2, 0, CaptureW - 1)
			if (r < 0)
				r := ColorListLastX(rList, BarColorTolerance, y2, 0, CaptureW - 1)
			if (l >= 0 and r >= 0)
				break
			}
		}
	tcUsed := false
	refW := BarColRef()
	DllCall("QueryPerformanceCounter", "Int64*", tcNow)
	if (MgInPlay and refW > 8 and BarColT and ((tcNow - BarColT) / QpcFreq) <= 3.0)
		{
		curW := (l >= 0 and r > l) ? (r - l + 1) : 0
		if (curW < refW * 0.9 and BarByTrackContrast(row, tcL, tcW) and Abs(tcW - refW) <= refW * 0.25)
			{
			l := tcL
			r := tcL + tcW - 1
			tcUsed := true
			}
		}

	if (l < 0 or r < 0 or r <= l or (r - l + 1) > CaptureW * 0.75)
		{
		LastBarL := -1
		LastBarR := -1
		BarLiveMiss := BarLiveMiss + 1
		if (BarLiveMiss > 12)
			{
			BarLiveL := -1
			BarLiveR := -1
			BarWLive := -1
			BarLiveOnlyAt := 0
			}
		return false
		}
	LastBarL := l
	LastBarR := r
	if (tcUsed)
		{
		LastBarL := -1
		LastBarR := -1
		}
	RunLeft := l
	RunWidth := r - l + 1
	if (!tcUsed)
		{
		if (!IsObject(BarColRing))
			BarColRing := []
		BarColRing.Push(RunWidth)
		if (BarColRing.MaxIndex() > 5)
			BarColRing.RemoveAt(1)
		BarColT := tcNow
		}
	BarScanRow := row
	BarLiveMiss := 0

	pl := BarPixAt(Round(l - FishBarLeft) + 2, row)
	pr := BarPixAt(Round(r - FishBarLeft) - 2, row)
	cfgOk := false
	if (pl >= 0 and ColorListHitPx(lList, pl, BarColorTolerance))
		cfgOk := true
	if (pr >= 0 and ColorListHitPx(rList, pr, BarColorTolerance))
		cfgOk := true
	if (cfgOk)
		BarLiveOnlyAt := 0
	else
		{
		if (!BarLiveOnlyAt)
			BarLiveOnlyAt := A_TickCount
		else if ((A_TickCount - BarLiveOnlyAt) > 6000)
			{
			BarLiveL := -1
			BarLiveR := -1
			BarWLive := -1
			BarLiveOnlyAt := 0
			LastBarL := -1
			LastBarR := -1
			return false
			}
		}
	if (BarWLive <= 0 or Abs(RunWidth - BarWLive) <= (BarWLive * 0.35))
		{
		if (pl >= 0)
			BarLiveL := pl
		if (pr >= 0)
			BarLiveR := pr
		}
	BarWLive := RunWidth
	return true
}

MinigameVisible(minRun) {
	global CaptureW, BarRowAgreement, RunWidth, BarLeftColor, BarRightColor, SpecialRod
	if (SpecialRod = "Castbound" or SpecialRod = "Remembrance" or SpecialRod = "MiguRod" or SpecialRod = "Halibut Harpoon")
		return BarPresent()
	if (BarLeftColor != "" and BarRightColor != "")
		return FindBarByColor()
	if (!CalibrateBarRow(minRun))
		return false
	if (BarRowAgreement < 3)
		return false
	if (RunWidth > CaptureW * 0.75)
		return false
	return true
}

ColStats(x, ys, ByRef m, ByRef sd) {
	global pCaptureBits, CaptureW
	n := ys.MaxIndex()
	vals := []
	total := 0
	for i, y in ys
		{
		px := NumGet(pCaptureBits + 0, (y*CaptureW*4) + (x*4), "UInt")
		l := ((px & 0xFF) + ((px >> 8) & 0xFF) + ((px >> 16) & 0xFF)) // 3
		vals[i] := l
		total += l
		}
	m := total / n
	q := 0
	for i, l in vals
		q += (l-m)*(l-m)
	sd := Sqrt(q/n)
}

FindFishBand(xFrom, xTo, barKnown) {
	global CaptureW, CaptureH, FishBarLeft, RunLeft, RunWidth, LastFishX
	ys := []
	Loop, 7
		{
		ry := Floor(CaptureH * (A_Index*2 - 1) / 14)
		if (ry >= CaptureH)
			ry := CaptureH - 1
		ys.Push(ry)
		}
	off := Round(CaptureW * 0.025)
	if (off < 10)
		off := 10
	if (xFrom < off)
		xFrom := off
	if (xTo > CaptureW - off - 1)
		xTo := CaptureW - off - 1
	if (xFrom > xTo)
		return -1

	means := []
	sds := []
	x := xFrom - off
	while (x <= xTo + off)
		{
		ColStats(x, ys, m, sd)
		means[x] := m
		sds[x] := sd
		x++
		}

	bestC := -1
	bestScore := -1
	bandStart := -1
	x := xFrom
	while (x <= xTo + 1)
		{
		ok := false
		if (x <= xTo and sds[x] <= 25)
			{
			dl := means[x] - means[x-off]
			dr := means[x] - means[x+off]
			cmin := (Abs(dl) < Abs(dr)) ? Abs(dl) : Abs(dr)
			if (cmin >= 8 and ((dl > 0) = (dr > 0)))
				ok := true
			}
		if (ok)
			{
			if (bandStart < 0)
				bandStart := x
			}
		else if (bandStart >= 0)
			{
			w := x - bandStart
			if (w >= 5 and w <= 14)
				{
				c := Round(bandStart + w/2)
				dl := means[c] - means[c-off]
				dr := means[c] - means[c+off]
				peak := (Abs(dl) < Abs(dr)) ? Abs(dl) : Abs(dr)
				score := (LastFishX >= 0) ? (100000 - Abs((FishBarLeft + c) - LastFishX)) : peak
				if (score > bestScore)
					{
					bestScore := score
					bestC := c
					}
				}
			bandStart := -1
			}
		x++
		}
	if (bestC < 0)
		return -1
	return FishBarLeft + bestC
}

StripHasFishLine() {
	global CaptureW, CaptureH, BarScanRow
	off := Round(CaptureW * 0.025)
	if (off < 10)
		off := 10
	checkRows := []
	Loop, 5
		{
		ry := Floor(CaptureH * (A_Index*2 - 1) / 10)
		if (ry >= CaptureH)
			ry := CaptureH - 1
		checkRows.Push(ry)
		}
	xStart := off
	xEnd := CaptureW - off - 1
	x := xStart
	while (x <= xEnd)
		{
		if (IsDarkNotch(x, BarScanRow, off))
			{
			votes := 0
			for i, ry in checkRows
				{
				if (IsDarkNotch(x, ry, off))
					votes++
				}
			if (votes >= 3)
				return true
			}
		x++
		}
	return false
}

FindColorCenter(targetBGR, tol) {
	global pCaptureBits, CaptureW, CaptureH, FishBarLeft
	tB := (targetBGR >> 16) & 0xFF
	tG := (targetBGR >> 8) & 0xFF
	tR := targetBGR & 0xFF
	Loop, 5
		{
		y := Floor(CaptureH * (A_Index*2 - 1) / 10)
		if (y < 0)
			y := 0
		if (y >= CaptureH)
			y := CaptureH - 1
		rowOffset := y * CaptureW * 4
		runStart := -1
		runEnd := -1
		x := 0
		while (x < CaptureW)
			{
			px := NumGet(pCaptureBits + 0, rowOffset + (x*4), "UInt")
			b := px & 0xFF
			g := (px >> 8) & 0xFF
			r := (px >> 16) & 0xFF
			if (Abs(r-tR) <= tol and Abs(g-tG) <= tol and Abs(b-tB) <= tol)
				{
				if (runStart < 0)
					runStart := x
				runEnd := x
				}
			else if (runStart >= 0 and (x - runEnd) > 4)
				break
			x++
			}
		if (runStart >= 0)
			return FishBarLeft + ((runStart + runEnd) / 2)
		}
	return -1
}

GetFishPos() {
	global FishBarColorTolerance, LastFishX, CaptureW, CaptureH, FishBarLeft, FishColor, BarScanRow
	global RelLock, SpecialRod, PinFishX, ControlMode, LineFishX, NoiseFishX, CastFishX, RemTargetX, MiguFishX, HaliFishX
	if (SpecialRod = "Castbound")
		{
		CastboundScan()
		return CastFishX
		}
	if (SpecialRod = "Halibut Harpoon")
		{
		if (HalibutBarScan())
			return HaliFishX
		return -1
		}
	if (SpecialRod = "Noiseform")
		{
		NoiseScan()
		return NoiseFishX
		}
	if (SpecialRod = "Remembrance")
		{
		if (RemembranceScan())
			return RemTargetX
		return -1
		}
	if (SpecialRod = "MiguRod")
		{
		if (MiguScan())
			return MiguFishX
		return -1
		}
	if (ControlMode = "Lines")
		{
		LineScan()
		if (LineFishX >= 0)
			return LineFishX
		}
	if (SpecialRod = "Pinions Aria")
		{
		PinionScan()
		if (PinFishX >= 0)
			return PinFishX
		}
	if (RelLock = 1)
		{
		rfx := FindFishRelative()
		if (rfx >= 0)
			return rfx
		}
	fList := ColorListParse(FishColor)
	tol := FishBarColorTolerance
	row := BarScanRow
	if (row < 0 or row >= CaptureH)
		row := CaptureH // 2

	if (LastFishX >= 0)
		{
		lx := Round(LastFishX - FishBarLeft)
		fx := ColorListCenterX(fList, tol, row, lx - 55, lx + 55)
		if (fx >= 0)
			{
			LastFishX := fx
			return fx
			}
		}
	fx := ColorListCenterX(fList, tol, row, 0, CaptureW - 1)
	if (fx >= 0)
		{
		LastFishX := fx
		return fx
		}
	Loop, 3
		{
		y2 := Floor(CaptureH * (A_Index*2 - 1) / 6)
		fx := ColorListCenterX(fList, tol, y2, 0, CaptureW - 1)
		if (fx >= 0)
			{
			LastFishX := fx
			return fx
			}
		}
	fx := FindFishBand(0, CaptureW - 1, true)
	if (fx >= 0)
		{
		LastFishX := fx
		return fx
		}
	return LastFishX
}

GetFishX() {
	global CaptureW, CaptureH, FishBarLeft, BarScanRow, RunLeft, RunWidth, LastFishX
	y := BarScanRow
	if (y < 0 or y >= CaptureH)
		y := CaptureH // 2
	off := Round(CaptureW * 0.025)
	if (off < 10)
		off := 10
	ref := (LastFishX >= 0) ? LastFishX : (RunLeft + RunWidth/2)

	checkRows := []
	Loop, 5
		{
		ry := Floor(CaptureH * (A_Index*2 - 1) / 10)
		if (ry < 0)
			ry := 0
		if (ry >= CaptureH)
			ry := CaptureH - 1
		checkRows.Push(ry)
		}

	bestX := -1
	bestDist := 999999
	x := off
	while (x < CaptureW - off)
		{
		if (IsDarkNotch(x, y, off))
			{
			votes := 0
			for i, ry in checkRows
				{
				if (IsDarkNotch(x, ry, off))
					votes++
				}
			if (votes >= 3)
				{
				cx := FishBarLeft + x
				d := Abs(cx - ref)
				if (d < bestDist)
					{
					bestDist := d
					bestX := cx
					}
				}
			}
		x++
		}
	if (bestX < 0)
		return -1
	LastFishX := bestX
	return bestX
}

IsDarkNotch(x, y, off) {
	global pCaptureBits, CaptureW, CaptureH
	if (y < 0 or y >= CaptureH or x < off or x >= CaptureW - off)
		return false
	rowOffset := y * CaptureW * 4
	pc := NumGet(pCaptureBits + 0, rowOffset + (x*4), "UInt")
	pl := NumGet(pCaptureBits + 0, rowOffset + ((x-off)*4), "UInt")
	pr := NumGet(pCaptureBits + 0, rowOffset + ((x+off)*4), "UInt")
	c := ((pc & 0xFF) + ((pc >> 8) & 0xFF) + ((pc >> 16) & 0xFF)) // 3
	lN := ((pl & 0xFF) + ((pl >> 8) & 0xFF) + ((pl >> 16) & 0xFF)) // 3
	rN := ((pr & 0xFF) + ((pr >> 8) & 0xFF) + ((pr >> 16) & 0xFF)) // 3
	navg := (lN + rN) // 2
	margin := Round(navg * 0.25)
	if (margin < 8)
		margin := 8
	return (lN - c >= margin and rN - c >= margin)
}

FindColorX(targetHex, tol) {
	global pCaptureBits, CaptureW, CaptureH, FishBarLeft
	tB := (targetHex >> 16) & 0xFF
	tG := (targetHex >> 8) & 0xFF
	tR := targetHex & 0xFF
	Loop, 5
		{
		y := Floor(CaptureH * (A_Index*2 - 1) / 10)
		if (y < 0)
			y := 0
		if (y >= CaptureH)
			y := CaptureH - 1
		rowOffset := y * CaptureW * 4
		Loop, % CaptureW
			{
			x := A_Index - 1
			px := NumGet(pCaptureBits + 0, rowOffset + (x*4), "UInt")
			b := px & 0xFF
			g := (px >> 8) & 0xFF
			r := (px >> 16) & 0xFF
			if (Abs(r-tR) <= tol and Abs(g-tG) <= tol and Abs(b-tB) <= tol)
				return FishBarLeft + x
			}
		}
	return -1
}


BGR(hex) {
	r := "0x" . SubStr(hex,1,2)
	g := "0x" . SubStr(hex,3,2)
	b := "0x" . SubStr(hex,5,2)
	return (b<<16) | (g<<8) | r
}

EnsureBrush(ByRef hBrush, hexColor) {
	if (!hBrush)
		hBrush := DllCall("CreateSolidBrush", "UInt", BGR(hexColor), "Ptr")
	return hBrush
}

WM_CTLCOLOREDIT(wParam, lParam, msg, hwnd) {
	global hBrushInput, ColorInputBGR, ColorInput, hMgCodeBox, hBrushWhite
	if (hMgCodeBox and lParam = hMgCodeBox)
		{
		DllCall("SetTextColor", "Ptr", wParam, "UInt", 0x101010)
		DllCall("SetBkColor", "Ptr", wParam, "UInt", 0xFFFFFF)
		return EnsureBrush(hBrushWhite, "FFFFFF")
		}
	DllCall("SetBkMode", "Ptr", wParam, "Int", 1)
	DllCall("SetTextColor", "Ptr", wParam, "UInt", 0xFFFFFF)
	DllCall("SetBkColor", "Ptr", wParam, "UInt", ColorInputBGR)
	return EnsureBrush(hBrushInput, ColorInput)
}

WM_CTLCOLORBTN(wParam, lParam, msg, hwnd) {
	global hBrushBG, ColorTextBGR, ColorBG
	DllCall("SetBkMode", "Ptr", wParam, "Int", 1)
	DllCall("SetTextColor", "Ptr", wParam, "UInt", ColorTextBGR)
	return EnsureBrush(hBrushBG, ColorBG)
}

WM_MOUSEMOVE(wParam, lParam, msg, hwnd) {
	global IconTips
	static lastHwnd := 0
	if (hwnd = lastHwnd)
		return
	lastHwnd := hwnd
	if (IsObject(IconTips) and IconTips.HasKey(hwnd))
		{
		ToolTip, % IconTips[hwnd], , , 3
		SetTimer, ClearIconTip, 120
		}
	else
		ToolTip, , , , 3
}

WM_SETCURSOR(wParam, lParam, msg, hwnd) {
	global hVersionsBtn
	if (hVersionsBtn and wParam = hVersionsBtn)
		{
		DllCall("SetCursor", "Ptr", DllCall("LoadCursor", "Ptr", 0, "Ptr", 32649, "Ptr"))
		return true
		}
}

WM_MOUSEWHEEL(wParam, lParam, msg, hwnd) {
	global hFaqBox, GuiHwnd, SIDEW, HEADH, BARH, DpiF
	mwD := (wParam >> 16) & 0xFFFF
	if (mwD > 32767)
		mwD -= 65536
	MouseGetPos, , , , mwCtl, 2
	if (hFaqBox and mwCtl = hFaqBox)
		{
		mwLines := (mwD > 0) ? -3 : 3
		SendMessage, 0xB6, 0, %mwLines%, , ahk_id %hFaqBox%
		return 0
		}
	if (!GuiHwnd)
		return
	mwSx := lParam & 0xFFFF
	if (mwSx > 32767)
		mwSx -= 65536
	mwSy := (lParam >> 16) & 0xFFFF
	if (mwSy > 32767)
		mwSy -= 65536
	VarSetCapacity(mwPt, 8, 0)
	NumPut(mwSx, mwPt, 0, "Int")
	NumPut(mwSy, mwPt, 4, "Int")
	DllCall("ScreenToClient", "Ptr", GuiHwnd, "Ptr", &mwPt)
	mwCx := NumGet(mwPt, 0, "Int") / DpiF
	mwCy := NumGet(mwPt, 4, "Int") / DpiF
	if (mwCx < SIDEW or mwCy < HEADH + BARH)
		return
	ScrollBy((mwD > 0) ? -66 : 66)
	return 0
}

WM_CTLCOLORSTATIC(wParam, lParam, msg, hwnd) {
	global hBrushBG, hBrushGreen, hBrushRed, hStartStopBtnHwnd, SpecialBrushes, MacroRunning, ColorTextBGR
	global ColorBG, ColorGreen, ColorRed, hFrzGui
	if (hFrzGui and DllCall("GetParent", "Ptr", lParam, "Ptr") = hFrzGui)
		return
	DllCall("SetBkMode", "Ptr", wParam, "Int", 1)
	if (lParam = hStartStopBtnHwnd)
		{
		DllCall("SetTextColor", "Ptr", wParam, "UInt", 0xFFFFFF)
		if (MacroRunning)
			return EnsureBrush(hBrushRed, ColorRed)
		return EnsureBrush(hBrushGreen, ColorGreen)
		}
	if (IsObject(SpecialBrushes) and SpecialBrushes.HasKey(lParam))
		{
		e := SpecialBrushes[lParam]
		if (e.brush)
			{
			DllCall("SetTextColor", "Ptr", wParam, "UInt", e.text)
			return e.brush
			}
		}
	DllCall("SetTextColor", "Ptr", wParam, "UInt", ColorTextBGR)
	return EnsureBrush(hBrushBG, ColorBG)
}

;====================================================================================================;

;====================================================================================================;
;====================================================================================================;

CtrlSnapPos(h, ByRef cx, ByRef cy, ByRef cw, ByRef ch) {
	global GuiHwnd, DpiF
	VarSetCapacity(sr, 16, 0)
	DllCall("GetWindowRect", "Ptr", h, "Ptr", &sr)
	VarSetCapacity(sp, 8, 0)
	NumPut(NumGet(sr, 0, "Int"), sp, 0, "Int")
	NumPut(NumGet(sr, 4, "Int"), sp, 4, "Int")
	DllCall("ScreenToClient", "Ptr", GuiHwnd, "Ptr", &sp)
	cx := Round(NumGet(sp, 0, "Int") / DpiF)
	cy := Round(NumGet(sp, 4, "Int") / DpiF)
	cw := Round((NumGet(sr, 8, "Int") - NumGet(sr, 0, "Int")) / DpiF)
	ch := Round((NumGet(sr, 12, "Int") - NumGet(sr, 4, "Int")) / DpiF)
}

SnapshotBase(lst) {
	global CtrlBaseX, CtrlBaseY, CtrlW, CtrlH
	for i, h in lst
		{
		if (CtrlBaseY.HasKey(h))
			continue
		CtrlSnapPos(h, cx, cy, cw, ch)
		CtrlBaseX[h] := cx
		CtrlBaseY[h] := cy
		CtrlW[h] := cw
		CtrlH[h] := ch
		}
}

SetBase(h, x, y) {
	global CtrlBaseX, CtrlBaseY, CtrlW, CtrlH
	CtrlBaseX[h] := x
	CtrlBaseY[h] := y
	if (!CtrlH.HasKey(h) or !CtrlW.HasKey(h))
		{
		CtrlSnapPos(h, cx, cy, cw, ch)
		CtrlW[h] := cw
		CtrlH[h] := ch
		}
}

ShowList(lst, cond) {
	for i, h in lst
		GuiControl, % (cond ? "1:Show" : "1:Hide"), %h%
}

CollectVisible() {
	global AllManaged, VisibleCtrls
	VisibleCtrls := []
	for i, h in AllManaged
		{
		if (DllCall("GetWindowLong", "Ptr", h, "Int", -16) & 0x10000000)
			VisibleCtrls.Push(h)
		}
}

ApplyScroll() {
	global VisibleCtrls, CtrlBaseX, CtrlBaseY, CtrlW, CtrlH, CtrlRgnR, CtrlClip
	global SecScroll, SecMaxScroll, TargetSection, WINH, WINW, SecTopEdge, GuiHwnd
	global SbTrack, SbThumb, SbTrackH, SbThumbH, SbShown, DpiF
	bot := 0
	for i, h in VisibleCtrls
		{
		if (!CtrlBaseY.HasKey(h))
			continue
		bb := CtrlBaseY[h] + CtrlH[h]
		if (bb > bot)
			bot := bb
		}
	mx := bot + 14 - WINH
	if (mx < 0)
		mx := 0
	SecMaxScroll := mx
	off := SecScroll.HasKey(TargetSection) ? SecScroll[TargetSection] : 0
	if (off > mx)
		off := mx
	if (off < 0)
		off := 0
	SecScroll[TargetSection] := off

	if (SbTrack and SbThumb)
		{
		SbTop := SecTopEdge + 6
		SbH := WINH - SbTop - 12
		SbX := WINW - 15
		if (mx <= 0 or SbH < 40)
			{
			if (SbShown != 0)
				{
				SbShown := 0
				GuiControl, 1:Hide, %SbTrack%
				GuiControl, 1:Hide, %SbThumb%
				}
			}
		else
			{
			SbView := WINH - SecTopEdge
			SbTh := Round(SbH * SbView / (SbView + mx))
			if (SbTh < 30)
				SbTh := 30
			if (SbTh > SbH)
				SbTh := SbH
			SbY := SbTop + Round((SbH - SbTh) * off / mx)
			GuiControl, 1:Move, %SbTrack%, % "x" . SbX . " y" . SbTop . " w9 h" . SbH
			GuiControl, 1:Move, %SbThumb%, % "x" . SbX . " y" . SbY . " w9 h" . SbTh
			if (SbTrackH != SbH)
				{
				SbTrackH := SbH
				SbRgn := DllCall("CreateRoundRectRgn", "Int", 0, "Int", 0, "Int", Round(9 * DpiF) + 1, "Int", Round(SbH * DpiF) + 1
					, "Int", Round(9 * DpiF), "Int", Round(9 * DpiF), "Ptr")
				DllCall("SetWindowRgn", "Ptr", SbTrack, "Ptr", SbRgn, "Int", true)
				}
			if (SbThumbH != SbTh)
				{
				SbThumbH := SbTh
				SbRgn := DllCall("CreateRoundRectRgn", "Int", 0, "Int", 0, "Int", Round(9 * DpiF) + 1, "Int", Round(SbTh * DpiF) + 1
					, "Int", Round(9 * DpiF), "Int", Round(9 * DpiF), "Ptr")
				DllCall("SetWindowRgn", "Ptr", SbThumb, "Ptr", SbRgn, "Int", true)
				}
			if (SbShown != 1)
				{
				SbShown := 1
				GuiControl, 1:Show, %SbTrack%
				GuiControl, 1:Show, %SbThumb%
				}
			}
		}

	n := VisibleCtrls.MaxIndex()
	if (!n)
		return
	shrunk := []
	hdwp := DllCall("BeginDeferWindowPos", "Int", n, "Ptr")
	for i, h in VisibleCtrls
		{
		if (!CtrlBaseY.HasKey(h))
			continue
		ny := CtrlBaseY[h] - off
		if (!IsCard(h))
			{
			if (ny < SecTopEdge)
				ny := -6000
			hdwp := DllCall("DeferWindowPos", "Ptr", hdwp, "Ptr", h, "Ptr", 0
				, "Int", Round(CtrlBaseX[h] * DpiF), "Int", (ny = -6000) ? ny : Round(ny * DpiF), "Int", 0, "Int", 0, "UInt", 0x001D, "Ptr")
			continue
			}
		cw := CtrlW[h]
		ch := CtrlH[h]
		nh := ch
		cut := 0
		if (ny + ch <= SecTopEdge)
			ny := -6000
		else if (ny < SecTopEdge)
			{
			cut := SecTopEdge - ny
			nh := ch - cut
			ny := SecTopEdge
			}
		shrunk.Push({h: h, cut: cut, w: cw, r: CtrlRgnR[h], ht: nh})
		hdwp := DllCall("DeferWindowPos", "Ptr", hdwp, "Ptr", h, "Ptr", 0
			, "Int", Round(CtrlBaseX[h] * DpiF), "Int", (ny = -6000) ? ny : Round(ny * DpiF)
			, "Int", Round(cw * DpiF), "Int", Round(nh * DpiF), "UInt", 0x0014, "Ptr")
		}
	DllCall("EndDeferWindowPos", "Ptr", hdwp)

	for i, e in shrunk
		{
		h := e.h
		prev := CtrlClip.HasKey(h) ? CtrlClip[h] : 0
		if (e.cut = prev)
			continue
		CtrlClip[h] := e.cut
		if (e.cut > 0)
			DllCall("SetWindowRgn", "Ptr", h, "Ptr", 0, "Int", true)
		else
			{
			rgn := DllCall("CreateRoundRectRgn", "Int", 0, "Int", 0, "Int", Round(e.w * DpiF) + 1, "Int", Round(e.ht * DpiF) + 1
				, "Int", Round(e.r * 2 * DpiF), "Int", Round(e.r * 2 * DpiF), "Ptr")
			DllCall("SetWindowRgn", "Ptr", h, "Ptr", rgn, "Int", true)
			}
		}
	DllCall("RedrawWindow", "Ptr", GuiHwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x0185)
}

IsCard(h) {
	global CtrlRgnR, CtrlH
	if (!CtrlRgnR.HasKey(h) or !CtrlH.HasKey(h))
		return false
	return (CtrlRgnR[h] > 0 and CtrlH[h] > 44)
}


ScrollBy(delta) {
	global SecScroll, SecMaxScroll, TargetSection, GuiHwnd
	off := SecScroll.HasKey(TargetSection) ? SecScroll[TargetSection] : 0
	nw := off + delta
	if (nw < 0)
		nw := 0
	if (nw > SecMaxScroll)
		nw := SecMaxScroll
	if (nw = off)
		return
	SecScroll[TargetSection] := nw
	if (GuiHwnd)
		{
		DllCall("SendMessage", "Ptr", GuiHwnd, "UInt", 0x000B, "Ptr", 0, "Ptr", 0)
		ApplyScroll()
		DllCall("SendMessage", "Ptr", GuiHwnd, "UInt", 0x000B, "Ptr", 1, "Ptr", 0)
		DllCall("RedrawWindow", "Ptr", GuiHwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x0185)
		}
	else
		ApplyScroll()
}

;====================================================================================================;
;====================================================================================================;

MgCodeCue(txt) {
	global hMgCodeBox
	if (hMgCodeBox)
		DllCall("SendMessage", "Ptr", hMgCodeBox, "UInt", 0x1501, "Ptr", 1, "WStr", txt)
}

MgBlockOpen(name, cardY, h) {
	global MgBlocks, MgAllCtrls, CARDX, CARDW
	hc := AddPanel(CARDX, cardY, CARDW, h)
	MgBlocks[name] := {card: hc, y: cardY, h: h, ctrls: [], dxs: [], dys: []}
	MgAllCtrls.Push(hc)
}

MgAdd(name, h) {
	global MgBlocks, MgAllCtrls, CtrlW, CtrlH
	b := MgBlocks[name]
	if (!IsObject(b))
		return
	CtrlSnapPos(h, cx, cy, cw, ch)
	b.ctrls.Push(h)
	b.dxs.Push(cx)
	b.dys.Push(cy - b.y)
	if (!CtrlW.HasKey(h))
		CtrlW[h] := cw
	if (!CtrlH.HasKey(h))
		CtrlH[h] := ch
	MgAllCtrls.Push(h)
}

LayoutMinigame() {
	global MgBlocks, MgVisible, SpecialRod, ControlMode, CARDX, MiniTop
	MgVisible := {}
	vis := ["mode"]
	if (SpecialRod = "Remembrance")
		vis.Push("remem")
	if (SpecialRod = "Pinions Aria")
		vis.Push("notes")
	else if (ControlMode != "Lines" or SpecialRod = "Remembrance")
		vis.Push("colors")
	if (SpecialRod = "Requiem")
		vis.Push("reel")
	if (ControlMode = "Manual")
		vis.Push("manual")
	else
		vis.Push("precision")
	vis.Push("barctl")
	if (ControlMode = "Manual")
		vis.Push("manrules")
	else
		vis.Push("precrules")
	vis.Push("detcheck")
	y := MiniTop
	for i, nm in vis
		{
		b := MgBlocks[nm]
		if (!IsObject(b))
			continue
		MgVisible[nm] := 1
		SetBase(b.card, CARDX, y)
		for j, h in b.ctrls
			SetBase(h, b.dxs[j], y + b.dys[j])
		y += b.h + 10
		}
}

AddPanel(px, py, pw, ph, pr := 10) {
	global SpecialBrushes, hBrushCard, ColorTextBGR, CardRects, CtrlRgnR, CtrlW, CtrlH
	if (!IsObject(CardRects))
		CardRects := []
	CardRects.Push({x: px, y: py, w: pw, h: ph})
	Gui, 1:Add, Text, x%px% y%py% w%pw% h%ph% HwndhPnl
	SpecialBrushes[hPnl] := {brush: hBrushCard, text: ColorTextBGR}
	if (pr > 0)
		RoundCtrl(hPnl, pw, ph, pr)
	return hPnl
}

FixCardBrushes(lst) {
	global SpecialBrushes, hBrushCard, ColorTextBGR, CardRects, GuiHwnd, DpiF
	if (!IsObject(CardRects))
		return
	for i, h in lst
		{
		if (SpecialBrushes.HasKey(h))
			continue
		VarSetCapacity(fcr, 16, 0)
		DllCall("GetWindowRect", "Ptr", h, "Ptr", &fcr)
		VarSetCapacity(fcp, 8, 0)
		NumPut(NumGet(fcr, 0, "Int"), fcp, 0, "Int")
		NumPut(NumGet(fcr, 4, "Int"), fcp, 4, "Int")
		DllCall("ScreenToClient", "Ptr", GuiHwnd, "Ptr", &fcp)
		cx := Round(NumGet(fcp, 0, "Int") / DpiF)
		cy := Round(NumGet(fcp, 4, "Int") / DpiF)
		for j, rc in CardRects
			{
			if (cx >= rc.x and cy >= rc.y and cx < rc.x + rc.w and cy < rc.y + rc.h)
				{
				SpecialBrushes[h] := {brush: hBrushCard, text: ColorTextBGR}
				break
				}
			}
		}
}

RoundCtrl(h, w, ht, r) {
	global CtrlRgnR, CtrlW, CtrlH, DpiF
	CtrlRgnR[h] := r
	CtrlW[h] := w
	CtrlH[h] := ht
	rgn := DllCall("CreateRoundRectRgn", "Int", 0, "Int", 0, "Int", Round(w * DpiF) + 1, "Int", Round(ht * DpiF) + 1
		, "Int", Round(r * 2 * DpiF), "Int", Round(r * 2 * DpiF), "Ptr")
	DllCall("SetWindowRgn", "Ptr", h, "Ptr", rgn, "Int", true)
}

;====================================================================================================;

BuildGui:

ColorBG := "121212"
ColorPanel := "1E1E1E"
ColorCard := "1B1B1B"
ColorInput := "0E0E0E"
ColorAccent := "5EA6FF"
ColorText := "4EA1F7"
ColorMuted := "3B6E99"
ColorBorder := "2A2A2A"
ColorGreen := "22C55E"
ColorRed := "EF4444"
ColorAmber := "F59E0B"
ColorDark := "1F2937"

ColorWhite := "FFFFFF"
ColorTextBGR := BGR(ColorText)
ColorWhiteBGR := BGR(ColorWhite)
ColorPanelBGR := BGR(ColorPanel)
ColorCardBGR := BGR(ColorCard)
ColorInputBGR := BGR(ColorInput)
ColorDarkBGR := BGR(ColorDark)
ColorMutedBGR := BGR(ColorMuted)
ColorAccentBGR := BGR(ColorAccent)
ColorGreenBGR := BGR(ColorGreen)
ColorAmberBGR := BGR(ColorAmber)
ColorYellowBGR := BGR("FACC15")
ColorRedBGR := BGR(ColorRed)

hBrushBG := DllCall("CreateSolidBrush", "UInt", BGR(ColorBG), "Ptr")
hBrushPanel := DllCall("CreateSolidBrush", "UInt", BGR(ColorPanel), "Ptr")
hBrushCard := DllCall("CreateSolidBrush", "UInt", BGR(ColorCard), "Ptr")
hBrushInput := DllCall("CreateSolidBrush", "UInt", BGR(ColorInput), "Ptr")
hBrushGreen := DllCall("CreateSolidBrush", "UInt", BGR(ColorGreen), "Ptr")
hBrushRed := DllCall("CreateSolidBrush", "UInt", BGR(ColorRed), "Ptr")
hBrushBorder := DllCall("CreateSolidBrush", "UInt", BGR(ColorBorder), "Ptr")
hBrushSbTrack := DllCall("CreateSolidBrush", "UInt", BGR("1A1A1A"), "Ptr")
hBrushSbThumb := DllCall("CreateSolidBrush", "UInt", BGR("6E6E6E"), "Ptr")
hBrushAmber := DllCall("CreateSolidBrush", "UInt", BGR(ColorAmber), "Ptr")
hBrushAccent := DllCall("CreateSolidBrush", "UInt", BGR(ColorAccent), "Ptr")

SpecialBrushes := {}

OnMessage(0x133, "WM_CTLCOLOREDIT")
OnMessage(0x135, "WM_CTLCOLORBTN")
OnMessage(0x138, "WM_CTLCOLORSTATIC")

GeneralCtrls := []
CastCtrls := []
NormalCastCtrls := []
PerfectCastCtrls := []
ShakeCtrls := []
UtilCtrls := []
TotemCtrls := []
TotemBodyCtrls := []
AquariumCtrls := []
AquariumBodyCtrls := []
KeeperCtrls := []
KeeperBodyCtrls := []
WebhookCtrls := []
WebhookBodyCtrls := []
FaqCtrls := []
AboutCtrls := []
VersionsCtrls := []
ReadThisCtrls := []
ThemedCtrls := []
CMCtrls := []
NavHwnd := {}

WINW := 760
WINH := 520
SIDEW := 176
HEADH := 70
BARH := 44
CARDX := 188
CARDW := 556
CX := 204
LW := 230
IX := 442
IW := 200
SWX := 678
SWW := 44
QX := 652
DX := 586
DW := 56
RH := 26
TXW := 524
ContentTop := 136

Gui, +HwndGuiHwnd -MaximizeBox +0x02000000
Gui, Font, s9 c%ColorText%, Segoe UI
Gui, Color, %ColorBG%, %ColorBG%
Gui, Margin, 0, 0

;---- Header ----------------------------------------------------------------------------------

Gui, Font, s14 Bold c%ColorText%, Segoe UI
Gui, Add, Text, x20 y13 w320 h28, 🐟 DeepFish BETA
Gui, Font, s8 Norm c%ColorMuted%, Segoe UI
Gui, Add, Text, x22 y42 w320 h16 HwndhSubtitle, Version 1.0.1  •  Made by Yato
SpecialBrushes[hSubtitle] := {brush: hBrushBG, text: ColorMutedBGR}

Gui, Font, s9 Bold c%ColorMuted%, Segoe UI
Gui, Add, Text, x490 y22 w130 h28 Center +0x100 +0x200 vRunStatusText HwndhRunStatus, ●  Idle
SpecialBrushes[hRunStatus] := {brush: hBrushPanel, text: ColorMutedBGR}
RoundCtrl(hRunStatus, 130, 28, 14)

StartStopLabel := MacroRunning ? "⏹ Stop" : "▶ Start"
Gui, Font, s10 Bold cFFFFFF, Segoe UI
Gui, Add, Text, x632 y18 w108 h36 Center +0x100 +0x200 vStartStopDisplay gPreviewOrToggle HwndhStartStopBtnHwnd, %StartStopLabel%

Gui, Add, Text, x0 y%HEADH% w%WINW% h1 HwndhDiv1
SpecialBrushes[hDiv1] := {brush: hBrushBorder, text: ColorTextBGR}

;---- Profile bar -----------------------------------------------------------------------------

ProfBarY := HEADH + 1
Gui, Add, Text, x0 y%ProfBarY% w%WINW% h%BARH% HwndhProfBG
SpecialBrushes[hProfBG] := {brush: hBrushPanel, text: ColorTextBGR}

Gui, Font, s9 c%ColorText%, Segoe UI
Gui, Add, Text, x20 y82 w20 h22 +0x200 HwndhProfIcon, 📁
SpecialBrushes[hProfIcon] := {brush: hBrushPanel, text: ColorTextBGR}
Gui, Add, DropDownList, x42 y80 w168 h240 vProfileSelect gProfileSelect HwndhProfileSelect
ThemedCtrls.Push(hProfileSelect)
gosub, RefreshProfileList

IconTips := {}

Gui, Add, Text, x218 y79 w28 h26 Center +0x100 +0x200 gProfileNew HwndhTipNew, ➕
SpecialBrushes[hTipNew] := {brush: hBrushBorder, text: ColorTextBGR}
RoundCtrl(hTipNew, 28, 26, 6)
IconTips[hTipNew] := "New profile"
Gui, Add, Text, x250 y79 w28 h26 Center +0x100 +0x200 gProfileDuplicate HwndhTipDup, 📄
SpecialBrushes[hTipDup] := {brush: hBrushBorder, text: ColorTextBGR}
RoundCtrl(hTipDup, 28, 26, 6)
IconTips[hTipDup] := "Duplicate current profile"
Gui, Add, Text, x282 y79 w28 h26 Center +0x100 +0x200 gProfileDelete HwndhTipDel, 🗑
SpecialBrushes[hTipDel] := {brush: hBrushBorder, text: ColorTextBGR}
RoundCtrl(hTipDel, 28, 26, 6)
IconTips[hTipDel] := "Delete current profile"
Gui, Add, Text, x314 y79 w28 h26 Center +0x100 +0x200 gMgCopyCode HwndhTipCopy, 📋
SpecialBrushes[hTipCopy] := {brush: hBrushBorder, text: ColorRedBGR}
RoundCtrl(hTipCopy, 28, 26, 6)
IconTips[hTipCopy] := "Copy your Minigame settings as a code"
Gui, Font, s9 Norm c101010, Segoe UI
Gui, Add, Edit, x346 y80 w156 h24 -Multi vMgCodeBox gMgCodeBoxChanged HwndhMgCodeBox
MgCodeBoxPrevLen := 0
MgCodeCue("Paste minigame code here")
IconTips[hMgCodeBox] := "Paste a Minigame settings code someone sent you.`nIt is applied and saved as soon as you paste it."

Gui, Font, s9 c%ColorAccent%, Segoe UI
Gui, Add, Text, x508 y79 w28 h26 Center +0x100 +0x200 gRevertSettings HwndhTipRevert, ↶
SpecialBrushes[hTipRevert] := {brush: hBrushBorder, text: ColorAccentBGR}
RoundCtrl(hTipRevert, 28, 26, 6)
IconTips[hTipRevert] := "Undo the last save (restores the previous saved values)"
Gui, Font, s9 Bold, Segoe UI
Gui, Add, Text, x546 y78 w84 h28 Center +0x100 +0x200 vSaveStatusText gSaveSettings HwndhTipSave, 💾 Save
SpecialBrushes[hTipSave] := {brush: hBrushAccent, text: 0x101010}
RoundCtrl(hTipSave, 84, 28, 7)
IconTips[hTipSave] := "Save settings to current profile"

Gui, Font, s9 Norm c%ColorText%, Segoe UI
autoChk := GuiAutoSave ? "Checked" : ""
Gui, Add, CheckBox, x640 y83 w100 h20 c%ColorText% vGuiAutoSave %autoChk% gToggleAutoSave HwndhTipAuto, Auto-save
SpecialBrushes[hTipAuto] := {brush: hBrushPanel, text: ColorTextBGR}
IconTips[hTipAuto] := "Save automatically whenever a setting changes"

Gui, Font, s9 c%ColorAccent%, Segoe UI

OnMessage(0x200, "WM_MOUSEMOVE")
OnMessage(0x20A, "WM_MOUSEWHEEL")
OnMessage(0x20, "WM_SETCURSOR")

DivY := HEADH + BARH + 1
Gui, Add, Text, x0 y%DivY% w%WINW% h4 HwndhDivFill
SpecialBrushes[hDivFill] := {brush: hBrushBG, text: ColorTextBGR}
Gui, Add, Text, x0 y%DivY% w%WINW% h1 HwndhDiv2
SpecialBrushes[hDiv2] := {brush: hBrushBorder, text: ColorTextBGR}

;---- Sidebar ---------------------------------------------------------------------------------

SideY := DivY + 1
SideH := WINH - SideY
Gui, Add, Text, x0 y%SideY% w%SIDEW% h%SideH% HwndhSidebarBG
SpecialBrushes[hSidebarBG] := {brush: hBrushPanel, text: ColorTextBGR}

NavDefs := [ ["ReadThis","⚠  READ THIS"], ["General","🎣  General"], ["Cast","🎯  Cast"], ["Shake","🐚  Shake"]
	, ["Minigame","🎮  Minigame"], ["Utilities","🧰  Utilities"]
	, ["Faq","❓  FAQ"], ["About","ℹ️  About"] ]

Gui, Font, s10 Bold c%ColorText%, Segoe UI
NavY := SideY + 12
for i, d in NavDefs
	{
	nk := d[1]
	nl := d[2]
	Gui, Add, Text, x4 y%NavY% w4 h34 vNavBar%nk% HwndhNB
	SpecialBrushes[hNB] := {brush: hBrushPanel, text: ColorTextBGR}
	RoundCtrl(hNB, 4, 34, 2)
	NavHwnd["bar" . nk] := hNB
	Gui, Add, Text, x12 y%NavY% w158 h34 +0x200 vNav%nk% gSidebarClick HwndhNV, %nl%
	SpecialBrushes[hNV] := {brush: hBrushPanel, text: (nk = "ReadThis") ? ColorRedBGR : ColorTextBGR}
	NavHwnd[nk] := hNV
	NavY += 38
	}

Gui, Font, s9 Bold c%ColorRed%, Segoe UI
VersionsBtnY := WINH - 80
Gui, Add, Text, x12 y%VersionsBtnY% w152 h28 Center +0x100 +0x200 gVersionsClick HwndhVersionsBtn, 📜  Versions
SpecialBrushes[hVersionsBtn] := {brush: hBrushBorder, text: ColorRedBGR}
RoundCtrl(hVersionsBtn, 152, 28, 7)

Gui, Font, s8 Norm c%ColorMuted%, Segoe UI
SideFootY := WINH - 42
Gui, Add, Text, x14 y%SideFootY% w156 h16 HwndhSideFoot1, F9  ·  Colors
SpecialBrushes[hSideFoot1] := {brush: hBrushPanel, text: ColorMutedBGR}
SideFootY += 16
Gui, Add, Text, x14 y%SideFootY% w156 h16 HwndhSideFoot2, © 2026 Yato
SpecialBrushes[hSideFoot2] := {brush: hBrushPanel, text: ColorMutedBGR}

Gui, Font, s9 Bold c%ColorMuted%, Segoe UI
Gui, Add, Text, x%CARDX% y122 w150 h30 Center +0x100 +0x200 vMiniTabSetup gMiniTabClick HwndhMT, Setup
MiniTabSetupH := hMT
RoundCtrl(hMT, 150, 30, 8)
Gui, Add, Text, x336 y122 w170 h30 Center +0x100 +0x200 vMiniTabColors gMiniTabClick HwndhMT, Color Manager
MiniTabColorsH := hMT
RoundCtrl(hMT, 170, 30, 8)
Gui, Font, s9 Norm c%ColorMuted%, Segoe UI

AllManaged := []
NeedSection := "General"
gosub, EnsureSection

TargetSection := "General"
gosub, ApplyCastModeLocks
gosub, ShowSection

if (GuiAlwaysOnTop)
	Gui, +AlwaysOnTop

RoundCtrl(hStartStopBtnHwnd, 108, 36, 10)
darkAttr := 1
DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", GuiHwnd, "Int", 20, "Int*", darkAttr, "Int", 4)
DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", GuiHwnd, "Int", 19, "Int*", darkAttr, "Int", 4)

SbX := WINW - 15
Gui, Add, Text, x%SbX% y158 w9 h200 HwndSbTrack
SpecialBrushes[SbTrack] := {brush: hBrushSbTrack, text: 0xFFFFFF}
Gui, Add, Text, x%SbX% y158 w9 h60 HwndSbThumb
SpecialBrushes[SbThumb] := {brush: hBrushSbThumb, text: 0xFFFFFF}
DllCall("SetWindowPos", "Ptr", SbThumb, "Ptr", 0, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x13)
GuiControl, 1:Hide, %SbTrack%
GuiControl, 1:Hide, %SbThumb%

Gui, Show, w%WINW% h%WINH%, DeepFish BETA
SetTimer, DFCheckForUpdate, -1200
gosub, RepaintGui

return

;====================================================================================================;

EnsureSection:
if (SectionBuilt.HasKey(NeedSection))
	return
SectionBuilt[NeedSection] := 1
ThemedMark := ThemedCtrls.MaxIndex()
if (!ThemedMark)
	ThemedMark := 0
NewLists := []
if (NeedSection = "General")
	{
	gosub, BuildGeneralSection
	NewLists := [GeneralCtrls]
	}
else if (NeedSection = "Cast")
	{
	gosub, BuildCastSection
	NewLists := [CastCtrls, NormalCastCtrls, PerfectCastCtrls]
	}
else if (NeedSection = "Shake")
	{
	gosub, BuildShakeSection
	NewLists := [ShakeCtrls]
	}
else if (NeedSection = "Minigame")
	{
	gosub, BuildMinigameSection
	gosub, BuildColorManagerSection
	NewLists := [MgAllCtrls, CMCtrls]
	}
else if (NeedSection = "Utilities")
	{
	gosub, BuildUtilitiesSection
	NewLists := [UtilCtrls]
	}
else if (NeedSection = "Totem")
	{
	gosub, BuildTotemSection
	NewLists := [TotemCtrls]
	}
else if (NeedSection = "Aquarium")
	{
	gosub, BuildAquariumSection
	NewLists := [AquariumCtrls]
	}
else if (NeedSection = "Keeper")
	{
	gosub, BuildKeeperSection
	NewLists := [KeeperCtrls]
	}
else if (NeedSection = "Webhook")
	{
	gosub, BuildWebhookSection
	NewLists := [WebhookCtrls]
	}
else if (NeedSection = "Faq")
	{
	gosub, BuildFaqSection
	NewLists := [FaqCtrls]
	}
else if (NeedSection = "About")
	{
	gosub, BuildAboutSection
	NewLists := [AboutCtrls]
	}
else if (NeedSection = "Versions")
	{
	gosub, BuildVersionsSection
	NewLists := [VersionsCtrls]
	}
else if (NeedSection = "ReadThis")
	{
	gosub, BuildReadThisSection
	NewLists := [ReadThisCtrls]
	}
else
	return

for i, lst in NewLists
	{
	FixCardBrushes(lst)
	SnapshotBase(lst)
	for j, h in lst
		AllManaged.Push(h)
	}
tk := ThemedMark + 1
tn := ThemedCtrls.MaxIndex()
while (tk <= tn)
	{
	DllCall("uxtheme\SetWindowTheme", "Ptr", ThemedCtrls[tk], "Str", "DarkMode_Explorer", "Ptr", 0)
	tk++
	}
if (NeedSection = "Minigame")
	gosub, RefreshControlModes
if (NeedSection = "Cast")
	gosub, ApplyCastModeLocks
return

RepaintGui:
DllCall("RedrawWindow", "Ptr", GuiHwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x0185)
return

RefreshRunChip:
gosub, SyncRunKeys
if (!hRunStatus)
	return
if (MacroRunning)
	{
	SpecialBrushes[hRunStatus] := {brush: hBrushGreen, text: 0x101010}
	GuiControl, 1:, RunStatusText, ●  Running
	}
else
	{
	SpecialBrushes[hRunStatus] := {brush: hBrushPanel, text: ColorMutedBGR}
	GuiControl, 1:, RunStatusText, ●  Idle
	}
DllCall("RedrawWindow", "Ptr", hRunStatus, "Ptr", 0, "Ptr", 0, "UInt", 0x0005)
return

;====================================================================================================;

BuildGeneralSection:

hC := AddPanel(CARDX, 120, CARDW, 152)
GeneralCtrls.Push(hC)
hC := AddPanel(CARDX, 282, CARDW, 168)
GeneralCtrls.Push(hC)
hC := AddPanel(CARDX, 460, CARDW, 152)
GeneralCtrls.Push(hC)

Gui, Font, s8 Bold c%ColorMuted%, Segoe UI
Gui, Add, Text, x%CX% y130 w%TXW% h16 HwndhL, HOTKEYS & WINDOW
GeneralCtrls.Push(hL)
Gui, Font, s9 Norm c%ColorMuted%, Segoe UI

Y := 152

GeneralHotDefs := [ ["Start/Stop key","StartStopKeyCtrl",StartStopKey]
	, ["Reload key","ReloadKeyCtrl",ReloadKey]
	, ["Exit key","ExitKeyCtrl",ExitKey] ]
for i, d in GeneralHotDefs
	{
	lbl := d[1]
	var := d[2]
	val := d[3]
	Gui, Add, Text, x%CX% y%Y% w%LW% h20 HwndhL, %lbl%:
	GeneralCtrls.Push(hL)
	Gui, Add, Hotkey, x%IX% y%Y% w%IW% h20 v%var% HwndhC, %val%
	GeneralCtrls.Push(hC)
	ThemedCtrls.Push(hC)
	Y += RH
	}

Gui, Font, s9 c%ColorText%, Segoe UI
aotChk := GuiAlwaysOnTop ? "Checked" : ""
Gui, Add, CheckBox, x%CX% y%Y% w300 h20 c%ColorText% vGuiAlwaysOnTop %aotChk% gToggleAlwaysOnTop HwndhC, Window always on top
GeneralCtrls.Push(hC)
Y += 22

keepChk := GuiKeepOpen ? "Checked" : ""
Gui, Add, CheckBox, x%CX% y%Y% w300 h20 c%ColorText% vGuiKeepOpen %keepChk% gToggleKeepOpen HwndhC, Always open after pressing Start
GeneralCtrls.Push(hC)

Gui, Font, s8 Bold c%ColorMuted%, Segoe UI
Gui, Add, Text, x%CX% y292 w%TXW% h16 HwndhL, AUTOMATIC GAME SETUP
GeneralCtrls.Push(hL)
Gui, Font, s8 Norm c%ColorMuted%, Segoe UI
Gui, Add, Text, x%DX% y292 w%DW% h16 Center HwndhL, delay ms
GeneralCtrls.Push(hL)

Y := 314
GeneralBoolDefs := [ ["Auto-lower graphics","AutoLowerGraphics","AutoGraphicsDelay"]
                   , ["Auto-zoom camera","AutoZoomInCamera","AutoZoomDelay"]
                   , ["Auto-enable camera mode","AutoEnableCameraMode","AutoCameraDelay"]
                   , ["Auto-look down","AutoLookDownCamera","AutoLookDelay"]
                   , ["Auto-blur camera","AutoBlurCamera","AutoBlurDelay"] ]

Gui, Font, s9 c%ColorText%, Segoe UI
for i, d in GeneralBoolDefs
	{
	lbl := d[1]
	var := d[2]
	dvar := d[3]
	val := %var%
	chk := val ? "Checked" : ""
	Gui, Add, CheckBox, x%CX% y%Y% w300 h20 c%ColorText% v%var% %chk% gQueueAutoSave HwndhC, %lbl%
	GeneralCtrls.Push(hC)
	Gui, Add, Edit, x%DX% y%Y% w%DW% h20 v%dvar% gQueueAutoSave HwndhD +Number, % %dvar%
	GeneralCtrls.Push(hD)
	ThemedCtrls.Push(hD)
	Y += RH
	}

Gui, Font, s8 Bold c%ColorMuted%, Segoe UI
Gui, Add, Text, x%CX% y470 w%TXW% h16 HwndhL, RECOVERY
GeneralCtrls.Push(hL)
Gui, Font, s9 Norm c%ColorMuted%, Segoe UI

Y := 492
GeneralNumDefs := [ ["Restart delay (ms)","RestartDelay"], ["Re-equip after N failed casts","UnstickAfter"] ]
for i, d in GeneralNumDefs
	{
	lbl := d[1]
	var := d[2]
	Gui, Add, Text, x%CX% y%Y% w%LW% h20 HwndhL, %lbl%:
	GeneralCtrls.Push(hL)
	Gui, Add, Edit, x%IX% y%Y% w%IW% h20 v%var% gQueueAutoSave HwndhC +Number, % %var%
	GeneralCtrls.Push(hC)
	ThemedCtrls.Push(hC)
	Y += RH
	}

GeneralKeyDefs := [ ["Rod hotbar slot key","RodSlotKey"
	, "The hotbar key your fishing rod sits on.`n`nUsed to un-equip and re-equip the rod when a`ncast gets stuck on the ground."]
	, ["Equipment bag key","BagSlotKey"
	, "The hotbar key for your equipment bag.`n`nIf set, the macro switches to this and back to`nthe rod to un-stick a cast. Leave blank to just`npress the rod key twice instead."] ]

for i, d in GeneralKeyDefs
	{
	lbl := d[1]
	var := d[2]
	hint := d[3]
	Gui, Font, s9 Norm c%ColorMuted%, Segoe UI
	Gui, Add, Text, x%CX% y%Y% w%LW% h20 HwndhL, %lbl%:
	GeneralCtrls.Push(hL)
	Gui, Add, Edit, x%IX% y%Y% w%IW% h20 v%var% gQueueAutoSave HwndhC, % %var%
	GeneralCtrls.Push(hC)
	ThemedCtrls.Push(hC)
	Gui, Font, s9 Bold c%ColorAccent%, Segoe UI
	Gui, Add, Text, x%QX% y%Y% w16 h20 Center +0x100 +0x200 HwndhQ, ?
	Gui, Font, s9 Norm c%ColorMuted%, Segoe UI
	GeneralCtrls.Push(hQ)
	IconTips[hQ] := hint
	Y += RH
	}

return

;====================================================================================================;

BuildCastSection:

hC := AddPanel(CARDX, 120, CARDW, 62)
CastCtrls.Push(hC)

Gui, Font, s9 c%ColorMuted%, Segoe UI
Y := ContentTop

Gui, Add, Text, x%CX% y%Y% w%LW% h20 HwndhL, Cast mode:
CastCtrls.Push(hL)
CastModeChoice := (CastMode = "Perfect") ? 2 : 1
Gui, Add, DropDownList, x%IX% y%Y% w%IW% h100 vCastMode gCastModeChanged Choose%CastModeChoice% HwndhC, Normal|Perfect
CastCtrls.Push(hC)
ThemedCtrls.Push(hC)
Gui, Font, s9 Bold c%ColorAccent%, Segoe UI
Gui, Add, Text, x%QX% y%Y% w16 h20 Center +0x100 +0x200 HwndhQ, ?
Gui, Font, s9 Norm c%ColorMuted%, Segoe UI
CastCtrls.Push(hQ)
IconTips[hQ] := "How the rod is cast.`n`nNORMAL - holds the mouse for a fixed time,`nthen lets go. Simple and reliable.`n`nPERFECT - watches the cast power bar and`nlets go the instant it fills, for a perfect`ncast every time. Needs the green and white`nbar colors to match your game."

CastGroupTop := 202

; ---- Normal group ----
hC := AddPanel(CARDX, 192, CARDW, 78)
NormalCastCtrls.Push(hC)
hC := AddPanel(CARDX, 280, CARDW, 108)
NormalCastCtrls.Push(hC)

Y := CastGroupTop
NormalCastDefs := [ ["Hold rod cast duration (ms)","HoldRodCastDuration"
	, "How long the mouse is held down to cast.`n`nHIGHER = casts further out.`nLOWER  = casts closer in."]
	, ["Wait for bobber delay (ms)","WaitForBobberDelay"
	, "How long to wait after casting before it`nstarts looking for the shake button.`n`nRaise it if shaking starts before the`nbobber has landed."] ]
for i, d in NormalCastDefs
	{
	lbl := d[1]
	var := d[2]
	hint := d[3]
	Gui, Add, Text, x%CX% y%Y% w%LW% h20 HwndhL, %lbl%:
	NormalCastCtrls.Push(hL)
	Gui, Add, Edit, x%IX% y%Y% w%IW% h20 v%var% gQueueAutoSave HwndhC +Number, % %var%
	NormalCastCtrls.Push(hC)
	ThemedCtrls.Push(hC)
	Gui, Font, s9 Bold c%ColorAccent%, Segoe UI
	Gui, Add, Text, x%QX% y%Y% w16 h20 Center +0x100 +0x200 HwndhQ, ?
	Gui, Font, s9 Norm c%ColorMuted%, Segoe UI
	NormalCastCtrls.Push(hQ)
	IconTips[hQ] := hint
	Y += RH
	}

Gui, Font, s8 Bold c%ColorMuted%, Segoe UI
Gui, Add, Text, x%CX% y290 w%TXW% h16 HwndhNCTipHdr, QUICK RULES — NORMAL
NormalCastCtrls.Push(hNCTipHdr)
Gui, Font, s9 Norm cFFFFFF, Segoe UI
NormalCastTips := "• Casts a fixed distance every time.`n"
NormalCastTips .= "• Raise the hold duration to cast further out.`n"
NormalCastTips .= "• Raise the bobber delay on laggy servers.`n"
NormalCastTips .= "• No colors to calibrate — this always works."
Gui, Add, Text, x%CX% y312 w%TXW% h68 cFFFFFF HwndhNCTips, %NormalCastTips%
NormalCastCtrls.Push(hNCTips)
SpecialBrushes[hNCTips] := {brush: hBrushCard, text: 0xFFFFFF}

; ---- Perfect group ----
hC := AddPanel(CARDX, 192, CARDW, 196)
PerfectCastCtrls.Push(hC)
hC := AddPanel(CARDX, 398, CARDW, 148)
PerfectCastCtrls.Push(hC)

Gui, Font, s9 c%ColorMuted%, Segoe UI
Y := CastGroupTop
PerfectCastDefs := [ ["Green tolerance","PerfectGreenTolerance",1
	, "How closely the green marker on the cast bar`nmust match.`n`nHIGHER = more forgiving.`nTOO HIGH = matches the wrong thing."]
	, ["White tolerance","PerfectWhiteTolerance",1
	, "How closely the white fill bar must match.`n`nHIGHER = more forgiving.`nTOO HIGH = matches other white UI."]
	, ["Fail timeout (s)","PerfectFailTimeout",1
	, "How long to wait for a perfect release before`ngiving up and letting go anyway.`n`nStops the macro hanging if the bar is`nnever found."]
	, ["Release timing","PerfectReleaseTiming",0
	, "Nudges when it lets go.`n`nNEGATIVE = release EARLIER (use if it`nreleases too late).`nPOSITIVE = release LATER (use if it`nreleases too early).`n`n0 = default. Try steps of 0.5."] ]
for i, d in PerfectCastDefs
	{
	lbl := d[1]
	var := d[2]
	isInt := d[3]
	hint := d[4]
	opt := isInt ? "+Number" : ""
	Gui, Add, Text, x%CX% y%Y% w%LW% h20 HwndhL, %lbl%:
	PerfectCastCtrls.Push(hL)
	Gui, Add, Edit, x%IX% y%Y% w%IW% h20 v%var% gQueueAutoSave HwndhC %opt%, % %var%
	PerfectCastCtrls.Push(hC)
	ThemedCtrls.Push(hC)
	Gui, Font, s9 Bold c%ColorAccent%, Segoe UI
	Gui, Add, Text, x%QX% y%Y% w16 h20 Center +0x100 +0x200 HwndhQ, ?
	Gui, Font, s9 Norm c%ColorMuted%, Segoe UI
	PerfectCastCtrls.Push(hQ)
	IconTips[hQ] := hint
	Y += RH
	}

Gui, Add, Text, x%CX% y%Y% w%LW% h20 HwndhL, Green bar color:
PerfectCastCtrls.Push(hL)
Gui, Add, Edit, x%IX% y%Y% w%IW% h20 vPerfectGreenColor gColorFieldChanged HwndhC, % PerfectGreenColor
PerfectCastCtrls.Push(hC)
ThemedCtrls.Push(hC)
Gui, Add, Progress, x%SWX% y%Y% w%SWW% h20 vCastGreenSwatch HwndhCastGreenSwatch Background60AA4A, 0
PerfectCastCtrls.Push(hCastGreenSwatch)
Y += RH

Gui, Add, Text, x%CX% y%Y% w%LW% h20 HwndhL, White bar color:
PerfectCastCtrls.Push(hL)
Gui, Add, Edit, x%IX% y%Y% w%IW% h20 vPerfectWhiteColor gColorFieldChanged HwndhC, % PerfectWhiteColor
PerfectCastCtrls.Push(hC)
ThemedCtrls.Push(hC)
Gui, Add, Progress, x%SWX% y%Y% w%SWW% h20 vCastWhiteSwatch HwndhCastWhiteSwatch BackgroundFFFEF3, 0
PerfectCastCtrls.Push(hCastWhiteSwatch)
Y += RH + 2

Gui, Font, s9 Bold c%ColorAccent%, Segoe UI
Gui, Add, Text, x%CX% y%Y% w200 h26 Center +0x100 +0x200 gOpenColorManager HwndhC, 🎨  Color Manager  (F9)
PerfectCastCtrls.Push(hC)
SpecialBrushes[hC] := {brush: hBrushCard, text: ColorAccentBGR}
RoundCtrl(hC, 200, 26, 7)
Gui, Font, s9 Norm c%ColorMuted%, Segoe UI

Gui, Font, s8 Bold c%ColorMuted%, Segoe UI
Gui, Add, Text, x%CX% y408 w%TXW% h16 HwndhPCTipHdr, QUICK RULES — PERFECT
PerfectCastCtrls.Push(hPCTipHdr)
Gui, Font, s9 Norm cFFFFFF, Segoe UI
PerfectCastTips := "• Releases too late? Lower Release timing by 0.5.`n"
PerfectCastTips .= "• Releases too early? Raise it by 0.5.`n"
PerfectCastTips .= "• Never releases at all? Re-pick the green and white`n"
PerfectCastTips .= "   colors in the Color Manager, or raise the tolerances.`n"
PerfectCastTips .= "• Falls back to a normal cast if the bar is never found,`n"
PerfectCastTips .= "   so a bad calibration cannot hang it."
Gui, Add, Text, x%CX% y430 w%TXW% h100 cFFFFFF HwndhPCTips, %PerfectCastTips%
PerfectCastCtrls.Push(hPCTips)
SpecialBrushes[hPCTips] := {brush: hBrushCard, text: 0xFFFFFF}

return

;====================================================================================================;

CastModeChanged:
GuiControlGet, CastMode, , CastMode
gosub, ApplyCastModeLocks
TargetSection := "Cast"
gosub, ShowSection
gosub, QueueAutoSave
return

;====================================================================================================;

ApplyCastModeLocks:
if (CastMode = "Perfect")
	{
	AutoZoomInCamera := false
	GuiControl, 1:, AutoZoomInCamera, 0
	GuiControl, 1:Disable, AutoZoomInCamera
	GuiControl, 1:Disable, AutoZoomDelay
	}
else
	{
	GuiControl, 1:Enable, AutoZoomInCamera
	GuiControl, 1:Enable, AutoZoomDelay
	}
return

;====================================================================================================;

BuildShakeSection:

hC := AddPanel(CARDX, 120, CARDW, 88)
ShakeCtrls.Push(hC)
hC := AddPanel(CARDX, 218, CARDW, 138)
ShakeCtrls.Push(hC)
hC := AddPanel(CARDX, 366, CARDW, 192)
ShakeCtrls.Push(hC)

Gui, Font, s8 Bold c%ColorMuted%, Segoe UI
Gui, Add, Text, x%CX% y130 w%TXW% h16 HwndhL, MODE
ShakeCtrls.Push(hL)
Gui, Font, s9 Norm c%ColorMuted%, Segoe UI

Y := 152
Gui, Add, Text, x%CX% y%Y% w%LW% h20 HwndhL, Shake mode:
ShakeCtrls.Push(hL)
ShakeModeChoice := (ShakeMode = "Navigation") ? 2 : ((ShakeMode = "Disabled") ? 3 : 1)
Gui, Add, DropDownList, x%IX% y%Y% w%IW% h100 vShakeMode Choose%ShakeModeChoice% HwndhC, Click|Navigation|Disabled
ShakeCtrls.Push(hC)
ThemedCtrls.Push(hC)
Y += RH

Gui, Add, Text, x%CX% y%Y% w%LW% h20 HwndhL, In-game navigation key:
ShakeCtrls.Push(hL)
Gui, Add, Edit, x%IX% y%Y% w%IW% h20 vNavigationKey HwndhC, %NavigationKey%
ShakeCtrls.Push(hC)
ThemedCtrls.Push(hC)

Gui, Font, s8 Bold c%ColorMuted%, Segoe UI
Gui, Add, Text, x%CX% y228 w%TXW% h16 HwndhL, TIMING
ShakeCtrls.Push(hL)
Gui, Font, s9 Norm c%ColorMuted%, Segoe UI

Y := 250
ShakeTimeDefs := [ ["Click failsafe (s)","ClickShakeFailsafe"]
                 , ["Click tolerance","ClickShakeColorTolerance"]
                 , ["Click scan delay (ms)","ClickScanDelay"]
                 , ["Repeat bypass count","RepeatBypassCounter"] ]
for i, d in ShakeTimeDefs
	{
	lbl := d[1]
	var := d[2]
	Gui, Add, Text, x%CX% y%Y% w%LW% h20 HwndhL, %lbl%:
	ShakeCtrls.Push(hL)
	Gui, Add, Edit, x%IX% y%Y% w%IW% h20 v%var% gQueueAutoSave HwndhC +Number, % %var%
	ShakeCtrls.Push(hC)
	ThemedCtrls.Push(hC)
	Y += RH
	}

Gui, Font, s8 Bold c%ColorMuted%, Segoe UI
Gui, Add, Text, x%CX% y376 w%TXW% h16 HwndhL, SEARCH AREA
ShakeCtrls.Push(hL)
Gui, Font, s9 Norm c%ColorMuted%, Segoe UI

Y := 398
ShakeAreaDefs := [ ["Navigation failsafe (s)","NavigationShakeFailsafe"]
                 , ["Navigation spam delay (ms)","NavigationSpamDelay"]
                 , ["Search area left (%)","ShakeAreaLeftPct"]
                 , ["Search area right (%)","ShakeAreaRightPct"]
                 , ["Search area top (%)","ShakeAreaTopPct"]
                 , ["Search area bottom (%)","ShakeAreaBottomPct"] ]
for i, d in ShakeAreaDefs
	{
	lbl := d[1]
	var := d[2]
	Gui, Add, Text, x%CX% y%Y% w%LW% h20 HwndhL, %lbl%:
	ShakeCtrls.Push(hL)
	Gui, Add, Edit, x%IX% y%Y% w%IW% h20 v%var% gQueueAutoSave HwndhC +Number, % %var%
	ShakeCtrls.Push(hC)
	ThemedCtrls.Push(hC)
	Y += RH
	}

return

;====================================================================================================;
;====================================================================================================;

BuildMinigameSection:


MgBlocks := {}

; ------------------------------------------------- detection mode, special rod, edge fallback
MgBlockOpen("mode", 120, 90)
Gui, Font, s8 Bold c%ColorMuted%, Segoe UI
Gui, Add, Text, x%CX% y130 w%TXW% h16 HwndhL, DETECTION
MgAdd("mode", hL)
Gui, Font, s9 Norm c%ColorMuted%, Segoe UI

Y := 152
Gui, Add, Text, x%CX% y%Y% w%LW% h20 HwndhL, Detection mode:
MgAdd("mode", hL)
ControlModeChoice := (ControlMode = "Manual") ? 1 : ((ControlMode = "Lines") ? 3 : 2)
Gui, Add, DropDownList, x%IX% y%Y% w%IW% h100 vControlMode gControlModeChanged Choose%ControlModeChoice% HwndhC, Manual|Precision|Lines
ControlModeDdl := hC
MgAdd("mode", hC)
ThemedCtrls.Push(hC)
Gui, Font, s9 Bold c%ColorAccent%, Segoe UI
Gui, Add, Text, x%QX% y%Y% w16 h20 Center +0x100 +0x200 HwndhQ, ?
Gui, Font, s9 Norm c%ColorMuted%, Segoe UI
MgAdd("mode", hQ)
IconTips[hQ] := "How the macro steers the bar.`n`nPRECISION - looks at the bar every frame and`nre-decides instantly. It also tracks how fast`nthe fish is MOVING, so it aims where the fish`nis going. Almost no tuning needed.`n`nLINES - reads the bar's EDGES instead of`nmatching colors, so your color picks do not`nmatter at all.`n`nMANUAL - presses the mouse for a calculated`nnumber of milliseconds, then brakes. You tune`nthe timings yourself with multipliers."

Y += RH
Gui, Add, Text, x%CX% y%Y% w%LW% h20 HwndhL, Special rod (use default skin):
MgAdd("mode", hL)
SpecialBrushes[hL] := {brush: hBrushCard, text: ColorRedBGR}
SpecialRodChoice := (SpecialRod = "Pinions Aria") ? 2 : ((SpecialRod = "Requiem") ? 3 : ((SpecialRod = "Darkheart") ? 4 : ((SpecialRod = "Bellona's Waraxe") ? 5 : ((SpecialRod = "Dreambreaker") ? 6 : ((SpecialRod = "Tranquility") ? 7 : ((SpecialRod = "Noiseform") ? 8 : ((SpecialRod = "Verdant Oath") ? 9 : ((SpecialRod = "Lullaby") ? 10 : ((SpecialRod = "Castbound") ? 11 : ((SpecialRod = "Remembrance") ? 12 : ((SpecialRod = "MiguRod") ? 13 : ((SpecialRod = "Halibut Harpoon") ? 14 : 1))))))))))))
Gui, Add, DropDownList, x%IX% y%Y% w%IW% h260 vSpecialRod gSpecialRodChanged Choose%SpecialRodChoice% HwndhC, None|Pinions Aria|Requiem|Darkheart|Bellona's Waraxe|Dreambreaker|Tranquility|Noiseform|Verdant Oath|Lullaby|Castbound|Remembrance|MiguRod|Halibut Harpoon
MgAdd("mode", hC)
ThemedCtrls.Push(hC)
Gui, Font, s9 Bold c%ColorAccent%, Segoe UI
Gui, Add, Text, x%QX% y%Y% w16 h20 Center +0x100 +0x200 HwndhQ, ?
Gui, Font, s9 Norm c%ColorMuted%, Segoe UI
MgAdd("mode", hQ)
IconTips[hQ] := "Extra behaviour for rods with their own`nmechanics.`n`nUse the DEFAULT rod skin. Other skins`nchange how the bar looks and break detection."

; -------------------------------------------------------------------------------- bar colors
MgBlockOpen("colors", 204, 276)
Y := 220
ColorFieldDefs := [ ["Fish line color","FishColor","FishColorSwatch"
	, "The thin marker that slides along the bar."]
	, ["Bar left-end color","BarLeftColor","BarLeftColorSwatch"
	, "The LEFT end of the reeling bar.`n`nEach entry holds a LIST - if the bar changes`nshade as it fills, add every shade its left`nend takes."]
	, ["Bar right-end color","BarRightColor","BarRightColorSwatch"
	, "The RIGHT end of the reeling bar.`n`nEach entry holds a LIST - if the bar changes`nshade as it fills, add every shade its right`nend takes."]
	, ["Bar arrow color","ArrowColor","ArrowColorSwatch"
	, "The small arrow drawn inside the reeling bar."] ]

for i, d in ColorFieldDefs
	{
	lbl := d[1]
	var := d[2]
	sw := d[3]
	hint := d[4]
	Gui, Add, Text, x%CX% y%Y% w%LW% h20 HwndhL, %lbl%:
	MgAdd("colors", hL)
	Gui, Add, Edit, x%IX% y%Y% w%IW% h20 v%var% gColorFieldChanged HwndhC, % %var%
	MgAdd("colors", hC)
	ThemedCtrls.Push(hC)
	swVal := Format("{:06X}", ColMain(%var%))
	if (!ColCount(%var%))
		swVal := "202020"
	Gui, Add, Progress, x%SWX% y%Y% w%SWW% h20 v%sw% Background%swVal% HwndhS, 0
	MgAdd("colors", hS)
	Gui, Font, s9 Bold c%ColorAccent%, Segoe UI
	Gui, Add, Text, x%QX% y%Y% w16 h20 Center +0x100 +0x200 HwndhQ, ?
	Gui, Font, s9 Norm c%ColorMuted%, Segoe UI
	MgAdd("colors", hQ)
	IconTips[hQ] := hint
	Y += RH
	}

MiniColorFieldDefs := [ ["Bar color tolerance","BarColorTolerance"
	, "How closely the picked colors must match.`n`nHIGHER = more forgiving.`nTOO HIGH = matches the wrong thing.`n`nBefore pushing this up, add the extra shade`nas another color in the Color Manager - that`nis far safer than a wide tolerance."]
	, ["Fish line tolerance","FishBarColorTolerance"
	, "How closely a pixel must match the fish line`ncolor to count as the fish.`n`nHIGHER = more forgiving. Raise this if the`nminigame is never detected.`nTOO HIGH = scenery gets mistaken for the fish."]
	, ["Arrow tolerance","ArrowColorTolerance"
	, "How closely the arrow's color must match.`n`nHIGHER = more forgiving (good if the rod`nshifts hue or the screen shakes).`nTOO HIGH = matches the wrong thing."] ]

for i, d in MiniColorFieldDefs
	{
	lbl := d[1]
	var := d[2]
	hint := d[3]
	Gui, Add, Text, x%CX% y%Y% w%LW% h20 HwndhL, %lbl%:
	MgAdd("colors", hL)
	Gui, Add, Edit, x%IX% y%Y% w%IW% h20 v%var% gQueueAutoSave HwndhC +Number, % %var%
	MgAdd("colors", hC)
	ThemedCtrls.Push(hC)
	Gui, Font, s9 Bold c%ColorAccent%, Segoe UI
	Gui, Add, Text, x%QX% y%Y% w16 h20 Center +0x100 +0x200 HwndhQ, ?
	Gui, Font, s9 Norm c%ColorMuted%, Segoe UI
	MgAdd("colors", hQ)
	IconTips[hQ] := hint
	Y += RH
	}

Y += 4
Gui, Font, s9 Bold c%ColorAccent%, Segoe UI
Gui, Add, Text, x%CX% y%Y% w200 h26 Center +0x100 +0x200 gOpenColorManager HwndhC, 🎨  Color Manager  (F9)
MgAdd("colors", hC)
SpecialBrushes[hC] := {brush: hBrushCard, text: ColorAccentBGR}
RoundCtrl(hC, 200, 26, 7)
Gui, Font, s8 Norm c%ColorMuted%, Segoe UI
Gui, Add, Text, x412 y%Y% w316 h26 +0x200 HwndhL, Every entry holds a LIST — add each shade.
MgAdd("colors", hL)
SpecialBrushes[hL] := {brush: hBrushCard, text: ColorMutedBGR}

Y += 30
Gui, Font, s9 Bold c%ColorAccent%, Segoe UI
Gui, Add, Text, x%CX% y%Y% w200 h26 Center +0x100 +0x200 gMgRestoreDefaults HwndhC, ↺  Restore defaults
MgAdd("colors", hC)
SpecialBrushes[hC] := {brush: hBrushCard, text: ColorAccentBGR}
RoundCtrl(hC, 200, 26, 7)
Gui, Font, s8 Norm c%ColorMuted%, Segoe UI
Gui, Add, Text, x412 y%Y% w316 h26 +0x200 HwndhL, Resets Setup and every Color Manager color.
MgAdd("colors", hL)
SpecialBrushes[hL] := {brush: hBrushCard, text: ColorMutedBGR}
Gui, Font, s9 Norm c%ColorMuted%, Segoe UI

; --------------------------------------------------------------------- falling notes (Pinions)
MgBlockOpen("notes", 204, 162)
Y := 220
Gui, Add, Text, x%CX% y%Y% w%LW% h20 HwndhL, Note color:
MgAdd("notes", hL)
SpecialBrushes[hL] := {brush: hBrushCard, text: ColorYellowBGR}
Gui, Add, Edit, x%IX% y%Y% w%IW% h20 vNoteColor gColorFieldChanged HwndhC, % NoteColor
MgAdd("notes", hC)
ThemedCtrls.Push(hC)
swVal := Format("{:06X}", ColMain(NoteColor))
if (!ColCount(NoteColor))
	swVal := "202020"
Gui, Add, Progress, x%SWX% y%Y% w%SWW% h20 vNoteColorSwatch Background%swVal% HwndhS, 0
MgAdd("notes", hS)
Y += RH

NoteFieldDefs := [ ["Note tolerance","NoteColorTolerance"
	, "How closely a pixel must match a note color.`n`n10-22 is the tested range and it is capped at`n25 - above that the fish icon counts as a note`nand the marker jumps around."]
	, ["Note priority","NoteBias"
	, "How strongly the bar chases a note instead of`nthe fish, 0-100.`n`n100 = go straight to the note.`n0 = ignore notes and track the fish only."]
	, ["Resonance hand-off (px)","NoteHandoff"
	, "Resonance state only.`n`nHow many pixels BEFORE a note lands to start`nmoving to the next note behind it.`n`nHIGHER = leaves early, reaches the second note`nin time but can drop the first.`n0 = never leave early (old behaviour)."] ]

for i, d in NoteFieldDefs
	{
	lbl := d[1]
	var := d[2]
	hint := d[3]
	Gui, Add, Text, x%CX% y%Y% w%LW% h20 HwndhL, %lbl%:
	MgAdd("notes", hL)
	SpecialBrushes[hL] := {brush: hBrushCard, text: ColorYellowBGR}
	Gui, Add, Edit, x%IX% y%Y% w%IW% h20 v%var% gQueueAutoSave HwndhC +Number, % %var%
	MgAdd("notes", hC)
	ThemedCtrls.Push(hC)
	Gui, Font, s9 Bold c%ColorAccent%, Segoe UI
	Gui, Add, Text, x%QX% y%Y% w16 h20 Center +0x100 +0x200 HwndhQ, ?
	Gui, Font, s9 Norm c%ColorMuted%, Segoe UI
	MgAdd("notes", hQ)
	IconTips[hQ] := hint
	Y += RH
	}

Y += 4
Gui, Font, s9 Bold c%ColorAccent%, Segoe UI
Gui, Add, Text, x%CX% y%Y% w200 h26 Center +0x100 +0x200 gOpenColorManager HwndhC, 🎨  Color Manager  (F9)
MgAdd("notes", hC)
SpecialBrushes[hC] := {brush: hBrushCard, text: ColorAccentBGR}
RoundCtrl(hC, 200, 26, 7)
Gui, Font, s8 Norm c%ColorMuted%, Segoe UI
Gui, Add, Text, x412 y%Y% w316 h26 +0x200 HwndhL, Notes are hunted across the Shake search area.
MgAdd("notes", hL)
SpecialBrushes[hL] := {brush: hBrushCard, text: ColorMutedBGR}
Gui, Font, s9 Norm c%ColorMuted%, Segoe UI

; ------------------------------------------------------------------- Requiem reel limits
MgBlockOpen("reel", 204, 70)
ReelFieldDefs := [ ["Min hold (ms)","ReelMinHold"
	, "Once the macro presses the mouse it will not`nrelease for at least this long.`n`nRaise it if the reel keeps snapping.`nToo high = sluggish, overshoots the fish."]
	, ["Min release (ms)","ReelMinRelease"
	, "Once the macro releases it will not press again`nfor at least this long.`n`nRaise it if the reel keeps snapping.`nToo high = sluggish, falls behind the fish."] ]
Y := 216
for i, d in ReelFieldDefs
	{
	lbl := d[1]
	var := d[2]
	hint := d[3]
	Gui, Add, Text, x%CX% y%Y% w%LW% h20 HwndhL, %lbl%:
	MgAdd("reel", hL)
	SpecialBrushes[hL] := {brush: hBrushCard, text: ColorYellowBGR}
	Gui, Add, Edit, x%IX% y%Y% w%IW% h20 v%var% gQueueAutoSave HwndhC +Number, % %var%
	MgAdd("reel", hC)
	ThemedCtrls.Push(hC)
	Gui, Font, s9 Bold c%ColorAccent%, Segoe UI
	Gui, Add, Text, x%QX% y%Y% w16 h20 Center +0x100 +0x200 HwndhQ, ?
	Gui, Font, s9 Norm c%ColorMuted%, Segoe UI
	MgAdd("reel", hQ)
	IconTips[hQ] := hint
	Y += RH
	}

; ----------------------------------------------------------- Remembrance: living / departed
MgBlockOpen("remem", 204, 96)
Gui, Font, s8 Bold c%ColorMuted%, Segoe UI
Gui, Add, Text, x%CX% y212 w%TXW% h16 HwndhL, REMEMBRANCE
MgAdd("remem", hL)
Gui, Font, s9 Norm c%ColorMuted%, Segoe UI
Y := 236
Gui, Add, Text, x%CX% y%Y% w%LW% h20 HwndhL, Rod state:
MgAdd("remem", hL)
SpecialBrushes[hL] := {brush: hBrushCard, text: ColorYellowBGR}
RemembranceChoice := (RemembranceMode = "Departed") ? 2 : 1
Gui, Add, DropDownList, x%IX% y%Y% w%IW% h100 vRemembranceMode gRemembranceModeChanged Choose%RemembranceChoice% HwndhC, Living|Departed
MgAdd("remem", hC)
ThemedCtrls.Push(hC)
Gui, Font, s9 Bold c%ColorAccent%, Segoe UI
Gui, Add, Text, x%QX% y%Y% w16 h20 Center +0x100 +0x200 HwndhQ, ?
Gui, Font, s9 Norm c%ColorMuted%, Segoe UI
MgAdd("remem", hQ)
IconTips[hQ] := "Which state the rod is in.`n`nBoth states put a second, BLACK fish line on the`nbar, and you want to stay off it.`n`nLIVING - sitting on both lines PAUSES progress,`nso the bar still takes the white line when the two`nare too close to separate.`n`nDEPARTED - sitting on both LOSES progress, so the`nbar keeps clear of the black line even if it has to`ngive up the white one for a moment."
Y += RH
Gui, Font, s8 Norm c%ColorMuted%, Segoe UI
Gui, Add, Text, x%CX% y%Y% w%TXW% h20 +0x200 HwndhL, Switching state re-fills the bar colors - they differ between the two.
MgAdd("remem", hL)
SpecialBrushes[hL] := {brush: hBrushCard, text: ColorMutedBGR}
Gui, Font, s9 Norm c%ColorMuted%, Segoe UI

; --------------------------------------------------------------------------- manual steering
TuningFieldDefs := [ ["Stable Right Multiplier","StableRightMultiplier"
	, "GAS PEDAL for moving RIGHT.`n`nTOO HIGH  = shoots past the fish.`nTOO LOW   = never catches up to it."]
	, ["Stable Right Division","StableRightDivision"
	, "BRAKES after moving right.`n`nBIGGER number = WEAKER brakes (slides past).`nSMALLER number = STRONGER brakes (stops early).`n`nYes, it works backwards."]
	, ["Stable Left Multiplier","StableLeftMultiplier"
	, "GAS PEDAL for moving LEFT.`n`nTOO HIGH  = shoots past the fish.`nTOO LOW   = never catches up to it."]
	, ["Stable Left Division","StableLeftDivision"
	, "BRAKES after moving left.`n`nBIGGER number = WEAKER brakes (slides past).`nSMALLER number = STRONGER brakes (stops early).`n`nYes, it works backwards."]
	, ["Unstable Right Multiplier","UnstableRightMultiplier"
	, "Gas pedal for RIGHT, used only when the macro`nCANNOT SEE the bar and is guessing.`n`nTOO HIGH = shoots past.  TOO LOW = too slow."]
	, ["Unstable Right Division","UnstableRightDivision"
	, "Brakes for the guessing right move.`n`nBIGGER = weaker brakes.`nSMALLER = stronger brakes."]
	, ["Unstable Left Multiplier","UnstableLeftMultiplier"
	, "Gas pedal for LEFT, used only when the macro`nCANNOT SEE the bar and is guessing.`n`nTOO HIGH = shoots past.  TOO LOW = too slow."]
	, ["Unstable Left Division","UnstableLeftDivision"
	, "Brakes for the guessing left move.`n`nBIGGER = weaker brakes.`nSMALLER = stronger brakes."]
	, ["Right Ankle Break Multiplier","RightAnkleBreakMultiplier"
	, "Tiny PAUSE before turning around to go right.`n`nTOO HIGH = smooth but slow to react.`nTOO LOW  = jittery, shakes back and forth."]
	, ["Left Ankle Break Multiplier","LeftAnkleBreakMultiplier"
	, "Tiny PAUSE before turning around to go left.`n`nTOO HIGH = smooth but slow to react.`nTOO LOW  = jittery, shakes back and forth."] ]

MgBlockOpen("manual", 456, 288)
Gui, Font, s8 Bold c%ColorMuted%, Segoe UI
Gui, Add, Text, x%CX% y466 w%TXW% h16 HwndhC, MANUAL STEERING
MgAdd("manual", hC)
Gui, Font, s9 c%ColorDark%, Segoe UI
Gui, Add, Text, x%CX% y486 w%TXW% h22 +0x200 HwndhWarn, ⚠  Wrong values break tracking. Hover a ? to learn more.
MgAdd("manual", hWarn)
SpecialBrushes[hWarn] := {brush: hBrushAmber, text: ColorDarkBGR}
RoundCtrl(hWarn, TXW, 22, 6)
Gui, Font, s9 Norm c%ColorMuted%, Segoe UI

Y := 516
for i, d in TuningFieldDefs
	{
	lbl := d[1]
	var := d[2]
	hint := d[3]
	Gui, Add, Text, x%CX% y%Y% w%LW% h20 HwndhL, %lbl%:
	MgAdd("manual", hL)
	Gui, Add, Edit, x%IX% y%Y% w%IW% h20 v%var% gQueueAutoSave HwndhC, % %var%
	MgAdd("manual", hC)
	ThemedCtrls.Push(hC)
	Gui, Font, s9 Bold c%ColorAccent%, Segoe UI
	Gui, Add, Text, x%QX% y%Y% w16 h20 Center +0x100 +0x200 HwndhQ, ?
	Gui, Font, s9 Norm c%ColorMuted%, Segoe UI
	MgAdd("manual", hQ)
	IconTips[hQ] := hint
	Y += 24
	}

; ------------------------------------------------------------------------ precision steering
PrecisionFieldDefs := [ ["Kp","Kp"
	, "How hard it steers based on DISTANCE from`nthe fish.`n`nTOO HIGH = overshoots and wobbles.`nTOO LOW  = drifts, never quite arrives.`n`nSafe range: 0.3 to 0.8."]
	, ["Kd","Kd"
	, "How hard it steers based on SPEED. This is`nthe part Manual mode has no equivalent for --`nit accounts for the fish MOVING.`n`nTOO HIGH = sluggish, over-damped.`nTOO LOW  = oscillates around the fish.`n`nThis is the most important value here."]
	, ["Velocity Smoothing","VelocitySmoothing"
	, "How much it trusts the newest speed reading.`n0.2 means 20% new, 80% history.`n`nHIGHER = reacts faster but jitters more.`nLOWER  = smoother but slower to notice a`nchange of direction."]
	, ["Stopping Distance","StoppingDistanceMultiplier"
	, "How early it starts braking, measured in`nspeed. Faster closing = brakes sooner.`n`nTOO HIGH = brakes way too early, crawls.`nTOO LOW  = sails straight past the fish."] ]

MgBlockOpen("precision", 456, 144)
Gui, Font, s8 Bold c%ColorMuted%, Segoe UI
Gui, Add, Text, x%CX% y466 w%TXW% h16 HwndhC, PRECISION STEERING
MgAdd("precision", hC)
Gui, Font, s9 Norm c%ColorMuted%, Segoe UI

Y := 488
for i, d in PrecisionFieldDefs
	{
	lbl := d[1]
	var := d[2]
	hint := d[3]
	Gui, Add, Text, x%CX% y%Y% w%LW% h20 HwndhL, %lbl%:
	MgAdd("precision", hL)
	Gui, Add, Edit, x%IX% y%Y% w%IW% h20 v%var% gQueueAutoSave HwndhC, % %var%
	MgAdd("precision", hC)
	ThemedCtrls.Push(hC)
	Gui, Font, s9 Bold c%ColorAccent%, Segoe UI
	Gui, Add, Text, x%QX% y%Y% w16 h20 Center +0x100 +0x200 HwndhQ, ?
	Gui, Font, s9 Norm c%ColorMuted%, Segoe UI
	MgAdd("precision", hQ)
	IconTips[hQ] := hint
	Y += 24
	}

; ------------------------------------------------------------------------------- bar behaviour
MgBlockOpen("barctl", 620, 142)
Gui, Font, s8 Bold c%ColorMuted%, Segoe UI
Gui, Add, Text, x%CX% y630 w%TXW% h16 HwndhC, BAR BEHAVIOUR
MgAdd("barctl", hC)
Gui, Font, s9 Norm c%ColorMuted%, Segoe UI

Y := 652
MinigameFieldDefs := [ ["Minigame failsafe (s)","BarCalculationFailsafe",1
	, "Max SECONDS for one minigame (including waiting`nfor the bar). If it runs over, the macro re-equips`nthe rod and starts a fresh cast.`n`nDefault 60."]
	, ["Stabilizer clicks","StabilizerLoop",1
	, "Rapid clicks after each move to hold the bar`nstill. Lower control = increase (12-14)`n`nHIGHER = steadier, holds position better.`nLOWER = reacts faster."]
	, ["Side bar ratio","SideBarRatio",0
	, "How far in from the edges the amber markers sit.`n`nHIGHER = markers move inward, so the macro`nstarts edge-holding sooner.`nLOWER = markers sit closer to the edges."]
	, ["Side wait multiplier","SideBarWaitMultiplier",0
	, "How long it waits at the far edges before`ncoming back.`n`nHIGHER = waits longer (less bouncing).`nLOWER = leaves the edge sooner."] ]

for i, d in MinigameFieldDefs
	{
	lbl := d[1]
	var := d[2]
	isInt := d[3]
	hint := d[4]
	opt := isInt ? "+Number" : ""
	Gui, Add, Text, x%CX% y%Y% w%LW% h20 HwndhL, %lbl%:
	MgAdd("barctl", hL)
	Gui, Add, Edit, x%IX% y%Y% w%IW% h20 v%var% gQueueAutoSave HwndhC %opt%, % %var%
	MgAdd("barctl", hC)
	ThemedCtrls.Push(hC)
	Gui, Font, s9 Bold c%ColorAccent%, Segoe UI
	Gui, Add, Text, x%QX% y%Y% w16 h20 Center +0x100 +0x200 HwndhQ, ?
	Gui, Font, s9 Norm c%ColorMuted%, Segoe UI
	MgAdd("barctl", hQ)
	IconTips[hQ] := hint
	Y += RH
	}

; ------------------------------------------------------------------------------- quick rules
MgBlockOpen("manrules", 800, 158)
Gui, Font, s8 Bold c%ColorMuted%, Segoe UI
Gui, Add, Text, x%CX% y810 w%TXW% h16 HwndhC, QUICK RULES — MANUAL
MgAdd("manrules", hC)
Gui, Font, s9 Norm cFFFFFF, Segoe UI
ManualTipsLines := ["• RIGHT values should be HIGHER than LEFT values."
	, "• UNSTABLE values should be HIGHER than STABLE values."
	, "• Keep every Division between 1.0 and 1.5."
	, "• Overshoots the fish? Lower the Multiplier."
	, "• Too slow to catch up? Raise the Multiplier."
	, "• Change ONE value at a time, by about 15%."]
RuleY := 832
for i, RuleTxt in ManualTipsLines
	{
	Gui, Add, Text, x%CX% y%RuleY% w%TXW% h16 cFFFFFF HwndhC, %RuleTxt%
	MgAdd("manrules", hC)
	SpecialBrushes[hC] := {brush: hBrushCard, text: 0xFFFFFF}
	RuleY += 16
	}
Gui, Font, s9 Norm c%ColorMuted%, Segoe UI

MgBlockOpen("precrules", 800, 186)
Gui, Font, s8 Bold c%ColorMuted%, Segoe UI
Gui, Add, Text, x%CX% y810 w%TXW% h16 HwndhC, QUICK RULES — PRECISION / LINES
MgAdd("precrules", hC)
Gui, Font, s9 Norm cFFFFFF, Segoe UI
PrecTipsLines := ["• Try the defaults FIRST. Precision needs far less"
	, "   tuning than Manual — usually none at all."
	, "• Wobbles or shakes on the fish? Raise Kd."
	, "• Slow to catch a fish that bolts? Raise Kp."
	, "• Sails past the fish? Raise Stopping Distance."
	, "• Crawls and never arrives? Lower Stopping Distance."
	, "• Kd matters most. Kp near 0.5 and Kd near 0.3 is a"
	, "   good place to start."
	, "• Change ONE value at a time, by about 0.1."]
RuleY := 832
for i, RuleTxt in PrecTipsLines
	{
	Gui, Add, Text, x%CX% y%RuleY% w%TXW% h16 cFFFFFF HwndhC, %RuleTxt%
	MgAdd("precrules", hC)
	SpecialBrushes[hC] := {brush: hBrushCard, text: 0xFFFFFF}
	RuleY += 16
	}
Gui, Font, s9 Norm c%ColorMuted%, Segoe UI

; ------------------------------------------------------------------------ live detection check
MgBlockOpen("detcheck", 1000, 88)
Gui, Font, s8 Bold c%ColorMuted%, Segoe UI
Gui, Add, Text, x%CX% y1009 w%TXW% h16 HwndhC, DETECTION CHECK
MgAdd("detcheck", hC)
Gui, Font, s9 Norm c%ColorText%, Segoe UI
Gui, Add, Text, x%CX% y1029 w170 h28 Center +0x100 +0x200 vDetTestBtn gDetTestToggle HwndhC, ▶  Test detection
MgAdd("detcheck", hC)
SpecialBrushes[hC] := {brush: hBrushCard, text: ColorAccentBGR}
RoundCtrl(hC, 170, 28, 7)
Gui, Font, s9 Norm cFFFFFF, Segoe UI
Gui, Add, Text, x386 y1029 w342 h28 +0x200 vDetTestOut HwndhC, Stop the macro first`, then press Test.
MgAdd("detcheck", hC)
SpecialBrushes[hC] := {brush: hBrushCard, text: 0xFFFFFF}
Gui, Font, s8 Norm c%ColorMuted%, Segoe UI
Gui, Add, Text, x%CX% y1060 w%TXW% h16 HwndhC, Press Test, then cast your rod and play a minigame to see what it picks up.
MgAdd("detcheck", hC)
SpecialBrushes[hC] := {brush: hBrushCard, text: ColorMutedBGR}
Gui, Font, s9 Norm c%ColorMuted%, Segoe UI

return
;====================================================================================================;
;====================================================================================================;

BuildUtilitiesSection:

Gui, Font, s13 Bold c%ColorText%, Segoe UI
Gui, Add, Text, x%CARDX% y120 w%CARDW% h30 HwndhUH, Fishing Utilities
UtilCtrls.Push(hUH)
Gui, Font, s9 Norm c%ColorMuted%, Segoe UI
Gui, Add, Text, x%CARDX% y152 w%CARDW% h18 HwndhUS, Extras that run alongside fishing. Turn one on and open it to set it up.
UtilCtrls.Push(hUS)
SpecialBrushes[hUS] := {brush: hBrushBG, text: ColorMutedBGR}

UtilRowDefs := [ ["Auto Totem","UtilTotemOn","UtilTotemToggle","UtilOpenTotem"]
	, ["Auto Aquarium","UtilAquariumOn","UtilAquariumToggle","UtilOpenAquarium"]
	, ["Auto Keeperbound Recharge","UtilKeeperOn","UtilKeeperToggle","UtilOpenKeeper"]
	, ["Discord Webhook","UtilWebhookOn","UtilWebhookToggle","UtilOpenWebhook"] ]

UtilRowY := 180
for i, d in UtilRowDefs
	{
	lbl := d[1]
	cvar := d[2]
	ctog := d[3]
	copen := d[4]
	hC := AddPanel(CARDX, UtilRowY, CARDW, 54)
	UtilCtrls.Push(hC)
	Gui, Font, s10 Bold c%ColorText%, Segoe UI
	UtilLblY := UtilRowY + 17
	Gui, Add, Text, x%CX% y%UtilLblY% w240 h20 HwndhC, %lbl%
	UtilCtrls.Push(hC)
	SpecialBrushes[hC] := {brush: hBrushCard, text: ColorTextBGR}
	Gui, Font, s9 Norm c%ColorText%, Segoe UI
	if (cvar = "UtilTotemOn")
		uchk := TotemAuto ? "Checked" : ""
	else if (cvar = "UtilAquariumOn")
		uchk := AquariumAuto ? "Checked" : ""
	else if (cvar = "UtilKeeperOn")
		uchk := KeeperAuto ? "Checked" : ""
	else
		uchk := WebhookOn ? "Checked" : ""
	Gui, Add, CheckBox, x572 y%UtilLblY% w58 h20 c%ColorText% v%cvar% %uchk% g%ctog% HwndhC, On
	UtilCtrls.Push(hC)
	SpecialBrushes[hC] := {brush: hBrushCard, text: ColorTextBGR}
	UtilBtnY := UtilRowY + 13
	Gui, Font, s9 Bold c%ColorAccent%, Segoe UI
	Gui, Add, Text, x642 y%UtilBtnY% w86 h28 Center +0x100 +0x200 g%copen% HwndhC, Open
	UtilCtrls.Push(hC)
	SpecialBrushes[hC] := {brush: hBrushCard, text: ColorAccentBGR}
	RoundCtrl(hC, 86, 28, 7)
	Gui, Font, s9 Norm c%ColorMuted%, Segoe UI
	UtilRowY += 64
	}

UtilNoteY := UtilRowY + 4
Gui, Font, s8 c%ColorMuted%, Segoe UI
Gui, Add, Text, x%CARDX% y%UtilNoteY% w%CARDW% h48 HwndhC, More add-ons will appear here as they are added.`nAuto Totem only works in a private server.`nTotem and Aquarium both turn camera mode off - it hides the UI they read.
UtilCtrls.Push(hC)
SpecialBrushes[hC] := {brush: hBrushBG, text: ColorMutedBGR}
Gui, Font, s9 c%ColorMuted%, Segoe UI

return

UtilTotemToggle:
GuiControlGet, UtilTotemOn, 1:, UtilTotemOn
TotemAuto := UtilTotemOn
GuiControl, 1:, TotemAuto, %UtilTotemOn%
gosub, RefreshCameraLock
gosub, ShowSection
gosub, QueueAutoSave
return

UtilWebhookToggle:
GuiControlGet, UtilWebhookOn, 1:, UtilWebhookOn
WebhookOn := UtilWebhookOn
GuiControl, 1:, WebhookOn, %UtilWebhookOn%
gosub, ShowSection
gosub, QueueAutoSave
return

UtilOpenTotem:
TargetSection := "Totem"
gosub, ShowSection
return

UtilAquariumToggle:
GuiControlGet, UtilAquariumOn, 1:, UtilAquariumOn
AquariumAuto := UtilAquariumOn
GuiControl, 1:, AquariumAuto, %UtilAquariumOn%
gosub, RefreshCameraLock
gosub, ShowSection
gosub, QueueAutoSave
return

UtilOpenAquarium:
TargetSection := "Aquarium"
gosub, ShowSection
return

UtilKeeperToggle:
GuiControlGet, UtilKeeperOn, 1:, UtilKeeperOn
KeeperAuto := UtilKeeperOn
GuiControl, 1:, KeeperAuto, %UtilKeeperOn%
gosub, RefreshCameraLock
gosub, ShowSection
gosub, QueueAutoSave
return

UtilOpenKeeper:
TargetSection := "Keeper"
gosub, ShowSection
return

UtilOpenWebhook:
TargetSection := "Webhook"
gosub, ShowSection
return

UtilBack:
TargetSection := "Utilities"
gosub, ShowSection
return

;====================================================================================================;

BuildKeeperSection:

Gui, Font, s9 Norm c%ColorAccent%, Segoe UI
Gui, Add, Text, x%CARDX% y120 w220 h18 +0x100 gUtilBack HwndhC, <  Fishing Add-ons
KeeperCtrls.Push(hC)
SpecialBrushes[hC] := {brush: hBrushBG, text: ColorAccentBGR}

hC := AddPanel(CARDX, 140, CARDW, 50)
KeeperCtrls.Push(hC)
Gui, Font, s11 Bold c%ColorText%, Segoe UI
Gui, Add, Text, x%CX% y155 w300 h20 HwndhC, Auto Keeperbound Recharge
KeeperCtrls.Push(hC)
SpecialBrushes[hC] := {brush: hBrushCard, text: ColorTextBGR}
Gui, Font, s9 Norm c%ColorText%, Segoe UI
KBchk := KeeperAuto ? "Checked" : ""
Gui, Add, CheckBox, x572 y155 w58 h20 c%ColorText% vKeeperAuto %KBchk% gKeeperAutoChanged HwndhC, On
KeeperCtrls.Push(hC)
SpecialBrushes[hC] := {brush: hBrushCard, text: ColorTextBGR}
Gui, Font, s9 Bold c%ColorAccent%, Segoe UI
Gui, Add, Text, x642 y151 w86 h28 Center +0x100 +0x200 gUtilBack HwndhC, Hide
KeeperCtrls.Push(hC)
SpecialBrushes[hC] := {brush: hBrushCard, text: ColorAccentBGR}
RoundCtrl(hC, 86, 28, 7)

; ---- the gamepass requirement, stated up front ----
hC := AddPanel(CARDX, 196, CARDW, 58)
KeeperCtrls.Push(hC)
Gui, Font, s9 Bold cFFC24B, Segoe UI
Gui, Add, Text, x%CX% y206 w620 h18 HwndhC, Requires the ENCHANT ANYWHERE gamepass - without it this does nothing.
KeeperCtrls.Push(hC)
SpecialBrushes[hC] := {brush: hBrushCard, text: 0x4BC2FF}
Gui, Add, Text, x%CX% y226 w620 h18 HwndhC, You MUST manually recharge ONCE before starting the macro.
KeeperCtrls.Push(hC)
SpecialBrushes[hC] := {brush: hBrushCard, text: 0x4BC2FF}
Gui, Font, s9 Norm c%ColorText%, Segoe UI

hC := AddPanel(CARDX, 260, CARDW, 278)
KeeperCtrls.Push(hC)
KeeperBodyCtrls.Push(hC)

KbFieldDefs := [ ["Every (catches)","KeeperEveryCatches","num"
	, "How many catches between recharges.`n`nA Keeperbound rod loses about 0.2% power per`ncatch, so 50 catches is roughly 10% lost."]
	, ["Recharges per trip","KeeperRecharges","num"
	, "How many times to enchant in one visit.`n`nEach one refills about 5% power, so two`nrecharges covers the drain from 50 catches."]
	, ["Relic hotbar key","KeeperRelicKey","str"
	, "The hotbar number your Enchant Relic sits on.`n`nPut the relic in a hotbar slot and type that`nnumber here."]
	, ["Inventory key","KeeperInvKey","str"
	, "The key that opens the inventory.`n`nG in Fisch - the game prints Press (G) To Open`nabove the hotbar."]
	, ["Between relics (ms)","KeeperBetweenDelay","num"
	, "Pause between one enchant and the next.`n`nToo quick and the game only registers the`nfirst one, so keep this around 2000."]
	, ["Step delay (ms)","KeeperStepDelay","num"
	, "Pause after each click, so the game keeps up."]
	, ["Menu delay (ms)","KeeperOpenDelay","num"
	, "Pause after opening or closing the inventory."] ]

KbY := 266
for i, d in KbFieldDefs
	{
	lbl := d[1]
	var := d[2]
	hint := d[4]
	Gui, Add, Text, x%CX% y%KbY% w%LW% h20 HwndhKC, %lbl%:
	KeeperCtrls.Push(hKC)
	KeeperBodyCtrls.Push(hKC)
	SpecialBrushes[hKC] := {brush: hBrushCard, text: ColorTextBGR}
	if (d[3] = "num")
		Gui, Add, Edit, x%IX% y%KbY% w%IW% h20 v%var% gQueueAutoSave HwndhKC +Number, % %var%
	else
		Gui, Add, Edit, x%IX% y%KbY% w%IW% h20 v%var% gQueueAutoSave HwndhKC, % %var%
	KeeperCtrls.Push(hKC)
	KeeperBodyCtrls.Push(hKC)
	ThemedCtrls.Push(hKC)
	Gui, Font, s9 Bold c%ColorAccent%, Segoe UI
	Gui, Add, Text, x%QX% y%KbY% w16 h20 Center +0x100 +0x200 HwndhKQ, ?
	Gui, Font, s9 Norm c%ColorText%, Segoe UI
	KeeperCtrls.Push(hKQ)
	KeeperBodyCtrls.Push(hKQ)
	SpecialBrushes[hKQ] := {brush: hBrushCard, text: ColorAccentBGR}
	IconTips[hKQ] := hint
	KbY += 22
	}

; ---- point at the two buttons yourself, rather than trusting it to find them ----
Gui, Font, s8 Bold c%ColorMuted%, Segoe UI
KbSecY := KbY + 2
Gui, Add, Text, x%CX% y%KbSecY% w400 h16 HwndhKC, BUTTON POSITIONS
KeeperCtrls.Push(hKC)
KeeperBodyCtrls.Push(hKC)
SpecialBrushes[hKC] := {brush: hBrushCard, text: ColorMutedBGR}
Gui, Font, s9 Norm c%ColorText%, Segoe UI
KbY := KbSecY + 18

KbPosDefs := [ ["Enchant Rod", "KbEnchantSpot", "KeeperPickEnchant", "KeeperClearEnchant"]
	, ["Confirm", "KbConfirmSpot", "KeeperPickConfirm", "KeeperClearConfirm"] ]
for i, d in KbPosDefs
	{
	plbl := d[1]
	pvar := d[2]
	pset := d[3]
	pclr := d[4]
	Gui, Add, Text, x%CX% y%KbY% w120 h20 HwndhKC, %plbl%:
	KeeperCtrls.Push(hKC)
	KeeperBodyCtrls.Push(hKC)
	SpecialBrushes[hKC] := {brush: hBrushCard, text: ColorTextBGR}
	Gui, Font, s8 c%ColorMuted%, Segoe UI
	Gui, Add, Text, x330 y%KbY% w224 h20 +0x200 v%pvar% HwndhKC, -
	KeeperCtrls.Push(hKC)
	KeeperBodyCtrls.Push(hKC)
	SpecialBrushes[hKC] := {brush: hBrushCard, text: ColorMutedBGR}
	Gui, Font, s9 Bold c%ColorAccent%, Segoe UI
	KbBtnY := KbY - 2
	Gui, Add, Text, x562 y%KbBtnY% w96 h24 Center +0x100 +0x200 g%pset% HwndhKC, Set
	KeeperCtrls.Push(hKC)
	KeeperBodyCtrls.Push(hKC)
	SpecialBrushes[hKC] := {brush: hBrushCard, text: ColorAccentBGR}
	RoundCtrl(hKC, 96, 24, 6)
	Gui, Font, s9 Norm c%ColorMuted%, Segoe UI
	Gui, Add, Text, x666 y%KbBtnY% w62 h24 Center +0x100 +0x200 g%pclr% HwndhKC, Clear
	KeeperCtrls.Push(hKC)
	KeeperBodyCtrls.Push(hKC)
	SpecialBrushes[hKC] := {brush: hBrushCard, text: ColorMutedBGR}
	RoundCtrl(hKC, 62, 24, 6)
	Gui, Font, s9 Norm c%ColorText%, Segoe UI
	KbY += 26
	}

Gui, Font, s9 Norm c%ColorMuted%, Segoe UI
KbStatY := KbY + 2
Gui, Add, Text, x%CX% y%KbStatY% w520 h20 vKbStatLine HwndhKC, Idle.
KeeperCtrls.Push(hKC)
KeeperBodyCtrls.Push(hKC)
SpecialBrushes[hKC] := {brush: hBrushCard, text: ColorMutedBGR}

return

KeeperAutoChanged:
GuiControlGet, KeeperAuto, 1:, KeeperAuto
GuiControl, 1:, UtilKeeperOn, % (KeeperAuto ? 1 : 0)
gosub, RefreshCameraLock
gosub, ShowSection
gosub, QueueAutoSave
return

KeeperRefreshSpots:
if (Round(KeeperEnchantX) > 0 and Round(KeeperEnchantY) > 0)
	KbTxt := "set to " . Round(KeeperEnchantX) . ", " . Round(KeeperEnchantY)
else
	KbTxt := "not set - found by looking"
GuiControl, 1:, KbEnchantSpot, %KbTxt%
if (Round(KeeperConfirmX) > 0 and Round(KeeperConfirmY) > 0)
	KbTxt := "set to " . Round(KeeperConfirmX) . ", " . Round(KeeperConfirmY)
else
	KbTxt := "not set - found by looking"
GuiControl, 1:, KbConfirmSpot, %KbTxt%
return

KeeperClearEnchant:
KeeperEnchantX := 0
KeeperEnchantY := 0
gosub, KeeperRefreshSpots
gosub, QueueAutoSave
return

KeeperClearConfirm:
KeeperConfirmX := 0
KeeperConfirmY := 0
gosub, KeeperRefreshSpots
gosub, QueueAutoSave
return

KeeperPickEnchant:
KbPickWhat := "enchant"
KbPickMsg := "Press U over the ""Enchant Rod"" button        (open your inventory first)`nEsc to cancel"
gosub, KeeperPickPos
return

KeeperPickConfirm:
KbPickWhat := "confirm"
KbPickMsg := "Press U over the ""Confirm"" button        (press Enchant Rod first)`nEsc to cancel"
gosub, KeeperPickPos
return

KeeperPickPos:
Gui, Hide
Sleep 250
CoordMode, Mouse, Screen
CoordMode, ToolTip, Screen
KbPickCancel := false
KbPx := 0
KbPy := 0
Loop
	{
	if GetKeyState("Escape", "P")
		{
		KbPickCancel := true
		break
		}
	if GetKeyState("u", "P")
		{
		MouseGetPos, KbPx, KbPy
		while GetKeyState("u", "P")
			Sleep 20
		break
		}
	MouseGetPos, KbMx, KbMy
	ToolTip, %KbPickMsg%, % KbMx + 26, % KbMy + 30, 20
	Sleep 25
	}
ToolTip, , , , 20
CoordMode, Mouse, Client
CoordMode, ToolTip, Relative
if (!KbPickCancel)
	{
	if (!RobloxHwnd or !WinExist("ahk_id " . RobloxHwnd))
		{
		WinGet, RobloxHwnd, ID, ahk_exe RobloxPlayerBeta.exe
		if (!RobloxHwnd)
			WinGet, RobloxHwnd, ID, Roblox
		}
	if (!RobloxHwnd)
		{
		msgbox, 4144, DeepFish, Could not find the Roblox window, so that position cannot be saved.`n`nStart Roblox first, then set the positions again.
		Gui, Show
		TargetSection := "Keeper"
		gosub, ShowSection
		gosub, KeeperRefreshSpots
		return
		}
	VarSetCapacity(KbPt, 8, 0)
	NumPut(KbPx, KbPt, 0, "Int")
	NumPut(KbPy, KbPt, 4, "Int")
	DllCall("ScreenToClient", "Ptr", RobloxHwnd, "Ptr", &KbPt)
	KbCliX := NumGet(KbPt, 0, "Int")
	KbCliY := NumGet(KbPt, 4, "Int")
	VarSetCapacity(KbRc, 16, 0)
	DllCall("GetClientRect", "Ptr", RobloxHwnd, "Ptr", &KbRc)
	KbCw := NumGet(KbRc, 8, "Int")
	KbCh := NumGet(KbRc, 12, "Int")
	if (KbCliX < 0 or KbCliY < 0 or KbCliX >= KbCw or KbCliY >= KbCh)
		{
		msgbox, 4144, DeepFish, That spot is outside the Roblox window, so it was not saved.`n`nThe game window is %KbCw% x %KbCh%, and you picked %KbCliX%`, %KbCliY% inside it.`n`nPut Roblox on the screen you macro on, open your inventory there, and pick the button on that same screen.
		Gui, Show
		TargetSection := "Keeper"
		gosub, ShowSection
		gosub, KeeperRefreshSpots
		return
		}
	if (KbPickWhat = "enchant")
		{
		KeeperEnchantX := KbCliX
		KeeperEnchantY := KbCliY
		}
	else
		{
		KeeperConfirmX := KbCliX
		KeeperConfirmY := KbCliY
		}
	gosub, QueueAutoSave
	}
Gui, Show
TargetSection := "Keeper"
gosub, ShowSection
gosub, KeeperRefreshSpots
return

KeeperStatusTick:
if (KbBusy)
	KbLine := "Running now - " . KbStatus . "..."
else if (!KeeperAuto)
	KbLine := "Off."
else if (KeeperRelicKey = "")
	KbLine := "Set a relic hotbar key to enable."
else if (!MacroRunning)
	KbLine := "Waiting for the macro to start."
else
	{
	KbLeft := Round(KeeperEveryCatches) - KbCatches
	if (KbLeft < 0)
		KbLeft := 0
	KbLine := KbLeft . " more catches until the next recharge."
	}
if (KbLastResult != "")
	KbLine .= "   Last: " . KbLastResult . "."
GuiControl, 1:, KbStatLine, %KbLine%
return

;====================================================================================================;

BuildAquariumSection:

Gui, Font, s9 Norm c%ColorAccent%, Segoe UI
Gui, Add, Text, x%CARDX% y120 w220 h18 +0x100 gUtilBack HwndhC, ‹  Fishing Add-ons
AquariumCtrls.Push(hC)
SpecialBrushes[hC] := {brush: hBrushBG, text: ColorAccentBGR}

hC := AddPanel(CARDX, 140, CARDW, 54)
AquariumCtrls.Push(hC)
Gui, Font, s11 Bold c%ColorText%, Segoe UI
Gui, Add, Text, x%CX% y157 w220 h20 HwndhC, Auto Aquarium
AquariumCtrls.Push(hC)
SpecialBrushes[hC] := {brush: hBrushCard, text: ColorTextBGR}
Gui, Font, s9 Norm c%ColorText%, Segoe UI
AQchk := AquariumAuto ? "Checked" : ""
Gui, Add, CheckBox, x572 y157 w58 h20 c%ColorText% vAquariumAuto %AQchk% gAquariumAutoChanged HwndhC, On
AquariumCtrls.Push(hC)
SpecialBrushes[hC] := {brush: hBrushCard, text: ColorTextBGR}
Gui, Font, s9 Bold c%ColorAccent%, Segoe UI
Gui, Add, Text, x642 y153 w86 h28 Center +0x100 +0x200 gUtilBack HwndhC, Hide
AquariumCtrls.Push(hC)
SpecialBrushes[hC] := {brush: hBrushCard, text: ColorAccentBGR}
RoundCtrl(hC, 86, 28, 7)

hC := AddPanel(CARDX, 204, CARDW, 222)
AquariumCtrls.Push(hC)
AquariumBodyCtrls.Push(hC)

AqFieldDefs := [ ["Run every (minutes)","AquariumEveryMin"
	, "How long to fish between aquarium trips.`n`nFish food lasts one hour, so 60 keeps it`nalways active."]
	, ["Cards per trip","AquariumFoodCount"
	, "A safety cap on how many cards it will press`nin one trip.`n`nThe row holds your owned foods first and then`nthe shop, so there are more cards than there`nare foods - the sweep stops on its own at the`nend of the row.`n`nAnything under 10 is treated as 10, or it`nwould cut the trip short."]
	, ["Buy limit per trip","AquariumMaxBuys"
	, "The most Buy buttons it will press in one trip.`n`nEvery card gets pressed once, so leave this`nabove the number of foods on sale - it is only`nhere to stop a runaway from spending.`n`nA sold-out card looks exactly like a Buy one`nand costs nothing to press."]
	, ["Step delay (ms)","AquariumStepDelay"
	, "Pause after each click, to let the button`nchange from Buy to Use."]
	, ["Menu delay (ms)","AquariumOpenDelay"
	, "Pause after opening or closing the Aquariums`nmenu. Raise it if the panel is slow to appear."]
	, ["Scroll sweep (notches)","AquariumScrollSteps"
	, "Wheel notches per nudge when winding the row`nback to the start.`n`nIt keeps nudging until the row stops moving,`nso this is just the step size."] ]

AqY := 220
Gui, Font, s9 Norm c%ColorText%, Segoe UI
for i, d in AqFieldDefs
	{
	lbl := d[1]
	var := d[2]
	hint := d[3]
	Gui, Add, Text, x%CX% y%AqY% w%LW% h20 HwndhAC, %lbl%:
	AquariumCtrls.Push(hAC)
	AquariumBodyCtrls.Push(hAC)
	SpecialBrushes[hAC] := {brush: hBrushCard, text: ColorTextBGR}
	Gui, Add, Edit, x%IX% y%AqY% w%IW% h20 v%var% gQueueAutoSave HwndhAC +Number, % %var%
	AquariumCtrls.Push(hAC)
	AquariumBodyCtrls.Push(hAC)
	ThemedCtrls.Push(hAC)
	Gui, Font, s9 Bold c%ColorAccent%, Segoe UI
	Gui, Add, Text, x%QX% y%AqY% w16 h20 Center +0x100 +0x200 HwndhAQ, ?
	Gui, Font, s9 Norm c%ColorText%, Segoe UI
	AquariumCtrls.Push(hAQ)
	AquariumBodyCtrls.Push(hAQ)
	SpecialBrushes[hAQ] := {brush: hBrushCard, text: ColorAccentBGR}
	IconTips[hAQ] := hint
	AqY += 26
	}

Gui, Font, s9 Norm c%ColorMuted%, Segoe UI
AqStatY := AqY + 8
Gui, Add, Text, x%CX% y%AqStatY% w520 h20 vAqStatLine HwndhAC, Idle.
AquariumCtrls.Push(hAC)
AquariumBodyCtrls.Push(hAC)
SpecialBrushes[hAC] := {brush: hBrushCard, text: ColorMutedBGR}

AqNoteY := 436
Gui, Font, s8 c%ColorMuted%, Segoe UI
Gui, Add, Text, x%CARDX% y%AqNoteY% w%CARDW% h62 HwndhAC, Presses Aquariums at the top of the screen`, buys each fish food and uses it`, then closes the menu and carries on fishing.`nIt only runs between casts`, never during a minigame.`nCamera mode is forced off while this is on - it hides the Aquariums button.
AquariumCtrls.Push(hAC)
SpecialBrushes[hAC] := {brush: hBrushBG, text: ColorMutedBGR}
Gui, Font, s9 c%ColorMuted%, Segoe UI

return

AquariumAutoChanged:
GuiControlGet, AquariumAuto, 1:, AquariumAuto
GuiControl, 1:, UtilAquariumOn, % (AquariumAuto ? 1 : 0)
gosub, RefreshCameraLock
gosub, ShowSection
gosub, QueueAutoSave
return

AquariumStatusTick:
if (AqBusy)
	AqLine := "Running now - " . AqStatus . "..."
else if (!AquariumAuto)
	AqLine := "Off."
else if (!MacroRunning)
	AqLine := "Waiting for the macro to start."
else if (AqNextTick = 0)
	AqLine := "Next trip: on the next cast."
else
	{
	AqLeft := (AqNextTick - A_TickCount) // 1000
	if (AqLeft < 0)
		AqLeft := 0
	AqLine := "Next trip in " . (AqLeft // 60) . "m " . Mod(AqLeft, 60) . "s."
	}
if (AqLastResult != "")
	AqLine .= "   Last trip: " . AqLastResult . "."
GuiControl, 1:, AqStatLine, %AqLine%
return

;====================================================================================================;

BuildTotemSection:

Gui, Font, s9 Norm c%ColorAccent%, Segoe UI
Gui, Add, Text, x%CARDX% y120 w220 h18 +0x100 gUtilBack HwndhC, ‹  Fishing Add-ons
TotemCtrls.Push(hC)
SpecialBrushes[hC] := {brush: hBrushBG, text: ColorAccentBGR}

hC := AddPanel(CARDX, 140, CARDW, 54)
TotemCtrls.Push(hC)
Gui, Font, s11 Bold c%ColorText%, Segoe UI
Gui, Add, Text, x%CX% y157 w220 h20 HwndhC, Auto Totem
TotemCtrls.Push(hC)
SpecialBrushes[hC] := {brush: hBrushCard, text: ColorTextBGR}
Gui, Font, s9 Norm c%ColorText%, Segoe UI
TAchk := TotemAuto ? "Checked" : ""
Gui, Add, CheckBox, x572 y157 w58 h20 c%ColorText% vTotemAuto %TAchk% gTotemAutoChanged HwndhC, On
TotemCtrls.Push(hC)
SpecialBrushes[hC] := {brush: hBrushCard, text: ColorTextBGR}
Gui, Font, s9 Bold c%ColorAccent%, Segoe UI
Gui, Add, Text, x642 y153 w86 h28 Center +0x100 +0x200 gUtilBack HwndhC, Hide
TotemCtrls.Push(hC)
SpecialBrushes[hC] := {brush: hBrushCard, text: ColorAccentBGR}
RoundCtrl(hC, 86, 28, 7)

; ---- body ----
hC := AddPanel(CARDX, 204, CARDW, 148)
TotemCtrls.Push(hC)
TotemBodyCtrls.Push(hC)

Gui, Font, s9 c%ColorText%, Segoe UI
TGchk := TotemGlobal ? "Checked" : ""
Gui, Add, CheckBox, x%CX% y216 w400 h20 c%ColorText% vTotemGlobal %TGchk% gTotemGlobalChanged HwndhTC, Share Totem settings across all profiles
TotemCtrls.Push(hTC)
TotemBodyCtrls.Push(hTC)
SpecialBrushes[hTC] := {brush: hBrushCard, text: ColorTextBGR}
Gui, Font, s9 Bold c%ColorAccent%, Segoe UI
Gui, Add, Text, x%QX% y216 w16 h20 Center +0x100 +0x200 HwndhTC, ?
TotemCtrls.Push(hTC)
TotemBodyCtrls.Push(hTC)
IconTips[hTC] := "ON  - one set of Totem settings shared by every`n      profile, stored in Settings.ini.`nOFF - each profile keeps its own."
Gui, Font, s9 Norm c%ColorText%, Segoe UI

TotemOptList := "None|Day|Night|Clearcast|Aurora|Starfall|Eclipse|Tempest|Windset|Smokescreen|Shiny|Sparkling|Mutation"

Gui, Add, Text, x%CX% y244 w160 h20 HwndhTC, Totem to macro:
TotemCtrls.Push(hTC)
TotemBodyCtrls.Push(hTC)
Gui, Add, DropDownList, x%IX% y242 w%IW% h240 vTotemSel1 gTotemSelChanged HwndhTC, %TotemOptList%
TotemCtrls.Push(hTC)
TotemBodyCtrls.Push(hTC)
ThemedCtrls.Push(hTC)
GuiControl, 1:ChooseString, TotemSel1, %TotemSel1%

Gui, Add, Text, x%CX% y272 w160 h20 HwndhTC, Second totem:
TotemCtrls.Push(hTC)
TotemBodyCtrls.Push(hTC)
Gui, Add, DropDownList, x%IX% y270 w%IW% h240 vTotemSel2 gTotemSelChanged HwndhTC, %TotemOptList%
TotemCtrls.Push(hTC)
TotemBodyCtrls.Push(hTC)
ThemedCtrls.Push(hTC)
GuiControl, 1:ChooseString, TotemSel2, %TotemSel2%

Gui, Add, Text, x%CX% y302 w130 h20 HwndhTC, Check every (s):
TotemCtrls.Push(hTC)
TotemBodyCtrls.Push(hTC)
Gui, Add, Edit, x338 y300 w60 h20 vTotemPollSec gQueueAutoSave HwndhTC +Number, % TotemPollSec
TotemCtrls.Push(hTC)
TotemBodyCtrls.Push(hTC)
ThemedCtrls.Push(hTC)
Gui, Add, Text, x420 y302 w110 h20 HwndhTC, Pop delay (ms):
TotemCtrls.Push(hTC)
TotemBodyCtrls.Push(hTC)
Gui, Add, Edit, x536 y300 w60 h20 vTotemActDelay gQueueAutoSave HwndhTC +Number, % TotemActDelay
TotemCtrls.Push(hTC)
TotemBodyCtrls.Push(hTC)
ThemedCtrls.Push(hTC)

; ---- hotbar keys ----
hC := AddPanel(CARDX, 362, CARDW, 162)
TotemCtrls.Push(hC)
TotemBodyCtrls.Push(hC)

Gui, Font, s8 Bold c%ColorMuted%, Segoe UI
Gui, Add, Text, x%CX% y372 w%TXW% h16 HwndhTotemKeyHdr, HOTBAR KEYS
TotemCtrls.Push(hTotemKeyHdr)
TotemBodyCtrls.Push(hTotemKeyHdr)
Gui, Font, s9 Norm c%ColorText%, Segoe UI
TotemKeyTop := 394

TotemRowNames := ["Sundial","Clearcast","Tempest","Windset","Smokescreen","Eclipse","Aurora","Starfall","Shiny","Sparkling","Mutation"]
TotemRowLabel := {Sundial: "Sundial (day/night)", Clearcast: "Clearcast (clears weather)"
	, Tempest: "Tempest (Rain)", Windset: "Windset (Windy)", Smokescreen: "Smokescreen (Foggy)"
	, Eclipse: "Eclipse", Aurora: "Aurora", Starfall: "Starfall"
	, Shiny: "Shiny", Sparkling: "Sparkling", Mutation: "Mutation"}
TotemLblH := {}
TotemEdtH := {}

for i, nm in TotemRowNames
	{
	kvar := "TotemKey" . nm
	lt := TotemRowLabel[nm]
	Gui, Add, Text, x%CX% y%TotemKeyTop% w260 h20 HwndhTL, %lt%
	TotemCtrls.Push(hTL)
	TotemBodyCtrls.Push(hTL)
	SpecialBrushes[hTL] := {brush: hBrushCard, text: ColorWhiteBGR}
	TotemLblH[nm] := hTL
	Gui, Add, Edit, x%IX% y%TotemKeyTop% w70 h20 v%kvar% gQueueAutoSave HwndhTE Limit6, % %kvar%
	TotemCtrls.Push(hTE)
	TotemBodyCtrls.Push(hTE)
	ThemedCtrls.Push(hTE)
	TotemEdtH[nm] := hTE
	}

; ---- status ----
hC := AddPanel(CARDX, 534, CARDW, 78)
TotemCtrls.Push(hC)
TotemBodyCtrls.Push(hC)
Gui, Font, s8 Bold c%ColorMuted%, Segoe UI
Gui, Add, Text, x%CX% y544 w%TXW% h16 HwndhC, STATUS
TotemCtrls.Push(hC)
TotemBodyCtrls.Push(hC)
Gui, Font, s9 Norm cFFFFFF, Segoe UI
Gui, Add, Text, x%CX% y564 w%TXW% h18 vTotemStatusText HwndhC, ---
TotemCtrls.Push(hC)
TotemBodyCtrls.Push(hC)
SpecialBrushes[hC] := {brush: hBrushCard, text: 0xFFFFFF}
Gui, Font, s8 c%ColorMuted%, Segoe UI
Gui, Add, Text, x%CX% y584 w%TXW% h28 HwndhTotemNote, Private servers only - totems cannot be used in public ones.`nCamera mode hides the weather icons, so it stays off while Auto Totem is on.
TotemCtrls.Push(hTotemNote)
TotemBodyCtrls.Push(hTotemNote)
SpecialBrushes[hTotemNote] := {brush: hBrushCard, text: ColorMutedBGR}
Gui, Font, s9 c%ColorMuted%, Segoe UI

return

;====================================================================================================;

TotemStatusTick:
if (TargetSection != "Totem")
	{
	SetTimer, TotemStatusTick, Off
	return
	}
if (!TotemAuto)
	TotemStat := "Auto Totem is off."
else if (TotemTime = "" and TotemWeather = "")
	TotemStat := "Waiting for the first check..."
else
	{
	TotemStat := "Time: " . (TotemTime = "" ? "?" : TotemTime)
	TotemStat .= "     Weather: " . (TotemWeather = "" ? "clear" : TotemWeather)
	if (TotemEvents != "")
		TotemStat .= "     " . TotemEvents
	}
GuiControl, 1:, TotemStatusText, %TotemStat%
return

;====================================================================================================;

RefreshTotemKeys:
if (!TotemLblH)
	return
TotemNeed := {}
TotemNeedList := []
for i, sel in [TotemSel1, TotemSel2]
	{
	if (sel = "" or sel = "None")
		continue
	if (sel = "Day" or sel = "Night")
		{
		TotemNeed["Sundial"] := 1
		continue
		}
	if (!TotemNeed.HasKey(sel))
		{
		TotemNeed[sel] := 1
		TotemNeedList.Push(sel)
		}
	if (sel = "Aurora" or sel = "Starfall" or sel = "Eclipse")
		TotemNeed["Sundial"] := 1
	if (sel = "Tempest" or sel = "Windset" or sel = "Smokescreen")
		TotemNeed["Clearcast"] := 1
	}
TotemOrder := []
if (TotemNeed.HasKey("Sundial"))
	TotemOrder.Push("Sundial")
if (TotemNeed.HasKey("Clearcast"))
	TotemOrder.Push("Clearcast")
for i, nm in TotemNeedList
	{
	if (nm = "Sundial" or nm = "Clearcast")
		continue
	TotemOrder.Push(nm)
	}
RowY := TotemKeyTop
for i, nm in TotemRowNames
	{
	GuiControl, 1:Hide, % TotemLblH[nm]
	GuiControl, 1:Hide, % TotemEdtH[nm]
	}
for i, nm in TotemOrder
	{
	hL := TotemLblH[nm]
	hE := TotemEdtH[nm]
	SetBase(hL, CX, RowY)
	SetBase(hE, IX, RowY)
	if (TargetSection = "Totem" and TotemAuto)
		{
		GuiControl, 1:Show, %hL%
		GuiControl, 1:Show, %hE%
		}
	RowY += 24
	}
return

;====================================================================================================;

TotemSelChanged:
GuiControlGet, TotemSel1, 1:, TotemSel1
GuiControlGet, TotemSel2, 1:, TotemSel2
gosub, ShowSection
gosub, QueueAutoSave
return

;====================================================================================================;

TotemGlobalChanged:
GuiControlGet, TotemGlobal, 1:, TotemGlobal
TGval := TotemGlobal ? 1 : 0
IniWrite, %TGval%, %SettingsFile%, Totem, Global
gosub, QueueAutoSave
return

;====================================================================================================;

TotemAutoChanged:
GuiControlGet, TotemAuto, 1:, TotemAuto
GuiControl, 1:, UtilTotemOn, % (TotemAuto ? 1 : 0)
gosub, RefreshCameraLock
gosub, ShowSection
gosub, QueueAutoSave
return

;====================================================================================================;

RefreshCameraLock:
if (TotemAuto or AquariumAuto or KeeperAuto)
	{
	GuiControl, 1:Disable, AutoEnableCameraMode
	GuiControl, 1:Disable, AutoCameraDelay
	}
else
	{
	GuiControl, 1:Enable, AutoEnableCameraMode
	GuiControl, 1:Enable, AutoCameraDelay
	}
return

;====================================================================================================;

BuildWebhookSection:

Gui, Font, s9 Norm c%ColorAccent%, Segoe UI
Gui, Add, Text, x%CARDX% y120 w220 h18 +0x100 gUtilBack HwndhWC, ‹  Fishing Add-ons
WebhookCtrls.Push(hWC)
SpecialBrushes[hWC] := {brush: hBrushBG, text: ColorAccentBGR}

hC := AddPanel(CARDX, 140, CARDW, 54)
WebhookCtrls.Push(hC)
Gui, Font, s11 Bold c%ColorText%, Segoe UI
Gui, Add, Text, x%CX% y157 w240 h20 HwndhWC, Discord Webhook
WebhookCtrls.Push(hWC)
SpecialBrushes[hWC] := {brush: hBrushCard, text: ColorTextBGR}
Gui, Font, s9 Norm c%ColorText%, Segoe UI
WEchk := WebhookOn ? "Checked" : ""
Gui, Add, CheckBox, x572 y157 w58 h20 c%ColorText% vWebhookOn gWebhookOnChanged %WEchk% HwndhWC, On
WebhookCtrls.Push(hWC)
SpecialBrushes[hWC] := {brush: hBrushCard, text: ColorTextBGR}
Gui, Font, s9 Bold c%ColorAccent%, Segoe UI
Gui, Add, Text, x642 y153 w86 h28 Center +0x100 +0x200 gUtilBack HwndhWC, Hide
WebhookCtrls.Push(hWC)
SpecialBrushes[hWC] := {brush: hBrushCard, text: ColorAccentBGR}
RoundCtrl(hWC, 86, 28, 7)
Gui, Font, s9 Norm c%ColorText%, Segoe UI

hC := AddPanel(CARDX, 204, CARDW, 62)
WebhookCtrls.Push(hC)
WebhookBodyCtrls.Push(hC)
Gui, Add, Text, x%CX% y218 w160 h20 HwndhWC, Webhook URL:
WebhookCtrls.Push(hWC)
WebhookBodyCtrls.Push(hWC)
SpecialBrushes[hWC] := {brush: hBrushCard, text: ColorTextBGR}
Gui, Add, Edit, x%CX% y238 w%TXW% h20 vWebhookURL gQueueAutoSave HwndhWC, % WebhookURL
WebhookCtrls.Push(hWC)
WebhookBodyCtrls.Push(hWC)
ThemedCtrls.Push(hWC)

hC := AddPanel(CARDX, 276, CARDW, 226)
WebhookCtrls.Push(hC)
WebhookBodyCtrls.Push(hC)

Gui, Font, s8 Bold c%ColorMuted%, Segoe UI
Gui, Add, Text, x%CX% y286 w%TXW% h16 HwndhWC, NOTIFICATIONS
WebhookCtrls.Push(hWC)
WebhookBodyCtrls.Push(hWC)
Gui, Font, s9 Norm c%ColorText%, Segoe UI

Gui, Add, Text, x%CX% y310 w240 h20 HwndhWC, Status report every (min):
WebhookCtrls.Push(hWC)
WebhookBodyCtrls.Push(hWC)
SpecialBrushes[hWC] := {brush: hBrushCard, text: ColorTextBGR}
Gui, Add, Edit, x%IX% y310 w70 h20 vWebhookSummaryMin gQueueAutoSave HwndhWC +Number, % WebhookSummaryMin
WebhookCtrls.Push(hWC)
WebhookBodyCtrls.Push(hWC)
ThemedCtrls.Push(hWC)

Gui, Add, Text, x%CX% y336 w240 h20 HwndhWC, Alert if no catch for (min):
WebhookCtrls.Push(hWC)
WebhookBodyCtrls.Push(hWC)
SpecialBrushes[hWC] := {brush: hBrushCard, text: ColorTextBGR}
Gui, Add, Edit, x%IX% y336 w70 h20 vWebhookStallMin gQueueAutoSave HwndhWC +Number, % WebhookStallMin
WebhookCtrls.Push(hWC)
WebhookBodyCtrls.Push(hWC)
ThemedCtrls.Push(hWC)

WAchk := WebhookOnAlert ? "Checked" : ""
Gui, Add, CheckBox, x%CX% y368 w%TXW% h20 c%ColorText% vWebhookOnAlert gQueueAutoSave %WAchk% HwndhWC, Send alerts (stopped, stalled, re-equip)
WebhookCtrls.Push(hWC)
WebhookBodyCtrls.Push(hWC)
SpecialBrushes[hWC] := {brush: hBrushCard, text: ColorTextBGR}

WCchk := WebhookOnCatch ? "Checked" : ""
Gui, Add, CheckBox, x%CX% y392 w%TXW% h20 c%ColorText% vWebhookOnCatch gQueueAutoSave %WCchk% HwndhWC, Send a message for every catch
WebhookCtrls.Push(hWC)
WebhookBodyCtrls.Push(hWC)
SpecialBrushes[hWC] := {brush: hBrushCard, text: ColorTextBGR}

WSchk := WebhookShot ? "Checked" : ""
Gui, Add, CheckBox, x%CX% y416 w%TXW% h20 c%ColorText% vWebhookShot gQueueAutoSave %WSchk% HwndhWC, Attach a screenshot to status reports
WebhookCtrls.Push(hWC)
WebhookBodyCtrls.Push(hWC)
SpecialBrushes[hWC] := {brush: hBrushCard, text: ColorTextBGR}

Gui, Font, s8 c%ColorMuted%, Segoe UI
Gui, Add, Text, x%CX% y440 w%TXW% h28 HwndhWC, Captures the whole screen. It shows your username, level`nand cash, and is deleted right after it is sent.
WebhookCtrls.Push(hWC)
WebhookBodyCtrls.Push(hWC)
SpecialBrushes[hWC] := {brush: hBrushCard, text: ColorMutedBGR}

Gui, Font, s9 Norm c%ColorText%, Segoe UI
Gui, Add, Button, x%CX% y470 w170 h26 gWebhookTest HwndhWebhookTestBtn, Send test message
WebhookCtrls.Push(hWebhookTestBtn)
WebhookBodyCtrls.Push(hWebhookTestBtn)
ThemedCtrls.Push(hWebhookTestBtn)
Gui, Font, s9 Norm c%ColorMuted%, Segoe UI
return

;====================================================================================================;

WebhookOnChanged:
GuiControlGet, WebhookOn, 1:, WebhookOn
GuiControl, 1:, UtilWebhookOn, % (WebhookOn ? 1 : 0)
gosub, ShowSection
gosub, QueueAutoSave
return

;====================================================================================================;

WebhookTest:
GuiControlGet, WebhookURL, 1:, WebhookURL
if (WebhookURL = "")
	{
	msgbox, 4144, DeepFish, Enter a webhook URL first.
	return
	}
WhF := WhField("Status", "Test message", true)
WhF .= "," . WhField("Runtime", "0h 0m", true)
WhJ := WhBuildJson("DeepFish connected", "If you can read this, the webhook is working.", 3066993, WhF, "DeepFish")
if (WhPost(WhJ))
	msgbox, 4160, DeepFish, Test message sent.
else
	msgbox, 4144, DeepFish, Could not send. Check the URL is a full Discord webhook link and that you are online.
return

;====================================================================================================;

BuildFaqSection:

Gui, Font, s13 Bold c%ColorText%, Segoe UI
Gui, Add, Text, x%CARDX% y120 w%CARDW% h28 HwndhFaqHdr, Frequently Asked Questions
FaqCtrls.Push(hFaqHdr)

FaqTexts := []
FaqNames := ["General", "Cast", "Shake", "Minigame", "Special Rods", "Utilities"]
FaqT := ""
FaqT .= "Problems you can hit before the macro even starts fishing, in the order you usually hit them.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "1.  THE MACRO DOES NOTHING AT ALL`n`n"
FaqT .= "Right-click the DeepFish file and choose Run as administrator.`n`n"
FaqT .= "If Roblox, or anything else on your PC, is running with more permission than the macro, Windows quietly throws away every click and key press the macro sends. Nothing looks broken, the game just ignores it. Try this before you change any setting.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "2.  COULD NOT FIND THE ROBLOX GAME WINDOW`n`n"
FaqT .= "Open Roblox and join a game before you press Start.`n`n"
FaqT .= "If Roblox is already open, close it fully and open it again. The macro looks for the Roblox player window, so a Roblox page open in your browser does not count.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "3.  I PRESS START BUT IT DOES NOT FISH`n`n"
FaqT .= "The Start button does not start fishing by itself. It finds Roblox, brings it to the front, maximizes it and turns your Start/Stop key on. Press your Start/Stop key after that to begin.`n`n"
FaqT .= "If the DeepFish window disappears when you press Start, that is normal. Tick Always open after pressing Start in General if you would rather keep it on screen.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "4.  MY START, RELOAD OR EXIT KEY DOES NOTHING`n`n"
FaqT .= "Check the Start/Stop key, Reload key and Exit key in General match the keys you are pressing.`n`n"
FaqT .= "Programs like Discord, OBS, Nvidia or keyboard software can grab a key before the macro sees it. Pick a key nothing else uses, such as F6.`n`n"
FaqT .= "These keys work anywhere on your PC while the macro is armed, so avoid keys you type in chat.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "5.  THE COLOR PICKER OR DETECTION LANDS IN THE WRONG PLACE`n`n"
FaqT .= "Run Roblox in fullscreen. If that does not fix it, set Windows display scale to 100% (Settings > System > Display > Scale) and restart your PC.`n`n"
FaqT .= "Windows scaling above 100% makes the macro look at the wrong part of the screen, so colors get picked from the wrong spot and nothing is ever detected. If true fullscreen breaks detection on your PC, use windowed fullscreen instead.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "6.  IT BROKE AFTER I RESIZED OR MOVED ROBLOX`n`n"
FaqT .= "Stop the macro and start it again.`n`n"
FaqT .= "The macro measures the Roblox window when it starts. Switching fullscreen on or off, resizing the window or dragging it to another monitor while it is running leaves it looking at the old spot.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "7.  THE CAMERA SETUP STEPS MESS THINGS UP`n`n"
FaqT .= "Untick the Auto options you do not want in General > Automatic game setup, or raise the delay ms next to the step that fails.`n`n"
FaqT .= "Each step (lower graphics, zoom, camera mode, look down, blur) presses keys and moves the camera for you. On a slow PC the game may not keep up, and a bigger delay gives it time.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "8.  AUTO-ENABLE CAMERA MODE IS GREYED OUT`n`n"
FaqT .= "That is on purpose. It is locked off while Auto Totem, Auto Aquarium or Auto Keeperbound is turned on, because camera mode hides the game interface those features need to read.`n`n"
FaqT .= "With camera mode off, the rod is equipped with your Rod hotbar slot key, so make sure that key is set in General > Recovery.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "9.  THE MACRO FISHES WITHOUT A ROD IN MY HAND`n`n"
FaqT .= "Set Rod hotbar slot key in General > Recovery to the number your rod sits on.`n`n"
FaqT .= "When camera mode is off, that key is the only way the macro equips your rod.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "10.  MY SETTINGS KEEP RESETTING`n`n"
FaqT .= "Press Save, or tick Auto-save so every change is saved the moment you make it.`n`n"
FaqT .= "Settings are stored per profile, so also check the profile at the top of the window is the one you think you are on. Auto Aquarium and Auto Keeperbound settings are shared by every profile, and Auto Totem can be shared with Share Totem settings across all profiles.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "11.  A POPUP SAYS SOME SETTINGS WERE INVALID AND WERE RESET`n`n"
FaqT .= "A value in that profile file could not be read, so the macro put that one setting back to its default. The popup lists which ones. Set them again and press Save.`n`n"
FaqT .= "This usually happens after editing a profile file by hand.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "12.  A POPUP SAYS A FIELD CONTAINS AN INVALID NUMBER`n`n"
FaqT .= "One of the boxes has letters, spaces or symbols where only a number belongs. The popup lists which field. Fix it and save again. Nothing in that field was saved until you do.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "13.  I CANNOT NAME OR DELETE A PROFILE`n`n"
FaqT .= "Profile names cannot contain these characters: \ / : * ? < > | or double quotes.`n`n"
FaqT .= "The Default profile cannot be deleted, and neither can your only profile. Make another profile first.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "14.  THE DEEPFISH WINDOW COVERS THE GAME`n`n"
FaqT .= "Untick Window always on top in General.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "15.  MY GAME LAGS WHILE THE MACRO RUNS`n`n"
FaqT .= "Tick Auto-lower graphics in General, and close other heavy programs.`n`n"
FaqT .= "The macro reads the screen many times a second. A low frame rate in Roblox makes the minigame harder to follow, so lower graphics directly helps tracking.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "16.  I NEED HELP WITH SOMETHING NOT LISTED HERE`n`n"
FaqT .= "Ask in the Discord (link in About). Say which rod you are using, your screen resolution, and include a screenshot or short video of the problem.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqTexts.Push(FaqT)
FaqT := ""
FaqT .= "Problems with getting the rod into the water.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "1.  THE MACRO NEVER CASTS`n`n"
FaqT .= "Make sure your rod is in your hand. Set Rod hotbar slot key in General > Recovery so the macro can equip it itself.`n`n"
FaqT .= "Also check nothing is open on screen, such as your inventory, a shop or a dialog box. The cast click lands on that instead.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "2.  MY CASTS ARE TOO SHORT OR TOO FAR`n`n"
FaqT .= "Normal cast: change Hold rod cast duration (ms) in Cast. Higher casts further out, lower casts closer in.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "3.  IT STARTS SHAKING BEFORE THE BOBBER LANDS`n`n"
FaqT .= "Raise Wait for bobber delay (ms) in Cast. Laggy servers need a bigger delay.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "4.  PERFECT CAST NEVER LETS GO`n`n"
FaqT .= "Open the Color Manager (F9) and pick the green and white colors of the cast power bar again, or raise Green tolerance and White tolerance a little.`n`n"
FaqT .= "If the bar is never found it gives up after Fail timeout (s) and lets go anyway, so it will not hang forever.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "5.  PERFECT CAST LETS GO TOO EARLY OR TOO LATE`n`n"
FaqT .= "Change Release timing in Cast in steps of 0.5. Lower it if it lets go too late, raise it if it lets go too early.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "6.  PERFECT CAST LETS GO AT RANDOM MOMENTS`n`n"
FaqT .= "Lower Green tolerance and White tolerance. When they are too high, other white or green parts of the screen get mistaken for the cast bar.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "7.  MY ROD OR BOBBER GETS STUCK ON THE GROUND`n`n"
FaqT .= "Set Re-equip after N failed casts in General to 2, and fill in Rod hotbar slot key and Equipment bag key.`n`n"
FaqT .= "After that many failed casts the macro swaps to your equipment bag and back to the rod, which drops the stuck bobber. If you leave Equipment bag key blank it presses the rod key twice instead.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "8.  IT CASTS AGAIN BEFORE THE CATCH ANIMATION FINISHES`n`n"
FaqT .= "Raise Restart delay (ms) in General. Try 3000 and adjust from there.`n`n"
FaqT .= "This is the pause between finishing a catch and the next cast. Too short and the cast is wasted while the game is still showing the catch.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "9.  IT MAKES A STRAY CAST RIGHT AFTER A MINIGAME`n`n"
FaqT .= "First raise Restart delay (ms) in General.`n`n"
FaqT .= "If it still happens, the macro is probably mistaking something on screen for the minigame after it ends, then clicking. Stop the macro, press Test detection in Minigame with no minigame on screen, and lower Fish line tolerance or remove extra colors until nothing is detected.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqTexts.Push(FaqT)
FaqT := ""
FaqT .= "Problems between the cast and the minigame.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "1.  IT CASTS BUT NEVER SHAKES`n`n"
FaqT .= "Check Shake mode in Shake. Click clicks the shake button with the mouse, Navigation uses the keyboard, and Disabled does not shake at all.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "2.  NAVIGATION MODE DOES NOTHING`n`n"
FaqT .= "Set In-game navigation key in Shake to the key Roblox uses to turn on UI navigation. It is backslash by default.`n`n"
FaqT .= "If you changed that key in your Roblox settings, the macro needs the same key.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "3.  CLICK MODE MISSES THE SHAKE BUTTON`n`n"
FaqT .= "Make the search area cover where the shake button actually appears. Change Search area left, right, top and bottom (%) in Shake.`n`n"
FaqT .= "If the button is inside the area but still missed, raise Click tolerance by 1 at a time.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "4.  CLICK MODE CLICKS THINGS THAT ARE NOT THE SHAKE BUTTON`n`n"
FaqT .= "Lower Click tolerance, and shrink the search area so it does not include other white parts of the screen like chat or menus.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "5.  SHAKING IS TOO SLOW AND THE FISH GETS AWAY`n`n"
FaqT .= "Click mode: lower Click scan delay (ms). Navigation mode: lower Navigation spam delay (ms).`n`n"
FaqT .= "Going too low can make the game miss inputs, so lower it a little at a time.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "6.  IT KEEPS CLICKING THE SAME SPOT`n`n"
FaqT .= "Lower Repeat bypass count in Shake. That is how many times the same spot is clicked before the macro moves on.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "7.  IT SHAKES FOREVER AND NEVER REACHES THE MINIGAME`n`n"
FaqT .= "Check the minigame is actually being detected (see the Minigame tab). The macro keeps shaking until it sees the minigame.`n`n"
FaqT .= "Click failsafe (s) and Navigation failsafe (s) in Shake set how long it shakes before giving up and casting again.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqTexts.Push(FaqT)
FaqT := ""
FaqT .= "Problems once the reeling bar appears. Use Test detection in Minigame to see what the macro can see.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "1.  THE MINIGAME IS NEVER DETECTED`n`n"
FaqT .= "Stop the macro, press Test detection in Minigame, then cast and play a minigame yourself. It shows whether the bar and the fish line are being seen.`n`n"
FaqT .= "If they are not, open the Color Manager (F9) and pick the colors again while the minigame is on screen. Each color keeps a list, so if the bar looks different at night or while it fills, add that shade too.`n`n"
FaqT .= "Raise Fish line tolerance a little at a time if picking again does not help. Colors differ between rod skins, so a new rod often needs a fresh pick.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "2.  TEST DETECTION NEVER SHOWS THE ARROW`n`n"
FaqT .= "That is normal on many rods. The arrow is only a backup used when the bar itself cannot be seen, so the bar and fish line are what matter.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "3.  IT THINKS A MINIGAME IS ON SCREEN WHEN THERE IS NONE`n`n"
FaqT .= "Your tolerances are too high or a picked color matches scenery. Lower Fish line tolerance and Bar color tolerance, and remove any colors in the Color Manager that do not belong to the bar.`n`n"
FaqT .= "Check with Test detection while no minigame is on screen. Nothing should be detected.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "4.  THE BAR IS FOUND BUT DOES NOT FOLLOW THE FISH`n`n"
FaqT .= "Check Special rod in Minigame. It must match the rod you are holding, or set it to None for a normal rod.`n`n"
FaqT .= "Try Precision as the Detection mode. It needs the least tuning. Lines reads the edges of the bar instead of your colors, which helps if your colors keep failing.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "5.  THE BAR WOBBLES OR ROCKS AROUND THE FISH`n`n"
FaqT .= "Precision or Lines: raise Kd a little, then raise Stopping Distance if it still overshoots. Change one value at a time.`n`n"
FaqT .= "Near the fish the macro clicks rapidly on its own to hold the bar centered, so a small amount of fast clicking there is expected.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "6.  THE BAR SAILS PAST THE FISH`n`n"
FaqT .= "Raise Stopping Distance in Minigame. It starts braking sooner.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "7.  THE BAR CRAWLS AND NEVER REACHES THE FISH`n`n"
FaqT .= "Lower Stopping Distance, or raise Kp a little.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "8.  THE BAR FALLS BEHIND A FISH THAT MOVES FAST`n`n"
FaqT .= "Raise Kp a little. Raising Velocity Smoothing makes it react to direction changes sooner, but too high makes it jittery.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "9.  THE BAR GETS STUCK AGAINST ONE EDGE`n`n"
FaqT .= "Usually the steering is too weak to pull it back. Raise Stopping Distance first.`n`n"
FaqT .= "On Manual mode, change Side bar ratio and Side wait multiplier in Minigame.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "10.  THE BLUE BAR ON THE OVERLAY KEEPS CHANGING SIZE`n`n"
FaqT .= "When the bar gets pushed into the edge of the minigame, part of it is cut off, so it is measured smaller. Fix the steering first (see above) and the size usually settles.`n`n"
FaqT .= "A short size change right as a minigame starts or ends is normal.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "11.  MANUAL MODE WILL NOT TRACK PROPERLY`n`n"
FaqT .= "Manual needs tuning by hand, so try Precision first. If you stay on Manual, follow Quick rules in Minigame: Right values higher than Left, Unstable higher than Stable, every Division between 1.0 and 1.5, and change one value by about 15% at a time.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "12.  THE MINIGAME GIVES UP AND RECASTS`n`n"
FaqT .= "Minigame failsafe (s) in Minigame is the longest one minigame may last before the macro re-equips and casts again. Raise it if your fish take longer than 60 seconds.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "13.  SOME DETECTION MODES ARE MISSING`n`n"
FaqT .= "Special rods only list the modes that work with them. Set Special rod to None to see all three.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "14.  I MESSED UP MY MINIGAME SETTINGS`n`n"
FaqT .= "Press Restore defaults in Minigame. It resets the Minigame setup and every color in the Color Manager, so pick your colors again afterwards.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqTexts.Push(FaqT)
FaqT := ""
FaqT .= "Rods with their own mechanics. Pick the rod in Minigame > Special rod. Settings in yellow are specific to that rod.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "1.  I PICKED A SPECIAL ROD AND IT STILL DOES NOT WORK`n`n"
FaqT .= "Stop the macro and start it again after changing Special rod. Some rods watch a different part of the screen, and that is only measured when the macro starts.`n`n"
FaqT .= "Check you are holding the rod you picked. The wrong setting on the wrong rod steers badly.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "2.  CASTBOUND`n`n"
FaqT .= "Castbound ignores the Color Manager and finds the bar on its own, so there are no colors to pick.`n`n"
FaqT .= "Its bar shrinks and grows during the fight. That is the rod, not a detection problem. If the bar rocks or overshoots, raise Stopping Distance.`n`n"
FaqT .= "The game freezes the minigame for about a second now and then. The macro holds steady until it moves again.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "3.  REMEMBRANCE`n`n"
FaqT .= "Set Rod state to Living or Departed to match your rod. Switching it fills in the right bar colors for that state.`n`n"
FaqT .= "The goal is to keep the bar on the white fish line and away from the black one. On Living, covering both only pauses progress. On Departed, covering both loses progress, so the bar steers clear of the black line even if it briefly leaves the white one.`n`n"
FaqT .= "The pink marker on the overlay shows where the macro sees the black line. Restart the macro after picking this rod.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "4.  PINIONS ARIA`n`n"
FaqT .= "The bar chases the falling notes. If notes are missed, check Note color in the Color Manager and keep Note tolerance between 10 and 22. Above 25 the fish icon starts counting as a note.`n`n"
FaqT .= "Note priority sets how strongly the bar goes for a note instead of the fish. Resonance hand-off (px) makes the bar leave early for the next note. Notes are searched for across the Shake search area.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "5.  REQUIEM`n`n"
FaqT .= "If the reel keeps snapping, raise Min hold (ms) and Min release (ms). If the bar feels sluggish or falls behind, lower them.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "6.  NOISEFORM AND VERDANT OATH`n`n"
FaqT .= "Picking these rods fills in their colors for you. If detection is off afterwards, pick the colors again in the Color Manager.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "7.  DARKHEART, LULLABY, DREAMBREAKER AND BELLONAS WARAXE`n`n"
FaqT .= "These only allow the detection modes that work with them. Use Lines, or Precision where it is offered, and tune Kp, Kd and Stopping Distance as usual.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "8.  MIGUROD`n`n"
FaqT .= "MiguRod finds its bar on its own, so the bar colors do not matter for it. If the bar on the overlay looks wrong, that is worth reporting. The pale fish line is still matched by color, so pick that again in the Color Manager if the macro loses track of it.`n`n"
FaqT .= "The red exclamation marks slice the bar when they strike, which makes it shorter. That cannot really be avoided, so the macro does not try to dodge them and just keeps following the fish.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqTexts.Push(FaqT)
FaqT := ""
FaqT .= "Problems with Auto Totem, Auto Aquarium, Auto Keeperbound and the Discord webhook. Turn each one on in Utilities first.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "1.  AUTO TOTEM DOES NOTHING`n`n"
FaqT .= "Totems only work in private servers. They cannot be used in public ones.`n`n"
FaqT .= "Pick a totem in Totem to macro, and fill in the hotbar key for that totem. Day and Night need your Sundial key. Weather totems need your Clearcast key.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "2.  AUTO TOTEM USES THE WRONG TOTEM OR MISREADS THE WEATHER`n`n"
FaqT .= "The macro reads the time and weather icons in the bottom right of your screen. Make sure nothing covers them.`n`n"
FaqT .= "Camera mode hides those icons, so it stays off while Auto Totem is on.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "3.  AUTO TOTEM USED A SUNDIAL OR CLEARCAST I DID NOT PICK`n`n"
FaqT .= "That is on purpose. If a totem needs a different time of day, it uses a Sundial first and waits for the time to change. If a weather totem needs clear weather, it uses Clearcast first.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "4.  MY ROD IS NOT BACK IN MY HAND AFTER A TOTEM`n`n"
FaqT .= "Set Rod hotbar slot key in General > Recovery. It is used to re-equip the rod after popping a totem.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "5.  AUTO TOTEM CHECKS TOO OFTEN OR NOT OFTEN ENOUGH`n`n"
FaqT .= "Change Check every (s). Pop delay (ms) is the wait after using a totem before it checks again.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "6.  AUTO AQUARIUM SAYS IT COULD NOT FIND THE FISH FOOD PANEL`n`n"
FaqT .= "The macro presses Aquariums at the top of the screen. Make sure that bar is visible and nothing is covering it. Camera mode hides it, so it stays off while this is on.`n`n"
FaqT .= "If the menu is slow to open on your PC, raise Menu delay (ms).`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "7.  AUTO AQUARIUM SKIPS SOME FISH FOOD`n`n"
FaqT .= "Raise Step delay (ms) so each press has time to register, and raise Scroll sweep (notches) if food far along the row is being missed. Cards per trip limits how many cards it handles.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "8.  AUTO AQUARIUM SPENDS TOO MUCH MONEY`n`n"
FaqT .= "Lower Buy limit per trip. Run every (minutes) controls how often it visits.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "9.  AUTO KEEPERBOUND DOES NOTHING`n`n"
FaqT .= "It needs the ENCHANT ANYWHERE gamepass. Without it the enchant button does nothing.`n`n"
FaqT .= "Put your Enchant Relic in a hotbar slot and type that number into Relic hotbar key.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "10.  AUTO KEEPERBOUND SAYS IT COULD NOT OPEN THE INVENTORY`n`n"
FaqT .= "Set Inventory key to the key that opens your inventory. It is G by default. Raise Menu delay (ms) if your inventory is slow to open.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "11.  AUTO KEEPERBOUND SAYS ENCHANT ROD DID NOTHING`n`n"
FaqT .= "Use Set under Button positions to show the macro exactly where the Enchant Rod and Confirm buttons are.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "12.  MY HOTBAR NUMBER KEYS STOPPED WORKING`n`n"
FaqT .= "The Enchant your Rod confirm box is probably still open. While it is open the game ignores number keys. Press Cancel on it. The macro closes it by itself before each recharge.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "13.  HOW MANY RECHARGES DO I NEED`n`n"
FaqT .= "A Keeperbound rod loses about 0.2% power per catch, and each recharge gives back about 5%. 50 catches drain about 10%, so set Recharges per trip to 2 if Every (catches) is 50.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "14.  THE WEBHOOK TEST SAYS IT COULD NOT SEND`n`n"
FaqT .= "Paste the full Discord webhook link into Webhook URL. It should start with https://discord.com/api/webhooks/. Check you are online.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "15.  I GET NO WEBHOOK MESSAGES`n`n"
FaqT .= "Turn the webhook On in Utilities and on its own page, and press Send test message to check the link works.`n`n"
FaqT .= "Catch messages need Send a message for every catch. Stopped and no-catch alerts need Send alerts. Status reports are sent every Status report every (min) minutes.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqT .= "16.  I DO NOT WANT MY NAME OR MONEY IN WEBHOOK SCREENSHOTS`n`n"
FaqT .= "Untick Attach a screenshot to status reports. The screenshot shows your whole screen, including your username, level and cash.`n`n"
FaqT .= "--------------------------------------------------------`n"
FaqTexts.Push(FaqT)

Gui, Font, s9 Bold c%ColorMuted%, Segoe UI
FaqTabH := []
FaqTabX := CARDX
for i, nm in FaqNames
	{
	Gui, Add, Text, x%FaqTabX% y152 w88 h28 Center +0x100 +0x200 vFaqTab%i% gFaqTabClick HwndhFT, %nm%
	RoundCtrl(hFT, 88, 28, 8)
	FaqTabH.Push(hFT)
	FaqCtrls.Push(hFT)
	FaqTabX += 93
	}

Gui, Font, s9 Norm cFFFFFF, Consolas
FaqStart := FaqTexts[1]
Gui, Add, Edit, x%CARDX% y186 w%CARDW% h314 ReadOnly VScroll +0x4 vFaqBox HwndhFaqBox, %FaqStart%
FaqCtrls.Push(hFaqBox)
ThemedCtrls.Push(hFaqBox)
SpecialBrushes[hFaqBox] := {brush: hBrushCard, text: 0xFFFFFF}
Gui, Font, s9 Norm c%ColorText%, Segoe UI
FaqTab := 1
gosub, FaqPaintTabs

return

FaqTabClick:
FaqTab := SubStr(A_GuiControl, 7) + 0
GuiControl, 1:, FaqBox, % FaqTexts[FaqTab]
gosub, FaqPaintTabs
return

FaqPaintTabs:
for i, h in FaqTabH
	{
	if (i = FaqTab)
		SpecialBrushes[h] := {brush: hBrushAccent, text: 0x101010}
	else
		SpecialBrushes[h] := {brush: hBrushBorder, text: ColorTextBGR}
	WinSet, Redraw, , ahk_id %h%
	}
return

;====================================================================================================;

BuildAboutSection:

hC := AddPanel(CARDX, 120, CARDW, 74)
AboutCtrls.Push(hC)

Gui, Font, s14 Bold c%ColorAccent%, Segoe UI
Gui, Add, Text, x%CX% y132 w%TXW% h28 HwndhAbtHdr, 🐟 DeepFish BETA
AboutCtrls.Push(hAbtHdr)
SpecialBrushes[hAbtHdr] := {brush: hBrushCard, text: ColorAccentBGR}
Gui, Font, s9 Norm cFFFFFF, Segoe UI
Gui, Add, Text, x%CX% y162 w%TXW% h18 HwndhAbtVer, Version 1.0.1  •  Made by Yato
AboutCtrls.Push(hAbtVer)
SpecialBrushes[hAbtVer] := {brush: hBrushCard, text: 0xFFFFFF}

hC := AddPanel(CARDX, 204, CARDW, 106)
AboutCtrls.Push(hC)
Gui, Font, s8 Bold c%ColorMuted%, Segoe UI
Gui, Add, Text, x%CX% y214 w%TXW% h16 HwndhAbtLinkHdr, LINKS
AboutCtrls.Push(hAbtLinkHdr)
Gui, Font, s9 Norm cFFFFFF, Segoe UI
Gui, Add, Text, x%CX% y236 w%TXW% h20 +0x100 gOpenDiscord HwndhAbtDiscord, 💬  Discord  —  discord.gg/9dkmX6pAZd
AboutCtrls.Push(hAbtDiscord)
SpecialBrushes[hAbtDiscord] := {brush: hBrushCard, text: 0xFFFFFF}
Gui, Add, Text, x%CX% y258 w%TXW% h20 +0x100 gOpenYouTube HwndhAbtYouTube, ▶  YouTube  —  youtube.com/@yatoark
AboutCtrls.Push(hAbtYouTube)
SpecialBrushes[hAbtYouTube] := {brush: hBrushCard, text: 0xFFFFFF}
Gui, Add, Text, x%CX% y280 w%TXW% h20 +0x100 gOpenAsphalt HwndhAbtAsphalt, ▶  Original source  —  youtube.com/@AsphaltCake
AboutCtrls.Push(hAbtAsphalt)
SpecialBrushes[hAbtAsphalt] := {brush: hBrushCard, text: 0xFFFFFF}

hC := AddPanel(CARDX, 320, CARDW, 84)
AboutCtrls.Push(hC)
Gui, Font, s8 Bold c%ColorMuted%, Segoe UI
Gui, Add, Text, x%CX% y330 w%TXW% h16 HwndhAbtCredHdr, CREDITS
AboutCtrls.Push(hAbtCredHdr)
Gui, Font, s9 Norm cFFFFFF, Segoe UI
AboutCredits := "• Yato — Creator, design and development.`n"
AboutCredits .= "• AsphaltCake — Precision/Lines mode control method,`n"
AboutCredits .= "   adapted from IRUS IDIOTPROOF/IRUS COMET.`n"
Gui, Add, Text, x%CX% y352 w%TXW% h48 cFFFFFF HwndhAbtCred, %AboutCredits%
AboutCtrls.Push(hAbtCred)
SpecialBrushes[hAbtCred] := {brush: hBrushCard, text: 0xFFFFFF}

hC := AddPanel(CARDX, 414, CARDW, 96)
AboutCtrls.Push(hC)
Gui, Font, s8 Bold c%ColorMuted%, Segoe UI
Gui, Add, Text, x%CX% y424 w%TXW% h16 HwndhAbtDonHdr, DONATIONS
AboutCtrls.Push(hAbtDonHdr)
Gui, Font, s9 Norm cFFFFFF, Segoe UI
AboutDon := "Appreciated but never required. Message me directly`n"
AboutDon .= "on Discord for details please don't send a friend`n"
AboutDon .= "request, I get a lot.`n"
AboutDon .= "Accepting PayPal, Server Boosts and Discord Nitro."
Gui, Add, Text, x%CX% y446 w%TXW% h60 cFFFFFF HwndhAbtDon, %AboutDon%
AboutCtrls.Push(hAbtDon)
SpecialBrushes[hAbtDon] := {brush: hBrushCard, text: 0xFFFFFF}

hC := AddPanel(CARDX, 520, CARDW, 112)
AboutCtrls.Push(hC)
Gui, Font, s8 Bold c%ColorMuted%, Segoe UI
Gui, Add, Text, x%CX% y530 w%TXW% h16 HwndhAbtLicHdr, LICENCE
AboutCtrls.Push(hAbtLicHdr)
Gui, Font, s9 Norm cFFFFFF, Segoe UI
AboutLic := "© 2026 Yato. Personal use only. Do not redistribute,`n"
AboutLic .= "republish a modified build, or sell this macro. Reusing`n"
AboutLic .= "parts of it is fine as long as ""Yato"" is credited visibly`n"
AboutLic .= "in your project's interface. Provided as is, with no`n"
AboutLic .= "warranty — use at your own risk."
Gui, Add, Text, x%CX% y552 w%TXW% h76 cFFFFFF HwndhAbtLic, %AboutLic%
AboutCtrls.Push(hAbtLic)
SpecialBrushes[hAbtLic] := {brush: hBrushCard, text: 0xFFFFFF}

return

;====================================================================================================;

BuildReadThisSection:

; ---- Settings people must set before starting. Each group is a card; each string in it is one bullet. ----
; ---- Pictures: any file listed in ReadThisImages that exists next to the script is shown under the first card. ----
ReadThisGroups := [ ["FISCH SETTINGS  (Menu)"
		, [ "Extra Brightness:   →   slider all the way to the RIGHT (max)"
		  , "Camera Shake   →   OFF"
		  , "Fishing Minigame Shake:   →   slider all the way to the LEFT (0)"
		  , "Show Enchant Info   →   OFF" ] ]
	, ["WINDOWS / ROBLOX"
		, [ "Run Roblox in FULLSCREEN. If detection then fails on your PC, use windowed fullscreen instead."
		  , "Windows display scale must be 100% (Settings > System > Display > Scale), then restart your PC."
		  , "Do not resize, move or un-fullscreen the Roblox window while the macro is running - it measures the window once at Start."
		  , "Set Roblox graphics quality to low, or leave Auto-lower graphics ticked in General." ] ] ]
ReadThisImages := [ "Images\readthis1.png", "Images\readthis2.png", "Images\readthis3.png" ]

Gui, Font, s13 Bold c%ColorRed%, Segoe UI
Gui, Add, Text, x%CARDX% y120 w%CARDW% h30 HwndhC, ⚠  Read this first
ReadThisCtrls.Push(hC)
SpecialBrushes[hC] := {brush: hBrushBG, text: ColorRedBGR}
Gui, Font, s9 Norm c%ColorMuted%, Segoe UI
Gui, Add, Text, x%CARDX% y152 w%CARDW% h18 HwndhC, These must be set exactly like this before you press Start.
ReadThisCtrls.Push(hC)
SpecialBrushes[hC] := {brush: hBrushBG, text: ColorMutedBGR}

RtY := 180
for gi, grp in ReadThisGroups
	{
	RtCardH := 36
	RtHeights := []
	for i, ln in grp[2]
		{
		RtN := Ceil(StrLen(ln) / 88)
		if (RtN < 1)
			RtN := 1
		RtHeights.Push(RtN * 16 + 8)
		RtCardH += RtN * 16 + 8
		}
	hC := AddPanel(CARDX, RtY, CARDW, RtCardH)
	ReadThisCtrls.Push(hC)
	Gui, Font, s8 Bold c%ColorRed%, Segoe UI
	RtLY := RtY + 10
	Gui, Add, Text, x%CX% y%RtLY% w%TXW% h16 HwndhC, % grp[1]
	ReadThisCtrls.Push(hC)
	SpecialBrushes[hC] := {brush: hBrushCard, text: ColorRedBGR}
	Gui, Font, s9 Norm cFFFFFF, Segoe UI
	RtLY += 24
	for i, ln in grp[2]
		{
		RtH := RtHeights[i] - 8
		Gui, Add, Text, x%CX% y%RtLY% w%TXW% h%RtH% HwndhC, % "•  " . ln
		ReadThisCtrls.Push(hC)
		SpecialBrushes[hC] := {brush: hBrushCard, text: 0xFFFFFF}
		RtLY += RtHeights[i]
		}
	RtY += RtCardH + 10

	if (gi = 1)
		{
		for pi, img in ReadThisImages
			{
			RtPath := A_ScriptDir . "\" . img
			if (!FileExist(RtPath))
				continue
			Gui, Add, Picture, x%CARDX% y%RtY% w%CARDW% h-1 HwndhC, %RtPath%
			ReadThisCtrls.Push(hC)
			CtrlSnapPos(hC, RtPX, RtPY, RtPW, RtPH)
			RtY += RtPH + 10
			}
		}
	}
Gui, Font, s9 Norm c%ColorMuted%, Segoe UI

return

;====================================================================================================;

BuildVersionsSection:

; ---- Changelog: newest version first. To add a release, copy one block and put it at the top. ----
VersionNotes := []
VersionNotes.Push(["Version 1.0.1", ["Fixed Castbound"
	, "Improved Pinions Aria note tracking"]])
VersionNotes.Push(["Version 1.0.0", ["Added Remembrance Rod"
	, "Added Castbound Rod"
	, "Added MiguRod"
	, "Added Halibut Harpoon Rod"
	, "Added Color Manager"
	, "Added Auto Update"
	, "Updated FAQ"
	, "Fixed Bugs"]])

Gui, Font, s13 Bold c%ColorText%, Segoe UI
Gui, Add, Text, x%CARDX% y120 w%CARDW% h30 HwndhC, Versions
VersionsCtrls.Push(hC)
Gui, Font, s9 Norm c%ColorMuted%, Segoe UI
Gui, Add, Text, x%CARDX% y152 w%CARDW% h18 HwndhC, What changed in each update.
VersionsCtrls.Push(hC)
SpecialBrushes[hC] := {brush: hBrushBG, text: ColorMutedBGR}

VerY := 180
for vi, vn in VersionNotes
	{
	VerCardH := 44 + (vn[2].Length() * 20) + 10
	hC := AddPanel(CARDX, VerY, CARDW, VerCardH)
	VersionsCtrls.Push(hC)
	Gui, Font, s11 Bold cFFFFFF, Segoe UI
	VerTY := VerY + 12
	Gui, Add, Text, x%CX% y%VerTY% w%TXW% h24 HwndhC, % vn[1]
	VersionsCtrls.Push(hC)
	SpecialBrushes[hC] := {brush: hBrushCard, text: 0xFFFFFF}
	Gui, Font, s9 Norm cFFFFFF, Segoe UI
	VerLY := VerY + 44
	for li, ln in vn[2]
		{
		Gui, Add, Text, x%CX% y%VerLY% w%TXW% h20 HwndhC, % "•  " . ln
		VersionsCtrls.Push(hC)
		SpecialBrushes[hC] := {brush: hBrushCard, text: 0xFFFFFF}
		VerLY += 20
		}
	VerY += VerCardH + 10
	}
Gui, Font, s9 Norm c%ColorMuted%, Segoe UI

return

;====================================================================================================;

VersionsClick:
TargetSection := "Versions"
gosub, ShowSection
return

;====================================================================================================;

OpenDiscord:
Run, https://discord.gg/9dkmX6pAZd
return

OpenYouTube:
Run, https://www.youtube.com/@yatoark
return

OpenAsphalt:
Run, https://www.youtube.com/@AsphaltCake
return

;====================================================================================================;

SidebarClick:
TargetSection := SubStr(A_GuiControl, 4)
gosub, ShowSection
return

;====================================================================================================;

MiniTabClick:
MiniTab := (A_GuiControl = "MiniTabColors") ? "Colors" : "Setup"
TargetSection := "Minigame"
gosub, ShowSection
return

;====================================================================================================;

ShowSection:

if (GuiHwnd)
	DllCall("SendMessage", "Ptr", GuiHwnd, "UInt", 0x000B, "Ptr", 0, "Ptr", 0)
NeedSection := TargetSection
gosub, EnsureSection

OnUtil := (TargetSection = "Utilities")
OnTotem := (TargetSection = "Totem")
OnAqua := (TargetSection = "Aquarium")
OnKeep := (TargetSection = "Keeper")
OnWeb := (TargetSection = "Webhook")
OnMini := (TargetSection = "Minigame")
OnCast := (TargetSection = "Cast")
OnSetup := (OnMini and MiniTab != "Colors")
OnColors := (OnMini and MiniTab = "Colors")
SecTopEdge := OnMini ? 158 : 120

ShowList(GeneralCtrls, TargetSection = "General")
ShowList(CastCtrls, OnCast)
ShowList(NormalCastCtrls, OnCast and CastMode = "Normal")
ShowList(PerfectCastCtrls, OnCast and CastMode != "Normal")
ShowList(ShakeCtrls, TargetSection = "Shake")
ShowList(UtilCtrls, OnUtil)
ShowList(FaqCtrls, TargetSection = "Faq")
ShowList(AboutCtrls, TargetSection = "About")
ShowList(VersionsCtrls, TargetSection = "Versions")
ShowList(ReadThisCtrls, TargetSection = "ReadThis")

; ---- Minigame: two faces, Setup and the Color Manager ----
GuiControl, % (OnMini ? "1:Show" : "1:Hide"), MiniTabSetup
GuiControl, % (OnMini ? "1:Show" : "1:Hide"), MiniTabColors
if (OnSetup)
	LayoutMinigame()
for nm, b in MgBlocks
	{
	MgOn := (OnSetup and MgVisible.HasKey(nm))
	GuiControl, % (MgOn ? "1:Show" : "1:Hide"), % b.card
	ShowList(b.ctrls, MgOn)
	}
ShowList(CMCtrls, OnColors)
if (OnColors)
	gosub, CMRefresh
if (MiniTabSetupH)
	{
	if (OnColors)
		{
		SpecialBrushes[MiniTabSetupH] := {brush: hBrushBorder, text: ColorTextBGR}
		SpecialBrushes[MiniTabColorsH] := {brush: hBrushAccent, text: 0x101010}
		}
	else
		{
		SpecialBrushes[MiniTabSetupH] := {brush: hBrushAccent, text: 0x101010}
		SpecialBrushes[MiniTabColorsH] := {brush: hBrushBorder, text: ColorTextBGR}
		}
	}

; ---- Totem ----
ShowList(TotemCtrls, OnTotem)
if (OnTotem and !TotemAuto)
	ShowList(TotemBodyCtrls, false)
gosub, RefreshTotemKeys
if (OnTotem)
	SetTimer, TotemStatusTick, 1000
else
	SetTimer, TotemStatusTick, Off

; ---- Keeperbound ----
ShowList(KeeperCtrls, OnKeep)
if (OnKeep and !KeeperAuto)
	ShowList(KeeperBodyCtrls, false)
if (OnKeep)
	{
	gosub, KeeperRefreshSpots
	gosub, KeeperStatusTick
	SetTimer, KeeperStatusTick, 1000
	}
else
	SetTimer, KeeperStatusTick, Off

; ---- Aquarium ----
ShowList(AquariumCtrls, OnAqua)
if (OnAqua and !AquariumAuto)
	ShowList(AquariumBodyCtrls, false)
if (OnAqua)
	{
	gosub, AquariumStatusTick
	SetTimer, AquariumStatusTick, 1000
	}
else
	SetTimer, AquariumStatusTick, Off

; ---- Webhook ----
ShowList(WebhookCtrls, OnWeb)
if (OnWeb and !WebhookOn)
	ShowList(WebhookBodyCtrls, false)

if (TargetSection = "Faq" and hFaqBox)
	{
	SendMessage, 0xB1, 0, 0, , ahk_id %hFaqBox%
	SendMessage, 0xB7, 0, 0, , ahk_id %hFaqBox%
	}

GuiControl, 1:, UtilTotemOn, % (TotemAuto ? 1 : 0)
GuiControl, 1:, UtilAquariumOn, % (AquariumAuto ? 1 : 0)
GuiControl, 1:, UtilKeeperOn, % (KeeperAuto ? 1 : 0)
GuiControl, 1:, UtilWebhookOn, % (WebhookOn ? 1 : 0)

; ---- sidebar highlight (the two add-on pages keep Utilities lit) ----
NavActive := TargetSection
if (NavActive = "Totem" or NavActive = "Webhook" or NavActive = "Aquarium" or NavActive = "Keeper")
	NavActive := "Utilities"
for i, d in NavDefs
	{
	nk := d[1]
	hv := NavHwnd[nk]
	hb := NavHwnd["bar" . nk]
	if (nk = NavActive)
		{
		SpecialBrushes[hv] := {brush: hBrushBG, text: (nk = "ReadThis") ? ColorRedBGR : ColorAccentBGR}
		SpecialBrushes[hb] := {brush: hBrushAccent, text: ColorAccentBGR}
		}
	else
		{
		SpecialBrushes[hv] := {brush: hBrushPanel, text: (nk = "ReadThis") ? ColorRedBGR : ColorTextBGR}
		SpecialBrushes[hb] := {brush: hBrushPanel, text: ColorTextBGR}
		}
	}

CollectVisible()
ApplyScroll()
if (GuiHwnd)
	DllCall("SendMessage", "Ptr", GuiHwnd, "UInt", 0x000B, "Ptr", 1, "Ptr", 0)
gosub, RepaintGui

return

;====================================================================================================;

DetTestToggle:
if (DetTesting)
	{
	DetTesting := false
	SetTimer, DetTestTick, Off
	GuiControl, 1:, DetTestBtn, ▶  Test detection
	GuiControl, 1:, DetTestOut, Test stopped.
	Loop, 20
		tooltip, , , , %A_Index%
	return
	}
if (MacroRunning)
	{
	GuiControl, 1:, DetTestOut, Stop the macro first - the test needs the capture to itself.
	return
	}
DetTesting := true
Loop, 20
	tooltip, , , , %A_Index%
GuiControl, 1:, DetTestBtn, ⏹  Stop test
SetTimer, DetTestTick, 250
return

DetTestTick:
if (!DetTesting or TargetSection != "Minigame" or MacroRunning)
	{
	DetTesting := false
	SetTimer, DetTestTick, Off
	GuiControl, 1:, DetTestBtn, ▶  Test detection
	Loop, 20
		tooltip, , , , %A_Index%
	return
	}
gosub, ResolveRoblox
if (!RobloxHwnd)
	{
	GuiControl, 1:, DetTestOut, Roblox is not open.
	return
	}
gosub, Calculations
gosub, CaptureFishBar
DetC := MgDetect()
DetTxt := "Bar " . (MgSawBar ? "✔" : "✘")
DetTxt .= "    Fish line " . (MgSawFish ? "✔" : "✘")
DetTxt .= "    Arrow " . ((MgSawArrow or FindArrowX() >= 0) ? "✔" : "✘")
DetTxt .= "    →  " . DetC . "%"
if (DetC >= 90)
	DetTxt .= "  solid"
else if (DetC >= 55)
	DetTxt .= "  usable"
else if (DetC > 0)
	DetTxt .= "  weak - re-pick colors"
else
	DetTxt .= "  nothing seen"
GuiControl, 1:, DetTestOut, %DetTxt%
return

;====================================================================================================;

RefreshControlModes:
if (SpecialRod = "Noiseform")
	CmList := "Precision"
else
if (SpecialRod = "Darkheart" or SpecialRod = "Pinions Aria" or SpecialRod = "Lullaby"
	or SpecialRod = "Castbound")
	CmList := "Lines"
else if (SpecialRod = "Remembrance")
	CmList := "Lines|Precision"
else if (SpecialRod = "MiguRod" or SpecialRod = "Halibut Harpoon")
	CmList := "Precision"
else if (SpecialRod = "Requiem" or SpecialRod = "Bellona's Waraxe" or SpecialRod = "Dreambreaker"
	or SpecialRod = "Verdant Oath")
	CmList := "Lines|Precision"
else
	CmList := "Manual|Precision|Lines"
if (!InStr("|" . CmList . "|", "|" . ControlMode . "|"))
	{
	sp := InStr(CmList, "|")
	ControlMode := sp ? SubStr(CmList, 1, sp - 1) : CmList
	}
if (ControlModeDdl)
	{
	GuiControl, 1:, ControlMode, % "|" . CmList
	GuiControl, 1:ChooseString, ControlMode, %ControlMode%
	}
return

;====================================================================================================;

ApplyVerdantOathPreset:
FishColor := "0x434B5B"
BarLeftColor := "0x67512C"
BarRightColor := "0x65502D"
ArrowColor := "0x848587"
BarColorTolerance := 3
FishBarColorTolerance := 12
ArrowColorTolerance := 0
GuiControl, 1:, FishColor, %FishColor%
GuiControl, 1:, BarLeftColor, %BarLeftColor%
GuiControl, 1:, BarRightColor, %BarRightColor%
GuiControl, 1:, ArrowColor, %ArrowColor%
GuiControl, 1:, BarColorTolerance, %BarColorTolerance%
GuiControl, 1:, FishBarColorTolerance, %FishBarColorTolerance%
GuiControl, 1:, ArrowColorTolerance, %ArrowColorTolerance%
gosub, RefreshSwatches
return

ApplyNoRodPreset:
NoRodSets := [ ["0x0C4125","0x33A95F"]                                                  ; Noiseform
	, ["0x0D0B0B","0x5D52A8"]                                                           ; Halibut Harpoon
	, ["0x434B5B","0x67512C"]                                                           ; Verdant Oath
	, ["0xFFFFFF","0x474747"], ["0xFFFFFF","0xB5B5B5"]                                  ; Remembrance
	, ["0xF9D9D4,0xFAD6CE,0xF9D4C7,0xF9D2C4,0xF8D0B7","0xE9B681,0xE0A66F,0xD1935B"] ]   ; MiguRod
NoRodHit := false
for i, s in NoRodSets
	{
	if (FishColor = s[1] and BarLeftColor = s[2])
		NoRodHit := true
	}
if (!NoRodHit)
	return
for i, f in ProfileFields
	{
	if (f[2] != "FishColor" and f[2] != "BarLeftColor" and f[2] != "BarRightColor" and f[2] != "ArrowColor")
		continue
	NoRodKey := f[2]
	%NoRodKey% := f[3]
	if (!NoRodQuiet)
		GuiControl, 1:, %NoRodKey%, % f[3]
	}
if (!NoRodQuiet)
	gosub, RefreshSwatches
return

ApplyHalibutPreset:
FishColor := "0x0D0B0B"
BarLeftColor := "0x5D52A8"
BarRightColor := "0x5D52A8"
ArrowColor := "0x413A76"
BarColorTolerance := 3
FishBarColorTolerance := 3
ArrowColorTolerance := 3
GuiControl, 1:, FishColor, %FishColor%
GuiControl, 1:, BarLeftColor, %BarLeftColor%
GuiControl, 1:, BarRightColor, %BarRightColor%
GuiControl, 1:, ArrowColor, %ArrowColor%
GuiControl, 1:, BarColorTolerance, %BarColorTolerance%
GuiControl, 1:, FishBarColorTolerance, %FishBarColorTolerance%
GuiControl, 1:, ArrowColorTolerance, %ArrowColorTolerance%
gosub, RefreshSwatches
return

ApplyRemembrancePreset:
if (RemembranceMode = "Departed")
	{
	BarLeftColor := "0x474747"
	BarRightColor := "0x474747"
	BarColorTolerance := 8
	}
else
	{
	BarLeftColor := "0xB5B5B5"
	BarRightColor := "0xB5B5B5"
	BarColorTolerance := 10
	}
FishColor := "0xFFFFFF"
FishBarColorTolerance := 10
GuiControl, 1:, BarLeftColor, %BarLeftColor%
GuiControl, 1:, BarRightColor, %BarRightColor%
GuiControl, 1:, BarColorTolerance, %BarColorTolerance%
GuiControl, 1:, FishColor, %FishColor%
GuiControl, 1:, FishBarColorTolerance, %FishBarColorTolerance%
gosub, RefreshSwatches
return

ApplyMiguRodPreset:
BarLeftColor := "0xE9B681,0xE0A66F,0xD1935B"
BarRightColor := "0xE9B681,0xE0A66F,0xD1935B"
BarColorTolerance := 14
FishColor := "0xF9D9D4,0xFAD6CE,0xF9D4C7,0xF9D2C4,0xF8D0B7"
FishBarColorTolerance := 10
GuiControl, 1:, BarLeftColor, %BarLeftColor%
GuiControl, 1:, BarRightColor, %BarRightColor%
GuiControl, 1:, BarColorTolerance, %BarColorTolerance%
GuiControl, 1:, FishColor, %FishColor%
GuiControl, 1:, FishBarColorTolerance, %FishBarColorTolerance%
gosub, RefreshSwatches
return

RemembranceModeChanged:
GuiControlGet, RemembranceMode, 1:, RemembranceMode
gosub, ApplyRemembrancePreset
gosub, QueueAutoSave
return

ApplyNoiseformPreset:
FishColor := "0x0C4125"
BarLeftColor := "0x33A95F"
BarRightColor := "0x2C894D"
ArrowColor := "0x000000"
BarColorTolerance := 3
FishBarColorTolerance := 5
ArrowColorTolerance := 0
Kp := 0.3
Kd := 0.3
VelocitySmoothing := 0.5
StoppingDistanceMultiplier := 5.0
GuiControl, 1:, FishColor, %FishColor%
GuiControl, 1:, BarLeftColor, %BarLeftColor%
GuiControl, 1:, BarRightColor, %BarRightColor%
GuiControl, 1:, ArrowColor, %ArrowColor%
GuiControl, 1:, BarColorTolerance, %BarColorTolerance%
GuiControl, 1:, FishBarColorTolerance, %FishBarColorTolerance%
GuiControl, 1:, ArrowColorTolerance, %ArrowColorTolerance%
GuiControl, 1:, Kp, %Kp%
GuiControl, 1:, Kd, %Kd%
GuiControl, 1:, VelocitySmoothing, %VelocitySmoothing%
GuiControl, 1:, StoppingDistanceMultiplier, %StoppingDistanceMultiplier%
gosub, RefreshSwatches
return

SpecialRodChanged:
GuiControlGet, SpecialRod, 1:, SpecialRod
if (SpecialRod = "Requiem" or SpecialRod = "Darkheart" or SpecialRod = "Lullaby"
	or SpecialRod = "Verdant Oath")
	ControlMode := "Lines"
if (SpecialRod = "Remembrance")
	ControlMode := "Lines"
if (SpecialRod = "MiguRod" or SpecialRod = "Halibut Harpoon")
	ControlMode := "Precision"
if (SpecialRod = "Halibut Harpoon")
	gosub, ApplyHalibutPreset
if (SpecialRod = "None")
	gosub, ApplyNoRodPreset
if (SpecialRod = "Noiseform")
	gosub, ApplyNoiseformPreset
if (SpecialRod = "Remembrance")
	gosub, ApplyRemembrancePreset
if (SpecialRod = "MiguRod")
	gosub, ApplyMiguRodPreset
if (SpecialRod = "Verdant Oath")
	gosub, ApplyVerdantOathPreset
gosub, RefreshControlModes
TargetSection := "Minigame"
gosub, ShowSection
gosub, QueueAutoSave
return

;====================================================================================================;

ControlModeChanged:
GuiControlGet, ControlMode, , ControlMode
TargetSection := "Minigame"
gosub, ShowSection
gosub, QueueAutoSave
return

;====================================================================================================;

RefreshProfileList:

ProfileNames := "|"
Loop, Files, %ProfilesDir%\*.ini
	{
	SplitPath, A_LoopFileName, , , , NameNoExt
	ProfileNames .= NameNoExt . "|"
	}
GuiControl, 1:, ProfileSelect, %ProfileNames%
GuiControl, 1:ChooseString, ProfileSelect, %ActiveProfile%

return

;====================================================================================================;


;====================================================================================================;
;====================================================================================================;

MgCopyCode:

Gui, 1:Submit, NoHide
MgShareBad := ""
MgShareOut := "DF1;" . MgShareSig()
for MgShareI, MgShareF in MgShareFields()
	{
	MgShareK := MgShareF[2]
	MgShareV := %MgShareK%
	if (InStr(MgShareV, ";"))
		MgShareBad .= MgShareK . "`n"
	MgShareOut .= ";" . MgShareV
	}
if (MgShareBad != "")
	{
	msgbox, 4144, DeepFish, A settings code cannot hold a semicolon, and these fields contain one:`n`n%MgShareBad%`nTake the semicolons out, then copy again.
	return
	}
MgShareOut .= ";" . MgShareHash(MgShareOut)
clipboard := MgShareOut
MgCodeCue("✅ Code copied to clipboard")
settimer, MgShareStatusClear, -4000
return

;====================================================================================================;

MgCodeBoxChanged:
GuiControlGet, MgShareIn, 1:, MgCodeBox
MgCodeBoxLen := StrLen(MgShareIn)
MgCodeBoxJump := MgCodeBoxLen - MgCodeBoxPrevLen
MgCodeBoxPrevLen := MgCodeBoxLen
if (MgCodeBoxLen = 0 or MgCodeBoxJump < 10)
	return
gosub, MgApplyCode
MgCodeBoxPrevLen := 0
GuiControl, 1:, MgCodeBox,
return

;====================================================================================================;

MgApplyCode:

MgShareIn := StrReplace(MgShareIn, "`r", "")
MgShareIn := StrReplace(MgShareIn, "`n", "")
MgShareIn := StrReplace(MgShareIn, "`t", "")
MgShareIn := Trim(MgShareIn)
MgShareFlds := MgShareFields()
MgShareParts := StrSplit(MgShareIn, ";")
MgShareErr := ""
if (MgShareIn = "")
	MgShareErr := "That box is empty. Copy a settings code first, then paste it into the box."
else if (MgShareParts.MaxIndex() < 3 or MgShareParts[1] != "DF1")
	MgShareErr := "That is not a DeepFish settings code. A code starts with DF1 and is one long line of text."
else if (MgShareParts.MaxIndex() != MgShareFlds.MaxIndex() + 3 or MgShareParts[2] != MgShareSig())
	MgShareErr := "That code was made by a different version of DeepFish, so it cannot be read safely. Ask for a code from someone on this version."
else
	{
	MgShareChk := MgShareParts[MgShareParts.MaxIndex()]
	MgShareBody := SubStr(MgShareIn, 1, StrLen(MgShareIn) - StrLen(MgShareChk) - 1)
	if (MgShareChk != MgShareHash(MgShareBody))
		MgShareErr := "That code is damaged or was cut short. Copy the whole thing again and make sure nothing is missing."
	}

if (MgShareErr = "")
	{
	MgShareBad := ""
	for MgShareI, MgShareF in MgShareFlds
		{
		MgShareV := MgShareParts[MgShareI + 2]
		if (!ProfFieldOk(MgShareF[4], MgShareV))
			MgShareBad .= MgShareF[2] . "`n"
		MgShareNew%MgShareI% := MgShareV
		}
	if (MgShareBad != "")
		MgShareErr := "That code holds values this version does not accept, so nothing was changed:`n`n" . MgShareBad
	}

if (MgShareErr != "")
	{
	msgbox, 4144, DeepFish, %MgShareErr%
	return
	}

for MgShareI, MgShareF in MgShareFlds
	{
	MgShareK := MgShareF[2]
	%MgShareK% := MgShareNew%MgShareI%
	}

gosub, RefreshGuiFields
gosub, RefreshControlModes
gosub, CMRefresh
gosub, ShowSection
gosub, SaveSettings
MgCodeCue("✅ Code applied and saved")
settimer, MgShareStatusClear, -5000
return

;====================================================================================================;

MgShareStatusClear:
MgCodeCue("Paste minigame code here")
return

;====================================================================================================;

MgRestoreDefaults:
MgDefAlso := {FishBarColorTolerance: 1, PerfectGreenColor: 1, PerfectWhiteColor: 1}
for i, f in ProfileFields
	{
	if (f[1] != "Minigame" and !MgDefAlso.HasKey(f[2]))
		continue
	key := f[2]
	%key% := f[3]
	}
gosub, RefreshGuiFields
gosub, RefreshControlModes
gosub, CMRefresh
gosub, ShowSection
gosub, SaveSettings
return

;====================================================================================================;

RefreshGuiFields:

for i, f in ProfileFields
	{
	key := f[2]
	type := f[4]
	val := %key%
	if (type = "bool")
		{
		chkval := val ? 1 : 0
		GuiControl, 1:, %key%, %chkval%
		}
	else if (type = "shakemode" or type = "controlmode" or type = "castmode" or type = "specialrod"
		or type = "remembrancemode")
		{
		GuiControl, 1:ChooseString, %key%, %val%
		}
	else
		GuiControl, 1:, %key%, %val%
	}

gosub, RefreshSwatches
gosub, RefreshCameraLock

if (TargetSection != "")
	{
	gosub, ApplyCastModeLocks
	gosub, ShowSection
	}

return

;====================================================================================================;

SaveSettings:

Gui, Submit, NoHide

BadFields := ""
for i, f in ProfileFields
	{
	var := f[2]
	type := f[4]
	if (type = "num")
		{
		val := %var%
		if val is not number
			BadFields .= var . "`n"
		}
	}
if (BadFields != "")
	{
	msgbox, 4144, DeepFish, One or more fields contain an invalid number and were not saved:`n`n%BadFields%
	return
	}

FileCopy, %ActiveProfileFile%, %ActiveProfileFile%.bak, 1

for i, f in ProfileFields
	{
	sec := f[1]
	key := f[2]
	type := f[4]
	val := %key%
	if (type = "bool")
		val := val ? "true" : "false"
	DstFile := (sec = "Aquarium" or sec = "Keeper" or (TotemGlobal and sec = "Totem")) ? SettingsFile : ActiveProfileFile
	IniWrite, %val%, %DstFile%, %sec%, %key%
	}

HotkeyState := HotkeysArmed ? "On" : "Off"
if (StartStopKeyCtrl != StartStopKey)
	{
	Hotkey, % "$" . StartStopKey, , Off
	StartStopKey := StartStopKeyCtrl
	Hotkey, % "$" . StartStopKey, HotkeyToggle, %HotkeyState%
	}
if (ReloadKeyCtrl != ReloadKey)
	{
	Hotkey, % "$" . ReloadKey, , Off
	ReloadKey := ReloadKeyCtrl
	Hotkey, % "$" . ReloadKey, HotkeyReload, %HotkeyState%
	}
if (ExitKeyCtrl != ExitKey)
	{
	Hotkey, % "$" . ExitKey, , Off
	ExitKey := ExitKeyCtrl
	Hotkey, % "$" . ExitKey, HotkeyExit, %HotkeyState%
	}
IniWrite, %WebhookURL%, %SettingsFile%, Webhook, URL
WhVal := WebhookOn ? 1 : 0
IniWrite, %WhVal%, %SettingsFile%, Webhook, Enabled
WhVal := WebhookShot ? 1 : 0
IniWrite, %WhVal%, %SettingsFile%, Webhook, Screenshot
IniWrite, %WebhookSummaryMin%, %SettingsFile%, Webhook, SummaryMinutes
IniWrite, %WebhookStallMin%, %SettingsFile%, Webhook, StallMinutes
WhVal := WebhookOnCatch ? 1 : 0
IniWrite, %WhVal%, %SettingsFile%, Webhook, OnCatch
WhVal := WebhookOnAlert ? 1 : 0
IniWrite, %WhVal%, %SettingsFile%, Webhook, OnAlert
IniWrite, %StartStopKey%, %SettingsFile%, Hotkeys, StartStop
IniWrite, %ReloadKey%, %SettingsFile%, Hotkeys, Reload
IniWrite, %ExitKey%, %SettingsFile%, Hotkeys, Exit

GuiControl, 1:, SaveStatusText, ✅ Saved
settimer, RestoreSaveButton, -1500
return

RestoreSaveButton:
GuiControl, 1:, SaveStatusText, 💾 Save

return

;====================================================================================================;

ProfileSelect:

GuiControlGet, NewProfileChoice, 1:, ProfileSelect
if (NewProfileChoice = "" or NewProfileChoice = ActiveProfile)
	return
ActiveProfile := NewProfileChoice
ActiveProfileFile := ProfilesDir . "\" . ActiveProfile . ".ini"
IniWrite, %ActiveProfile%, %SettingsFile%, Profiles, ActiveProfile
gosub, LoadActiveProfile
gosub, RefreshGuiFields
return

;====================================================================================================;

ProfileNew:

Gui, 1:-AlwaysOnTop
InputBox, NewProfileName, New Profile, Enter a name for the new profile:, , 300, 130
if (GuiAlwaysOnTop)
	Gui, 1:+AlwaysOnTop
if ErrorLevel
	return
NewProfileName := Trim(NewProfileName)
if (NewProfileName = "")
	return
if RegExMatch(NewProfileName, "[\\/:*?""<>|]")
	{
	msgbox, 4144, DeepFish, Profile names can't contain \ / : * ? " < > |
	return
	}
NewProfileFile := ProfilesDir . "\" . NewProfileName . ".ini"
if FileExist(NewProfileFile)
	{
	msgbox, 4144, DeepFish, A profile named "%NewProfileName%" already exists.
	return
	}
for i, f in ProfileFields
	{
	sec := f[1]
	key := f[2]
	def := f[3]
	IniWrite, %def%, %NewProfileFile%, %sec%, %key%
	}
ActiveProfile := NewProfileName
ActiveProfileFile := NewProfileFile
IniWrite, %ActiveProfile%, %SettingsFile%, Profiles, ActiveProfile
gosub, LoadActiveProfile
gosub, RefreshProfileList
gosub, RefreshGuiFields

return

;====================================================================================================;

ProfileDuplicate:

Gui, 1:-AlwaysOnTop
InputBox, NewProfileName, Duplicate Profile, Enter a name for the copy of "%ActiveProfile%":, , 320, 130
if (GuiAlwaysOnTop)
	Gui, 1:+AlwaysOnTop
if ErrorLevel
	return
NewProfileName := Trim(NewProfileName)
if (NewProfileName = "")
	return
if RegExMatch(NewProfileName, "[\\/:*?""<>|]")
	{
	msgbox, 4144, DeepFish, Profile names can't contain \ / : * ? " < > |
	return
	}
NewProfileFile := ProfilesDir . "\" . NewProfileName . ".ini"
if FileExist(NewProfileFile)
	{
	msgbox, 4144, DeepFish, A profile named "%NewProfileName%" already exists.
	return
	}
FileCopy, %ActiveProfileFile%, %NewProfileFile%
ActiveProfile := NewProfileName
ActiveProfileFile := NewProfileFile
IniWrite, %ActiveProfile%, %SettingsFile%, Profiles, ActiveProfile
gosub, LoadActiveProfile
gosub, RefreshProfileList
gosub, RefreshGuiFields

return

;====================================================================================================;

ProfileDelete:

ProfileCount := 0
Loop, Files, %ProfilesDir%\*.ini
	ProfileCount++
if (ActiveProfile = "Default")
	{
	msgbox, 4144, DeepFish, The Default profile can't be deleted.
	return
	}
if (ProfileCount <= 1)
	{
	msgbox, 4144, DeepFish, You can't delete the only remaining profile.
	return
	}
MsgBox, 4100, DeepFish, Delete profile "%ActiveProfile%"? This can't be undone.
IfMsgBox, No
	return
FileDelete, %ActiveProfileFile%
ActiveProfile := "Default"
ActiveProfileFile := DefaultProfileFile
IniWrite, %ActiveProfile%, %SettingsFile%, Profiles, ActiveProfile
gosub, LoadActiveProfile
gosub, RefreshProfileList
gosub, RefreshGuiFields

return

;====================================================================================================;


;----------------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------------

ColNorm(v) {
	t := Trim(v)
	if (t = "")
		return -1
	hadPrefix := false
	if (SubStr(t, 1, 1) = "#")
		{
		t := SubStr(t, 2)
		hadPrefix := true
		}
	else if (SubStr(t, 1, 2) = "0x" or SubStr(t, 1, 2) = "0X")
		{
		t := SubStr(t, 3)
		hadPrefix := true
		}
	if (RegExMatch(t, "^[0-9a-fA-F]{6}$"))
		{
		hv := "0x" . t
		return hv + 0
		}
	if (!hadPrefix and RegExMatch(t, "^[0-9]{1,8}$") and (t + 0) <= 0xFFFFFF)
		return t + 0        
	return -1
}

ColListToArray(str) {
	arr := []
	Loop, Parse, str, `,;| , %A_Space%%A_Tab%
		{
		cn := ColNorm(A_LoopField)
		if (cn >= 0)
			arr.Push(cn)
		}
	return arr
}

ColArrayToList(arr) {
	out := ""
	for i, v in arr
		out .= (out = "" ? "" : ", ") . Format("0x{:06X}", v)
	return out
}

ColListAdd(str, hex) {
	arr := ColListToArray(str)
	cn := ColNorm(hex)
	if (cn < 0)
		return ColArrayToList(arr)
	for i, v in arr
		{
		if (v = cn)
			return ColArrayToList(arr)
		}
	if (arr.MaxIndex() >= 9)
		return ColArrayToList(arr)
	arr.Push(cn)
	return ColArrayToList(arr)
}

ColListRemoveAt(str, idx) {
	arr := ColListToArray(str)
	if (idx < 1 or idx > arr.MaxIndex())
		return ColArrayToList(arr)
	arr.RemoveAt(idx)
	return ColArrayToList(arr)
}

CMStore(key, val) {
	global
	%key% := val
	CMSec := CMTargetSection[key]
	IniWrite, %val%, %ActiveProfileFile%, %CMSec%, %key%
	GuiControl, 1:, %key%, %val%
	gosub, RefreshSwatches
}

;----------------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------------

BuildColorManagerSection:

CMRowSw := []
CMRowTx := []
CMRowBt := []
CMNavH := {}

; ---- left: which color ----
hC := AddPanel(CARDX, 162, 218, 356)
CMCtrls.Push(hC)

Gui, Font, s8 Bold c%ColorMuted%, Segoe UI
Gui, Add, Text, x204 y174 w186 h16 HwndhC, COLOR
CMCtrls.Push(hC)
Gui, Font, s9 Norm c%ColorText%, Segoe UI

CMy := 196
for i, k in CMTargetKeys
	{
	lb := CMTargetLabel[k]
	Gui, Add, Text, x196 y%CMy% w202 h28 +0x200 vCMNav%i% gCMNavClick HwndhCMN, %lb%
	CMCtrls.Push(hCMN)
	CMNavH[k] := hCMN
	CMy += 30
	}

Gui, Font, s9 Bold c%ColorAccent%, Segoe UI
Gui, Add, Text, x204 y414 w186 h28 Center +0x100 +0x200 gCMPickAdd HwndhC, 🎯  Pick from screen  (F9)
CMCtrls.Push(hC)
SpecialBrushes[hC] := {brush: hBrushCard, text: ColorAccentBGR}
RoundCtrl(hC, 186, 28, 7)
Gui, Font, s9 Norm c%ColorText%, Segoe UI
Gui, Add, Text, x204 y446 w186 h28 Center +0x100 +0x200 gCMTypeAdd HwndhC, ＋  Type a hex value
CMCtrls.Push(hC)
SpecialBrushes[hC] := {brush: hBrushCard, text: ColorTextBGR}
RoundCtrl(hC, 186, 28, 7)
Gui, Font, s9 Norm c%ColorRed%, Segoe UI
Gui, Add, Text, x204 y478 w186 h28 Center +0x100 +0x200 gCMClearAll HwndhC, Clear this list
CMCtrls.Push(hC)
SpecialBrushes[hC] := {brush: hBrushCard, text: ColorRedBGR}
RoundCtrl(hC, 186, 28, 7)

; ---- right: the list ----
hC := AddPanel(418, 162, 326, 356)
CMCtrls.Push(hC)

Gui, Font, s11 Bold c%ColorAccent%, Segoe UI
Gui, Add, Text, x434 y176 w294 h22 vCMTitle HwndhC, Fish line
CMCtrls.Push(hC)
SpecialBrushes[hC] := {brush: hBrushCard, text: ColorAccentBGR}
Gui, Font, s9 Norm cFFFFFF, Segoe UI
Gui, Add, Text, x434 y200 w294 h56 vCMHint HwndhC,
CMCtrls.Push(hC)
SpecialBrushes[hC] := {brush: hBrushCard, text: 0xFFFFFF}

Gui, Font, s9 Norm c%ColorText%, Segoe UI
CMy := 262
Loop, %CMRowMax%
	{
	ri := A_Index
	Gui, Add, Progress, x434 y%CMy% w40 h22 vCMSw%ri% HwndhCMS Background202020, 0
	CMCtrls.Push(hCMS)
	CMRowSw.Push(hCMS)
	Gui, Add, Text, x482 y%CMy% w160 h22 +0x200 vCMHex%ri% HwndhCMT, --
	CMCtrls.Push(hCMT)
	SpecialBrushes[hCMT] := {brush: hBrushCard, text: 0xFFFFFF}
	CMRowTx.Push(hCMT)
	Gui, Add, Text, x656 y%CMy% w26 h22 Center +0x100 +0x200 vCMDel%ri% gCMRowDelete HwndhCMB, ✕
	CMCtrls.Push(hCMB)
	SpecialBrushes[hCMB] := {brush: hBrushCard, text: ColorRedBGR}
	CMRowBt.Push(hCMB)
	CMy += 24
	}

Gui, Font, s9 Norm c%ColorMuted%, Segoe UI
Gui, Add, Text, x434 y264 w294 h60 vCMEmpty HwndhC, Nothing picked for this one yet.`n`nUse "Pick from screen" and click the color in game.
CMCtrls.Push(hC)
SpecialBrushes[hC] := {brush: hBrushCard, text: ColorMutedBGR}

Gui, Font, s9 Norm c%ColorAccent%, Segoe UI
Gui, Add, Text, x434 y482 w294 h26 Center +0x100 +0x200 vCMCopyBtn gCMCopyBar HwndhC, ⇄  Copy to the other end
CMCtrls.Push(hC)
SpecialBrushes[hC] := {brush: hBrushCard, text: ColorAccentBGR}
RoundCtrl(hC, 294, 26, 7)

Gui, Font, s9 Norm c%ColorMuted%, Segoe UI
return

CMCopyBar:
if (CMSel = "BarLeftColor")
	CMStore("BarRightColor", BarLeftColor)
else if (CMSel = "BarRightColor")
	CMStore("BarLeftColor", BarRightColor)
gosub, ShowSection
return

;====================================================================================================;

CMNavClick:
CMIdx := SubStr(A_GuiControl, 6)
if (CMIdx >= 1 and CMIdx <= CMTargetKeys.MaxIndex())
	CMSel := CMTargetKeys[CMIdx]
gosub, CMRefresh
gosub, RepaintGui
return

CMRefresh:
if (!CMNavH)
	return
for i, k in CMTargetKeys
	{
	h := CMNavH[k]
	if (k = CMSel)
		SpecialBrushes[h] := {brush: hBrushBG, text: ColorAccentBGR}
	else
		SpecialBrushes[h] := {brush: hBrushCard, text: ColorTextBGR}
	CMCnt := ColCount(%k%)
	GuiControl, 1:, CMNav%i%, % (k = CMSel ? "  ▸ " : "     ") . CMTargetLabel[k]
		. (CMCnt ? "      " . CMCnt : "      not set")
	}
GuiControl, 1:, CMTitle, % CMTargetLabel[CMSel]
GuiControl, 1:, CMHint, % CMTargetHint[CMSel]
if (CMSel = "BarLeftColor")
	{
	GuiControl, 1:, CMCopyBtn, ⇄  Copy this list to Bar - right end
	GuiControl, 1:Show, CMCopyBtn
	}
else if (CMSel = "BarRightColor")
	{
	GuiControl, 1:, CMCopyBtn, ⇄  Copy this list to Bar - left end
	GuiControl, 1:Show, CMCopyBtn
	}
else
	GuiControl, 1:Hide, CMCopyBtn
CMList := ColListToArray(%CMSel%)
CMn := CMList.MaxIndex()
if (!CMn)
	CMn := 0
Loop, %CMRowMax%
	{
	ri := A_Index
	if (ri <= CMn)
		{
		hx := Format("0x{:06X}", CMList[ri])
		sw := SubStr(hx, 3)
		GuiControl, 1:+Background%sw%, CMSw%ri%
		GuiControl, 1:, CMHex%ri%, % hx . (ri = 1 ? "      (primary)" : "")
		GuiControl, 1:Show, CMSw%ri%
		GuiControl, 1:Show, CMHex%ri%
		GuiControl, 1:Show, CMDel%ri%
		}
	else
		{
		GuiControl, 1:Hide, CMSw%ri%
		GuiControl, 1:Hide, CMHex%ri%
		GuiControl, 1:Hide, CMDel%ri%
		}
	}
if (CMn = 0)
	GuiControl, 1:Show, CMEmpty
else
	GuiControl, 1:Hide, CMEmpty
return

CMRowDelete:
CMIdx := SubStr(A_GuiControl, 6)
CMStore(CMSel, ColListRemoveAt(%CMSel%, CMIdx))
gosub, ShowSection
return

CMClearAll:
CMStore(CMSel, "")
gosub, ShowSection
return

CMTypeAdd:
Gui, 1:+OwnDialogs
InputBox, CMTyped, Add color, Enter a hex color (for example 0xF1F1F1):, , 320, 130
if ErrorLevel
	return
CMTyped := Trim(CMTyped)
CMTest := ColListToArray(CMTyped)
if (!CMTest.MaxIndex())
	{
	msgbox, 4144, DeepFish, That is not a hex color. Use six hex digits, like 0xF1F1F1.
	return
	}
CMStore(CMSel, ColListAdd(%CMSel%, CMTest[1]))
gosub, ShowSection
return

CMPickAdd:
FreezeTarget := CMSel
FreezeMode := "add"
gosub, FreezePick
return

FreezePickHotkey:
if (FreezeActive)
	return
FreezeTarget := CMSel
FreezeMode := "add"
gosub, FreezePick
return

OpenColorManager:
gosub, DisarmHotkeys
if (!WinExist("DeepFish BETA"))
	Gui, 1:Show
TargetSection := "Minigame"
MiniTab := "Colors"
gosub, ShowSection
return

;----------------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------------

FreezePick:
if (FreezeActive)
	return
FreezeActive := true
FreezePicked := ""

SysGet, FrzVX, 76
SysGet, FrzVY, 77
SysGet, FrzVW, 78
SysGet, FrzVH, 79
if (FrzVW < 1)
	{
	FrzVX := 0
	FrzVY := 0
	FrzVW := A_ScreenWidth
	FrzVH := A_ScreenHeight
	}

Gui, 1:Hide

if (hFullBM)
	{
	DllCall("DeleteObject", "Ptr", hFullBM)
	hFullBM := 0
	}
if (hFullMemDC)
	{
	DllCall("DeleteDC", "Ptr", hFullMemDC)
	hFullMemDC := 0
	}
hFrzScreenDC := DllCall("GetDC", "Ptr", 0, "Ptr")
hFullMemDC := DllCall("CreateCompatibleDC", "Ptr", hFrzScreenDC, "Ptr")
VarSetCapacity(FrzBMI, 40, 0)
NumPut(40, FrzBMI, 0, "UInt")
NumPut(FrzVW, FrzBMI, 4, "Int")
NumPut(-FrzVH, FrzBMI, 8, "Int")
NumPut(1, FrzBMI, 12, "UShort")
NumPut(32, FrzBMI, 14, "UShort")
NumPut(0, FrzBMI, 16, "UInt")
hFullBM := DllCall("CreateDIBSection", "Ptr", hFrzScreenDC, "Ptr", &FrzBMI, "UInt", 0, "Ptr*", pFullBits, "Ptr", 0, "UInt", 0, "Ptr")
DllCall("SelectObject", "Ptr", hFullMemDC, "Ptr", hFullBM)
DllCall("BitBlt", "Ptr", hFullMemDC, "Int", 0, "Int", 0, "Int", FrzVW, "Int", FrzVH
	, "Ptr", hFrzScreenDC, "Int", FrzVX, "Int", FrzVY, "UInt", 0x00CC0020)
DllCall("ReleaseDC", "Ptr", 0, "Ptr", hFrzScreenDC)
Gui, 1:Show, NoActivate

FrzWhat := CMTargetLabel.HasKey(FreezeTarget) ? CMTargetLabel[FreezeTarget] : FreezeTarget
gosub, FrzBuildMenu
if (!RobloxHwnd)
	gosub, ResolveRoblox
FrzMonL := 0
FrzMonT := 0
FrzMonW := A_ScreenWidth
FrzMonH := A_ScreenHeight
if (RobloxHwnd)
	{
	RobloxClientRect(RobloxHwnd, FrzRx, FrzRy, FrzRw, FrzRh)
	FrzRcx := FrzRx + (FrzRw // 2)
	FrzRcy := FrzRy + (FrzRh // 2)
	SysGet, FrzMonN, MonitorCount
	Loop, %FrzMonN%
		{
		SysGet, FrzM, Monitor, %A_Index%
		if (FrzRcx >= FrzMLeft and FrzRcx < FrzMRight and FrzRcy >= FrzMTop and FrzRcy < FrzMBottom)
			{
			FrzMonL := FrzMLeft
			FrzMonT := FrzMTop
			FrzMonW := FrzMRight - FrzMLeft
			FrzMonH := FrzMBottom - FrzMTop
			break
			}
		}
	}
FrzBW := FrzMonW - 220
if (FrzBW > 1060)
	FrzBW := 1060
if (FrzBW < 420)
	FrzBW := 420
FrzBX := FrzMonL + ((FrzMonW - FrzBW) // 2) - FrzVX
FrzBY := FrzMonT + 54 - FrzVY
FrzTX := FrzBX + 28
FrzTW := FrzBW - 56
Gui, Frz:New, +AlwaysOnTop -Caption +ToolWindow +HwndhFrzGui
Gui, Frz:Color, 000000
Gui, Frz:Margin, 0, 0
Gui, Frz:Add, Picture, x0 y0 w%FrzVW% h%FrzVH%, HBITMAP:%hFullBM%
FrzR1 := FrzBY + 22
FrzR2 := FrzBY + 62
FrzR3 := FrzBY + 92
FrzR4 := FrzBY + 122
Gui, Frz:Add, Progress, x%FrzBX% y%FrzBY% w%FrzBW% h158 Background0A0E16, 0
FrzExitW := 268
FrzHintW := FrzTW - FrzExitW
FrzExitX := FrzTX + FrzHintW
Gui, Frz:Font, s9 Bold cFF6B6B, Segoe UI
Gui, Frz:Add, Text, x%FrzTX% y%FrzR1% w%FrzTW% h20 BackgroundTrans, ❄   SCREEN FROZEN
Gui, Frz:Font, s20 Bold cFF4D4D, Segoe UI
Gui, Frz:Add, Text, x%FrzTX% y%FrzR2% w%FrzTW% h34 BackgroundTrans vFrzTitle, %FrzWhat%
Gui, Frz:Font, s10 Bold cFFD479, Segoe UI
Gui, Frz:Add, Text, x%FrzTX% y%FrzR3% w%FrzTW% h22 BackgroundTrans vFrzMenuTx, %FrzMenu%
Gui, Frz:Font, s10 Norm c9FB4D0, Segoe UI
Gui, Frz:Add, Text, x%FrzTX% y%FrzR4% w%FrzHintW% h24 BackgroundTrans vFrzCount, Click the color in game  ·  number keys switch
Gui, Frz:Font, s10 Bold cFF4D4D, Segoe UI
Gui, Frz:Add, Text, x%FrzExitX% y%FrzR4% w%FrzExitW% h24 BackgroundTrans, Right-click or Esc to finish
Gui, Frz:Show, x%FrzVX% y%FrzVY% w%FrzVW% h%FrzVH% NoActivate, DeepFishFreeze

LoupeSrc := 25
LoupeZoom := 7
LoupeImgW := LoupeSrc * LoupeZoom
LoupeW := LoupeImgW + 12
LoupeH := LoupeImgW + 12 + 28
Gui, Loupe:New, +AlwaysOnTop -Caption +ToolWindow +E0x8000020 +HwndhLoupeGui
Gui, Loupe:Color, 0B0E14
Gui, Loupe:Margin, 0, 0
Gui, Loupe:Show, x0 y0 w%LoupeW% h%LoupeH% NoActivate, DeepFishLoupe
hLoupeRgn := DllCall("CreateRoundRectRgn", "Int", 0, "Int", 0, "Int", LoupeW+1, "Int", LoupeH+1, "Int", 12, "Int", 12, "Ptr")
DllCall("SetWindowRgn", "Ptr", hLoupeGui, "Ptr", hLoupeRgn, "Int", true)

hLoupeDC := DllCall("GetDC", "Ptr", hLoupeGui, "Ptr")
hLoupeMem := DllCall("CreateCompatibleDC", "Ptr", hLoupeDC, "Ptr")
hLoupeBM := DllCall("CreateCompatibleBitmap", "Ptr", hLoupeDC, "Int", LoupeW, "Int", LoupeH, "Ptr")
hLoupeOldBM := DllCall("SelectObject", "Ptr", hLoupeMem, "Ptr", hLoupeBM, "Ptr")
DllCall("ReleaseDC", "Ptr", hLoupeGui, "Ptr", hLoupeDC)
hLoupeFont := DllCall("CreateFont", "Int", -14, "Int", 0, "Int", 0, "Int", 0, "Int", 700
	, "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 1, "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 0, "Str", "Consolas", "Ptr")

CoordMode, Mouse, Screen
FrzCancelled := false
FrzAdded := 0
Loop
	{
	if (GetKeyState("Escape", "P") or GetKeyState("RButton", "P"))
		{
		FrzCancelled := (FrzAdded = 0)
		while GetKeyState("RButton", "P")
			sleep 5
		break
		}
	FrzSwitch := 0
	Loop, % CMTargetKeys.MaxIndex()
		{
		if (A_Index <= 9 and GetKeyState(A_Index, "P"))
			{
			FrzSwitch := A_Index
			break
			}
		}
	if (FrzSwitch)
		{
		while GetKeyState(FrzSwitch, "P")
			sleep 5
		FreezeTarget := CMTargetKeys[FrzSwitch]
		CMSel := FreezeTarget
		FrzWhat := CMTargetLabel[FreezeTarget]
		FrzAdded := 0
		gosub, FrzBuildMenu
		GuiControl, Frz:, FrzTitle, %FrzWhat%
		GuiControl, Frz:, FrzMenuTx, %FrzMenu%
		GuiControl, Frz:, FrzCount, % FrzWhat . " already has " . ColCount(%FreezeTarget%) . "  ·  click to add more"
		}
	MouseGetPos, FrzMx, FrzMy
	FreezePaintLoupe(FrzMx, FrzMy)
	if GetKeyState("LButton", "P")
		{
		while GetKeyState("LButton", "P")
			sleep 5
		FrzHex := FreezePixelAt(FrzMx, FrzMy)
		if (FrzHex != "" and FreezeTarget != "")
			{
			FrzBefore := ColCount(%FreezeTarget%)
			if (FreezeMode = "add")
				CMStore(FreezeTarget, ColListAdd(%FreezeTarget%, FrzHex))
			else
				CMStore(FreezeTarget, FrzHex)
			FrzAfter := ColCount(%FreezeTarget%)
			FreezePicked := FrzHex
			if (FrzAfter > FrzBefore)
				{
				FrzAdded := FrzAdded + 1
				GuiControl, Frz:, FrzCount, % "added " . FrzAdded . "   (" . FrzAfter . " on this color)   last " . FrzHex
				}
			else
				GuiControl, Frz:, FrzCount, % "added " . FrzAdded . "   " . FrzHex . " was already in the list"
			}
		}
	sleep 12
	}
CoordMode, Mouse, Client

Gui, Loupe:Destroy
Gui, Frz:Destroy
Gui, 1:Default
Gui, 1:Show
if (hLoupeMem)
	{
	if (hLoupeOldBM)
		DllCall("SelectObject", "Ptr", hLoupeMem, "Ptr", hLoupeOldBM)
	DllCall("DeleteDC", "Ptr", hLoupeMem)
	hLoupeMem := 0
	hLoupeOldBM := 0
	}
if (hLoupeBM)
	{
	DllCall("DeleteObject", "Ptr", hLoupeBM)
	hLoupeBM := 0
	}
if (hLoupeFont)
	{
	DllCall("DeleteObject", "Ptr", hLoupeFont)
	hLoupeFont := 0
	}
FreezeActive := false

TargetSection := "Minigame"
MiniTab := "Colors"
gosub, ShowSection
return

FrzBuildMenu:
FrzMenu := ""
for FrzI, FrzK in CMTargetKeys
	FrzMenu .= (FrzMenu = "" ? "" : "     ")
		. ((FrzK = FreezeTarget) ? "▸ " : "") . FrzI . " " . CMShortLabel[FrzK]
return

FreezePixelAt(sx, sy) {
	global pFullBits, FrzVX, FrzVY, FrzVW, FrzVH
	x := sx - FrzVX
	y := sy - FrzVY
	if (x < 0 or y < 0 or x >= FrzVW or y >= FrzVH)
		return ""
	v := NumGet(pFullBits + 0, (y*FrzVW*4) + (x*4), "UInt")
	return Format("0x{:02X}{:02X}{:02X}", (v >> 16) & 0xFF, (v >> 8) & 0xFF, v & 0xFF)
}

FreezePaintLoupe(sx, sy) {
	global hLoupeGui, hLoupeMem, hLoupeFont, hFullMemDC, pFullBits
	global LoupeSrc, LoupeZoom, LoupeImgW, LoupeW, LoupeH
	global FrzVX, FrzVY, FrzVW, FrzVH
	static lastX := -99999, lastY := -99999
	if (!hLoupeMem)
		return
	px := sx - FrzVX
	py := sy - FrzVY
	half := LoupeSrc // 2

	DllCall("SetBkMode", "Ptr", hLoupeMem, "Int", 1)
	brBG := DllCall("CreateSolidBrush", "UInt", 0x140E0B, "Ptr")
	VarSetCapacity(rc, 16, 0)
	NumPut(0, rc, 0, "Int"), NumPut(0, rc, 4, "Int"), NumPut(LoupeW, rc, 8, "Int"), NumPut(LoupeH, rc, 12, "Int")
	DllCall("FillRect", "Ptr", hLoupeMem, "Ptr", &rc, "Ptr", brBG)
	DllCall("DeleteObject", "Ptr", brBG)

	sx0 := px - half
	sy0 := py - half
	if (sx0 < 0)
		sx0 := 0
	if (sy0 < 0)
		sy0 := 0
	if (sx0 > FrzVW - LoupeSrc)
		sx0 := FrzVW - LoupeSrc
	if (sy0 > FrzVH - LoupeSrc)
		sy0 := FrzVH - LoupeSrc
	DllCall("SetStretchBltMode", "Ptr", hLoupeMem, "Int", 3)
	DllCall("StretchBlt", "Ptr", hLoupeMem, "Int", 6, "Int", 6, "Int", LoupeImgW, "Int", LoupeImgW
		, "Ptr", hFullMemDC, "Int", sx0, "Int", sy0, "Int", LoupeSrc, "Int", LoupeSrc, "UInt", 0x00CC0020)
	cpx := (px - sx0)
	cpy := (py - sy0)
	if (cpx < 0)
		cpx := 0
	if (cpy < 0)
		cpy := 0

	cx := 6 + (cpx * LoupeZoom)
	cy := 6 + (cpy * LoupeZoom)
	penW := DllCall("CreatePen", "Int", 0, "Int", 1, "UInt", 0xFFFFFF, "Ptr")
	penK := DllCall("CreatePen", "Int", 0, "Int", 1, "UInt", 0x000000, "Ptr")
	hollow := DllCall("GetStockObject", "Int", 5, "Ptr")
	oldBr := DllCall("SelectObject", "Ptr", hLoupeMem, "Ptr", hollow, "Ptr")
	oldPen := DllCall("SelectObject", "Ptr", hLoupeMem, "Ptr", penK, "Ptr")
	DllCall("Rectangle", "Ptr", hLoupeMem, "Int", cx-2, "Int", cy-2, "Int", cx+LoupeZoom+2, "Int", cy+LoupeZoom+2)
	DllCall("SelectObject", "Ptr", hLoupeMem, "Ptr", penW)
	DllCall("Rectangle", "Ptr", hLoupeMem, "Int", cx-1, "Int", cy-1, "Int", cx+LoupeZoom+1, "Int", cy+LoupeZoom+1)
	DllCall("SelectObject", "Ptr", hLoupeMem, "Ptr", oldPen)
	DllCall("SelectObject", "Ptr", hLoupeMem, "Ptr", oldBr)
	DllCall("DeleteObject", "Ptr", penW)
	DllCall("DeleteObject", "Ptr", penK)

	hex := FreezePixelAt(sx, sy)
	if (hex = "")
		hex := "0x000000"
	sr := "0x" . SubStr(hex, 3, 2)
	sg := "0x" . SubStr(hex, 5, 2)
	sb := "0x" . SubStr(hex, 7, 2)
	swBGR := (sb << 16) | (sg << 8) | sr
	brSw := DllCall("CreateSolidBrush", "UInt", swBGR, "Ptr")
	NumPut(6, rc, 0, "Int"), NumPut(LoupeImgW + 10, rc, 4, "Int")
	NumPut(34, rc, 8, "Int"), NumPut(LoupeImgW + 32, rc, 12, "Int")
	DllCall("FillRect", "Ptr", hLoupeMem, "Ptr", &rc, "Ptr", brSw)
	DllCall("DeleteObject", "Ptr", brSw)

	oldFont := DllCall("SelectObject", "Ptr", hLoupeMem, "Ptr", hLoupeFont, "Ptr")
	DllCall("SetTextColor", "Ptr", hLoupeMem, "UInt", 0xF7F1EE)
	NumPut(40, rc, 0, "Int"), NumPut(LoupeImgW + 10, rc, 4, "Int")
	NumPut(LoupeW - 6, rc, 8, "Int"), NumPut(LoupeImgW + 32, rc, 12, "Int")
	DllCall("DrawText", "Ptr", hLoupeMem, "Str", hex, "Int", -1, "Ptr", &rc, "UInt", 0x24)
	DllCall("SelectObject", "Ptr", hLoupeMem, "Ptr", oldFont)

	hdc := DllCall("GetDC", "Ptr", hLoupeGui, "Ptr")
	DllCall("BitBlt", "Ptr", hdc, "Int", 0, "Int", 0, "Int", LoupeW, "Int", LoupeH
		, "Ptr", hLoupeMem, "Int", 0, "Int", 0, "UInt", 0x00CC0020)
	DllCall("ReleaseDC", "Ptr", hLoupeGui, "Ptr", hdc)

	lx := sx + 26
	ly := sy + 26
	if (lx + LoupeW > FrzVX + FrzVW)
		lx := sx - LoupeW - 26
	if (ly + LoupeH > FrzVY + FrzVH)
		ly := sy - LoupeH - 26
	if (lx != lastX or ly != lastY)
		{
		lastX := lx
		lastY := ly
		DllCall("SetWindowPos", "Ptr", hLoupeGui, "Ptr", -1, "Int", lx, "Int", ly, "Int", 0, "Int", 0, "UInt", 0x0215)
		}
}

;====================================================================================================;

ClearIconTip:
MouseGetPos, , , , HoverCtrlHwnd, 2
if (!IconTips.HasKey(HoverCtrlHwnd))
	{
	ToolTip, , , , 3
	SetTimer, ClearIconTip, Off
	}
return

;====================================================================================================;

ColorFieldChanged:
GuiControlGet, PerfectGreenColor, 1:, PerfectGreenColor
GuiControlGet, PerfectWhiteColor, 1:, PerfectWhiteColor
GuiControlGet, FishColor, 1:, FishColor
GuiControlGet, NoteColor, 1:, NoteColor
GuiControlGet, BarLeftColor, 1:, BarLeftColor
GuiControlGet, BarRightColor, 1:, BarRightColor
GuiControlGet, ArrowColor, 1:, ArrowColor
gosub, RefreshSwatches
gosub, QueueAutoSave
return

QueueAutoSave:
if (GuiAutoSave)
	settimer, AutoSaveNow, -1200
return

AutoSaveNow:
if (!GuiAutoSave)
	return
gosub, SaveSettings
return

RefreshSwatches:
SwFish := Format("{:06X}", ColMain(FishColor))
if (!ColCount(FishColor))
	SwFish := "202020"
GuiControl, 1:+Background%SwFish%, FishColorSwatch
SwNote := Format("{:06X}", ColMain(NoteColor))
if (!ColCount(NoteColor))
	SwNote := "202020"
GuiControl, 1:+Background%SwNote%, NoteColorSwatch
SwLeft := Format("{:06X}", ColMain(BarLeftColor))
if (!ColCount(BarLeftColor))
	SwLeft := "202020"
GuiControl, 1:+Background%SwLeft%, BarLeftColorSwatch
SwRight := Format("{:06X}", ColMain(BarRightColor))
if (!ColCount(BarRightColor))
	SwRight := "202020"
GuiControl, 1:+Background%SwRight%, BarRightColorSwatch
SwArrow := Format("{:06X}", ColMain(ArrowColor))
if (!ColCount(ArrowColor))
	SwArrow := "202020"
GuiControl, 1:+Background%SwArrow%, ArrowColorSwatch
SwCastG := Format("{:06X}", ColMain(PerfectGreenColor))
if (!ColCount(PerfectGreenColor))
	SwCastG := "202020"
GuiControl, 1:+Background%SwCastG%, CastGreenSwatch
SwCastW := Format("{:06X}", ColMain(PerfectWhiteColor))
if (!ColCount(PerfectWhiteColor))
	SwCastW := "202020"
GuiControl, 1:+Background%SwCastW%, CastWhiteSwatch
return

;====================================================================================================;


;====================================================================================================;

ClearDumpTip:
tooltip, , , , 3
return

ToggleAlwaysOnTop:
GuiControlGet, GuiAlwaysOnTop,, GuiAlwaysOnTop
if (GuiAlwaysOnTop)
	Gui, +AlwaysOnTop
else
	Gui, -AlwaysOnTop
IniWrite, %GuiAlwaysOnTop%, %SettingsFile%, GUI, AlwaysOnTop
return

ToggleKeepOpen:
GuiControlGet, GuiKeepOpen,, GuiKeepOpen
IniWrite, %GuiKeepOpen%, %SettingsFile%, GUI, KeepOpen
return

ToggleAutoSave:
GuiControlGet, GuiAutoSave, 1:, GuiAutoSave
IniWrite, %GuiAutoSave%, %SettingsFile%, GUI, AutoSave
if (GuiAutoSave)
	gosub, SaveSettings
return

RevertSettings:
if !FileExist(ActiveProfileFile . ".bak")
	{
	GuiControl, 1:, SaveStatusText, ↶ none
	settimer, RestoreSaveButton, -1500
	return
	}
FileCopy, %ActiveProfileFile%.bak, %ActiveProfileFile%, 1
gosub, LoadActiveProfile
gosub, RefreshGuiFields
gosub, RefreshSwatches
GuiControl, 1:, SaveStatusText, ↶ undone
settimer, RestoreSaveButton, -1500
return

ShowGuiFromTray:
gosub, DisarmHotkeys
Gui, Show
return

GuiClose:
gosub, DoExit
return

GuiEscape:
return