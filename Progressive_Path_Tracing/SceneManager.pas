{-------------------------------------------------- Progressive Path Tracing ---------------------------------------------------

This unit is responsible for reading a scene file, loading all the primitives and materials in memory, and providing methods to
access the scene - in particular a method which takes as a parameter a ray and a wavelength, and returns whether the ray gets
absorbed by a primitive with a light material. This method is probabilistic, and the average of successive samples converge
towards the correct result.

-------------------------------------------------------------------------------------------------------------------------------}

unit SceneManager;

interface

uses Windows, SysUtils, Classes, VectorMath, VectorTypes, MaterialTypes, Utils, Math, PRNG;

const
 { This small number is used to make sure rays collide properly. Floating-point inaccuracies means that when a ray collides with
   a surface, the collision point may be right behind the surface, and if the ray is reflected, it will immediately bounce back
   into the surface which is incorrect, so we account for this by moving the intersection point slightly forward or backward,
   depending on whether reflection or refraction is occuring. }
 SELF_INTERSECTION_EPSILON = 1e-7;

type
 TSceneManager = class
 private
  FDepth: Longword;
  FPRNG: array of TPRNG;
  FPrimitives: array of TPrimitive;
  FMaterials: array of TMaterial;
  function FirstIntersection(Ray: TRay; var Primitive: Longword): Double;
 public
  constructor Create(ADepth, AWorkerCount: Longword; Scene: Pointer); reintroduce;
  destructor Destroy; override;
  function Raytrace(Ray: TRay; Wavelength, Worker: Longword): Boolean;
 end;

 PSceneManager = ^TSceneManager;

implementation

{ Loads the scene pointed at by Scene. }
constructor TSceneManager.Create(ADepth, AWorkerCount: Longword; Scene: Pointer);
Var
 I: Integer;
 PrimitiveType, Len: Longword;
