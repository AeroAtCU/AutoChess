#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
; Should I explicitely set CoordMode or just let default settings figure it out?

global SAN_map := "ABCDEFGH"

; Output the pixel location of a chess coordinate
;PixelFromSAN(SAN, bl, tr, player_color:="White"){
PixelFromSAN(SAN, player_color:="White"){
  ; Extract the row and collumn into their own variables
  SAN_char := SubStr(SAN, 1, 1)
  SAN_num  := SubStr(SAN, 2, 1)

  ; Get the number of squares we need to move from the sides
  x_blocks := InStr(SAN_map, SAN_char, CaseSensitive:=False) - 1
  y_blocks := SAN_num - 1

  ; Get size of each block
  x_block_size := Abs(bl[1] - tr[1]) / 7
  y_block_size := Abs(bl[2] - tr[2]) / 7

  ; Compute the actual pixel to go to, assuming white player
  if ((InStr(player_color, "W", CaseSensitive:=False)) != 0){
    right_dist := x_blocks * x_block_size
    up_dist    := y_blocks * y_block_size

    x_coord := bl[1] + right_dist
    y_coord := bl[2] - up_dist

    return Array(x_coord, y_coord)
  }

  if (InStr(player_color, "B", CaseSensitive:=False)){
    ; Not programming black yet
  }

  ; If neither black nor white work, just return bottom left coord
  Return Array(-1, -1)
}

; Simple way to view coordinates. 'Msgbox, % array' just doesn't work
MsgBoxTuple(coord, name := ""){
  MsgBox, % name . "  x:" . coord[1] . "  y:" . coord[2]
}

MousePreMoveSANString(SAN_string, player_color := "White"){
  Loop, parse, SAN_string, %A_Space%
  {
    SAN_pair = %A_LoopField%
    SAN1 := SubStr(SAN_pair, 1, 2)
    SAN2 := SubStr(SAN_pair, 4, 2)
    coord1 := PixelFromSAN(SAN1, "White")
    coord2 := PixelFromSAN(SAN2, "White")
    ;MouseMove, coord1[1], coord1[2]
    ;MouseMove, coord2[1], coord2[2]
    MouseClickDrag, Left, coord1[1], coord1[2], coord2[1], coord2[2], 1
  }
}

^i::
unnamed_opening := "D2,D4 C1,F4 E2,E3 G1,F3 F1,D3"
MousePreMoveSANString(unnamed_opening)
Return

^t::
; global bl = Array(208, 576)
; global tr = Array(492, 289)
; MouseMove, coord[1], coord[2]

Loop, parse, SAN_map, `
{
  Loop, 8
  {
    SAN := A_LoopField A_Index
    ; msgbox, %A_LoopField%
    ; msgbox, %A_Index%
    coord := PixelFromSAN(SAN, "White")
    MouseMove, coord[1], coord[2]
    sleep, 1
  }
}

; MsgBoxTuple(coord, "coord")
Return

; Get coordinates of centerpoint of bottom left square
^+l::
MouseGetPos, bl_x, bl_y
global bl := Array(bl_x, bl_y)

PixelGetColor, bl_color, bl[0], bl[1]
SoundBeep

Return


; Get coordinates of centerpoint of top right square
^+r::
MouseGetPos, tr_x, tr_y
global tr := Array(tr_x, tr_y)

PixelGetColor, tr_color, tr[1], tr[2]
SoundBeep
Return


#+r::
WinGetActiveTitle, active_title
if InStr(active_title, "MINGW"){
Send, {esc}:w{enter}
Sleep, 50
}

Reload
Return
