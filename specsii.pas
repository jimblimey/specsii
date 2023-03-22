program specscii;
{$mode objfpc}{$H+}
uses Classes, SysUtils;

var
  om: Array of Array of String;
  stc: String;
  ltc: Integer;
{$I specfont.inc}

function GetBit(a: Byte; b: Byte): Byte;
begin
  Result := (a shr b) and 1;
end;

procedure RenderCharacter(o: Integer; gdata: Array of Byte; ch: String);
  procedure PlotRow(l: Integer; t: Integer; d: Byte; c: String);
  var
    z, x1, y1: Integer;
  begin
    for z := 0 to 7 do
    begin
      if GetBit(d,7-z) = 1 then
      begin
        x1 := l+z;
        y1 := t;
        if x1 < ltc then om[x1,y1] := c;
      end
      else
      begin
        x1 := l+z;
        y1 := t;
        if x1 < ltc then om[x1,y1] := ' '
      end;
    end;
  end;
var
  c,l,t: Integer;
  z: Integer;
begin
  z := 0;
  l := o*8;
  t := 0;
  for c := 0 to 7 do
  begin
    PlotRow(l, t+c, gdata[z+c], ch);
  end;
  inc(z,8);
end;

procedure PrintString(s: String; ch: String);
var
  i,j: Integer;
begin
  
  for i := 1 to Length(s) do
  begin
    RenderCharacter(i-1,ZXFont[Ord(s[i])],ch);
  end;
  
  for j := 0 to 7 do
  begin
    for i := 0 to ltc do
    begin
      write(om[i,j]);
    end;
    writeln;
  end;
end;

begin
  if ParamStr(1) = '' then exit;
  stc := ParamStr(1);
  ltc := Length(stc)*8;
  SetLength(om,ltc+1,8);
  PrintString(stc,'@');
  Writeln();
end.

