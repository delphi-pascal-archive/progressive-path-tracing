{-------------------------------------------------- Progressive Path Tracing ---------------------------------------------------

This unit implements a camera, which takes as a parameter a camera position and a camera target, and allows one to project the
scene as viewed from the camera's point of view onto a 2D plane. Since this class is the only one which requires matrix math,
the matrix code has been merged into this unit for convenience.

-------------------------------------------------------------------------------------------------------------------------------}

unit Camera;

interface

uses VectorTypes, VectorMath, Math;

type
 TMatrix = array [0..3, 0..3] of Double;

 TCamera = class
 private
  FCameraPosition: TVector;
  FInverseViewMatrix: TMatrix;
  FCorners: array [0..3] of TVector;
 public
  constructor Create(ACameraPosition, ACameraTarget: TVector; AspectRatio: Double); reintroduce;
  function TraceCameraRay(U, V: Double): TRay;
 end;

 PCamera = ^TCamera;

implementation

{ Multiplication of a matrix with a vector (returns a vector). }
function MulMatrix(A: TMatrix; B: TVector): TVector;
begin
 Result.X := A[0, 0] * B.X + A[1, 0] * B.Y + A[2, 0] * B.Z + A[3, 0];
 Result.Y := A[0, 1] * B.X + A[1, 1] * B.Y + A[2, 1] * B.Z + A[3, 1];
 Result.Z := A[0, 2] * B.X + A[1, 2] * B.Y + A[2, 2] * B.Z + A[3, 2];
 // W        := A[0, 3] * B.X + A[1, 3] * B.Y + A[2, 3] * B.Z + A[3, 3]; // perspective division redundant because of ray normalization
end;

{ This function creates an orthogonal view matrix, using a position point and a target vector. }
function LookAt(Position, Target: TVector): TMatrix;
Var
 Up, XAxis, YAxis, ZAxis: TVector;
begin
 { Create the Up vector. }
 Up := NormalizeVector(CrossVector(CrossVector(SubVector(Target, Position), Vector(0, 1, 0)), SubVector(Target, Position)));

 { Create the rotation axis basis. }
 zAxis := NormalizeVector(SubVector(Target, Position));
 xAxis := NormalizeVector(CrossVector(Up, zAxis));
 yAxis := NormalizeVector(CrossVector(zAxis, xAxis));

 { Build the matrix from those vectors. }
 Result[0][0] := xAxis.X;
 Result[0][1] := xAxis.Y;
 Result[0][2] := xAxis.Z;
 Result[0][3] := -DotVector(xAxis, Position);
 Result[1][0] := yAxis.X;
 Result[1][1] := yAxis.Y;
 Result[1][2] := yAxis.Z;
 Result[1][3] := -DotVector(yAxis, Position);
 Result[2][0] := zAxis.X;
 Result[2][1] := zAxis.Y;
 Result[2][2] := zAxis.Z;
 Result[2][3] := -DotVector(zAxis, Position);
 Result[3][0] := 0;
 Result[3][1] := 0;
 Result[3][2] := 0;
 Result[3][3] := 1;
end;

{ Creates the camera, taking into account the camera position, target and aspect ratio. }
constructor TCamera.Create(ACameraPosition, ACameraTarget: TVector; AspectRatio: Double);
begin
 { Create the matrix. }
 inherited Create;
 FCameraPosition := ACameraPosition;
 FInverseViewMatrix := LookAt(FCameraPosition, ACameraTarget);

 { Find the corner points (all the others can be interpolated with a bilinear interpolation). }
 FCorners[0] := MulMatrix(FInverseViewMatrix, Vector(-(-1) * AspectRatio, (-1), 1));
 FCorners[1] := MulMatrix(FInverseViewMatrix, Vector(-(+1) * AspectRatio, (-1), 1));
 FCorners[2] := MulMatrix(FInverseViewMatrix, Vector(-(+1) * AspectRatio, (+1), 1));
 FCorners[3] := MulMatrix(FInverseViewMatrix, Vector(-(-1) * AspectRatio, (+1), 1));
end;

{ Returns the camera ray going through the pixel at U, V. }
function TCamera.TraceCameraRay(U, V: Double): TRay;
begin
 { Interpolate the focal plane point and trace the ray from it. }
 Result.Direction := NormalizeVector(LerpVector(LerpVector(FCorners[0], FCorners[1], U), LerpVector(FCorners[3], FCorners[2], U), V));
 Result.Origin := FCameraPosition;
end;

end.
