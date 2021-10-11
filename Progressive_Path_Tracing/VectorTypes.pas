{-------------------------------------------------- Progressive Path Tracing ---------------------------------------------------

This unit contains types for a vector (TVector), a ray (TRay), and all the implemented geometric primitives, as descendants of
the TPrimitive class. Those classes must expose three methods - an Intersect method which returns the distance along the ray
passed as a parameter at which an intersection with said primitive occurs (the result is negative if no intersection exists),
a NormalAt function which returns the surface normal at a given point (this point is guaranteed to be located on the primitive
if and only if the primitive's Intersect function is accurate), and a constructor which takes as an input a pointer, which
points to a memory range containing the primitive's description (for instance, a sphere would read its center and radius).
Primitives must remember to call their inherited constructor at the end of their own constructor, passing an appropriately
incremented pointer (that is, pointing to just after the memory range containing the primitive's information. This is to read
the primitive's material. Primitive constructors can choose to read it themselves if they wish to, however (it's a Longword).

-------------------------------------------------------------------------------------------------------------------------------}

unit VectorTypes;

interface

uses SysUtils, Math;

type
 { Defines a 3D vector. }
 TVector = record
  X, Y, Z: Double;
 end; PVector = ^TVector;

 { Defines a ray. }
 TRay = record
  Origin, Direction: TVector;
 end; PRay = ^TRay;

{ Helper function declarations. }
function Vector(const X, Y, Z: Double): TVector;
function RayBetween(const P1, P2: TVector): TRay;

type
 { The base primitive class. }
 TPrimitive = class
 private
  FMaterial: Longword;
 public
  constructor Create(Data: Pointer); virtual;
  function Intersects(Ray: TRay): Double; virtual; abstract;
  function NormalAt(Point: TVector): TVector; virtual; abstract;
  property Material: Longword read FMaterial;
 end;

 { A sphere primitive. }
 TSphere = class(TPrimitive)
 private
  FCenter: TVector;
  FRadius: Double;
  FRadiusSquared: Double;
 public
  constructor Create(Data: Pointer); override;
  function Intersects(Ray: TRay): Double; override;
  function NormalAt(Point: TVector): TVector; override;
  property Center: TVector read FCenter;
  property Radius: Double read FRadius;
 end;

 { A plane primitive. }
 TPlane = class(TPrimitive)
 private
  FNormal, FPoint: TVector;
 public
  constructor Create(Data: Pointer); override;
  function Intersects(Ray: TRay): Double; override;
  function NormalAt(Point: TVector): TVector; override;
  property Normal: TVector read FNormal;
  property Point: TVector read FPoint;
 end;

 { A triangle primitive. }
 TTriangle = class(TPrimitive)
 private
  FPoints: array [0..2] of TVector;
  FNormal: TVector;
  FE1, FE2: TVector;
  function GetPoints(Index: Integer): TVector;
 public
  constructor Create(Data: Pointer); override;
  function Intersects(Ray: TRay): Double; override;
  function NormalAt(Point: TVector): TVector; override;
  property Points[Index: Integer]: TVector read GetPoints;
 end;

implementation

uses VectorMath;

{ Converts a triplet of (x, y, z) coordinates into a TVector record. }
function Vector(const X, Y, Z: Double): TVector;
begin
 Result.X := X;
 Result.Y := Y;
 Result.Z := Z;
end;

{ Returns a normalized ray starting at P1 and going through P2. }
function RayBetween(const P1, P2: TVector): TRay;
begin
 Result.Origin := P1;
 Result.Direction := NormalizeVector(SubVector(P2, P1));
end;

{ -------------------------------------------------------- PRIMITIVE --------------------------------------------------------- }

constructor TPrimitive.Create(Data: Pointer);
begin
 { We just read the material indez. }
 FMaterial := PLongword(Data)^;
end;

{ ---------------------------------------------------------- SPHERE ---------------------------------------------------------- }

constructor TSphere.Create(Data: Pointer);
Var
 P: PDouble;
begin
 { A sphere is defined by a center and a radius, so we need to read 4 doubles from the scene data stream. }
 P := Data;
 FCenter.X := P^; Inc(P);
 FCenter.Y := P^; Inc(P);
 FCenter.Z := P^; Inc(P);
 FRadius := P^;   Inc(P);
 inherited Create(P);
 FRadiusSquared := FRadius * FRadius;
end;

function TSphere.Intersects(Ray: TRay): Double;
Var
 qA, qB, qC, Delta, P1, P2: Double;
begin
 { Transform the ray origin to sphere center. }
 Ray.Origin := SubVector(Ray.Origin, FCenter);

 { Compute the quadratic terms. }
 qA := SelfDotVector(Ray.Direction);
 qB := 2 * DotVector(Ray.Direction, Ray.Origin);
 qC := SelfDotVector(Ray.Origin) - FRadiusSquared;

 { Compute the discriminant. }
 Delta := qB * qB - 4 * qA * qC;

 { If there is no solution, return a negative number. }
 if (Delta < 0) then Result := -1 else
  begin
   { Otherwise, compute the two solutions, and decide which one to return. }
   Delta := Sqrt(Delta);
   qA := qA * 2;
   qB := -qB;
   P1 := (qB + Delta) / qA;
   P2 := (qB - Delta) / qA;

   if (P1 < 0) then begin Result := P2; Exit; end; // regardless since negative result = no intersection
   if (P2 < 0) then begin Result := P1; Exit; end; // regardless since negative result = no intersection
   Result := Min(P1, P2);
  end;
end;

function TSphere.NormalAt(Point: TVector): TVector;
begin
 { This one is easy, just take the vector from the sphere's center to the point and normalize. Note that since the sphere's
   intersection code is correct, we know that Point will always be located on the sphere. We can therefore take a shortcut
   and simply divide by the radius instead of going through the whole normalization process. }
 Result := DivVector(SubVector(Point, FCenter), FRadius);
end;

{ ---------------------------------------------------------- PLANE ----------------------------------------------------------- }

constructor TPlane.Create(Data: Pointer);
Var
 P: PDouble;
begin
 { A plane is defined by a point on the plane, and a normal vector. }
 P := Data;
 FNormal.X := P^; Inc(P);
 FNormal.Y := P^; Inc(P);
 FNormal.Z := P^; Inc(P);
 FPoint.X := P^;  Inc(P);
 FPoint.Y := P^;  Inc(P);
 FPoint.Z := P^;  Inc(P);
 inherited Create(P);
end;

function TPlane.Intersects(Ray: TRay): Double;
Var
 dn: Double;
begin
 { Compute the denominator. }
 dn := DotVector(Ray.Direction, FNormal);

 { If the denominator is dangerously close to zero, there is no intersection (means the ray is almost parallel to the plane). }
 if Abs(dn) < 0.0000001 then Result := -1 else
  begin
   { Compute the numerator and divide. }
   Result := DotVector(SubVector(FPoint, Ray.Origin), FNormal) / dn;
  end;
end;

function TPlane.NormalAt(Point: TVector): TVector;
begin
 { A plane is actually defined by its normal so there is no need to calculate it - it's given to us. }
 Result := FNormal;
end;

{ --------------------------------------------------------- TRIANGLE --------------------------------------------------------- }
constructor TTriangle.Create(Data: Pointer);
Var
 I: Longword;
 P: PDouble;
begin
 { A triangle is defined by three vectors representing the triangle's vertices. }
 P := Data;
 for I := 0 to 2 do
  begin
   FPoints[I].X := P^; Inc(P);
   FPoints[I].Y := P^; Inc(P);
   FPoints[I].Z := P^; Inc(P);
  end;

 { Call the inherited constructor). }
 inherited Create(P);

 { Precompute some values. }
 FE1 := SubVector(FPoints[1], FPoints[0]);
 FE2 := SubVector(FPoints[2], FPoints[0]);

 { The triangle's normal at any point is the cross product of (Point1 - Point0) and (Point2 - Point0). Note that this makes
   the order of the vertices important, as inverting two vertices will invert the normal too, this is known as winding. }
 FNormal := NormalizeVector(CrossVector(FE1, FE2));
end;

function TTriangle.GetPoints(Index: Integer): TVector;
begin
 Result := FPoints[Index];
end;

function TTriangle.Intersects(Ray: TRay): Double;
Var
 H, S, Q: TVector;
 A, U, V: Double;
begin
 { I tried to simplify and optimise a code found online. }
 { This code is NOT optimal for triangle intersection, because it involves a normalization to obtain the "t" parameter of the ray. }
 H := CrossVector(Ray.Direction, FE2);
 A := DotVector(H, FE1);

 if (Abs(A) < 0.00001) then Result := -1 else
  begin
   A := 1 / A;
   S := SubVector(Ray.Origin, FPoints[0]);
   U := A * DotVector(S, H);

   if (U < 0.0) or (U > 1) then Result := -1 else
    begin
     Q := CrossVector(S, FE1);
     V := A * DotVector(Ray.Direction, Q);

     { If both barycentric coordinates U, V are between 0 and 1, we use the barycentric formula to retrieve the intersection distance. }
     if (V < 0.0) or (U + V > 1.0) then Result := -1 else
      if (Abs(A * DotVector(FE2, Q)) < 0.00001) then Result := -1 else Result := LengthVector(SubVector(AddVector(AddVector(MulVector(FPoints[0], 1 - u - v), MulVector(FPoints[1], u)), MulVector(FPoints[2], v)), Ray.Origin));
    end;
  end;
end;

function TTriangle.NormalAt(Point: TVector): TVector;
begin
 { The normal has been precomputed since it is independent of the point's location. }
 Result := FNormal;
end;

end.
