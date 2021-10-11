{-------------------------------------------------- Progressive Path Tracing ---------------------------------------------------

This unit contains vector math functions, such as vector addition, multiplication, dot and cross products, and other, more
specialized functions such as vector reflection according to a normal, and calculation of the Fresnel term for an incident
and normal vector.

-------------------------------------------------------------------------------------------------------------------------------}

unit VectorMath;

interface

uses Math, VectorTypes;

{ Standard vector functions. }
function AddVector(const A, B: TVector): TVector;
function SubVector(const A, B: TVector): TVector;
function MulVector(const A: TVector; const B: Double): TVector;
function DivVector(const A: TVector; const B: Double): TVector;
function NormalizeVector(const A: TVector): TVector;
function LengthVector(const A: TVector): Double;
function DotVector(const A, B: TVector): Double;
function SelfDotVector(const A: TVector): Double;
function CrossVector(const A, B: TVector): TVector;
function LerpVector(const A, B: TVector; T: Double): TVector;

{ Miscellaneous vector functions. }
function ReflectVector(I: TVector; N: TVector): TVector;
function Fresnel(I: TVector; N: TVector; R: Double; var Ni, CosI, CosT: Double): Double;
function RefractVector(I: TVector; N: TVector; Ni, CosI, CosT: Double): TVector;

implementation

{ Adds two vectors together, and returns the result. }
function AddVector(const A, B: TVector): TVector;
begin
 Result.X := A.X + B.X;
 Result.Y := A.Y + B.Y;
 Result.Z := A.Z + B.Z;
end;

{ Subtracts two vectors, and returns the result. }
function SubVector(const A, B: TVector): TVector;
begin
 Result.X := A.X - B.X;
 Result.Y := A.Y - B.Y;
 Result.Z := A.Z - B.Z;
end;

{ Multiplies two vectors together, and returns the result. }
function MulVector(const A: TVector; const B: Double): TVector;
begin
 Result.X := A.X * B;
 Result.Y := A.Y * B;
 Result.Z := A.Z * B;
end;

{ Divides two vectors, and returns the result. }
function DivVector(const A: TVector; const B: Double): TVector;
begin
 Result := MulVector(A, 1 / B);
end;

{ Returns the length of a vector. }
function LengthVector(const A: TVector): Double;
begin
 Result := Sqrt(SelfDotVector(A));
end;

{ Normalizes a vector, and returns the result. }
function NormalizeVector(const A: TVector): TVector;
Var
 L: Double;
begin
 L := LengthVector(A);
 if Abs(L) < 0.000001 then Result := Vector(0, 0, 0) else Result := DivVector(A, L);
end;

{ Returns the dot product of two vectors. }
function DotVector(const A, B: TVector): Double;
begin
 Result := A.X * B.X + A.Y * B.Y + A.Z * B.Z;
end;

{ Returns the dot product of a vector with itself (which is equal to its length squared). }
function SelfDotVector(const A: TVector): Double;
begin
 Result := A.X * A.X + A.Y * A.Y + A.Z * A.Z;
end;

{ Returns the cross product of two vectors. }
function CrossVector(const A, B: TVector): TVector;
begin
 Result.X := A.Y * B.Z - A.Z * B.Y;
 Result.Y := A.Z * B.X - A.X * B.Z;
 Result.Z := A.X * B.Y - A.Y * B.X;
end;

{ Linearly interpolates two vectors together. }
function LerpVector(const A, B: TVector; T: Double): TVector;
begin
 Result := AddVector(A, MulVector(SubVector(B, A), T));
end;

{ Reflects an incident vector against a normal vector, and returns the result. }
function ReflectVector(I: TVector; N: TVector): TVector;
Var
 D: Double;
begin
 D := DotVector(I, N);
 if D > 0 then N := MulVector(N, -1);
 Result := SubVector(I, MulVector(N, 2 * D));
end;

{ Computes the Fresnel term for an incident ray and a normal vector, and a refraction index. }
function Fresnel(I: TVector; N: TVector; R: Double; var Ni, CosI, CosT: Double): Double;
Var
 N1, N2: Double;
 SinT2, rOrth, rPar: Double;
begin
 if R = 0 then begin Result := 1; Exit; end;

 { First invert the refraction index depending on whether the ray is entering or leaving the medium (it is assumed surface
   normals always point outwards of the volume. }
 if DotVector(I, N) > 0 then
  begin
   N1 := R;
   N2 := 1;
   N := MulVector(N, -1);
  end
 else
  begin
   N1 := 1;
   N2 := R;
  end;

 { At this point we have I and N in opposite directions, N1 the "before" refraction index and N2 the "after" refraction index. }
 Ni := N1 / N2;
 CosI := -DotVector(N, I);
 SinT2 := Ni * Ni * (1 - CosI * CosI);
 if (SinT2 > 1) then Result := 1 else
  begin
   CosT := Sqrt(1 - SinT2);
   rOrth := (N1 * CosI - N2 * CosT) / (N1 * CosI + N2 * CosT);
   rPar := (N2 * CosI - N1 * CosT) / (N2 * CosI + N1 * CosT);
   Result := (rOrth * rOrth  + rPar * rPar) * 0.5;
  end;
end;

{ Performs vector refraction according to an incident ray, a normal vector and a refraction index. Essentially all calculations
  used in refraction can be recycled from the Fresnel Equations, which is why refraction is very simple in this case.          }
function RefractVector(I: TVector; N: TVector; Ni, CosI, CosT: Double): TVector;
begin
 Result := NormalizeVector(AddVector(MulVector(I, Ni), MulVector(N, Ni * CosI - CosT)));
end;

end.
