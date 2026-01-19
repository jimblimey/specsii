program specscii;
{$mode objfpc}{$H+}
uses Classes, SysUtils;

var
  i: Integer;
  outchar: String = '@';
  om: Array of Array of String;
  stc: String;
  ltc: Integer;
  CustomFont: array[32..127,0..7] of Byte;
  fontfile: String;
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
    if fontfile = '' then RenderCharacter(i-1,ZXFont[Ord(s[i])],ch)
    else RenderCharacter(i-1,CustomFont[Ord(s[i])],ch)
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

procedure LoadFontFile(const fn: String);
var
  fs: TFileStream;
  buf: array[0..767] of Byte;
  i, ch, row: Integer;
begin
  fs := TFileStream.Create(fn, fmOpenRead);
  if fs.Read(buf, 768) <> 768 then
  begin
    writeln('Invalid font file?');
    exit;
  end;

  i := 0;
  for ch := 32 to 127 do
    for row := 0 to 7 do
    begin
      CustomFont[ch, row] := buf[i];
      Inc(i);
    end;

  fs.Free;
end;

begin
  if ParamCount = 0 then Exit;
  
  fontfile := '';
  i := 1;
  while i <= ParamCount do
  begin
    if ParamStr(i).StartsWith('--char=') then
      outchar := Copy(ParamStr(i), 8, 999)
    else if ParamStr(i).StartsWith('--font=') then
      fontfile := Copy(ParamStr(i), 8, 999)
    else if stc = '' then
      stc := ParamStr(i);
    Inc(i);
  end;
  
  if fontfile <> '' then
  begin
    if not FileExists(fontfile) then
    begin
      writeln('Error: font file not found!');
      exit;
    end
    else LoadFontFile(fontfile);
  end;

  if stc = '' then Halt;

  ltc := Length(stc) * 8;
  SetLength(om, ltc + 1, 8);
  PrintString(stc, outchar);
end.

