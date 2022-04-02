#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
; Should I explicitely set CoordMode or just let default settings figure it out?
; Usage:
; control-shift-L: Set the current mouse position as the bottom left corner of the board
; control-shift-R: Set the current mouse position as the top right corner of the board
;
; control-i: the next four keys you type, within ten seconds, will be interpreted as a SAN
;   coordinate. The mouse will move from the first to the second coordinate.
; control-t: run through a test
; control-u: Run a premove example

; Constants declaration
global SAN_map := "ABCDEFGH"
SendMode Event


^i::
SoundBeep
; some random predefined coords that seem to work
bl_local := Array(800, 500)
tr_local := Array(1000, 300)

; L4 -- Stop reading input after 4 keystrokes (a full SAN command)
; T10 -- timeout after 1= seconds
; inputbox could also be good here
Input, user_input_SAN, L4 T10

; ErrorLevel = "Max" means the maximum number of characters is reached
if (ErrorLevel = "Max" & IsValidSAN(user_input_SAN))
{
  MousePreMoveSANString(user_input_SAN, bl_local, tr_local, player_color:="white", no_click:=True, speed:=2)
  msgbox, %user_input_SAN%
}
else
{
  MsgBox, "Something went wrong"
}
SoundBeep
sleep, 50
SoundBeep
Return


^u::
unnamed_opening := "D2D4 C1F4 E2E3 G1F3 F1D3"
MousePreMoveSANString(unnamed_opening, bl, tr, player_color:="white", no_click:=True, speed:=2)
Return

; A simple test to loop through all 64 board positions
^t::
bl_local := Array(800, 500)
tr_local := Array(1000, 300)
Loop, parse, SAN_map, `
{
  Loop, 8
  {
    SAN := A_LoopField A_Index
    ; msgbox, %A_LoopField%
    ; msgbox, %A_Index%
    coord := PixelFromSAN(SAN, bl_local, tr_local, "White")
    MouseMove, coord[1], coord[2], 0
    ;sleep, 1
  }
}


PixelFromSAN(SAN, bl_input, tr_input, player_color:="White"){
  ; Output the pixel location of a chess coordinate in SAN format
  ; (SAN could be for example "B1C3" for a knight)

  ; Check if a valid SAN
  if !(IsValidSAN(SAN))
  {
    Return Array(-1, -1)
  }

  ; Extract the row and collumn into their own variables (character & nummber)
  SAN_char := SubStr(SAN, 1, 1)
  SAN_num  := SubStr(SAN, 2, 1)

  ; Get the number of squares we need to move from the sides
  ; num of blocks in x direction is the characters location in the base san string
  x_blocks := InStr(SAN_map, SAN_char, CaseSensitive:=False) - 1
  y_blocks := SAN_num - 1

  ; Get size of each block
  x_block_size := Abs(bl_input[1] - tr_input[1]) / 7
  y_block_size := Abs(bl_input[2] - tr_input[2]) / 7

  ; Compute the actual pixel to go to, assuming white player
  if ((InStr(player_color, "W", CaseSensitive:=False)) != 0){
    right_dist := x_blocks * x_block_size
    up_dist    := y_blocks * y_block_size

    x_coord := bl_input[1] + right_dist
    y_coord := bl_input[2] - up_dist

    return Array(x_coord, y_coord)
  }

  if (InStr(player_color, "B", CaseSensitive:=False)){
    ; haven't programmed black yet
  }

  ; If neither black nor white work, just return bottom left coord
  Return Array(-1, -1)
}

IsValidSAN(SAN)
{
; Use RegExMatch()
return True
}

; Simple way to view coordinates. 'Msgbox, % array' just doesn't work
MsgBoxTuple(coord, name := ""){
  MsgBox, % name . "  x:" . coord[1] . "  y:" . coord[2]
}

MousePreMoveSANString(SAN_string, bl_input, tr_input, player_color := "White", no_click:=False, speed:=1){
  ; Going one pair at a time (pairs separated by spaces, coords sep. by commas)
  ; Convert the SAN value to a coordinate and move the mouse from A to B
  Loop, Parse, SAN_string, %A_Space%
  {
    SAN_pair = %A_LoopField%
    SAN1 := SubStr(SAN_pair, 1, 2)
    SAN2 := SubStr(SAN_pair, 3, 4)
    coord1 := PixelFromSAN(SAN1, bl_input, tr_input, player_color)
    coord2 := PixelFromSAN(SAN2, bl_input, tr_input, player_color)

    ; Provide option to just move the mouse for testing
    if (no_click)
    {
      MouseMove, coord1[1], coord1[2], speed
      MouseMove, coord2[1], coord2[2], speed
    }else{
      MouseClickDrag, Left, coord1[1], coord1[2], coord2[1], coord2[2], speed
    }
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
; reload, and if you're in git bash also write the vim file
WinGetActiveTitle, active_title
if InStr(active_title, "MINGW"){
Send, {esc}:w{enter}
Sleep, 50
}

Reload
Return


; Testing ability to save a default pixel location by saving/ reading
; from the end of the actual code file (AutoChess.ahk)
; 800,500,1000,300
; test
