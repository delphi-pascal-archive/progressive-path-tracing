{-------------------------------------------------- Progressive Path Tracing ---------------------------------------------------

This unit contains the TMaterial type and also contains helper functions related to spectral conversion, such as converting a
wavelength to an RGB color. It also contains functions to manipulate RGB color, such as adding two colors together. Spectrums
are coded over 400 indices, going from ultraviolet to infrared.

-------------------------------------------------------------------------------------------------------------------------------}

unit MaterialTypes;

interface

uses Windows, SysUtils, Graphics, Math;

type
 { Just a RGB color type. }
 TRGBColor = record
  R, G, B: Single;
 end; PRGBColor = ^TRGBColor;

 TMaterial = record
  AbsorptionSpectrum: array [0..399] of Double;
  RefractionIndices: array [0..399] of Double;
  Specularity: Double;
  IsLight: Boolean;
 end;

{ Adds two colors together. }
function AddColor(const A, B: TRGBColor): TRGBColor;

Var
 { This is the spectrum variable which matches a wavelength with its RGB color equivalent. }
 Spectrum: array [0..399] of TRGBColor;

implementation

{ Adds two colors together. }
function AddColor(const A, B: TRGBColor): TRGBColor;
begin
 Result.R := A.R + B.R;
 Result.G := A.G + B.G;
 Result.B := A.B + B.B;
end;

{ Procedure called at the beginning of the program, loads the Spectrum.bmp bitmap into memory in FP format. }
procedure LoadSpectrum;
Var
 Bmp: TBitmap;
 P: PRGBQUAD;
 I: Integer;
begin
 Bmp := TBitmap.Create;
 Bmp.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'Spectrum.bmp');
 P := Bmp.Scanline[0];
 for I := 0 to 399 do
  with Spectrum[I] do
   begin
    R := P^.rgbRed / 255 * 1 / Sqrt(2 * PI);
    G := P^.rgbGreen / 255 * 1 / Sqrt(2 * PI);
    B := P^.rgbBlue / 255 * 1 / Sqrt(2 * PI);
    Inc(P);
   end;
 Bmp.Free;
end;

initialization
 LoadSpectrum;

end.
