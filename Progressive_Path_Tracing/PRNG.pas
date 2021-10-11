{-------------------------------------------------- Progressive Path Tracing ---------------------------------------------------

This unit implements the Mersenne Twister pseudorandom number generator, in a class (to make it thread-safe). This PRNG is very
fast and has excellent pseudorandom statistical properties, which make it very suitable for use in Monte-Carlo simulations such
as path tracing.

-------------------------------------------------------------------------------------------------------------------------------}

unit PRNG;

interface

uses Windows, Utils;

{ Period parameters }
const
  MT19937M=397;
  MT19937MATRIX_A  =$9908b0df;
  MT19937UPPER_MASK=$80000000;
  MT19937LOWER_MASK=$7fffffff;
  TEMPERING_MASK_B=$9d2c5680;
  TEMPERING_MASK_C=$efc60000;
  MT19937N=624;

Type
  tMT19937StateArray = array [0..MT19937N-1] of longint;

type
 TPRNG = class
 private
  mt : tMT19937StateArray;
  mti: integer; // mti=MT19937N+1 means mt[] is not initialized
  procedure sgenrand_MT19937(seed: longint);         // Initialization by seed
  procedure lsgenrand_MT19937(const seed_array: tMT19937StateArray); // Initialization by array of seeds
  function  genrand_MT19937: longint;                // random longint (full range);
 public
  constructor Create(SeedModifier: Longword); reintroduce;
  function random: Double; overload;
 end;

 PPRNG = ^TPRNG;

implementation

{ Initializes the PRNG with a given seed. }
procedure TPRNG.sgenrand_MT19937(seed: longint);
var
  i: integer;
begin
  for i := 0 to MT19937N-1 do begin
    mt[i] := seed and $ffff0000;
    seed := 69069 * seed + 1;
    mt[i] := mt[i] or ((seed and $ffff0000) shr 16);
    seed := 69069 * seed + 1;
  end;
  mti := MT19937N;
end;

{ Seeds the PRNG. }
procedure TPRNG.lsgenrand_MT19937(const seed_array: tMT19937StateArray);
VAR
  i: integer;
begin
  for i := 0 to MT19937N-1 do mt[i] := seed_array[i];
  mti := MT19937N;
end;

{ Generates a new state for the PRNG. }
function TPRNG.genrand_MT19937: longint;
const
  mag01 : array [0..1] of longint =(0, MT19937MATRIX_A);
var
  y: longint;
  kk: integer;
begin
  if mti >= MT19937N { generate MT19937N longints at one time }
  then begin
     if mti = (MT19937N+1) then  // if sgenrand_MT19937() has not been called,
       sgenrand_MT19937(4357);   // default initial seed is used
     for kk:=0 to MT19937N-MT19937M-1 do begin
        y := (mt[kk] and MT19937UPPER_MASK) or (mt[kk+1] and MT19937LOWER_MASK);
        mt[kk] := mt[kk+MT19937M] xor (y shr 1) xor mag01[y and $00000001];
     end;
     for kk:= MT19937N-MT19937M to MT19937N-2 do begin
       y := (mt[kk] and MT19937UPPER_MASK) or (mt[kk+1] and MT19937LOWER_MASK);
       mt[kk] := mt[kk+(MT19937M-MT19937N)] xor (y shr 1) xor mag01[y and $00000001];
     end;
     y := (mt[MT19937N-1] and MT19937UPPER_MASK) or (mt[0] and MT19937LOWER_MASK);
     mt[MT19937N-1] := mt[MT19937M-1] xor (y shr 1) xor mag01[y and $00000001];
     mti := 0;
  end;
  y := mt[mti]; inc(mti);
  y := y xor (y shr 11);
  y := y xor (y shl 7)  and TEMPERING_MASK_B;
  y := y xor (y shl 15) and TEMPERING_MASK_C;
  y := y xor (y shr 18);
  Result := y;
end;

{ Creates the PRNG. The SeedModifier is used to create different states for each thread. }
constructor TPRNG.Create(SeedModifier: Longword);
begin
 inherited Create;
 mti := MT19937N + 1;
 sgenrand_MT19937(GetWorkerSeed(SeedModifier));
end;

// assembler magic
function TPRNG.random: Double;
const   Minus32: double = -32.0;
asm
  CALL    genrand_MT19937
  PUSH    0
  PUSH    EAX
  FLD     Minus32
  FILD    qword ptr [ESP]
  ADD     ESP,8
  FSCALE
  FSTP    ST(1)
end;

end.
