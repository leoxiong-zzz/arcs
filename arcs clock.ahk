#SingleInstance, Force
#NoTrayIcon
#NoEnv
SetBatchLines, -1

;Gdip initialization
Gui, -Caption +E0x80000 +Hwndhwnd +LastFound +ToolWindow
DllCall("SetParent", "UInt", WinExist(), "UInt", DllCall("GetShellWindow"))
Gui, Show, NoActivate

pToken := Gdip_Startup()
hbm := CreateDIBSection(430, 430)
hdc := CreateCompatibleDC()
obm := SelectObject(hdc, hbm)
pGraphics := Gdip_GraphicsFromHDC(hdc)

Gdip_SetSmoothingMode(pGraphics, 4) ;Anti-aliasing

IniRead, interval, options.ini, misc, updatespeed, 300

;Window position
IniRead, x, options.ini, position, x
IniRead, y, options.ini, position, y

;Load colors from options file
IniRead, scheme, options.ini, scheme, name, default
IniRead, color1, options.ini, %scheme%, 1, 0xFFEEEEEE
IniRead, color2, options.ini, %scheme%, 2, 0xFFAAAAAA
IniRead, color3, options.ini, %scheme%, 3, 0xFF777777
IniRead, color4, options.ini, %scheme%, 4, 0x33FFFFFF
IniRead, color5, options.ini, %scheme%, 5, 0x33DDDDDD
IniRead, color6, options.ini, %scheme%, 6, 0xFFFFFFFF
IniRead, color7, options.ini, %scheme%, 7, 0xFF80C0FF