begin
 { Set some members. }
 FDepth := ADepth;
 SetLength(FPRNG, AWorkerCount);
 for I := 0 to High(FPRNG) do FPRNG[I] := TPRNG.Create(GetWorkerSeed(I));

 { Read the number of primitives and materials from the scene. }
 SetLength(FPrimitives, PLongword(Scene)^); IncPtr(Scene, SizeOf(Longword));
 SetLength(FMaterials, PLongword(Scene)^); IncPtr(Scene, SizeOf(Longword));

 { Walk through the stream, loading each primitive. }
 for I := 0 to High(FPrimitives) do
  begin
   { Read the primitive's data length. }
   Len := PLongword(Scene)^;
   IncPtr(Scene, SizeOf(Longword));

   { Read the primitive type, and create the primitive accordingly. }
   PrimitiveType := PLongword(Scene)^;
   IncPtr(Scene, SizeOf(Longword));
   case PrimitiveType of
    0: FPrimitives[I] := TSphere.Create(Scene);
    1: FPrimitives[I] := TPlane.Create(Scene);
    2: FPrimitives[I] := TTriangle.Create(Scene);
   end;

   { Increment the pointer to the next primitive. }
   IncPtr(Scene, Len);
  end;

 { Walk through the stream, loading each material. }
 for I := 0 to High(FMaterials) do
  begin
   { Copy the material from the stream, and increment the pointer. }
   CopyMemory(@FMaterials[I], Scene, SizeOf(TMaterial));
   IncPtr(Scene, SizeOf(TMaterial));
  end;
end;

{ Releases all memory taken up by the primitives and materials. }
destructor TSceneManager.Destroy;
Var
 I: Integer;
begin
 { Release all primitives and PRNG classes. }
 for I := 0 to High(FPrimitives) do FPrimitives[I].Free;
 for I := 0 to High(FPRNG) do FPRNG[I].Free;
 inherited;
end;

{ Finds the first intersection of the given ray with the scene. }
function TSceneManager.FirstIntersection(Ray: TRay; var Primitive: Longword): Double;
Var
 Distance: Double;
 I: Integer;
begin
 Result := -1;

 { Iterate over all primitives. }
 for I := 0 to High(FPrimitives) do
  begin
   { Calculate the distance to this primitive. }
   Distance := FPrimitives[I].Intersects(Ray);

   { If it is greater than zero and less than the current closest distance, use it. }
   if (Distance < Result) and (Distance > 0) then
    begin
     Result := Distance;
     Primitive := I;
     Continue;
    end;

    { If the current closest distance is less than zero, use it. }
   if (Result < 0) then
    begin
     Result := Distance;
     Primitive := I;
    end;
  end;
end;

{ Raytrace a ray of a given wavelength, by a given worker. }
function TSceneManager.Raytrace(Ray: TRay; Wavelength, Worker: Longword): Boolean;
Var
 Distance: Double;
 Primitive: Longword;
 R, Ni, CosI, CosT: Double;
 Iteration: Integer;
 Normal: TVector;
begin
 { Raytracing is done using a modified Russian Roulette algorithm - after an intersection is found, the ray is checked for
   absorption - if it is absorbed, the process is stopped here (and it is returned either true or false depending on whether
   the ray got absorbed by some ordinary primitive or by a light). If the ray doesn't get absorbed, then it either gets
   reflected or refracted, according to the Fresnel Equations (nonrefractive materials are defined as those with a refractive
   index of 0. The decision of whether a ray is absorbed, refracted or reflected, is a random choice based on the probabilities
   of each event happening - this is why a ray will eventually get absorbed in most cases. For those cases where a ray can get
   stuck, we introduce a maximum depth limit, which limits the number of times a ray can be reflected or refracted - if it
   exceeds this depth limit, it is automatically discarded and assumed to be "eventually absorbed" (not by a light). }

 Result := False;

 { Repeat this operation until the maximum depth is attained. }
 for Iteration := 0 to FDepth - 1 do
  begin
   { Find the first intersection with the scene. }
   Distance := FirstIntersection(Ray, Primitive);

   { If there is no intersection with the scene, return False. }
   if (Distance < 0) then Exit;
   
   { For convenience we reference the primitive's material in a with clause. }
   with FMaterials[FPrimitives[Primitive].Material] do
    begin
     { Calculate the normal at the intersecting primitive. Note that we cannot reuse the intersection point here because of
       the self-intersection problem, we need to be able to offset the point slightly to avoid having the ray immediately
       reintersect the same primitive at the next iteration. And this offset can be either backwards or forwards depending
       on whether the ray is reflected or refracted. }
     Normal := FPrimitives[Primitive].NormalAt(AddVector(MulVector(Ray.Direction, Distance), Ray.Origin));

     { Check whether the intersecting primitive absorbs the ray. }
     if (FPRNG[Worker].random >= AbsorptionSpectrum[Wavelength]) then
      begin
       { If the primitive is a light, return True, otherwise return False. }
       Result := IsLight;
       { If light, check the light's dot product, as area lights don't emit the same amount of light in all directions. }
       if Result then Result := (FPRNG[Worker].random < Max(-DotVector(Normal, Ray.Direction), 0));
       Exit;
      end;

     { The ray didn't get absorbed, we now check for reflection or refraction. The probability of a ray being reflected depends
       on the Fresnel equations, which in turn depend on the incident ray, the surface normal and the refraction index.        }
     R := Fresnel(Ray.Direction, Normal, RefractionIndices[Wavelength], Ni, CosI, CosT);

     { We now perform a random trial to decide whether to reflect or to refract the ray. }
     if (FPRNG[Worker].random <= R) then
      begin
       { It got reflected, so place the new ray's origin slightly outside the primitive and get the new direction. }
       Ray.Origin := AddVector(MulVector(Ray.Direction, Distance - SELF_INTERSECTION_EPSILON), Ray.Origin);
       if (FPRNG[Worker].random < Specularity) then Ray.Direction := NormalizeVector(ReflectVector(Ray.Direction, Normal)) else
        begin
         Ray.Direction := NormalizeVector(Vector(FPRNG[Worker].random - FPRNG[Worker].random, FPRNG[Worker].random - FPRNG[Worker].random, FPRNG[Worker].random - FPRNG[Worker].random));
         if DotVector(Ray.Direction, Normal) < 0 then Ray.Direction := MulVector(Ray.Direction, -1);
        end;
      end
     else
      begin
       { It got refracted, move the ray's origin slightly inside the primitive and compute the new direction. }
       Ray.Origin := AddVector(MulVector(Ray.Direction, Distance + SELF_INTERSECTION_EPSILON), Ray.Origin);
       Ray.Direction := RefractVector(Ray.Direction, Normal, Ni, CosI, CosT);
      end;
    end;
  end;
end;

end.
