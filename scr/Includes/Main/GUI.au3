;coded by UEZ build 2013-05-29, idea taken from http://www.alessioatzeni.com/wp-content/tutorials/html-css/CSS3-Loading-Animation/index.html
;AutoIt v3.3.9.21 or higher needed!
#include <WindowsConstants.au3>
#include <GUIConstantsEx.au3>
#include <Memory.au3>
#include <GDIPlus.au3>
#include <WindowsConstants.au3>

#include "Loading GUI.au3"
AutoItSetOption("GUIOnEventMode", 1)

Global Const $iMaxBalls = 6
Global $iPerc = 0, $iMaxPerc = 0, $iMinPerc = 0, $iBall = 1, $sLoadingText = "Loading..."
Global $abErrors[$iMaxBalls]
Global Const $hDwmApiDll = DllOpen("dwmapi.dll")
Global $sChkAero = DllStructCreate("int;")
DllCall($hDwmApiDll, "int", "DwmIsCompositionEnabled", "ptr", DllStructGetPtr($sChkAero))
Global $bAero = DllStructGetData($sChkAero, 1)
Global $fStep = 0.02
If Not $bAero Then $fStep = 1.25

_GDIPlus_Startup()
Global Const $STM_SETIMAGE = 0x0172 ; $IMAGE_BITMAP = 0
Global $iW = 300, $iH = 120
Global Const $hGUI = GUICreate("Loading Parsec Shortcut", $iW, $iH, -1, -1, $WS_POPUPWINDOW) ;, $WS_EX_TOPMOST)
GUISetOnEvent($GUI_EVENT_CLOSE, "Close")
OnAutoItExitRegister("Close")
GUISetBkColor(0)
Global Const $iPic = GUICtrlCreatePic("", 0, 0, $iW, $iH)
GUICtrlSetState(-1, $GUI_DISABLE)
WinSetTrans($hGUI, "", 0)
GUISetState()
Global $hHBmp_BG, $hB, $iSleep = 20
GUIRegisterMsg($WM_TIMER, "PlayAnim")
DllCall("user32.dll", "int", "SetTimer", "hwnd", $hGUI, "int", 0, "int", $iSleep, "int", 0)

Global $z, $iPerc
For $z = 1 To 255 Step $fStep
	WinSetTrans($hGUI, "", $z)
Next

Func PlayAnim()
	;$hHBmp_BG = _GDIPlus_IncreasingBalls($iW, $iH, $iPerc, $sLoadingText & "   " & StringFormat("%05.2f %", Min($iPerc, 100)))
	$hHBmp_BG = _GDIPlus_IncreasingBalls($iW, $iH, $iPerc, $sLoadingText, 12, $iMaxBalls)
	$hB = GUICtrlSendMsg($iPic, $STM_SETIMAGE, $IMAGE_BITMAP, $hHBmp_BG)
	If $hB Then _WinAPI_DeleteObject($hB)
	_WinAPI_DeleteObject($hHBmp_BG)
	;If $iPerc > 110 Then $iPerc = 0
EndFunc   ;==>PlayAnim
Func _addBallError()
	PlayAnim()
	$abErrors[$iBall-1] = True
EndFunc
Func Close()
	GUIRegisterMsg($WM_TIMER, "")
	_WinAPI_DeleteObject($hHBmp_BG)
	_GDIPlus_Shutdown()
	GUIDelete()
	Exit
EndFunc   ;==>Close
Func _MaxMinPerc($iNewBall, $sNewText)
	$iBall = $iNewBall
	$iPerc = ($iBall-1)*(100/$iMaxBalls)
	$iMinPerc = ($iBall-1)*(100/$iMaxBalls)
	$iMaxPerc = ($iBall)*(100/$iMaxBalls)
	$sLoadingText = $sNewText
	Sleep(200) ;For the animation
EndFunc
Func _SetBallPerc($iNewPerc)
	If $iNewPerc > 100 Then $iNewPerc = 100
	$iPerc = (($iBall-1)+($iNewPerc/100))*(100/$iMaxBalls)
	PlayAnim()
EndFunc