;Create pens - b for brush, p for pen. type[color#]_[width]
bColor6 := Gdip_BrushCreateSolid(color6)

pColor1_4 := Gdip_CreatePen(color1, 4)
pColor1_5 := Gdip_CreatePen(color1, 5)
pColor2_4 := Gdip_CreatePen(color2, 4)
pColor2_5 := Gdip_CreatePen(color2, 5)
pColor2_7 := Gdip_CreatePen(color2, 7)
pColor3_5 := Gdip_CreatePen(color3, 5)
pColor3_15 := Gdip_CreatePen(color3, 15)
pColor4_4 := Gdip_CreatePen(color4, 4)
pColor4_66 := Gdip_CreatePen(color4, 66)
pColor5_4 := Gdip_CreatePen(color5, 4)
pColor5_5 := Gdip_CreatePen(color5, 5)
pColor5_6 := Gdip_CreatePen(color5, 6)
pColor5_7 := Gdip_CreatePen(color5, 7)
pColor5_15 := Gdip_CreatePen(color5, 15)
pColor6_1 := Gdip_CreatePen(color6, 1)
pColor7_1 := Gdip_CreatePen(color7, 1)

;GetNumberOfInterfaces
DllCall("Iphlpapi\GetNumberOfInterfaces", "UIntP", pdwNumIf)
pdwSize := 860 * pdwNumIf + 12
VarSetCapacity(pIfTable, pdwSize)

VarSetCapacity(lpSystemPowerStatus, 12) ;GetSystemPowerStatusg
VarSetCapacity(lpBuffer, 160) ;GlobalMemoryStatus
UpdateLayeredWindow(hwnd, hdc, x < 0 or (x > A_ScreenWidth - 430) ? A_ScreenWidth / 2 - 215 : x, y < 0 or (y > A_ScreenHeight - 430) ? A_ScreenHeight / 2 - 215 : y, 430, 430)

OnExit, exit
OnMessage(0x201, "WM_LBUTTONDOWN")
OnMessage(0x207, "WM_MBUTTONDOWN")
OnMessage(0x03, "WM_MOVE")
OnMessage(0x204, "WM_RBUTTONDOWN")

SetTimer, redraw, %interval%
redraw:
Gdip_GraphicsClear(pGraphics)

;Frame and disk (the script is executed from) space usage arc
DriveSpaceFree, driveSpaceFree, %drive%
DriveGet, capacity, Capacity, % drive := SubStr(A_ScriptDir, 1, 3)
Gdip_DrawArc(pGraphics, pColor4_66, 35, 35, 360, 360, -90, t := -(capacity - driveSpaceFree) / capacity * 360)
Gdip_DrawArc(pGraphics, pColor4_4, 66, 66, 298, 298, -90, 360 + t)

;Default arc for hour, minute, and seconds
Gdip_DrawArc(pGraphics, pColor5_5, 148, 148, 134, 134, 0, 360)
Gdip_DrawArc(pGraphics, pColor5_5, 154, 154, 122, 122, 0, 360)
Gdip_DrawArc(pGraphics, pColor5_5, 160, 160, 110, 110, 0, 360)

;Default arcs for month of year, day of month
Gdip_DrawArc(pGraphics, pColor5_5, 132, 132, 166, 166, 120, 150)
Gdip_DrawArc(pGraphics, pColor5_5, 140, 140, 150, 150, 120, 90)

;Default arcs for battery
Gdip_DrawArc(pGraphics, pColor5_6, 125, 125, 180, 180, -32, 66)

;Default arcs for network I/O
Gdip_DrawArc(pGraphics, pColor5_5, 140, 140, 150, 150, -32, 32)
Gdip_DrawArc(pGraphics, pColor5_5, 134, 134, 162, 162, -32, 32)

;Default arcs for CPU and RAM
Gdip_DrawArc(pGraphics, pColor5_4, 123, 123, 184, 184, 36, 40)
Gdip_DrawArc(pGraphics, pColor5_4, 123, 123, 184, 184, 78, 40)

;Default arcs for HDD (D:, E:, and F:)
Gdip_DrawArc(pGraphics, pColor5_15, 135, 135, 160, 160, 36, 26)
Gdip_DrawArc(pGraphics, pColor5_15, 135, 135, 160, 160, 64, 26)
Gdip_DrawArc(pGraphics, pColor5_15, 135, 135, 160, 160, 92, 26)

;Default arcs for volume
Gdip_DrawArc(pGraphics, pColor5_4, 123, 123, 184, 184, 120, 90)

;Arcs for hour, minute, and seconds
Gdip_DrawArc(pGraphics, pColor1_5, 148, 148, 134, 134, -90, Mod((A_Hour + A_Min / 60) * 30, 360))
Gdip_DrawArc(pGraphics, pColor2_5, 154, 154, 122, 122, -90, A_Min * 6)
Gdip_DrawArc(pGraphics, pColor3_5, 160, 160, 110, 110, -90, A_Sec * 6)

;Arcs for month of year and day of month
Gdip_DrawArc(pGraphics, pColor2_5, 132, 132, 166, 166, 120, (A_Mon / 12) * 150)
Gdip_DrawArc(pGraphics, pColor3_5, 140, 140, 150, 150, 120, (A_DD / A_LastDay()) * 90)

;Arcs for battery
DllCall("Kernel32\GetSystemPowerStatus", "UInt", &lpSystemPowerStatus)
Gdip_DrawArc(pGraphics, pColor2_7, 125, 125, 180, 180, 34, -((t := *(&lpSystemPowerStatus + 2)) = 255 ? 0 : t) * 0.66)

;Arcs for network I/O
DllCall("Iphlpapi\GetIfTable", "UInt", &pIfTable, "UIntP", pdwSize, "Int", true)
Loop, % decodeInteger(&pIfTable)
    down += decodeInteger((t := (&pIfTable + 860 * (A_Index - 1))) + 556), up += decodeInteger(t + 580)
downRate := (down - down2) / 1024, upRate := (up - up2) / 1024
down2 := down, up2 := up, down := 0, up := 0
Gdip_DrawArc(pGraphics, pColor1_5, 140, 140, 150, 150, 0, -(downRate > 255 ? 255 : downRate) / 255 * 32)
Gdip_DrawArc(pGraphics, pColor1_5, 134, 134, 162, 162, 0, -(upRate > 255 ? 255 : upRate) * 0.1254901961)

;Arcs for CPU and RAM
DllCall("kernel32\GlobalMemoryStatus", "UInt", &lpBuffer)
Gdip_DrawArc(pGraphics, pColor1_4, 123, 123, 184, 184, 76, -*(&lpBuffer + 4) * 0.4)

DllCall("GetSystemTimes", "UInt64P", lpIdleTime, "UInt64P", lpKernelTime, "UInt64P", lpUserTime)
usr := lpUserTime - lpUserTime2, ker := lpKernelTime - lpKernelTime2, idl := lpIdleTime - lpIdleTime2
lpUserTime2 := lpUserTime, lpKernelTime2 := lpKernelTime, lpIdleTime2 := lpIdleTime
Gdip_DrawArc(pGraphics, pColor1_4, 123, 123, 184, 184, 78, (ker + usr - idl) * 40 / (ker + usr))

;Arcs for HDD (D:, E:, and F:)
DriveSpaceFree, driveSpaceFree, D:
DriveGet, capacity, Capacity, D:
Gdip_DrawArc(pGraphics, pColor3_15, 135, 135, 160, 160, 49, (capacity - driveSpaceFree) / capacity * 13)
Gdip_DrawArc(pGraphics, pColor3_15, 135, 135, 160, 160, 49, (capacity - driveSpaceFree) / capacity * -13)

DriveSpaceFree, driveSpaceFree, E:
DriveGet, capacity, Capacity, E:
Gdip_DrawArc(pGraphics, pColor3_15, 135, 135, 160, 160, 77, (capacity - driveSpaceFree) / capacity * 13)
Gdip_DrawArc(pGraphics, pColor3_15, 135, 135, 160, 160, 77, (capacity - driveSpaceFree) / capacity * -13)

DriveSpaceFree, driveSpaceFree, F:
DriveGet, capacity, Capacity, F:
Gdip_DrawArc(pGraphics, pColor3_15, 135, 135, 160, 160, 105, (capacity - driveSpaceFree) / capacity * 13)
Gdip_DrawArc(pGraphics, pColor3_15, 135, 135, 160, 160, 105, (capacity - driveSpaceFree) / capacity * -13)

;Arcs for volume
SoundGet, volume
Gdip_DrawArc(pGraphics, pColor2_4, 123, 123, 184, 184, 120, volume * 0.9)

;Indicator hands for hour, minute, and seconds
Gdip_DrawLine(pGraphics, pColor6_1, 215, 215, 215 - 100 * Cos(t := (A_Hour * 30 + (A_Min * 6) / 12 + 90) * 0.0174532925), 215 - 100 * Sin(t))
Gdip_DrawLine(pGraphics, pColor6_1, 215, 215, 215 - 125 * Cos(t := (A_Min * 6 + 90) * 0.0174532925), 215 - 125 * Sin(t))
Gdip_DrawLine(pGraphics, pColor7_1, 215, 215, 215 - 146 * Cos(t := (A_Sec * 6 + 90) * 0.0174532925), 215 - 146 * Sin(t))

;Draw pin
Gdip_FillEllipse(pGraphics, bColor6, 210, 210, 10, 10)
 
UpdateLayeredWindow(hwnd, hdc)

return
A_LastDay(){
    time := A_YYYY A_MM
    time += 31, D
    tme := SubStr(time, 1, 6)
    time -= A_YYYY A_MM, D
    Return time
}
decodeInteger(ptr)
{
    Return *ptr | *++ptr << 8 | *++ptr << 16 | *++ptr << 24
}
WM_LBUTTONDOWN(wParam, lParam){
    PostMessage, 0xA1, 2
}
WM_MBUTTONDOWN(wParam, lParam){
    ExitApp
}
WM_MOVE(wParam, lParam){
    WinGetPos, x, y
    IniWrite, %x%, options.ini, position, x
    IniWrite, %y%, options.ini,position, y
}
WM_RBUTTONDOWN(wParam, lParam){
    Reload
}

return
exit:
GuiClose:
SelectObject(hdc, obm)
DeleteObject(hbm)
DeleteDC(hdc)
Gdip_DeleteGraphics(G)
Gdip_Shutdown(pToken)
ExitApp

return
#c::WinActivate, ahk_id %hwnd%

;#Include Gdip.ahk