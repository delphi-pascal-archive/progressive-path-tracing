{-------------------------------------------------- Progressive Path Tracing ---------------------------------------------------

This unit contains various miscellaneous functions used during path tracing (mainly during initialization). These functions
include mapping a file to memory, or getting the number of processors installed on the system.

-------------------------------------------------------------------------------------------------------------------------------}

unit Utils;

interface

uses Windows, SysUtils, Classes;

procedure IncPtr(var P: Pointer; const N: Longword);
procedure DecPtr(var P: Pointer; const N: Longword);
function MapFile(const FilePath: String; var H, M, Len: Longword): Pointer;
procedure UnmapFile(const H, M: Longword; const P: Pointer);
function ProcessorCount: Longword;
function GetWorkerSeed(const Worker: Longword): Longword;

implementation

{ Increments P by N bytes. }
procedure IncPtr(var P: Pointer; const N: Longword);
begin
 P := Ptr(Longword(P) + N);
end;

{ Decrements P by N bytes. }
procedure DecPtr(var P: Pointer; const N: Longword);
begin
 P := Ptr(Longword(P) - N);
end;

{ Maps a file to a pointer. }
function MapFile(const FilePath: String; var H, M, Len: Longword): Pointer;
begin
 Result := nil;
 Len := 0;

 { Open a file handle to the requested file, with read-only attributes. }
 H := CreateFile(PChar(FilePath), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING,
                 FILE_ATTRIBUTE_NORMAL or FILE_FLAG_SEQUENTIAL_SCAN, $0);

 { If we couldn't open the file, throw an exception. }
 if H = INVALID_HANDLE_VALUE then CloseHandle(H) else
  begin
   { Retreive the size of the file - up to 4 Gb! }
   Len := GetFileSize(H, nil);

   { If the file is empty, we can't map it, so we need to check for this. }
   if Len > 0 then
    begin
     { So we create a file mapping towards this file handle, still read-only. }
     M := CreateFileMapping(H, nil, PAGE_READONLY, 0, 0, nil);

     { If the mapping succeeded, get a pointer. }
     if M > 0 then Result := MapViewOfFile(M, FILE_MAP_READ, 0, 0, 0);
    end;
   end;
end;

{ Unmaps a file from memory. }
procedure UnmapFile(const H, M: Longword; const P: Pointer);
begin
 UnmapViewOfFile(P);
 CloseHandle(M);
 CloseHandle(H);
end;

{ Returns the processor count in the system (this includes cores, not sure if hyperthreading is taken into account). }
function ProcessorCount: Longword;
Var
 Sys: SYSTEM_INFO;
begin
 GetSystemInfo(Sys);
 Result := Sys.dwNumberOfProcessors;
end;

{ Returns a different pseudorandom seed depending on the worker. }
function GetWorkerSeed(const Worker: Longword): Longword;
begin
 Result := GetTickCount * (Worker + GetTickCount) * (Worker shl 7 + GetTickCount) - $5A5A5A5A;
end;

end.
