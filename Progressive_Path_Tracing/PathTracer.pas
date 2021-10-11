{-------------------------------------------------- Progressive Path Tracing ---------------------------------------------------

This unit contains the TPathTracer class, which is the only class that directly interacts with the interface. It's responsible
for managing the worker threads and interfacing with all the other classes.

-------------------------------------------------------------------------------------------------------------------------------}

unit PathTracer;

interface

uses Windows, SysUtils, Classes, Graphics, VectorMath, VectorTypes, SceneManager, Utils, Math, Camera, MaterialTypes;

type
 { A global threadinfo structure sent to each worker thread. }
 TWorkerSettings = record
  PManager: PSceneManager;
  PCamera: PCamera;
  PData: Pointer;
  PFlag: Pointer;
  PSampleCount: Pointer;
  DataLength: Longword;
  Width, Height, Stride, Batch: Longword;
 end;

 { A worker thread, responsible for tracing rays over and over until hell freezes over (or the user gets bored). }
 TWorkerThread = class(TThread)
 private
  FWorkerSettings: TWorkerSettings;
  FWorkerIndex: Longword;
 public
  constructor Create(CreateSuspended: Boolean; AWorkerSettings: TWorkerSettings; AWorkerIndex: Longword); reintroduce;
  destructor Destroy; override;
  procedure Execute; override;
 end;

 { The main class which controls everything indirectly. }
 TPathTracer = class
 private
  FSamples: Double;
  FWidth, FHeight: Longword;
  FManager: TSceneManager;
  FCamera: TCamera;
  FWorkers: array of TWorkerThread;
  FData: array of TRGBColor;
  FSampleCount: array of Longword;
  FWorkerFlags: array of Boolean;
  function GetSuspended: Boolean;
 public
  constructor Create(CreateSuspended: Boolean; WorkerCount, Depth, BatchSize, Width, Height: Longword; SceneFile: String); reintroduce;
  destructor Destroy; override;
  procedure Acquire(Bitmap: TBitmap);
  procedure Suspend;
  procedure Resume;
  property SampleCount: Double read FSamples;
  property Suspended: Boolean read GetSuspended;
 end;

implementation

constructor TWorkerThread.Create(CreateSuspended: Boolean; AWorkerSettings: TWorkerSettings; AWorkerIndex: Longword);
begin
 { Set some members. }
 inherited Create(CreateSuspended);
 FreeOnTerminate := True;
 Priority := tpLowest;
 FWorkerIndex := AWorkerIndex;
 FWorkerSettings := AWorkerSettings;
end;

destructor TWorkerThread.Destroy;
begin
 { Indicate the thread died by setting its flag to true. }
 PBoolean(Ptr(Longword(FWorkerSettings.PFlag) + FWorkerIndex))^ := True;
 inherited;
end;

procedure TWorkerThread.Execute;
Var
 I, J: Integer;
 N: Longword;
 U, V: Double;
 P: PRGBColor;
 Ray: TRay;
begin
 { Set the first pixel. }
 N := FWorkerIndex;

 { Iterate over all the pixels one by one. }
 repeat
  { Retrieve the correct camera ray. }
  U := (N mod FWorkerSettings.Width) / (FWorkerSettings.Width - 1);
  V := (N div FWorkerSettings.Height) / (FWorkerSettings.Height - 1);
  Ray := FWorkerSettings.PCamera^.TraceCameraRay(1 - U, V);

  { Add a sample for this pixel. }
  for J := 0 to FWorkerSettings.Batch - 1 do
  for I := 0 to 399 do
   if FWorkerSettings.PManager^.Raytrace(Ray, I, FWorkerIndex) then
    begin
     P := PRGBColor(Ptr(Longword(FWorkerSettings.PData) + N * SizeOf(TRGBColor)));
     P^ := AddColor(P^, Spectrum[I]);
    end;

  { Increment the sample count. }
  Inc(PLongword(Ptr(Longword(FWorkerSettings.PSampleCount) + N * SizeOf(Longword)))^, FWorkerSettings.Batch);

  { Go to the next pixel. }
  Inc(N, FWorkerSettings.Stride);
  if N >= FWorkerSettings.Width * FWorkerSettings.Height then N := FWorkerIndex;
 until Terminated;
end;

constructor TPathTracer.Create(CreateSuspended: Boolean; WorkerCount, Depth, BatchSize, Width, Height: Longword; SceneFile: String);
Var
 I: Integer;
 H, M, Len: Longword;
 P: Pointer;
 WorkerSettings: TWorkerSettings;
begin
 { Set some members. }
 inherited Create;
 FSamples := NaN;
 FWidth := Width;
 FHeight := Height;
 SetLength(FWorkers, WorkerCount);
 SetLength(FWorkerFlags, WorkerCount);
 ZeroMemory(@FWorkerFlags[0], WorkerCount);

 { Open the scene file and read the camera position and target at the beginning. }
 P := MapFile(SceneFile, H, M, Len);
 FCamera := TCamera.Create(PVector(P)^, PVector(Ptr(Longword(P) + SizeOf(TVector)))^, FWidth / FHeight);
 IncPtr(P, SizeOf(TVector) * 2);

 { Create the scene manager, passing the scene file pointer. }
 FManager := TSceneManager.Create(Depth, WorkerCount, P);

 { Release the scene file. }
 DecPtr(P, SizeOf(TVector) * 2);
 UnmapFile(H, M, P);

 { Allocate the data array and set it to zero. }
 SetLength(FData, FWidth * FHeight);
 ZeroMemory(@FData[0], FWidth * FHeight * SizeOf(TRGBColor));
 SetLength(FSampleCount, FWidth * FHeight);
 ZeroMemory(@FSampleCount[0], FWidth * FHeight * SizeOf(Longword));

 { Fill in the threadinfo structure. }
 with WorkerSettings do
  begin
   PManager := @FManager;
   PCamera := @FCamera;
   PData := @FData[0];
   PSampleCount := @FSampleCount[0];
   PFlag := @FWorkerFlags[0];
   DataLength := FWidth * FHeight * SizeOf(TRGBColor);
   Width := FWidth;
   Height := FHeight;
   Stride := Length(FWorkers);
   Batch := BatchSize;
  end;

 { Create all the threads. }
 for I := 0 to High(FWorkers) do FWorkers[I] := TWorkerThread.Create(CreateSuspended, WorkerSettings, I);
end;

destructor TPathTracer.Destroy;
Var
 I: Integer;
 Flag: Boolean;
begin
 try
  { First we resume, then terminate all threads. }
  for I := 0 to High(FWorkers) do
   begin
    FWorkers[I].Suspended := False;
    FWorkers[I].Terminate;
   end;

  { We wait until all threads have died, to avoid destroying shared objects that are still in use. }
  repeat
   Flag := True;
   for I := 0 to High(FWorkerFlags) do
    if not FWorkerFlags[I] then
     begin
      Flag := False;
      Break;
     end;
  until Flag;
 finally
  { At that point we free everything. }
  FCamera.Free;
  FManager.Free;
  inherited;
 end;
end;

{ Suspends all the threads. }
procedure TPathTracer.Suspend;
Var
 I: Integer;
begin
 for I := 0 to High(FWorkers) do FWorkers[I].Suspended := True;
end;

{ Resumes all the threads. }
procedure TPathTracer.Resume;
Var
 I: Integer;
begin
 for I := 0 to High(FWorkers) do FWorkers[I].Suspended := False;
end;

{ Acquires the current render state into a bitmap. }
procedure TPathTracer.Acquire(Bitmap: TBitmap);
Var
 N: Longword;
 P: PRGBQUAD;
 E: Pointer;
begin
 { Set the bitmap dimensions. }
 FSamples := 0;
 Bitmap.Width := FWidth;
 Bitmap.Height := FHeight;
 Bitmap.PixelFormat := pf32bit;

 { Fill in the bitmap. }
 P := Bitmap.ScanLine[Bitmap.Height - 1];
 E := Ptr(Longword(P) + FWidth * FHeight * 4);
 N := 0;
 while P <> E do
  begin
   { Perform sample count calculation here (might as well). }
   FSamples := FSamples + FSampleCount[N] / (FWidth * FHeight);
   if FSampleCount[N] = 0 then
    begin
     P^.rgbRed := 0;
     P^.rgbGreen := 0;
     P^.rgbBlue := 0;
    end
   else
    begin
     { Gamma and spectral correction (the spectrum used isn't perfect and favours the red and green components, giving everything a yellow-ish hue). }
     P^.rgbRed := Round(Max(Min(Power(FData[N].R / FSampleCount[N], 1 / 2.2) / (220 / 198), 1), 0) * 255);
     P^.rgbGreen := Round(Max(Min(Power(FData[N].G / FSampleCount[N], 1 / 2.2) / (209 / 198), 1), 0) * 255);
     P^.rgbBlue := Round(Max(Min(Power(FData[N].B / FSampleCount[N], 1 / 2.2) / (166 / 198), 1), 0) * 255);
    end;

   Inc(N);
   Inc(P);
  end;
end;

{ Getter which returns whether the threads are suspended or not. Since all threads are (hopefully) in the same state, and there
  is at least one worker thread, we can just check the first one.                                                              } 
function TPathTracer.GetSuspended: Boolean;
begin
 Result := FWorkers[0].Suspended;
end;

end.
